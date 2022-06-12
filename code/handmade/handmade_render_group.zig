const std = @import("std");
const assert = std.debug.assert;

const platform = @import("handmade_platform");

const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");
const hintrinsics = @import("handmade_intrinsics.zig");

const Round = hintrinsics.RoundF32ToInt;
const Floor = hintrinsics.FloorF32ToI32;
const Ceil = hintrinsics.CeilF32ToI32;
const SquareRoot = hintrinsics.SquareRoot;

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const loaded_bitmap = struct {
    width: i32 = 0,
    height: i32 = 0,
    pitch: i32 = 0,
    memory: [*]u8 = undefined,
};

pub const environment_map = struct {
    lod: [4]loaded_bitmap,
    pZ: f32,
};

pub const render_basis = struct {
    p: hm.v3 = hm.v3{ 0, 0, 0 },
};

pub const render_entity_basis = struct {
    basis: *render_basis,
    offset: hm.v2 = hm.v2{ 0, 0 },

    offsetZ: f32 = 0,
    entityZC: f32 = 0,
};

pub const render_group_entry_type = enum {
    Clear,
    Bitmap,
    Rectangle,
    CoordinateSystem,
    Saturation,

    pub fn Type(self: render_group_entry_type) type {
        return switch (self) {
            .Clear => render_entry_clear,
            .Bitmap => render_entry_bitmap,
            .Rectangle => render_entry_rectangle,
            .CoordinateSystem => render_entry_coordinate_system,
            .Saturation => render_entry_saturation,
        };
    }
};

pub const render_group_entry_header = struct {
    entryType: render_group_entry_type,
};

pub const render_entry_clear = struct {
    colour: hm.v4,
};

pub const render_entry_saturation = struct {
    level: f32,
};

pub const render_entry_coordinate_system = struct {
    origin: hm.v2,
    xAxis: hm.v2,
    yAxis: hm.v2,
    colour: hm.v4,
    texture: *const loaded_bitmap,
    normalMap: ?*loaded_bitmap,

    top: ?*environment_map,
    middle: ?*environment_map,
    bottom: ?*environment_map,
};

pub const render_entry_bitmap = struct {
    entityBasis: render_entity_basis,
    bitmap: *const loaded_bitmap,
    colour: hm.v4,
};

pub const render_entry_rectangle = struct {
    entityBasis: render_entity_basis,
    colour: hm.v4,

    dim: hm.v2,
};

pub const render_group = struct {
    defaultBasis: *render_basis,
    metersToPixels: f32,

    pushBufferSize: u32,
    maxPushBufferSize: u32,
    pushBufferBase: [*]u8,
};

// functions ------------------------------------------------------------------------------------------------------------------------------

pub inline fn SRGB255ToLinear1(c: hm.v4) hm.v4 {
    const inv255 = 1.0 / 255.0;
    const result = hm.v4{
        hm.Square(inv255 * hm.R(c)),
        hm.Square(inv255 * hm.G(c)),
        hm.Square(inv255 * hm.B(c)),
        inv255 * hm.A(c),
    };

    return result;
}

pub inline fn Linear1ToSRGB255(c: hm.v4) hm.v4 {
    const one255 = 255;
    const result = hm.v4{
        one255 * SquareRoot(hm.R(c)),
        one255 * SquareRoot(hm.G(c)),
        one255 * SquareRoot(hm.B(c)),
        one255 * hm.A(c),
    };

    return result;
}

pub inline fn UnScaleAndBiasNormal(normal: hm.v4) hm.v4 {
    const inv255 = 1.0 / 255.0;
    const result: hm.v4 = .{
        -1.0 + 2 * (inv255 * normal[0]),
        -1.0 + 2 * (inv255 * normal[1]),
        -1.0 + 2 * (inv255 * normal[2]),
        inv255 * normal[3],
    };

    return result;
}

pub fn DrawRectangleOutline(buffer: *loaded_bitmap, vMin: hm.v2, vMax: hm.v2, colour: hm.v3, r: f32) void {
    DrawRectangle(buffer, .{ hm.X(vMin) - r, hm.Y(vMin) - r }, .{ hm.X(vMax) + r, hm.Y(vMin) + r }, hm.ToV4(colour, 1));
    DrawRectangle(buffer, .{ hm.X(vMin) - r, hm.Y(vMax) - r }, .{ hm.X(vMax) + r, hm.Y(vMax) + r }, hm.ToV4(colour, 1));

    DrawRectangle(buffer, .{ hm.X(vMin) - r, hm.Y(vMin) - r }, .{ hm.X(vMin) + r, hm.Y(vMax) + r }, hm.ToV4(colour, 1));
    DrawRectangle(buffer, .{ hm.X(vMax) - r, hm.Y(vMin) - r }, .{ hm.X(vMax) + r, hm.Y(vMax) + r }, hm.ToV4(colour, 1));
}

pub fn DrawRectangle(buffer: *const loaded_bitmap, vMin: hm.v2, vMax: hm.v2, colour: hm.v4) void {
    const r = hm.R(colour);
    const g = hm.G(colour);
    const b = hm.B(colour);
    const a = hm.A(colour);

    var minX = Round(i32, vMin[0]);
    var minY = Round(i32, vMin[1]);
    var maxX = Round(i32, vMax[0]);
    var maxY = Round(i32, vMax[1]);

    if (minX < 0) {
        minX = 0;
    }

    if (minY < 0) {
        minY = 0;
    }

    if (maxX > buffer.width) {
        maxX = buffer.width;
    }

    if (maxY > buffer.height) {
        maxY = buffer.height;
    }

    // zig fmt: off
    const colour32: u32 = (Round(u32, a * 255.0) << 24) | 
                        (Round(u32, r * 255.0) << 16) | 
                        (Round(u32, g * 255.0) << 8) | 
                        (Round(u32, b * 255) << 0);
    // zig fmt: on

    var row = @ptrCast([*]u8, buffer.memory) + @intCast(u32, minX) * platform.BITMAP_BYTES_PER_PIXEL + @intCast(u32, minY * buffer.pitch);

    var y = minY;
    while (y < maxY) : (y += 1) {
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        var x = minX;
        while (x < maxX) : (x += 1) {
            pixel.* = colour32;
            pixel += 1;
        }
        row += @intCast(u32, buffer.pitch);
    }
}

inline fn Unpack4x8(packedValue: u32) hm.v4 {
    const result = hm.v4{
        @intToFloat(f32, ((packedValue >> 16) & 0xff)),
        @intToFloat(f32, ((packedValue >> 8) & 0xff)),
        @intToFloat(f32, ((packedValue >> 0) & 0xff)),
        @intToFloat(f32, ((packedValue >> 24) & 0xff)),
    };

    return result;
}

inline fn SRGBBilinearBlend(texelSample: bilinear_sample, fX: f32, fY: f32) hm.v4 {
    var texelA: hm.v4 = Unpack4x8(texelSample.a);
    var texelB: hm.v4 = Unpack4x8(texelSample.b);
    var texelC: hm.v4 = Unpack4x8(texelSample.c);
    var texelD: hm.v4 = Unpack4x8(texelSample.d);

    texelA = SRGB255ToLinear1(texelA);
    texelB = SRGB255ToLinear1(texelB);
    texelC = SRGB255ToLinear1(texelC);
    texelD = SRGB255ToLinear1(texelD);

    const result = hm.LerpV(
        hm.LerpV(texelA, fX, texelB),
        fY,
        hm.LerpV(texelC, fX, texelD),
    );

    return result;
}
/// `screenSpaceUV`: where the ray is being cast _from_ in normalized screen coordinates.
/// `sampleDirection`: what direction the cast is going - it does not have to be normalized.
/// `roughness`: which LODs of `map` we sample from. 
/// `distanceFromMapInZ`: how far the `map` is from the sample point in z, given in meters.
fn SampleEnvironmentMap(screenSpaceUV: hm.v2, sampleDirection: hm.v3, roughness: f32, map: *environment_map, distanceFromMapInZ: f32) hm.v3 {
    const lodIndex: u32 = @floatToInt(u32, roughness * @intToFloat(f32, map.lod.len - 1) + 0.5);
    assert(lodIndex < map.lod.len);

    const lod: *loaded_bitmap = &map.lod[lodIndex];

    const uvPerMeter = 0.1;
    const c: f32 = (uvPerMeter * distanceFromMapInZ) / hm.Y(sampleDirection);
    const offset: hm.v2 = hm.Scale(hm.v2{ hm.X(sampleDirection), hm.Z(sampleDirection) }, c);

    var uv: hm.v2 = hm.Add(offset, screenSpaceUV);

    uv = hm.ClampV201(uv);

    const tX: f32 = (hm.X(uv) * @intToFloat(f32, lod.width - 2));
    const tY: f32 = (hm.Y(uv) * @intToFloat(f32, lod.height - 2));

    const x: i32 = @floatToInt(i32, tX);
    const y: i32 = @floatToInt(i32, tY);

    const fX: f32 = tX - @intToFloat(f32, x);
    const fY: f32 = tY - @intToFloat(f32, y);

    assert((x >= 0) and (x < lod.width));
    assert((y >= 0) and (y < lod.height));

    if (!NOT_IGNORE) {
        const ptrOffset = y * lod.pitch + x * @sizeOf(u32);
        const texelPtr = if (ptrOffset > 0) lod.memory + @intCast(usize, ptrOffset) else lod.memory - @intCast(usize, -ptrOffset);
        const ptr = @ptrCast(*align(@alignOf(u8)) u32, texelPtr);
        ptr.* = 0xffffffff;
    }

    const sample: bilinear_sample = BilinearSample(lod, x, y);
    const result: hm.v3 = hm.XYZ(SRGBBilinearBlend(sample, fX, fY));

    return result;
}

const bilinear_sample = struct { a: u32 = 0, b: u32 = 0, c: u32 = 0, d: u32 = 0 };

inline fn BilinearSample(texture: *const loaded_bitmap, x: i32, y: i32) bilinear_sample {
    const ptrOffset = y * texture.pitch + x * @sizeOf(u32);
    const texelPtr = if (ptrOffset > 0) texture.memory + @intCast(usize, ptrOffset) else texture.memory - @intCast(usize, -ptrOffset);
    const pitchOffset = if (texture.pitch > 0) texelPtr + @intCast(usize, texture.pitch) else texelPtr - @intCast(usize, -texture.pitch);

    const result = bilinear_sample{
        .a = @ptrCast(*align(@alignOf(u8)) u32, texelPtr).*,
        .b = @ptrCast(*align(@alignOf(u8)) u32, texelPtr + @sizeOf(u32)).*,
        .c = @ptrCast(*align(@alignOf(u8)) u32, pitchOffset).*,
        .d = @ptrCast(*align(@alignOf(u8)) u32, pitchOffset + @sizeOf(u32)).*,
    };

    return result;
}

// zig fmt: off
pub fn DrawRectangleSlowly(buffer: *loaded_bitmap, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, 
                           notPremultipliedColour: hm.v4, texture: *const loaded_bitmap, normalMapOptional: ?*loaded_bitmap, 
                           top: ?*environment_map, _: ?*environment_map, bottom: ?*environment_map,
                           pixelsToMeters: f32) void
// zig fmt: on
{
    _ = pixelsToMeters;
    const colour = hm.ToV4(hm.Scale(hm.XYZ(notPremultipliedColour), hm.A(notPremultipliedColour)), hm.A(notPremultipliedColour));

    const xAxisLength = hm.Length(xAxis);
    const yAxisLength = hm.Length(yAxis);

    const nXAxis = hm.Scale(xAxis, yAxisLength / xAxisLength);
    const nYAxis = hm.Scale(yAxis, xAxisLength / yAxisLength);
    const nZScale = 0.5 * (xAxisLength + yAxisLength);

    const invXAxisLengthSq = 1 / hm.LengthSq(xAxis);
    const invYAxisLengthSq = 1 / hm.LengthSq(yAxis);

    // zig fmt: off
    const colour32: u32 = (Round(u32, hm.A(colour) * 255.0) << 24) | 
                          (Round(u32, hm.R(colour) * 255.0) << 16) | 
                          (Round(u32, hm.G(colour) * 255.0) << 8) | 
                          (Round(u32, hm.B(colour) * 255.0) << 0);
    // zig fmt: on

    const widthMax = buffer.width - 1;
    const heightMax = buffer.height - 1;

    const invWidthMax = 1.0 / @intToFloat(f32, widthMax);
    _ = invWidthMax;
    const invHeightMax = 1.0 / @intToFloat(f32, heightMax);

    const originZ = 0;
    const originY = hm.Y(hm.Add(origin, hm.Scale(hm.Add(xAxis, yAxis), 0.5)));
    const fixedCastY = invHeightMax * originY;
    _ = fixedCastY;

    var xMin = widthMax;
    var xMax = @as(i32, 0);

    var yMin = heightMax;
    var yMax = @as(i32, 0);

    const p: [4]hm.v2 = .{ origin, hm.Add(origin, xAxis), hm.Add(origin, hm.Add(xAxis, yAxis)), hm.Add(origin, yAxis) };

    for (p) |testP| {
        const floorX = Floor(hm.X(testP));
        const ceilX = Ceil(hm.X(testP));
        const floorY = Floor(hm.Y(testP));
        const ceilY = Ceil(hm.Y(testP));

        if (xMin > floorX) xMin = floorX;
        if (yMin > floorY) yMin = floorY;
        if (xMax < ceilX) xMax = ceilX;
        if (yMax < ceilY) yMax = ceilY;
    }

    if (xMin < 0) xMin = 0;
    if (yMin < 0) yMin = 0;
    if (xMax > widthMax) xMax = widthMax;
    if (yMax > heightMax) yMax = heightMax;

    var row = @ptrCast([*]u8, buffer.memory) + @intCast(u32, xMin) * platform.BITMAP_BYTES_PER_PIXEL + @intCast(u32, yMin * buffer.pitch);

    var y = yMin;
    while (y <= yMax) : (y += 1) {
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        var x = xMin;
        while (x <= xMax) : (x += 1) {
            if (NOT_IGNORE) {
                const pixelP = hm.V2(x, y);
                const d = hm.Sub(pixelP, origin);

                const edge0 = hm.Inner(d, hm.Scale(hm.Perp(xAxis), -1));
                const edge1 = hm.Inner(hm.Sub(d, xAxis), hm.Scale(hm.Perp(yAxis), -1));
                const edge2 = hm.Inner(hm.Sub(d, hm.Add(xAxis, yAxis)), hm.Perp(xAxis));
                const edge3 = hm.Inner(hm.Sub(d, yAxis), hm.Perp(yAxis));

                if (edge0 < 0 and edge1 < 0 and edge2 < 0 and edge3 < 0) {
                    const screenSpaceUV = hm.v2{ @intToFloat(f32, x) * invWidthMax, fixedCastY };

                    const zDiff = pixelsToMeters * (@intToFloat(f32, y) - originY);

                    const u = invXAxisLengthSq * hm.Inner(d, xAxis);
                    const v = invYAxisLengthSq * hm.Inner(d, yAxis);

                    assert((u >= 0) and (u <= 1.001));
                    assert((v >= 0) and (v <= 1.001));

                    const tX = (u * @intToFloat(f32, texture.width - 2));
                    const tY = (v * @intToFloat(f32, texture.height - 2));

                    const X: i32 = @floatToInt(i32, tX);
                    const Y: i32 = @floatToInt(i32, tY);

                    const fX = tX - @intToFloat(f32, X);
                    const fY = tY - @intToFloat(f32, Y);

                    assert((X >= 0) and (X < texture.width));
                    assert((Y >= 0) and (Y < texture.height));

                    const texelSample: bilinear_sample = BilinearSample(texture, X, Y);
                    var texel = SRGBBilinearBlend(texelSample, fX, fY);

                    if (normalMapOptional) |normalMap| {
                        const normalSample: bilinear_sample = BilinearSample(normalMap, X, Y);

                        var normalA: hm.v4 = Unpack4x8(normalSample.a);
                        var normalB: hm.v4 = Unpack4x8(normalSample.b);
                        var normalC: hm.v4 = Unpack4x8(normalSample.c);
                        var normalD: hm.v4 = Unpack4x8(normalSample.d);

                        var normal: hm.v4 = hm.LerpV(
                            hm.LerpV(normalA, fX, normalB),
                            fY,
                            hm.LerpV(normalC, fX, normalD),
                        );

                        normal = UnScaleAndBiasNormal(normal);

                        const normalXY = hm.Add(hm.Scale(nXAxis, hm.X(normal)), hm.Scale(nYAxis, hm.Y(normal)));

                        normal[0] = normalXY[0];
                        normal[1] = normalXY[1];
                        normal[2] *= nZScale;

                        normal = hm.ToV4(hm.Normalize(hm.XYZ(normal)), hm.W(normal));

                        var bounceDirection = hm.Scale(hm.XYZ(normal), 2 * hm.Z(normal));
                        bounceDirection[2] -= 1;

                        bounceDirection[2] = -bounceDirection[2];

                        var farMap: ?*environment_map = null;
                        const pZ = originZ + zDiff;
                        // var mapZ = @as(f32, 2.0);
                        const tEnvMap = hm.Y(bounceDirection);
                        var tFarMap = @as(f32, 0.0);
                        if (tEnvMap < -0.5) {
                            farMap = bottom;
                            tFarMap = -1 - 2 * tEnvMap;
                        } else if (tEnvMap > 0.5) {
                            farMap = top;
                            tFarMap = 2 * (tEnvMap - 0.5);
                        }

                        tFarMap *= tFarMap;
                        tFarMap *= tFarMap;

                        var lightColour: hm.v3 = .{ 0, 0, 0 };
                        if (farMap) |envMap| {
                            const distanceFromMapInZ = envMap.pZ - pZ;
                            const farMapColour = SampleEnvironmentMap(screenSpaceUV, bounceDirection, hm.W(normal), envMap, distanceFromMapInZ);
                            lightColour = hm.LerpV(lightColour, tFarMap, farMapColour);
                        }

                        hm.AddTo(&texel, hm.Scale(hm.ToV4(lightColour, 0), hm.A(texel)));
                        if (!NOT_IGNORE) {
                            texel = hm.ToV4(hm.Add(hm.Scale(bounceDirection, 0.5), hm.v3{ 0.5, 0.5, 0.5 }), hm.A(texel));
                            texel = hm.Hammard(texel, .{ hm.A(texel), hm.A(texel), hm.A(texel), 1 });

                            // const isoLine = 0;

                            // if (hm.Y(bounceDirection) >= (isoLine - 0.05) and hm.Y(bounceDirection) <= (isoLine + 0.05)) {
                            //     texel = hm.v4{ 1, 1, 1, 1 };
                            // } else {
                            //     texel = hm.v4{ 0, 0, 0, 1 };
                            // }
                        }
                    }

                    texel = hm.Hammard(texel, colour);
                    texel[0] = hm.Clampf01(texel[0]);
                    texel[1] = hm.Clampf01(texel[1]);
                    texel[2] = hm.Clampf01(texel[2]);

                    var dest: hm.v4 = .{
                        @intToFloat(f32, ((pixel[0] >> 16) & 0xff)),
                        @intToFloat(f32, ((pixel[0] >> 8) & 0xff)),
                        @intToFloat(f32, ((pixel[0] >> 0) & 0xff)),
                        @intToFloat(f32, ((pixel[0] >> 24) & 0xff)),
                    };

                    dest = SRGB255ToLinear1(dest);

                    const blended: hm.v4 = hm.Add(hm.Scale(dest, 1 - hm.A(texel)), texel);

                    var blended255 = Linear1ToSRGB255(blended);

                    pixel.* = (@floatToInt(u32, hm.A(blended255) + 0.5) << 24) |
                        (@floatToInt(u32, hm.R(blended255) + 0.5) << 16) |
                        (@floatToInt(u32, hm.G(blended255) + 0.5) << 8) |
                        (@floatToInt(u32, hm.B(blended255) + 0.5) << 0);
                }
            } else {
                pixel.* = colour32;
            }
            pixel += 1;
        }
        row += @intCast(u32, buffer.pitch);
    }
}

pub fn ChangeSaturation(buffer: *loaded_bitmap, level: f32) void {
    var destRow = buffer.memory;

    var y = @as(i32, 0);
    while (y < buffer.height) : (y += 1) {
        const dest = @ptrCast([*]u32, @alignCast(@alignOf(u32), destRow));

        var x = @as(i32, 0);
        while (x < buffer.width) : (x += 1) {
            const index = @intCast(u32, x);

            var d: hm.v4 = .{
                @intToFloat(f32, ((dest[index] >> 16) & 0xff)),
                @intToFloat(f32, ((dest[index] >> 8) & 0xff)),
                @intToFloat(f32, ((dest[index] >> 0) & 0xff)),
                @intToFloat(f32, ((dest[index] >> 24) & 0xff)),
            };

            d = SRGB255ToLinear1(d);

            const avg = (hm.R(d) + hm.G(d) + hm.B(d)) * (1.0 / 3.0);
            const delta = hm.v3{ hm.R(d) - avg, hm.G(d) - avg, hm.B(d) - avg };

            var result = hm.ToV4(hm.Add(hm.v3{ avg, avg, avg }, hm.Scale(delta, level)), hm.A(d));

            result = Linear1ToSRGB255(result);

            dest[index] =
                (@floatToInt(u32, hm.A(result) + 0.5) << 24) |
                (@floatToInt(u32, hm.R(result) + 0.5) << 16) |
                (@floatToInt(u32, hm.G(result) + 0.5) << 8) |
                (@floatToInt(u32, hm.B(result) + 0.5) << 0);
        }

        destRow += @intCast(usize, buffer.pitch);
    }
}

pub fn DrawBitmap(buffer: *loaded_bitmap, bitmap: *const loaded_bitmap, realX: f32, realY: f32, cAlpha: f32) void {
    var minX = Round(i32, realX);
    var minY = Round(i32, realY);
    var maxX = minX + bitmap.width;
    var maxY = minY + bitmap.height;

    var sourceOffesetX = @as(i32, 0);
    if (minX < 0) {
        sourceOffesetX = -minX;
        minX = 0;
    }

    var sourceOffesetY = @as(i32, 0);
    if (minY < 0) {
        sourceOffesetY = -minY;
        minY = 0;
    }

    if (maxX > buffer.width) {
        maxX = buffer.width;
    }

    if (maxY > buffer.height) {
        maxY = buffer.height;
    }

    const offset = sourceOffesetY * bitmap.pitch + platform.BITMAP_BYTES_PER_PIXEL * sourceOffesetX;

    var sourceRow = if (offset > 0) bitmap.memory + @intCast(usize, offset) else bitmap.memory - @intCast(usize, -offset);
    var destRow = buffer.memory + @intCast(usize, minX * platform.BITMAP_BYTES_PER_PIXEL + minY * buffer.pitch);

    var y = minY;
    while (y < maxY) : (y += 1) {
        const dest = @ptrCast([*]u32, @alignCast(@alignOf(u32), destRow));
        const source = @ptrCast([*]align(1) u32, sourceRow);
        var x = minX;
        while (x < maxX) : (x += 1) {
            const index = @intCast(u32, x - minX);

            var texel: hm.v4 = .{
                @intToFloat(f32, ((source[index] >> 16) & 0xff)),
                @intToFloat(f32, ((source[index] >> 8) & 0xff)),
                @intToFloat(f32, ((source[index] >> 0) & 0xff)),
                @intToFloat(f32, ((source[index] >> 24) & 0xff)),
            };

            texel = SRGB255ToLinear1(texel);
            texel = hm.Scale(texel, cAlpha);

            var d: hm.v4 = .{
                @intToFloat(f32, ((dest[index] >> 16) & 0xff)),
                @intToFloat(f32, ((dest[index] >> 8) & 0xff)),
                @intToFloat(f32, ((dest[index] >> 0) & 0xff)),
                @intToFloat(f32, ((dest[index] >> 24) & 0xff)),
            };

            d = SRGB255ToLinear1(d);

            var result: hm.v4 = hm.Scale(d, 1 - hm.A(texel)) + texel;

            result = Linear1ToSRGB255(result);

            dest[index] =
                (@floatToInt(u32, hm.A(result) + 0.5) << 24) |
                (@floatToInt(u32, hm.R(result) + 0.5) << 16) |
                (@floatToInt(u32, hm.G(result) + 0.5) << 8) |
                (@floatToInt(u32, hm.B(result) + 0.5) << 0);
        }

        destRow += @intCast(usize, buffer.pitch);
        sourceRow = if (bitmap.pitch > 0) sourceRow + @intCast(usize, bitmap.pitch) else sourceRow - @intCast(usize, -bitmap.pitch);
    }
}

pub fn DrawMatte(buffer: *loaded_bitmap, bitmap: *const loaded_bitmap, realX: f32, realY: f32, cAlpha: f32) void {
    var minX = Round(i32, realX);
    var minY = Round(i32, realY);
    var maxX = minX + bitmap.width;
    var maxY = minY + bitmap.height;

    var sourceOffesetX = @as(i32, 0);
    if (minX < 0) {
        sourceOffesetX = -minX;
        minX = 0;
    }

    var sourceOffesetY = @as(i32, 0);
    if (minY < 0) {
        sourceOffesetY = -minY;
        minY = 0;
    }

    if (maxX > buffer.width) {
        maxX = buffer.width;
    }

    if (maxY > buffer.height) {
        maxY = buffer.height;
    }

    const offset = sourceOffesetY * bitmap.pitch + platform.BITMAP_BYTES_PER_PIXEL * sourceOffesetX;

    var sourceRow = if (offset > 0) bitmap.memory + @intCast(usize, offset) else bitmap.memory - @intCast(usize, -offset);
    var destRow = buffer.memory + @intCast(usize, minX * platform.BITMAP_BYTES_PER_PIXEL + minY * buffer.pitch);

    var y = minY;
    while (y < maxY) : (y += 1) {
        const dest = @ptrCast([*]u32, @alignCast(@alignOf(u32), destRow));
        const source = @ptrCast([*]align(1) u32, sourceRow);
        var x = minX;
        while (x < maxX) : (x += 1) {
            const index = @intCast(u32, x - minX);

            const sA = cAlpha * @intToFloat(f32, ((source[index] >> 24) & 0xff));
            const rSA = (sA / 255.0) * cAlpha;
            // const sR = cAlpha * @intToFloat(f32, ((source[index] >> 16) & 0xff));
            // const sG = cAlpha * @intToFloat(f32, ((source[index] >> 8) & 0xff));
            // const sB = cAlpha * @intToFloat(f32, ((source[index] >> 0) & 0xff));

            const dA = @intToFloat(f32, ((dest[index] >> 24) & 0xff));
            const dR = @intToFloat(f32, ((dest[index] >> 16) & 0xff));
            const dG = @intToFloat(f32, ((dest[index] >> 8) & 0xff));
            const dB = @intToFloat(f32, ((dest[index] >> 0) & 0xff));
            // const rDA = (dA / 255.0);

            const invRSA = 1 - rSA;
            const a = invRSA * dA;
            const r = invRSA * dR;
            const g = invRSA * dG;
            const b = invRSA * dB;

            dest[index] = (@floatToInt(u32, a + 0.5) << 24) |
                (@floatToInt(u32, r + 0.5) << 16) |
                (@floatToInt(u32, g + 0.5) << 8) |
                (@floatToInt(u32, b + 0.5) << 0);
        }

        destRow += @intCast(usize, buffer.pitch);
        sourceRow = if (bitmap.pitch > 0) sourceRow + @intCast(usize, bitmap.pitch) else sourceRow - @intCast(usize, -bitmap.pitch);
    }
}

inline fn GetRenderEntityBasisP(group: *render_group, entityBasis: *render_entity_basis, screenCenter: hm.v2) hm.v2 {
    const entityBaseP = entityBasis.basis.p;
    const zFudge = 1 + 0.1 * (hm.Z(entityBaseP) + entityBasis.offsetZ);

    const entityGroundPointX = hm.X(screenCenter) + group.metersToPixels * zFudge * hm.X(entityBaseP);
    const entityGroundPointY = hm.Y(screenCenter) - group.metersToPixels * zFudge * hm.Y(entityBaseP);
    const entityz = -group.metersToPixels * hm.Z(entityBaseP);

    const center = hm.v2{
        entityGroundPointX + entityBasis.offset[0],
        entityGroundPointY + entityBasis.offset[1] + entityBasis.entityZC * entityz,
    };

    return center;
}

pub fn PushRenderElements(group: *render_group, comptime t: render_group_entry_type) ?*align(@alignOf(u8)) t.Type() {
    const element_type = t.Type();
    const element_ptr_type = ?*align(@alignOf(u8)) element_type;

    var result: element_ptr_type = null;

    var size: u32 = @sizeOf(element_type) + @sizeOf(render_group_entry_header);

    if ((group.pushBufferSize + size) < group.maxPushBufferSize) {
        const ptr = group.pushBufferBase + group.pushBufferSize;
        const header = @ptrCast(*render_group_entry_header, ptr);
        header.entryType = t;
        result = @ptrCast(element_ptr_type, ptr + @sizeOf(render_group_entry_header));
        group.pushBufferSize += size;
    } else {
        unreachable;
    }

    return result;
}

// zig fmt: off
pub fn PushPiece(group: *render_group, bitmap: *loaded_bitmap, offset: hm.v2, offsetZ: f32, alignment: hm.v2, 
                        _: hm.v2, colour: hm.v4, entityZC: f32) void 
// zig fmt: on
{
    if (PushRenderElements(group, .Bitmap)) |piece| {
        piece.entityBasis.basis = group.defaultBasis;
        piece.bitmap = bitmap;
        piece.entityBasis.offset = hm.Sub(hm.Scale(hm.v2{ offset[0], -offset[1] }, group.metersToPixels), alignment);
        piece.entityBasis.offsetZ = offsetZ;
        piece.entityBasis.entityZC = entityZC;
        piece.colour = colour;
    }
}

// zig fmt: off
/// Defaults: ```alpha = 1.0, entityZC = 1.0```
pub fn PushBitmap(group: *render_group, bitmap: *loaded_bitmap, offset: hm.v2, offsetZ: f32, alignment: hm.v2,
                         alpha: f32, entityZC: f32) void 
// zig fmt: on
{
    // NOTE (Manav): alpha > 1 mess up our rendering, as cAlpha will make rSA > 1 and invRSA negative
    assert(alpha <= 1);
    PushPiece(group, bitmap, offset, offsetZ, alignment, .{ 0, 0 }, .{ 1, 1, 1, alpha }, entityZC);
}

pub inline fn PushRect(group: *render_group, offset: hm.v2, offsetZ: f32, dim: hm.v2, colour: hm.v4, entityZC: f32) void {
    const halfDim = hm.Scale(dim, 0.5 * group.metersToPixels);

    if (PushRenderElements(group, .Rectangle)) |piece| {
        piece.entityBasis.basis = group.defaultBasis;
        piece.entityBasis.offset = hm.Sub(hm.Scale(hm.v2{ offset[0], -offset[1] }, group.metersToPixels), halfDim);
        piece.entityBasis.offsetZ = offsetZ;
        piece.entityBasis.entityZC = entityZC;
        piece.colour = colour;
        piece.dim = hm.Scale(dim, group.metersToPixels);
    }
}

pub inline fn PushRectOutline(group: *render_group, offset: hm.v2, offsetZ: f32, dim: hm.v2, colour: hm.v4, entityZC: f32) void {
    const thickness = 0.1;

    PushRect(group, hm.Sub(offset, hm.v2{ 0, 0.5 * hm.Y(dim) }), offsetZ, .{ hm.X(dim), thickness }, colour, entityZC);
    PushRect(group, hm.Add(offset, hm.v2{ 0, 0.5 * hm.Y(dim) }), offsetZ, .{ hm.X(dim), thickness }, colour, entityZC);

    PushRect(group, hm.Sub(offset, hm.v2{ 0.5 * hm.X(dim), 0 }), offsetZ, .{ thickness, hm.Y(dim) }, colour, entityZC);
    PushRect(group, hm.Add(offset, hm.v2{ 0.5 * hm.X(dim), 0 }), offsetZ, .{ thickness, hm.Y(dim) }, colour, entityZC);
}

pub fn Clear(group: *render_group, colour: hm.v4) void {
    if (PushRenderElements(group, .Clear)) |entry| {
        entry.colour = colour;
    }
}

pub fn Saturation(group: *render_group, level: f32) void {
    if (PushRenderElements(group, .Saturation)) |entry| {
        entry.level = level;
    }
}

// zig fmt: off
pub fn CoordinateSystem(group: *render_group, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, colour: hm.v4,
                        texture: *const loaded_bitmap, normalMap: ?*loaded_bitmap, 
                        top: ?*environment_map, middle: ?*environment_map, bottom: ?*environment_map) *align(1) render_entry_coordinate_system 
// zig fmt: on
{
    const entryElement = PushRenderElements(group, .CoordinateSystem);
    if (entryElement) |entry| {
        entry.origin = origin;
        entry.xAxis = xAxis;
        entry.yAxis = yAxis;
        entry.colour = colour;
        entry.texture = texture;
        entry.normalMap = normalMap;
        entry.top = top;
        entry.middle = middle;
        entry.bottom = bottom;
    }

    return entryElement.?;
}

pub fn AllocateRenderGroup(arena: *hi.memory_arena, maxPushBufferSize: u32, metersToPixels: f32) *render_group {
    var result: *render_group = arena.PushStruct(render_group);
    result.pushBufferBase = arena.PushSize(@alignOf(u8), maxPushBufferSize);
    result.defaultBasis = arena.PushStruct(render_basis);
    result.defaultBasis.p = .{ 0, 0, 0 };
    result.metersToPixels = metersToPixels;

    result.pushBufferSize = 0;
    result.maxPushBufferSize = maxPushBufferSize;

    return result;
}

pub fn RenderGroupToOutput(renderGroup: *render_group, outputTarget: *loaded_bitmap) void {
    const screenCenter = hm.v2{
        0.5 * @intToFloat(f32, outputTarget.width),
        0.5 * @intToFloat(f32, outputTarget.height),
    };

    var baseAddress = @as(u32, 0);
    while (baseAddress < renderGroup.pushBufferSize) {
        const ptr: [*]u8 = renderGroup.pushBufferBase + baseAddress;
        const header = @ptrCast(*render_group_entry_header, @alignCast(@alignOf(render_group_entry_header), ptr));
        baseAddress += @sizeOf(render_group_entry_header);

        const data: [*]u8 = ptr + @sizeOf(render_group_entry_header);

        switch (header.entryType) {
            .Clear => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_clear, data);
                const colour: hm.v4 = entry.colour;
                DrawRectangle(outputTarget, .{ 0, 0 }, .{ @intToFloat(f32, outputTarget.width), @intToFloat(f32, outputTarget.height) }, colour);

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },

            .Saturation => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_saturation, data);
                ChangeSaturation(outputTarget, entry.level);

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },

            .Bitmap => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_bitmap, data);
                if (!NOT_IGNORE) {
                    const p = GetRenderEntityBasisP(renderGroup, &entry.entityBasis, screenCenter);
                    DrawBitmap(outputTarget, entry.bitmap, hm.X(p), hm.Y(p), entry.a);
                }

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },

            .Rectangle => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_rectangle, data);
                const p = GetRenderEntityBasisP(renderGroup, &entry.entityBasis, screenCenter);
                DrawRectangle(outputTarget, p, hm.Add(p, entry.dim), entry.colour);

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },

            .CoordinateSystem => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_coordinate_system, data);

                const vMax: hm.v2 = hm.Add(entry.origin, hm.Add(entry.xAxis, entry.yAxis));
                DrawRectangleSlowly(
                    outputTarget,
                    entry.origin,
                    entry.xAxis,
                    entry.yAxis,
                    entry.colour,
                    entry.texture,
                    entry.normalMap,
                    entry.top,
                    entry.middle,
                    entry.bottom,
                    1.0 / renderGroup.metersToPixels,
                );

                const colour = .{ 1, 1, 0, 1 };
                const dim = hm.v2{ 2, 2 };
                var p = entry.origin;
                DrawRectangle(outputTarget, hm.Sub(p, dim), hm.Add(p, dim), colour);

                p = hm.Add(entry.origin, entry.xAxis);
                DrawRectangle(outputTarget, hm.Sub(p, dim), hm.Add(p, dim), colour);

                p = hm.Add(entry.origin, entry.yAxis);
                DrawRectangle(outputTarget, hm.Sub(p, dim), hm.Add(p, dim), colour);

                DrawRectangle(outputTarget, hm.Sub(vMax, dim), hm.Add(vMax, dim), colour);

                // for (entry.points) |point| {
                //     p = point;
                //     p = origin + hm.Scale(xAxis,  hm.X(p)) + hm.Scale(yAxis,  hm.Y(p));
                //     DrawRectangle(outputTarget, p - dim, p + dim, entry.colour[0], entry.colour[1], entry.colour[2], entry.colour[3]);
                // }

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },
        }
    }
}

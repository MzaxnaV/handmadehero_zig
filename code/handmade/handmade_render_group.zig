const std = @import("std");
const assert = std.debug.assert;

const platform = @import("handmade_platform");

const hd = @import("handmade_data.zig");
const hm = @import("handmade_math.zig");
const hi = @import("handmade_intrinsics.zig");

const simd = @import("simd");

// Works with iaca 2.3 (couldn't make it work with 3.0)
pub const iasa = struct {
    pub inline fn Start() void {
        if (NOT_IGNORE) {
            asm volatile ("movl $111, %%ebx\n.byte 0x64, 0x67, 0x90" ::: "memory");
        }
    }

    // DO NOT USE DEFER
    pub inline fn End() void {
        if (NOT_IGNORE) {
            asm volatile ("movl $222, %%ebx\n.byte 0x64, 0x67, 0x90" ::: "memory");
        }
    }
};

// doc ------------------------------------------------------------------------------------------------------------------------------------

// 1) Everything outside the renderer, Y _always_ goes upward, X to the right.
//
// 2) All bitmaps including the render target are assumed to be bottom-up (meaning that the first row pointer points to the bottom-most
//    row when viewed on screen)
//
// 3) It is mendatory that all inputs to the renderer are in world coordinates ("meters"), NOT pixels. If for some reason something
//    absolutely has to be specified in pixels that will be explicitly marked as in the API, but this should occur exceedingly sparingly.
//
// 4) Z is a special coordinate because it is broken up into discrete slices, and the renderer actually understands these slices. Z slices
//    are what control the scaling of things, whereas Z offsets inside a slice are what control Y offsetting.
//
// 5) All colour values specified to the renderer as v4's are in NON-premultiplied alpha.

// constants ------------------------------------------------------------------------------------------------------------------------------

/// build constant to dynamically remove code sections
const NOT_IGNORE = @import("build_consts").NOT_IGNORE;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const loaded_bitmap = struct {
    alignPercentage: hm.v2 = .{ 0, 0 },
    widthOverHeight: f32 = 0,

    width: i32 = 0,
    height: i32 = 0,
    pitch: i32 = 0,
    memory: [*]u8 = undefined,

    // Draw routines -----------------------------------------------------------------------------------------------------------------------
    // TODO: (Manav) should these really exist here?

    pub fn DrawRectangleOutline(buffer: *const loaded_bitmap, vMin: hm.v2, vMax: hm.v2, colour: hm.v3, r: f32) void {
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

        var minX = hi.RoundF32ToInt(i32, hm.X(vMin));
        var minY = hi.RoundF32ToInt(i32, hm.Y(vMin));
        var maxX = hi.RoundF32ToInt(i32, hm.X(vMax));
        var maxY = hi.RoundF32ToInt(i32, hm.Y(vMax));

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
        const colour32: u32 = (hi.RoundF32ToInt(u32, a * 255.0) << 24) | 
                            (hi.RoundF32ToInt(u32, r * 255.0) << 16) | 
                            (hi.RoundF32ToInt(u32, g * 255.0) << 8) | 
                            (hi.RoundF32ToInt(u32, b * 255) << 0);
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

    // zig fmt: off
    pub fn DrawRectangleSlowly(buffer: *const loaded_bitmap, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, 
                            notPremultipliedColour: hm.v4, texture: *const loaded_bitmap, normalMapOptional: ?*loaded_bitmap, 
                            top: ?*environment_map, _: ?*environment_map, bottom: ?*environment_map,
                            pixelsToMeters: f32) void
    // zig fmt: on
    {
        platform.BEGIN_TIMED_BLOCK(.DrawRectangleSlowly);
        defer platform.END_TIMED_BLOCK(.DrawRectangleSlowly);

        const colour = hm.ToV4(hm.Scale(hm.XYZ(notPremultipliedColour), hm.A(notPremultipliedColour)), hm.A(notPremultipliedColour));

        const xAxisLength = hm.Length(xAxis);
        const yAxisLength = hm.Length(yAxis);

        const nXAxis = hm.Scale(xAxis, yAxisLength / xAxisLength);
        const nYAxis = hm.Scale(yAxis, xAxisLength / yAxisLength);
        const nZScale = 0.5 * (xAxisLength + yAxisLength);

        const invXAxisLengthSq = 1 / hm.LengthSq(xAxis);
        const invYAxisLengthSq = 1 / hm.LengthSq(yAxis);

        // zig fmt: off
        const colour32: u32 = (hi.RoundF32ToInt(u32, hm.A(colour) * 255.0) << 24) | 
                            (hi.RoundF32ToInt(u32, hm.R(colour) * 255.0) << 16) | 
                            (hi.RoundF32ToInt(u32, hm.G(colour) * 255.0) << 8) | 
                            (hi.RoundF32ToInt(u32, hm.B(colour) * 255.0) << 0);
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
            const floorX = hi.FloorF32ToI32(hm.X(testP));
            const ceilX = hi.CeilF32ToI32(hm.X(testP));
            const floorY = hi.FloorF32ToI32(hm.Y(testP));
            const ceilY = hi.CeilF32ToI32(hm.Y(testP));

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

        platform.BEGIN_TIMED_BLOCK(.ProcessPixel);
        defer platform.END_TIMED_BLOCK_COUNTED(.ProcessPixel, @intCast(u32, (xMax - xMin + 1) * (yMax - yMin + 1)));
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

    // zig fmt: off
    pub fn DrawRectangleQuickly(buffer: *const loaded_bitmap, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, 
                                        notPremultipliedColour: hm.v4, texture: *const loaded_bitmap, pixelsToMeters: f32) void
    // zig fmt: on
    {
        platform.BEGIN_TIMED_BLOCK(.DrawRectangleQuickly);
        defer platform.END_TIMED_BLOCK(.DrawRectangleQuickly);

        _ = pixelsToMeters;
        const colour = hm.ToV4(hm.Scale(hm.XYZ(notPremultipliedColour), hm.A(notPremultipliedColour)), hm.A(notPremultipliedColour));

        const xAxisLength = hm.Length(xAxis);
        const yAxisLength = hm.Length(yAxis);
        _ = xAxisLength;
        _ = yAxisLength;

        // const nXAxis = hm.Scale(xAxis, yAxisLength / xAxisLength);
        // _ = nXAxis;
        // const nYAxis = hm.Scale(yAxis, xAxisLength / yAxisLength);
        // _ = nYAxis;
        // const nZScale = 0.5 * (xAxisLength + yAxisLength);
        // _ = nZScale;

        const invXAxisLengthSq = 1 / hm.LengthSq(xAxis);
        const invYAxisLengthSq = 1 / hm.LengthSq(yAxis);

        const widthMax = (buffer.width - 1) - 3;
        const heightMax = (buffer.height - 1) - 3;

        const invWidthMax = 1.0 / @intToFloat(f32, widthMax);
        _ = invWidthMax;
        const invHeightMax = 1.0 / @intToFloat(f32, heightMax);
        _ = invHeightMax;

        const originZ = 0;
        _ = originZ;
        const originY = hm.Y(hm.Add(origin, hm.Scale(hm.Add(xAxis, yAxis), 0.5)));
        const fixedCastY = invHeightMax * originY;
        _ = fixedCastY;

        var xMin = widthMax;
        var xMax = @as(i32, 0);

        var yMin = heightMax;
        var yMax = @as(i32, 0);

        const p: [4]hm.v2 = .{ origin, hm.Add(origin, xAxis), hm.Add(origin, hm.Add(xAxis, yAxis)), hm.Add(origin, yAxis) };

        for (p) |testP| {
            const floorX = hi.FloorF32ToI32(hm.X(testP));
            const ceilX = hi.CeilF32ToI32(hm.X(testP));
            const floorY = hi.FloorF32ToI32(hm.Y(testP));
            const ceilY = hi.CeilF32ToI32(hm.Y(testP));

            if (xMin > floorX) xMin = floorX;
            if (yMin > floorY) yMin = floorY;
            if (xMax < ceilX) xMax = ceilX;
            if (yMax < ceilY) yMax = ceilY;
        }

        if (xMin < 0) xMin = 0;
        if (yMin < 0) yMin = 0;
        if (xMax > widthMax) xMax = widthMax;
        if (yMax > heightMax) yMax = heightMax;

        const nXAxis = hm.Scale(xAxis, invXAxisLengthSq);
        const nYAxis = hm.Scale(yAxis, invYAxisLengthSq);

        const inv255 = 1.0 / 255.0;
        const inv255_4x = @splat(4, @as(f32, inv255));
        // const one255 = 255;
        // const one255_4x = @splat(4, @as(f32, one255));

        // const normalizedC = 1.0 / 255.0;
        // const normalizedSqC = 1.0 / hm.Square(255.0);

        const one = @splat(4, @as(f32, 1));
        const four_4x = @splat(4, @as(f32, 4));
        const zero = @splat(4, @as(f32, 0));
        const maskff = @splat(4, @as(i32, 0xff));
        const maskffff = @splat(4, @as(i32, 0xffff));
        const maskff00ff = @splat(4, @as(i32, 0xff00ff));
        _ = maskffff;
        _ = maskff00ff;

        const colourr_4x: simd.f32x4 = @splat(4, hm.R(colour));
        const colourg_4x: simd.f32x4 = @splat(4, hm.G(colour));
        const colourb_4x: simd.f32x4 = @splat(4, hm.B(colour));
        const coloura_4x: simd.f32x4 = @splat(4, hm.A(colour));

        const nXAxisx_4x: simd.f32x4 = @splat(4, hm.X(nXAxis));
        const nXAxisy_4x: simd.f32x4 = @splat(4, hm.Y(nXAxis));

        const nYAxisx_4x: simd.f32x4 = @splat(4, hm.X(nYAxis));
        const nYAxisy_4x: simd.f32x4 = @splat(4, hm.Y(nYAxis));

        const originx_4x: simd.f32x4 = @splat(4, hm.X(origin));
        const originy_4x: simd.f32x4 = @splat(4, hm.Y(origin));
        const maxColourValue: simd.f32x4 = @splat(4, @as(f32, 255 * 255));

        const widthm2: simd.f32x4 = @splat(4, @intToFloat(f32, texture.width - 2));
        const heightm2: simd.f32x4 = @splat(4, @intToFloat(f32, texture.height - 2));

        var row = @ptrCast([*]u8, buffer.memory) + @intCast(u32, xMin) * platform.BITMAP_BYTES_PER_PIXEL + @intCast(u32, yMin * buffer.pitch);

        const texturePitch = texture.pitch;
        const textureMemory = texture.memory;

        platform.BEGIN_TIMED_BLOCK(.ProcessPixel);
        defer platform.END_TIMED_BLOCK_COUNTED(.ProcessPixel, @intCast(u32, (xMax - xMin + 1) * (yMax - yMin + 1)));

        var y = yMin;
        while (y <= yMax) : (y += 1) {
            var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
            var pixelPX = simd.f32x4{
                @intToFloat(f32, 0 + xMin),
                @intToFloat(f32, 1 + xMin),
                @intToFloat(f32, 2 + xMin),
                @intToFloat(f32, 3 + xMin),
            } - originx_4x;

            const pixelPY = @splat(4, @intToFloat(f32, y)) - originy_4x;

            var xi = xMin;
            while (xi <= xMax) : (xi += 4) {
                iasa.Start();

                var u: simd.f32x4 = pixelPX * nXAxisx_4x + pixelPY * nXAxisy_4x;
                var v: simd.f32x4 = pixelPX * nYAxisx_4x + pixelPY * nYAxisy_4x;

                var writeMask: simd.u1x4 = @bitCast(simd.u1x4, (u >= zero)) & @bitCast(simd.u1x4, (u <= one)) &
                    @bitCast(simd.u1x4, (v >= zero)) & @bitCast(simd.u1x4, (v <= one));

                // if (@reduce(.Or, writeMask) != 0)
                {
                    const originalDest: simd.u32x4 = pixel[0..4].*;

                    u = @minimum(@maximum(u, zero), one);
                    v = @minimum(@maximum(v, zero), one);

                    var sampleA: simd.u32x4 = .{ 0, 0, 0, 0 };
                    var sampleB: simd.u32x4 = .{ 0, 0, 0, 0 };
                    var sampleC: simd.u32x4 = .{ 0, 0, 0, 0 };
                    var sampleD: simd.u32x4 = .{ 0, 0, 0, 0 };

                    const tX: simd.f32x4 = u * widthm2;
                    const tY: simd.f32x4 = v * heightm2;

                    const fetchX_4x: simd.i32x4 = simd.i._mm_cvttps_epi32(tX);
                    const fetchY_4x: simd.i32x4 = simd.i._mm_cvttps_epi32(tY);

                    const fX = tX - simd.i._mm_cvtepi32_ps(fetchX_4x);
                    const fY = tY - simd.i._mm_cvtepi32_ps(fetchY_4x);

                    var I = @as(u32, 0);
                    while (I < 4) : (I += 1) {
                        const fetchX: i32 = fetchX_4x[I];
                        const fetchY: i32 = fetchY_4x[I];

                        assert((fetchX >= 0) and (fetchX < texture.width));
                        assert((fetchY >= 0) and (fetchY < texture.height));

                        const ptrOffset = fetchY * texturePitch + fetchX * @sizeOf(u32);
                        const texelPtr = if (ptrOffset > 0) textureMemory + @intCast(usize, ptrOffset) else textureMemory - @intCast(usize, -ptrOffset);
                        const pitchOffset = if (texturePitch > 0) texelPtr + @intCast(usize, texturePitch) else texelPtr - @intCast(usize, -texturePitch);

                        sampleA[I] = @ptrCast(*align(@alignOf(u8)) u32, texelPtr).*;
                        sampleB[I] = @ptrCast(*align(@alignOf(u8)) u32, texelPtr + @sizeOf(u32)).*;
                        sampleC[I] = @ptrCast(*align(@alignOf(u8)) u32, pitchOffset).*;
                        sampleD[I] = @ptrCast(*align(@alignOf(u8)) u32, pitchOffset + @sizeOf(u32)).*;
                    }

                    var texelArb: simd.i32x4 = @bitCast(simd.i32x4, sampleA) & maskff00ff;
                    var texelAag: simd.i32x4 = @bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 8))) & maskff00ff;
                    texelArb = simd.z._mm_mullo_epi16(texelArb, texelArb);
                    var texelAa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, texelAag >> @splat(4, @as(u5, 16))) & maskff); // cvtepi32
                    texelAag = simd.z._mm_mullo_epi16(texelAag, texelAag);

                    var texelBrb: simd.i32x4 = @bitCast(simd.i32x4, sampleB) & maskff00ff;
                    var texelBag: simd.i32x4 = @bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 8))) & maskff00ff;
                    texelBrb = simd.z._mm_mullo_epi16(texelBrb, texelBrb);
                    var texelBa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, texelBag >> @splat(4, @as(u5, 16))) & maskff);
                    texelBag = simd.z._mm_mullo_epi16(texelBag, texelBag);

                    var texelCrb: simd.i32x4 = @bitCast(simd.i32x4, sampleC) & maskff00ff;
                    var texelCag: simd.i32x4 = @bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 8))) & maskff00ff;
                    texelCrb = simd.z._mm_mullo_epi16(texelCrb, texelCrb);
                    var texelCa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, texelCag >> @splat(4, @as(u5, 16))) & maskff);
                    texelCag = simd.z._mm_mullo_epi16(texelCag, texelCag);

                    var texelDrb: simd.i32x4 = @bitCast(simd.i32x4, sampleD) & maskff00ff;
                    var texelDag: simd.i32x4 = @bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 8))) & maskff00ff;
                    texelDrb = simd.z._mm_mullo_epi16(texelDrb, texelDrb);
                    var texelDa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, texelDag >> @splat(4, @as(u5, 16))) & maskff);
                    texelDag = simd.z._mm_mullo_epi16(texelDag, texelDag);

                    // var texelAb: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA) & maskff);
                    // var texelAg: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 8))) & maskff);
                    // var texelAr: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 16))) & maskff);
                    // var texelAa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 24))) & maskff);

                    // var texelBb: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB) & maskff);
                    // var texelBg: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 8))) & maskff);
                    // var texelBr: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 16))) & maskff);
                    // var texelBa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 24))) & maskff);

                    // var texelCb: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC) & maskff);
                    // var texelCg: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 8))) & maskff);
                    // var texelCr: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 16))) & maskff);
                    // var texelCa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 24))) & maskff);

                    // var texelDb: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD) & maskff);
                    // var texelDg: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 8))) & maskff);
                    // var texelDr: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 16))) & maskff);
                    // var texelDa: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 24))) & maskff);

                    var destb: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, originalDest) & maskff);
                    var destg: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, originalDest >> @splat(4, @as(u5, 8))) & maskff);
                    var destr: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, originalDest >> @splat(4, @as(u5, 16))) & maskff);
                    var desta: simd.f32x4 = simd.i._mm_cvtepi32_ps(@bitCast(simd.i32x4, originalDest >> @splat(4, @as(u5, 24))) & maskff);

                    // FIXME TODO (Manav): // shifting right doesn't work here, investigate properly why.
                    var texelAr: simd.f32x4 = simd.i._mm_cvtepi32_ps(simd.i._mm_srli_epi32(texelArb, 16));
                    var texelAg: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelAag & maskffff);
                    var texelAb: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelArb & maskffff);

                    var texelBr: simd.f32x4 = simd.i._mm_cvtepi32_ps(simd.i._mm_srli_epi32(texelArb, 16));
                    var texelBg: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelBag & maskffff);
                    var texelBb: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelBrb & maskffff);

                    var texelCr: simd.f32x4 = simd.i._mm_cvtepi32_ps(simd.i._mm_srli_epi32(texelArb, 16));
                    var texelCg: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelCag & maskffff);
                    var texelCb: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelCrb & maskffff);

                    var texelDr: simd.f32x4 = simd.i._mm_cvtepi32_ps(simd.i._mm_srli_epi32(texelArb, 16));
                    var texelDg: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelDag & maskffff);
                    var texelDb: simd.f32x4 = simd.i._mm_cvtepi32_ps(texelDrb & maskffff);

                    // texelAr = texelAr * texelAr;
                    // texelAg = texelAg * texelAg;
                    // texelAb = texelAb * texelAb;

                    // texelBr = texelBr * texelBr;
                    // texelBg = texelBg * texelBg;
                    // texelBb = texelBb * texelBb;

                    // texelCr = texelCr * texelCr;
                    // texelCg = texelCg * texelCg;
                    // texelCb = texelCb * texelCb;

                    // texelDr = texelDr * texelDr;
                    // texelDg = texelDg * texelDg;
                    // texelDb = texelDb * texelDb;

                    const ifX: simd.f32x4 = one - fX;
                    const ifY: simd.f32x4 = one - fY;

                    const l0: simd.f32x4 = ifY * ifX;
                    const l1: simd.f32x4 = ifY * fX;
                    const l2: simd.f32x4 = fY * ifX;
                    const l3: simd.f32x4 = fY * fX;

                    var texelr: simd.f32x4 = l0 * texelAr + l1 * texelBr + l2 * texelCr + l3 * texelDr;
                    var texelg: simd.f32x4 = l0 * texelAg + l1 * texelBg + l2 * texelCg + l3 * texelDg;
                    var texelb: simd.f32x4 = l0 * texelAb + l1 * texelBb + l2 * texelCb + l3 * texelDb;
                    var texela: simd.f32x4 = l0 * texelAa + l1 * texelBa + l2 * texelCa + l3 * texelDa;

                    texelr = texelr * colourr_4x;
                    texelg = texelg * colourg_4x;
                    texelb = texelb * colourb_4x;
                    texela = texela * coloura_4x;

                    // TODO (Manav): use _mm_min_ps and _mm_max_ps (minps maxps instruction) ?
                    texelr = @minimum(@maximum(texelr, zero), maxColourValue);
                    texelg = @minimum(@maximum(texelg, zero), maxColourValue);
                    texelb = @minimum(@maximum(texelb, zero), maxColourValue);
                    // texela = @minimum(@maximum(texela, zero), one); // NOTE (Manav): clamp alpha, we have a bug somewhere which makes alpha > 1

                    destr = destr * destr;
                    destg = destg * destg;
                    destb = destb * destb;
                    // desta = desta;

                    const invTexelA: simd.f32x4 = one - (texela * inv255_4x);
                    var blendedr = invTexelA * destr + texelr;
                    var blendedg = invTexelA * destg + texelg;
                    var blendedb = invTexelA * destb + texelb;
                    var blendeda = invTexelA * desta + texela;

                    // TODO (Manav): use _mm_sqrt_ps (sqrtps instruction) ?
                    blendedr = blendedr * simd.i._mm_rsqrt_ps(blendedr);
                    blendedg = blendedg * simd.i._mm_rsqrt_ps(blendedg);
                    blendedb = blendedb * simd.i._mm_rsqrt_ps(blendedb);
                    blendeda = blendeda;

                    const intr: simd.i32x4 = simd.i._mm_cvtps_epi32(blendedr);
                    const intg: simd.i32x4 = simd.i._mm_cvtps_epi32(blendedg);
                    const intb: simd.i32x4 = simd.i._mm_cvtps_epi32(blendedb);
                    const inta: simd.i32x4 = simd.i._mm_cvtps_epi32(blendeda);

                    const sr: simd.i32x4 = (intr << @splat(4, @as(u5, 16)));
                    const sg: simd.i32x4 = (intg << @splat(4, @as(u5, 8)));
                    const sb: simd.i32x4 = intb;
                    const sa: simd.i32x4 = (inta << @splat(4, @as(u5, 24)));

                    const out: simd.i32x4 = sr | sg | sb | sa;

                    const maskedOut: simd.u32x4 = @select(u32, @bitCast(simd.bx4, writeMask), @bitCast(simd.u32x4, out), originalDest);

                    {
                        // const pixel_ptr = @ptrCast(*align(@alignOf(i32)) simd.i32x4, pixel); // unaligned access
                        // pixel_ptr.* = maskedOut;

                        comptime var i = 0;
                        inline while (i < 4) : (i += 1) {
                            pixel[i] = maskedOut[i];
                        }
                    }
                }
                pixelPX += four_4x;
                pixel += 4;

                iasa.End();
            }
            row += @intCast(u32, buffer.pitch);
        }
    }

    pub fn ChangeSaturation(buffer: *const loaded_bitmap, level: f32) void {
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

    pub fn DrawBitmap(buffer: *const loaded_bitmap, bitmap: *const loaded_bitmap, realX: f32, realY: f32, cAlpha: f32) void {
        var minX = hi.RoundF32ToInt(i32, realX);
        var minY = hi.RoundF32ToInt(i32, realY);
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

                var result: hm.v4 = hm.Add(hm.Scale(d, 1 - hm.A(texel)), texel);

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

    pub fn DrawMatte(buffer: *const loaded_bitmap, bitmap: *const loaded_bitmap, realX: f32, realY: f32, cAlpha: f32) void {
        var minX = hi.RoundF32ToInt(i32, realX);
        var minY = hi.RoundF32ToInt(i32, realY);
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
    offset: hm.v3 = hm.v3{ 0, 0, 0 },
};

pub const render_group_entry_type = enum {
    Clear,
    Bitmap,
    Rectangle,
    CoordinateSystem,

    pub fn Type(self: render_group_entry_type) type {
        return switch (self) {
            .Clear => render_entry_clear,
            .Bitmap => render_entry_bitmap,
            .Rectangle => render_entry_rectangle,
            .CoordinateSystem => render_entry_coordinate_system,
        };
    }
};

pub const render_group_entry_header = struct {
    entryType: render_group_entry_type,
};

pub const render_entry_clear = struct {
    colour: hm.v4,
};

pub const render_entry_bitmap = struct {
    bitmap: *const loaded_bitmap,
    entityBasis: render_entity_basis,
    size: hm.v2,
    colour: hm.v4,
};

pub const render_entry_rectangle = struct {
    entityBasis: render_entity_basis,
    colour: hm.v4,

    dim: hm.v2,
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

pub const render_group_camera = struct {
    focalLength: f32,
    distanceAboveTarget: f32,
};

pub const render_group = struct {
    const Self = @This();

    gameCamera: render_group_camera,
    renderCamera: render_group_camera,

    /// This translates meters _on the monitor_ into pixels _on the monitor_.
    metersToPixels: f32,
    monitorHalfDimInMeters: hm.v2,

    globalAlpha: f32,
    defaultBasis: *render_basis,

    pushBufferSize: u32,
    maxPushBufferSize: u32,
    pushBufferBase: [*]u8,

    /// Create render group using the memory `arena`, initialize it and return a pointer to it.
    pub fn Allocate(arena: *hd.memory_arena, maxPushBufferSize: u32, resolutionPixelsX: u32, resolutionPixelsY: u32) *Self {
        _ = resolutionPixelsY;
        var result: *render_group = arena.PushStruct(render_group);
        result.pushBufferBase = arena.PushSize(@alignOf(u8), maxPushBufferSize);
        result.defaultBasis = arena.PushStruct(render_basis);
        result.defaultBasis.p = .{ 0, 0, 0 };

        result.pushBufferSize = 0;
        result.maxPushBufferSize = maxPushBufferSize;

        result.gameCamera.focalLength = 0.6;
        result.gameCamera.distanceAboveTarget = 9.0;
        result.renderCamera = result.gameCamera;
        // result.renderCamera.distanceAboveTarget = 50.0;

        result.globalAlpha = 1.0;

        const widthOfMonitorInMeters = 0.635;
        result.metersToPixels = @intToFloat(f32, resolutionPixelsX) * widthOfMonitorInMeters;

        const pixelsToMeters = 1 / result.metersToPixels;
        result.monitorHalfDimInMeters = hm.v2{
            0.5 * @intToFloat(f32, resolutionPixelsX) * pixelsToMeters,
            0.5 * @intToFloat(f32, resolutionPixelsY) * pixelsToMeters,
        };

        return result;
    }

    fn PushRenderElements(self: *Self, comptime t: render_group_entry_type) ?*align(@alignOf(u8)) t.Type() {
        const element_type = t.Type();
        const element_ptr_type = ?*align(@alignOf(u8)) element_type;

        var result: element_ptr_type = null;

        var size: u32 = @sizeOf(element_type) + @sizeOf(render_group_entry_header);

        if ((self.pushBufferSize + size) < self.maxPushBufferSize) {
            const ptr = self.pushBufferBase + self.pushBufferSize;
            const header = @ptrCast(*render_group_entry_header, ptr);
            header.entryType = t;
            result = @ptrCast(element_ptr_type, ptr + @sizeOf(render_group_entry_header));
            self.pushBufferSize += size;
        } else {
            unreachable;
        }

        return result;
    }

    // Render API routines ----------------------------------------------------------------------------------------------------------------------

    /// Defaults: ```colour = .{ 1.0, 1.0, 1.0, 1.0 }```
    pub inline fn PushBitmap(self: *Self, bitmap: *loaded_bitmap, height: f32, offset: hm.v3, colour: hm.v4) void {
        if (PushRenderElements(self, .Bitmap)) |entry| {
            entry.entityBasis.basis = self.defaultBasis;
            entry.bitmap = bitmap;

            const size = hm.V2(height * bitmap.widthOverHeight, height);
            const alignment: hm.v2 = hm.Hammard(bitmap.alignPercentage, size);

            entry.entityBasis.offset = hm.Sub(offset, hm.ToV3(alignment, 0));
            entry.colour = hm.Scale(colour, self.globalAlpha);
            entry.size = size;
        }
    }

    /// Defaults: ```colour = .{ 1.0, 1.0, 1.0, 1.0 }```
    pub inline fn PushRect(self: *Self, offset: hm.v3, dim: hm.v2, colour: hm.v4) void {
        if (PushRenderElements(self, .Rectangle)) |piece| {
            piece.entityBasis.basis = self.defaultBasis;

            // piece.entityBasis.offset = offset - V3(0.5 * dim, 0);
            piece.entityBasis.offset = hm.Sub(offset, hm.ToV3(hm.Scale(dim, 0.5), 0));
            piece.colour = colour;
            piece.dim = dim;
        }
    }

    /// Defaults: ```colour = .{ 1.0, 1.0, 1.0, 1.0 }```
    pub inline fn PushRectOutline(self: *Self, offset: hm.v3, dim: hm.v2, colour: hm.v4) void {
        const thickness = 0.1;

        PushRect(self, hm.Sub(offset, hm.v3{ 0, 0.5 * hm.Y(dim), 0 }), .{ hm.X(dim), thickness }, colour);
        PushRect(self, hm.Add(offset, hm.v3{ 0, 0.5 * hm.Y(dim), 0 }), .{ hm.X(dim), thickness }, colour);

        PushRect(self, hm.Sub(offset, hm.v3{ 0.5 * hm.X(dim), 0, 0 }), .{ thickness, hm.Y(dim) }, colour);
        PushRect(self, hm.Add(offset, hm.v3{ 0.5 * hm.X(dim), 0, 0 }), .{ thickness, hm.Y(dim) }, colour);
    }

    pub inline fn Clear(group: *Self, colour: hm.v4) void {
        if (PushRenderElements(group, .Clear)) |entry| {
            entry.colour = colour;
        }
    }

    // zig fmt: off
    pub fn CoordinateSystem(self: *Self, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, colour: hm.v4,
                            texture: *const loaded_bitmap, normalMap: ?*loaded_bitmap, 
                            top: ?*environment_map, middle: ?*environment_map, bottom: ?*environment_map) *align(1) render_entry_coordinate_system 
    // zig fmt: on
    {
        const entryElement = PushRenderElements(self, .CoordinateSystem);
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

    pub fn RenderGroupToOutput(self: *Self, outputTarget: *loaded_bitmap) void {
        platform.BEGIN_TIMED_BLOCK(
            .RenderGroupToOutput,
        );
        defer platform.END_TIMED_BLOCK(
            .RenderGroupToOutput,
        );

        const screenDim = hm.v2{
            @intToFloat(f32, outputTarget.width),
            @intToFloat(f32, outputTarget.height),
        };

        const pixelsToMeters = 1.0 / self.metersToPixels;

        var baseAddress = @as(u32, 0);
        while (baseAddress < self.pushBufferSize) {
            const ptr: [*]u8 = self.pushBufferBase + baseAddress;
            const header = @ptrCast(*render_group_entry_header, @alignCast(@alignOf(render_group_entry_header), ptr));
            baseAddress += @sizeOf(render_group_entry_header);

            const data: [*]u8 = ptr + @sizeOf(render_group_entry_header);

            switch (header.entryType) {
                .Clear => {
                    const entry = @ptrCast(*align(@alignOf(u8)) render_entry_clear, data);
                    const colour: hm.v4 = entry.colour;
                    outputTarget.DrawRectangle(.{ 0, 0 }, .{ @intToFloat(f32, outputTarget.width), @intToFloat(f32, outputTarget.height) }, colour);

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },

                .Bitmap => {
                    const entry = @ptrCast(*align(@alignOf(u8)) render_entry_bitmap, data);
                    const basis: entity_basis_p_result = GetRenderEntityBasisP(self, &entry.entityBasis, screenDim);

                    if (!NOT_IGNORE) {
                        // outputTarget.DrawBitmap(entry.bitmap, hm.X(basis.p), hm.Y(basis.p), hm.A(entry.colour));
                        outputTarget.DrawRectangleSlowly(
                            basis.p,
                            hm.Scale(hm.V2(hm.X(entry.size), 0), basis.scale),
                            hm.Scale(hm.V2(0, hm.Y(entry.size)), basis.scale),
                            entry.colour,
                            entry.bitmap,
                            null,
                            null,
                            null,
                            null,
                            pixelsToMeters,
                        );
                    } else {
                        outputTarget.DrawRectangleQuickly(
                            basis.p,
                            hm.Scale(hm.V2(hm.X(entry.size), 0), basis.scale),
                            hm.Scale(hm.V2(0, hm.Y(entry.size)), basis.scale),
                            entry.colour,
                            entry.bitmap,
                            pixelsToMeters,
                        );
                    }

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },

                .Rectangle => {
                    const entry = @ptrCast(*align(@alignOf(u8)) render_entry_rectangle, data);
                    const basis: entity_basis_p_result = GetRenderEntityBasisP(self, &entry.entityBasis, screenDim);
                    outputTarget.DrawRectangle(basis.p, hm.Add(basis.p, hm.Scale(entry.dim, basis.scale)), entry.colour);

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },

                .CoordinateSystem => {
                    const entry = @ptrCast(*align(@alignOf(u8)) render_entry_coordinate_system, data);

                    const vMax: hm.v2 = hm.Add(entry.origin, hm.Add(entry.xAxis, entry.yAxis));
                    outputTarget.DrawRectangleSlowly(
                        entry.origin,
                        entry.xAxis,
                        entry.yAxis,
                        entry.colour,
                        entry.texture,
                        entry.normalMap,
                        entry.top,
                        entry.middle,
                        entry.bottom,
                        pixelsToMeters,
                    );

                    const colour = .{ 1, 1, 0, 1 };
                    const dim = hm.v2{ 2, 2 };
                    var p: hm.v2 = entry.origin;
                    outputTarget.DrawRectangle(hm.Sub(p, dim), hm.Add(p, dim), colour);

                    p = hm.Add(entry.origin, entry.xAxis);
                    outputTarget.DrawRectangle(hm.Sub(p, dim), hm.Add(p, dim), colour);

                    p = hm.Add(entry.origin, entry.yAxis);
                    outputTarget.DrawRectangle(hm.Sub(p, dim), hm.Add(p, dim), colour);

                    outputTarget.DrawRectangle(hm.Sub(vMax, dim), hm.Add(vMax, dim), colour);

                    // for (entry.points) |point| {
                    //     p = point;
                    //     p = origin + hm.Scale(xAxis,  hm.X(p)) + hm.Scale(yAxis,  hm.Y(p));
                    //     outputTarget.DrawRectangle( p - dim, p + dim, entry.colour[0], entry.colour[1], entry.colour[2], entry.colour[3]);
                    // }

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },
            }
        }
    }
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
        one255 * hi.SquareRoot(hm.R(c)),
        one255 * hi.SquareRoot(hm.G(c)),
        one255 * hi.SquareRoot(hm.B(c)),
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

const entity_basis_p_result = struct {
    p: hm.v2 = hm.v2{ 0, 0 },
    scale: f32 = 0,
    valid: bool = false,
};

inline fn GetRenderEntityBasisP(group: *const render_group, entityBasis: *render_entity_basis, screenDim: hm.v2) entity_basis_p_result {
    const screenCenter = hm.Scale(screenDim, 0.5);

    var result: entity_basis_p_result = .{};

    const entityBaseP: hm.v3 = entityBasis.basis.p;

    const distanceToPZ = group.renderCamera.distanceAboveTarget - hm.Z(entityBaseP);
    const nearClipPlane = 0.2;

    const rawXY: hm.v3 = hm.ToV3(hm.Add(hm.XY(entityBaseP), hm.XY(entityBasis.offset)), 1);

    if (distanceToPZ > nearClipPlane) {
        const projectedXY: hm.v3 = hm.Scale(rawXY, group.renderCamera.focalLength / distanceToPZ);
        result.p = hm.Add(screenCenter, hm.Scale(hm.XY(projectedXY), group.metersToPixels));
        result.scale = group.metersToPixels * hm.Z(projectedXY);
        result.valid = true;
    }

    return result;
}

pub inline fn Unproject(group: *render_group, projectedXY: hm.v2, atDistanceFromCamera: f32) hm.v2 {
    const worldXY = hm.Scale(projectedXY, atDistanceFromCamera / group.gameCamera.focalLength);

    return worldXY;
}

pub inline fn GetCameraRectangleAtDistance(group: *render_group, distanceFromCamera: f32) hm.rect2 {
    const rawXY = Unproject(group, group.monitorHalfDimInMeters, distanceFromCamera);

    const result = hm.rect2.InitCenterHalfDim(.{ 0, 0 }, rawXY);

    return result;
}

pub inline fn GetCameraRectangleAtTarget(group: *render_group) hm.rect2 {
    const result = GetCameraRectangleAtDistance(group, group.gameCamera.distanceAboveTarget);
    return result;
}

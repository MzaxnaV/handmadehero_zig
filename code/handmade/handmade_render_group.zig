// const std = @import("std");

const platform = @import("handmade_platform");
const assert = platform.Assert;

const hd = @import("handmade_data.zig");
const hm = @import("handmade_math.zig");
const hi = @import("handmade_intrinsics.zig");

const simd = @import("simd");

pub const perf_analyzer = struct {
    /// DO NOT USE `defer` on `End()`.
    const method = enum {
        LLVM_MCA,
    };

    pub inline fn Start(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .LLVM_MCA => asm volatile ("# LLVM-MCA-BEGIN " ++ region ::: "memory"),
        }
    }

    pub inline fn End(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .LLVM_MCA => asm volatile ("# LLVM-MCA-END " ++ region ::: "memory"),
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
const NOT_IGNORE = @import("handmade_platform").NOT_IGNORE;

// game data types ------------------------------------------------------------------------------------------------------------------------
pub const loaded_bitmap = struct {
    alignPercentage: hm.v2 = .{ 0, 0 },
    widthOverHeight: f32 = 0,

    width: i32 = 0,
    height: i32 = 0,
    pitch: i32 = 0,
    memory: [*]u8 = undefined,

    // Draw routines -----------------------------------------------------------------------------------------------------------------------
    // TODO (Manav): should these really exist here?

    pub fn DrawRectangle(buffer: *const loaded_bitmap, vMin: hm.v2, vMax: hm.v2, colour: hm.v4, clipRect: hm.rect2i, even: bool) void {
        const r = hm.R(colour);
        const g = hm.G(colour);
        const b = hm.B(colour);
        const a = hm.A(colour);

        var fillRect = hm.rect2i{
            .xMin = hi.RoundF32ToInt(i32, hm.X(vMin)),
            .yMin = hi.RoundF32ToInt(i32, hm.Y(vMin)),
            .xMax = hi.RoundF32ToInt(i32, hm.X(vMax)),
            .yMax = hi.RoundF32ToInt(i32, hm.Y(vMax)),
        };

        fillRect.Intersect(clipRect);
        if (!even == (fillRect.yMin & 1 != 0)) {
            fillRect.yMin += 1;
        }

        // zig fmt: off
        const colour32: u32 = (hi.RoundF32ToInt(u32, a * 255.0) << 24) | 
                            (hi.RoundF32ToInt(u32, r * 255.0) << 16) | 
                            (hi.RoundF32ToInt(u32, g * 255.0) << 8) | 
                            (hi.RoundF32ToInt(u32, b * 255) << 0);
        // zig fmt: on

        var row = @as([*]u8, @ptrCast(buffer.memory)) + @as(u32, @intCast(fillRect.xMin)) * platform.BITMAP_BYTES_PER_PIXEL + @as(u32, @intCast(fillRect.yMin * buffer.pitch));

        var y = fillRect.yMin;
        while (y < fillRect.yMax) : (y += 2) {
            var pixel = @as([*]u32, @alignCast(@ptrCast(row)));
            var x = fillRect.xMin;
            var index = @as(u32, 0);
            while (x < fillRect.xMax) : (x += 1) {
                pixel[index] = colour32;
                index += 1;
            }
            row += @as(u32, @intCast(2 * buffer.pitch));
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

        const invWidthMax = 1.0 / @as(f32, @floatFromInt(widthMax));
        const invHeightMax = 1.0 / @as(f32, @floatFromInt(heightMax));

        const originZ = 0;
        const originY = hm.Y(hm.Add(origin, hm.Scale(hm.Add(xAxis, yAxis), 0.5)));
        const fixedCastY = invHeightMax * originY;

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

        var row = @as([*]u8, @ptrCast(buffer.memory)) + @as(u32, @intCast(xMin)) * platform.BITMAP_BYTES_PER_PIXEL + @as(u32, @intCast(yMin * buffer.pitch));

        platform.BEGIN_TIMED_BLOCK(.ProcessPixel);
        defer platform.END_TIMED_BLOCK_COUNTED(.ProcessPixel, @as(u32, @intCast((xMax - xMin + 1) * (yMax - yMin + 1))));
        var y = yMin;
        while (y <= yMax) : (y += 1) {
            var pixel = @as([*]u32, @alignCast(@ptrCast(row)));
            var index = @as(u32, 0);
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
                        const screenSpaceUV = hm.v2{ @as(f32, @floatFromInt(x)) * invWidthMax, fixedCastY };

                        const zDiff = pixelsToMeters * (@as(f32, @floatFromInt(y)) - originY);

                        const u = invXAxisLengthSq * hm.Inner(d, xAxis);
                        const v = invYAxisLengthSq * hm.Inner(d, yAxis);

                        assert((u >= 0) and (u <= 1.001));
                        assert((v >= 0) and (v <= 1.001));

                        const tX = (u * @as(f32, @floatFromInt(texture.width - 2)));
                        const tY = (v * @as(f32, @floatFromInt(texture.height - 2)));

                        const X: i32 = @as(i32, @intFromFloat(tX));
                        const Y: i32 = @as(i32, @intFromFloat(tY));

                        const fX = tX - @as(f32, @floatFromInt(X));
                        const fY = tY - @as(f32, @floatFromInt(Y));

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
                            @as(f32, @floatFromInt(((pixel[0] >> 16) & 0xff))),
                            @as(f32, @floatFromInt(((pixel[0] >> 8) & 0xff))),
                            @as(f32, @floatFromInt(((pixel[0] >> 0) & 0xff))),
                            @as(f32, @floatFromInt(((pixel[0] >> 24) & 0xff))),
                        };

                        dest = SRGB255ToLinear1(dest);

                        const blended: hm.v4 = hm.Add(hm.Scale(dest, 1 - hm.A(texel)), texel);

                        var blended255 = Linear1ToSRGB255(blended);

                        pixel[index] = (@as(u32, @intFromFloat(hm.A(blended255) + 0.5)) << 24) |
                            (@as(u32, @intFromFloat(hm.R(blended255) + 0.5)) << 16) |
                            (@as(u32, @intFromFloat(hm.G(blended255) + 0.5)) << 8) |
                            (@as(u32, @intFromFloat(hm.B(blended255) + 0.5)) << 0);
                    }
                } else {
                    pixel[index] = colour32;
                }
                index += 1;
            }
            row += @as(u32, @intCast(buffer.pitch));
        }
    }

    // zig fmt: off
    pub fn DrawRectangleQuickly(buffer: *const loaded_bitmap, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, notPremultipliedColour: hm.v4, 
                                texture: *const loaded_bitmap, pixelsToMeters: f32, clipRect: hm.rect2i, even: bool) void
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

        var fillRect = hm.rect2i.InvertedInfinityRectangle();

        const p: [4]hm.v2 = .{ origin, hm.Add(origin, xAxis), hm.Add(origin, hm.Add(xAxis, yAxis)), hm.Add(origin, yAxis) };
        for (p) |testP| {
            const floorX = hi.FloorF32ToI32(hm.X(testP));
            const ceilX = hi.CeilF32ToI32(hm.X(testP)) + 1;
            const floorY = hi.FloorF32ToI32(hm.Y(testP));
            const ceilY = hi.CeilF32ToI32(hm.Y(testP)) + 1;

            if (fillRect.xMin > floorX) fillRect.xMin = floorX;
            if (fillRect.yMin > floorY) fillRect.yMin = floorY;
            if (fillRect.xMax < ceilX) fillRect.xMax = ceilX;
            if (fillRect.yMax < ceilY) fillRect.yMax = ceilY;
        }

        // const clipRect = hm.rect2i{ .xMin = 0, .yMin = 0, .xMax = widthMax, .yMax = heightMax };
        // const clipRect = hm.rect2i{ .xMin = 128, .yMin = 128, .xMax = 256, .yMax = 256 };
        fillRect.Intersect(clipRect);
        if (!even == (fillRect.yMin & 1 != 0)) {
            fillRect.yMin += 1;
        }

        if (fillRect.HasArea()) {
            var startClipMask: simd.u1x4 = .{ 0x1, 0x1, 0x1, 0x1 };
            var endClipMask: simd.u1x4 = .{ 0x1, 0x1, 0x1, 0x1 };

            const StartClipMasks: [4]simd.u1x4 = [_]simd.u1x4{
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) << 0), // .{ 0x1, 0x1, 0x1, 0x1 },
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) << 1), // .{ 0x0, 0x1, 0x1, 0x1 },
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) << 2), // .{ 0x0, 0x0, 0x1, 0x1 },
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) << 3), // .{ 0x0, 0x0, 0x0, 0x1 },
            };

            const EndClipMasks: [4]simd.u1x4 = [_]simd.u1x4{
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) >> 0), // .{ 0x1, 0x1, 0x1, 0x1 },
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) >> 3), // .{ 0x1, 0x0, 0x0, 0x0 },
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) >> 2), // .{ 0x1, 0x1, 0x0, 0x0 },
                @bitCast(@as(u4, @bitCast(simd.u1x4{ 0x1, 0x1, 0x1, 0x1 })) >> 1), // .{ 0x1, 0x1, 0x1, 0x0 },
            };

            {
                const t: u2 = @intCast(fillRect.xMin & 3);
                if (t != 0) {
                    startClipMask = StartClipMasks[t];
                    fillRect.xMin = fillRect.xMin & ~@as(i32, 3);
                }
            }

            {
                const t: u2 = @intCast(fillRect.xMax & 3);
                if (t != 0) {
                    endClipMask = EndClipMasks[t];
                    fillRect.xMax = (fillRect.xMax & ~@as(i32, 3)) + 4;
                }
            }

            const nXAxis = hm.Scale(xAxis, invXAxisLengthSq);
            const nYAxis = hm.Scale(yAxis, invYAxisLengthSq);

            const inv255 = 1.0 / 255.0;
            const inv255_4x: simd.f32x4 = @splat(inv255);
            // const one255 = 255;
            // const one255_4x = @splat(4, @as(f32, one255));

            // const normalizedC = 1.0 / 255.0;
            // const normalizedSqC = 1.0 / hm.Square(255.0);

            const one: simd.f32x4 = @splat(1);
            const half: simd.f32x4 = @splat(0.5);
            const four_4x: simd.f32x4 = @splat(4);
            const zero: simd.f32x4 = @splat(0);
            const maskff: simd.i32x4 = @splat(0xff);
            const maskffff: simd.i32x4 = @splat(0xffff);
            const maskff00ff: simd.i32x4 = @splat(0xff00ff);

            const colourr_4x: simd.f32x4 = @splat(hm.R(colour));
            const colourg_4x: simd.f32x4 = @splat(hm.G(colour));
            const colourb_4x: simd.f32x4 = @splat(hm.B(colour));
            const coloura_4x: simd.f32x4 = @splat(hm.A(colour));

            const nXAxisx_4x: simd.f32x4 = @splat(hm.X(nXAxis));
            const nXAxisy_4x: simd.f32x4 = @splat(hm.Y(nXAxis));

            const nYAxisx_4x: simd.f32x4 = @splat(hm.X(nYAxis));
            const nYAxisy_4x: simd.f32x4 = @splat(hm.Y(nYAxis));

            const originx_4x: simd.f32x4 = @splat(hm.X(origin));
            const originy_4x: simd.f32x4 = @splat(hm.Y(origin));
            const maxColourValue: simd.f32x4 = @splat(255 * 255);

            const texturePitch_4x: simd.i32x4 = @splat(texture.pitch);

            const widthM2: simd.f32x4 = @splat(@as(f32, @floatFromInt(texture.width - 2)));
            const heightM2: simd.f32x4 = @splat(@as(f32, @floatFromInt(texture.height - 2)));

            var row = @as([*]u8, @ptrCast(buffer.memory)) + @as(u32, @intCast(fillRect.xMin)) * platform.BITMAP_BYTES_PER_PIXEL + @as(u32, @intCast(fillRect.yMin * buffer.pitch));

            const rowAdvance: i32 = buffer.pitch * 2;

            const texturePitch = texture.pitch;
            const textureMemory = texture.memory;

            const yMax = fillRect.yMax;
            const yMin = fillRect.yMin;
            const xMax = fillRect.xMax;
            const xMin = fillRect.xMin;

            platform.BEGIN_TIMED_BLOCK(.ProcessPixel);
            defer platform.END_TIMED_BLOCK_COUNTED(.ProcessPixel, @as(u32, @intCast(@divFloor(fillRect.GetClampedRectArea(), 2))));

            var y = yMin;
            while (y < yMax) : (y += 2) {
                var pixel = @as([*]u32, @alignCast(@ptrCast(row)));

                const pixelPY = @as(simd.f32x4, @splat(@as(f32, @floatFromInt(y)))) - originy_4x;

                const pynX = pixelPY * nXAxisy_4x;
                const pynY = pixelPY * nYAxisy_4x;

                var pixelPX = simd.f32x4{
                    @as(f32, @floatFromInt(0 + xMin)),
                    @as(f32, @floatFromInt(1 + xMin)),
                    @as(f32, @floatFromInt(2 + xMin)),
                    @as(f32, @floatFromInt(3 + xMin)),
                } - originx_4x;

                var clipMask: simd.u1x4 = startClipMask;

                var xi = xMin;
                while (xi < xMax) : (xi += 4) {
                    var u: simd.f32x4 = pixelPX * nXAxisx_4x + pynX;
                    var v: simd.f32x4 = pixelPX * nYAxisx_4x + pynY;

                    perf_analyzer.Start(.LLVM_MCA, "ProcessPixel");
                    var writeMask: simd.u1x4 = @as(simd.u1x4, @bitCast((u >= zero))) & @as(simd.u1x4, @bitCast((u <= one))) &
                        @as(simd.u1x4, @bitCast((v >= zero))) & @as(simd.u1x4, @bitCast((v <= one)));

                    writeMask = writeMask & clipMask;

                    // if (@reduce(.Or, writeMask) != 0)
                    {
                        const originalDest: simd.u32x4 = pixel[0..4].*;

                        u = @min(@max(u, zero), one);
                        v = @min(@max(v, zero), one);

                        const tX: simd.f32x4 = (u * widthM2) + half;
                        const tY: simd.f32x4 = (v * heightM2) + half;

                        var fetchX_4x: simd.i32x4 = simd.z._mm_cvttps_epi32(tX);
                        var fetchY_4x: simd.i32x4 = simd.z._mm_cvttps_epi32(tY);

                        const fX = tX - simd.z._mm_cvtepi32_ps(fetchX_4x);
                        const fY = tY - simd.z._mm_cvtepi32_ps(fetchY_4x);

                        fetchX_4x = fetchX_4x << @splat(2);
                        fetchY_4x *= texturePitch_4x;
                        // TODO (Manav): Investigate why below doesn't work
                        // fetchX_4x = simd.z._mm_mullo_epi16(fetchX_4x, texturePitch_4x) | (simd.z._mm_mulhi_epi16(fetchX_4x, texturePitch_4x) << @splat(4, @as(u5, 16)));

                        const fetch_4x = fetchX_4x + fetchY_4x;

                        const fetch0: i32 = fetch_4x[0];
                        const fetch1: i32 = fetch_4x[1];
                        const fetch2: i32 = fetch_4x[2];
                        const fetch3: i32 = fetch_4x[3];

                        const texelPtr0 = if (fetch0 > 0) textureMemory + @as(usize, @intCast(fetch0)) else textureMemory - @as(usize, @intCast(-fetch0));
                        const texelPtr1 = if (fetch1 > 0) textureMemory + @as(usize, @intCast(fetch1)) else textureMemory - @as(usize, @intCast(-fetch1));
                        const texelPtr2 = if (fetch2 > 0) textureMemory + @as(usize, @intCast(fetch2)) else textureMemory - @as(usize, @intCast(-fetch2));
                        const texelPtr3 = if (fetch3 > 0) textureMemory + @as(usize, @intCast(fetch3)) else textureMemory - @as(usize, @intCast(-fetch3));

                        const pitchOffset0 = if (texturePitch > 0) texelPtr0 + @as(usize, @intCast(texturePitch)) else texelPtr0 - @as(usize, @intCast(-texturePitch));
                        const pitchOffset1 = if (texturePitch > 0) texelPtr1 + @as(usize, @intCast(texturePitch)) else texelPtr1 - @as(usize, @intCast(-texturePitch));
                        const pitchOffset2 = if (texturePitch > 0) texelPtr2 + @as(usize, @intCast(texturePitch)) else texelPtr2 - @as(usize, @intCast(-texturePitch));
                        const pitchOffset3 = if (texturePitch > 0) texelPtr3 + @as(usize, @intCast(texturePitch)) else texelPtr3 - @as(usize, @intCast(-texturePitch));

                        var sampleA: simd.u32x4 = .{
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr0)).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr1)).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr2)).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr3)).*,
                        };

                        var sampleB: simd.u32x4 = .{
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr0 + @sizeOf(u32))).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr1 + @sizeOf(u32))).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr2 + @sizeOf(u32))).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr3 + @sizeOf(u32))).*,
                        };

                        var sampleC: simd.u32x4 = .{
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset0)).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset1)).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset2)).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset3)).*,
                        };

                        var sampleD: simd.u32x4 = .{
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset0 + @sizeOf(u32))).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset1 + @sizeOf(u32))).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset2 + @sizeOf(u32))).*,
                            @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset3 + @sizeOf(u32))).*,
                        };

                        const u5x4 = @Vector(4, u5);

                        var texelArb: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleA)) & maskff00ff;
                        var texelAag: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleA >> @as(u5x4, @splat(8)))) & maskff00ff;
                        texelArb = simd.z._mm_mullo_epi16(texelArb, texelArb);
                        var texelAa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(texelAag >> @as(u5x4, @splat(16)))) & maskff); // cvtepi32
                        texelAag = simd.z._mm_mullo_epi16(texelAag, texelAag);

                        var texelBrb: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleB)) & maskff00ff;
                        var texelBag: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleB >> @as(u5x4, @splat(8)))) & maskff00ff;
                        texelBrb = simd.z._mm_mullo_epi16(texelBrb, texelBrb);
                        var texelBa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(texelBag >> @as(u5x4, @splat(16)))) & maskff);
                        texelBag = simd.z._mm_mullo_epi16(texelBag, texelBag);

                        var texelCrb: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleC)) & maskff00ff;
                        var texelCag: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleC >> @as(u5x4, @splat(8)))) & maskff00ff;
                        texelCrb = simd.z._mm_mullo_epi16(texelCrb, texelCrb);
                        var texelCa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(texelCag >> @as(u5x4, @splat(16)))) & maskff);
                        texelCag = simd.z._mm_mullo_epi16(texelCag, texelCag);

                        var texelDrb: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleD)) & maskff00ff;
                        var texelDag: simd.i32x4 = @as(simd.i32x4, @bitCast(sampleD >> @as(u5x4, @splat(8)))) & maskff00ff;
                        texelDrb = simd.z._mm_mullo_epi16(texelDrb, texelDrb);
                        var texelDa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(texelDag >> @as(u5x4, @splat(16)))) & maskff);
                        texelDag = simd.z._mm_mullo_epi16(texelDag, texelDag);

                        // var texelAb: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA) & maskff);
                        // var texelAg: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 8))) & maskff);
                        // var texelAr: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 16))) & maskff);
                        // var texelAa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleA >> @splat(4, @as(u5, 24))) & maskff);

                        // var texelBb: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB) & maskff);
                        // var texelBg: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 8))) & maskff);
                        // var texelBr: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 16))) & maskff);
                        // var texelBa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleB >> @splat(4, @as(u5, 24))) & maskff);

                        // var texelCb: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC) & maskff);
                        // var texelCg: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 8))) & maskff);
                        // var texelCr: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 16))) & maskff);
                        // var texelCa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleC >> @splat(4, @as(u5, 24))) & maskff);

                        // var texelDb: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD) & maskff);
                        // var texelDg: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 8))) & maskff);
                        // var texelDr: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 16))) & maskff);
                        // var texelDa: simd.f32x4 = simd.z._mm_cvtepi32_ps(@bitCast(simd.i32x4, sampleD >> @splat(4, @as(u5, 24))) & maskff);

                        var destb: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(originalDest)) & maskff);
                        var destg: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(originalDest >> @as(u5x4, @splat(8)))) & maskff);
                        var destr: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(originalDest >> @as(u5x4, @splat(16)))) & maskff);
                        var desta: simd.f32x4 = simd.z._mm_cvtepi32_ps(@as(simd.i32x4, @bitCast(originalDest >> @as(u5x4, @splat(24)))) & maskff);

                        // Notes (Manav): >> operation on simd.i32x4 doesn't generate vpsrld but vpsrad
                        var texelAr: simd.f32x4 = simd.z._mm_cvtepi32_ps(simd.z._mm_srli_epi32(texelArb, 16));
                        var texelAg: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelAag & maskffff);
                        var texelAb: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelArb & maskffff);

                        var texelBr: simd.f32x4 = simd.z._mm_cvtepi32_ps(simd.z._mm_srli_epi32(texelArb, 16));
                        var texelBg: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelBag & maskffff);
                        var texelBb: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelBrb & maskffff);

                        var texelCr: simd.f32x4 = simd.z._mm_cvtepi32_ps(simd.z._mm_srli_epi32(texelArb, 16));
                        var texelCg: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelCag & maskffff);
                        var texelCb: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelCrb & maskffff);

                        var texelDr: simd.f32x4 = simd.z._mm_cvtepi32_ps(simd.z._mm_srli_epi32(texelArb, 16));
                        var texelDg: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelDag & maskffff);
                        var texelDb: simd.f32x4 = simd.z._mm_cvtepi32_ps(texelDrb & maskffff);

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
                        texelr = @min(@max(texelr, zero), maxColourValue);
                        texelg = @min(@max(texelg, zero), maxColourValue);
                        texelb = @min(@max(texelb, zero), maxColourValue);
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

                        const sr: simd.i32x4 = (intr << @as(u5x4, @splat(16)));
                        const sg: simd.i32x4 = (intg << @as(u5x4, @splat(8)));
                        const sb: simd.i32x4 = intb;
                        const sa: simd.i32x4 = (inta << @as(u5x4, @splat(24)));

                        const out: simd.i32x4 = sr | sg | sb | sa;

                        const maskedOut: simd.u32x4 = @select(u32, @as(simd.bx4, @bitCast(writeMask)), @as(simd.u32x4, @bitCast(out)), originalDest);

                        // @as(*align(@alignOf(u8)) simd.u32x4, @alignCast(@ptrCast(pixel))).* = maskedOut;
                        @as(*simd.u32x4, @alignCast(@ptrCast(pixel))).* = maskedOut;
                    }

                    perf_analyzer.End(.LLVM_MCA, "ProcessPixel");

                    pixelPX += four_4x;
                    pixel += 4;

                    if ((xi + 8) < xMax) {
                        clipMask = .{ 0x1, 0x1, 0x1, 0x1 };
                    } else {
                        clipMask = endClipMask;
                    }
                }
                row += @as(u32, @intCast(rowAdvance));
            }
        }
    }

    pub fn ChangeSaturation(buffer: *const loaded_bitmap, level: f32) void {
        var destRow = buffer.memory;

        var y = @as(i32, 0);
        while (y < buffer.height) : (y += 1) {
            const dest = @as([*]u32, @alignCast(@ptrCast(destRow)));

            var x = @as(i32, 0);
            while (x < buffer.width) : (x += 1) {
                const index = @as(u32, @intCast(x));

                var d: hm.v4 = .{
                    @as(f32, @floatFromInt(((dest[index] >> 16) & 0xff))),
                    @as(f32, @floatFromInt(((dest[index] >> 8) & 0xff))),
                    @as(f32, @floatFromInt(((dest[index] >> 0) & 0xff))),
                    @as(f32, @floatFromInt(((dest[index] >> 24) & 0xff))),
                };

                d = SRGB255ToLinear1(d);

                const avg = (hm.R(d) + hm.G(d) + hm.B(d)) * (1.0 / 3.0);
                const delta = hm.v3{ hm.R(d) - avg, hm.G(d) - avg, hm.B(d) - avg };

                var result = hm.ToV4(hm.Add(hm.v3{ avg, avg, avg }, hm.Scale(delta, level)), hm.A(d));

                result = Linear1ToSRGB255(result);

                dest[index] =
                    (@as(u32, @intFromFloat(hm.A(result) + 0.5)) << 24) |
                    (@as(u32, @intFromFloat(hm.R(result) + 0.5)) << 16) |
                    (@as(u32, @intFromFloat(hm.G(result) + 0.5)) << 8) |
                    (@as(u32, @intFromFloat(hm.B(result) + 0.5)) << 0);
            }

            destRow += @as(usize, @intCast(buffer.pitch));
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

        var sourceRow = if (offset > 0) bitmap.memory + @as(usize, @intCast(offset)) else bitmap.memory - @as(usize, @intCast(-offset));
        var destRow = buffer.memory + @as(usize, @intCast(minX * platform.BITMAP_BYTES_PER_PIXEL + minY * buffer.pitch));

        var y = minY;
        while (y < maxY) : (y += 1) {
            const dest = @as([*]u32, @alignCast(@ptrCast(destRow)));
            const source = @as([*]align(1) u32, @ptrCast(sourceRow));
            var x = minX;
            while (x < maxX) : (x += 1) {
                const index = @as(u32, @intCast(x - minX));

                var texel: hm.v4 = .{
                    @as(f32, @floatFromInt(((source[index] >> 16) & 0xff))),
                    @as(f32, @floatFromInt(((source[index] >> 8) & 0xff))),
                    @as(f32, @floatFromInt(((source[index] >> 0) & 0xff))),
                    @as(f32, @floatFromInt(((source[index] >> 24) & 0xff))),
                };

                texel = SRGB255ToLinear1(texel);
                texel = hm.Scale(texel, cAlpha);

                var d: hm.v4 = .{
                    @as(f32, @floatFromInt(((dest[index] >> 16) & 0xff))),
                    @as(f32, @floatFromInt(((dest[index] >> 8) & 0xff))),
                    @as(f32, @floatFromInt(((dest[index] >> 0) & 0xff))),
                    @as(f32, @floatFromInt(((dest[index] >> 24) & 0xff))),
                };

                d = SRGB255ToLinear1(d);

                var result: hm.v4 = hm.Add(hm.Scale(d, 1 - hm.A(texel)), texel);

                result = Linear1ToSRGB255(result);

                dest[index] =
                    (@as(u32, @intFromFloat(hm.A(result) + 0.5)) << 24) |
                    (@as(u32, @intFromFloat(hm.R(result) + 0.5)) << 16) |
                    (@as(u32, @intFromFloat(hm.G(result) + 0.5)) << 8) |
                    (@as(u32, @intFromFloat(hm.B(result) + 0.5)) << 0);
            }

            destRow += @as(usize, @intCast(buffer.pitch));
            sourceRow = if (bitmap.pitch > 0) sourceRow + @as(usize, @intCast(bitmap.pitch)) else sourceRow - @as(usize, @intCast(-bitmap.pitch));
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

        var sourceRow = if (offset > 0) bitmap.memory + @as(usize, @intCast(offset)) else bitmap.memory - @as(usize, @intCast(-offset));
        var destRow = buffer.memory + @as(usize, @intCast(minX * platform.BITMAP_BYTES_PER_PIXEL + minY * buffer.pitch));

        var y = minY;
        while (y < maxY) : (y += 1) {
            const dest = @as([*]u32, @alignCast(@ptrCast(destRow)));
            const source = @as([*]align(1) u32, @ptrCast(sourceRow));
            var x = minX;
            while (x < maxX) : (x += 1) {
                const index = @as(u32, @intCast(x - minX));

                const sA = cAlpha * @as(f32, @floatFromInt(((source[index] >> 24) & 0xff)));
                const rSA = (sA / 255.0) * cAlpha;
                // const sR = cAlpha * @intToFloat(f32, ((source[index] >> 16) & 0xff));
                // const sG = cAlpha * @intToFloat(f32, ((source[index] >> 8) & 0xff));
                // const sB = cAlpha * @intToFloat(f32, ((source[index] >> 0) & 0xff));

                const dA = @as(f32, @floatFromInt(((dest[index] >> 24) & 0xff)));
                const dR = @as(f32, @floatFromInt(((dest[index] >> 16) & 0xff)));
                const dG = @as(f32, @floatFromInt(((dest[index] >> 8) & 0xff)));
                const dB = @as(f32, @floatFromInt(((dest[index] >> 0) & 0xff)));
                // const rDA = (dA / 255.0);

                const invRSA = 1 - rSA;
                const a = invRSA * dA;
                const r = invRSA * dR;
                const g = invRSA * dG;
                const b = invRSA * dB;

                dest[index] = (@as(u32, @intFromFloat(a + 0.5)) << 24) |
                    (@as(u32, @intFromFloat(r + 0.5)) << 16) |
                    (@as(u32, @intFromFloat(g + 0.5)) << 8) |
                    (@as(u32, @intFromFloat(b + 0.5)) << 0);
            }

            destRow += @as(usize, @intCast(buffer.pitch));
            sourceRow = if (bitmap.pitch > 0) sourceRow + @as(usize, @intCast(bitmap.pitch)) else sourceRow - @as(usize, @intCast(-bitmap.pitch));
        }
    }
};

pub const environment_map = struct {
    lod: [4]loaded_bitmap,
    pZ: f32,
};

pub const render_group_entry_type = enum {
    Clear,
    Bitmap,
    Rectangle,
    CoordinateSystem,

    pub fn Type(comptime self: render_group_entry_type) type {
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

pub const render_entry_bitmap = struct { // make them packed?
    bitmap: *const loaded_bitmap,

    colour: hm.v4,
    p: hm.v2,
    size: hm.v2,
};

pub const render_entry_rectangle = struct {
    colour: hm.v4,
    p: hm.v2,
    dim: hm.v2,
};

pub const render_entry_coordinate_system = struct {
    origin: hm.v2,
    xAxis: hm.v2,
    yAxis: hm.v2,
    colour: hm.v4,
    texture: *const loaded_bitmap,
    normalMap: ?*loaded_bitmap,

    pixelsToMeters: f32,

    top: ?*environment_map,
    middle: ?*environment_map,
    bottom: ?*environment_map,
};

pub const render_transform = struct {
    /// This translates meters _on the monitor_ into pixels _on the monitor_.
    metersToPixels: f32,
    screenCenter: hm.v2,

    focalLength: f32,
    distanceAboveTarget: f32,

    offsetP: hm.v3,
    scale: f32,

    orthographic: bool,
};

const entity_basis_p_result = struct {
    p: hm.v2 = hm.v2{ 0, 0 },
    scale: f32 = 0,
    valid: bool = false,
};

fn GetRenderEntityBasisP(transform: *const render_transform, originalP: hm.v3) entity_basis_p_result {
    var result: entity_basis_p_result = .{};

    const p: hm.v3 = hm.Add(originalP, transform.offsetP);

    if (transform.orthographic) {
        result.p = hm.Add(transform.screenCenter, hm.Scale(hm.XY(p), transform.metersToPixels));
        result.scale = transform.metersToPixels;
        result.valid = true;
    } else {
        const offsetZ = 0;
        var distanceAboveTarget = transform.distanceAboveTarget;

        if (!NOT_IGNORE) { // DEBUG CAMERA
            distanceAboveTarget += 50;
        }

        const distanceToPZ = distanceAboveTarget - hm.Z(p);
        const nearClipPlane = 0.2;

        const rawXY: hm.v3 = hm.ToV3(hm.XY(p), 1);

        if (distanceToPZ > nearClipPlane) {
            const projectedXY: hm.v3 = hm.Scale(rawXY, transform.focalLength / distanceToPZ);
            result.scale = transform.metersToPixels * hm.Z(projectedXY);
            result.p = hm.Add(hm.Add(transform.screenCenter, hm.Scale(hm.XY(projectedXY), transform.metersToPixels)), .{ 0, result.scale * offsetZ });
            result.valid = true;
        }
    }

    return result;
}

pub const render_group = struct {
    const Self = @This();

    assets: *hd.game_assets,
    globalAlpha: f32,

    monitorHalfDimInMeters: hm.v2,
    transform: render_transform,

    pushBufferSize: u32,
    maxPushBufferSize: u32,
    pushBufferBase: [*]u8,

    /// Create render group using the memory `arena`, initialize it and return a pointer to it.
    pub fn Allocate(assets: *hd.game_assets, arena: *hd.memory_arena, maxPushBufferSize: u32) *Self {
        var pushBufferSize = maxPushBufferSize;

        var result: *render_group = arena.PushStruct(render_group);

        if (pushBufferSize == 0) {
            pushBufferSize = @intCast(arena.GetSizeRemaining(@alignOf(render_group)));
        }
        result.pushBufferBase = arena.PushSizeAlign(@alignOf(u8), pushBufferSize);

        result.maxPushBufferSize = pushBufferSize;
        result.pushBufferSize = 0;

        result.assets = assets;
        result.globalAlpha = 1.0;

        result.transform.offsetP = hm.v3{ 0, 0, 0 };
        result.transform.scale = 1;

        return result;
    }

    pub fn Perspective(self: *Self, pixelWidth: u32, pixelHeight: u32, metersToPixels: f32, focalLength: f32, distanceAboveTarget: f32) void {
        const pixelsToMeters = hm.SafeRatiof1(1, metersToPixels);

        self.monitorHalfDimInMeters = .{
            0.5 * @as(f32, @floatFromInt(pixelWidth)) * pixelsToMeters,
            0.5 * @as(f32, @floatFromInt(pixelHeight)) * pixelsToMeters,
        };

        self.transform.metersToPixels = metersToPixels;
        self.transform.focalLength = focalLength;
        self.transform.distanceAboveTarget = distanceAboveTarget; // 50.0
        self.transform.screenCenter = .{
            0.5 * @as(f32, @floatFromInt(pixelWidth)),
            0.5 * @as(f32, @floatFromInt(pixelHeight)),
        };
        self.transform.orthographic = false;
    }

    pub fn Orthographic(self: *Self, pixelWidth: u32, pixelHeight: u32, metersToPixels: f32) void {
        const pixelsToMeters = hm.SafeRatiof1(1, metersToPixels);

        self.monitorHalfDimInMeters = .{
            0.5 * @as(f32, @floatFromInt(pixelWidth)) * pixelsToMeters,
            0.5 * @as(f32, @floatFromInt(pixelHeight)) * pixelsToMeters,
        };

        self.transform.metersToPixels = metersToPixels;
        self.transform.focalLength = 1;
        self.transform.distanceAboveTarget = 1;
        self.transform.screenCenter = .{
            0.5 * @as(f32, @floatFromInt(pixelWidth)),
            0.5 * @as(f32, @floatFromInt(pixelHeight)),
        };

        self.transform.orthographic = true;
    }

    fn PushRenderElements(self: *Self, comptime t: render_group_entry_type) ?*align(@alignOf(u8)) t.Type() {
        const element_type = t.Type();
        const element_ptr_type = ?*align(@alignOf(u8)) element_type;

        var result: element_ptr_type = null;

        var size: u32 = @sizeOf(element_type) + @sizeOf(render_group_entry_header);

        if ((self.pushBufferSize + size) < self.maxPushBufferSize) {
            const ptr = self.pushBufferBase + self.pushBufferSize;
            const header = @as(*render_group_entry_header, @ptrCast(ptr));
            header.entryType = t;
            result = @as(element_ptr_type, @ptrCast(ptr + @sizeOf(render_group_entry_header)));
            self.pushBufferSize += size;
        } else {
            unreachable;
        }

        return result;
    }

    // Render API routines ----------------------------------------------------------------------------------------------------------------------

    pub inline fn PushBitmap2(self: *Self, ID: hd.game_asset_id, height: f32, offset: hm.v3, colour: hm.v4) void {
        if (self.assets.GetBitmap(ID)) |bitmap| {
            self.PushBitmap(bitmap, height, offset, colour);
        } else {
            @import("handmade.zig").LoadAsset(self.assets, ID);
        }
    }

    /// Defaults: ```colour = .{ 1.0, 1.0, 1.0, 1.0 }```
    pub inline fn PushBitmap(self: *Self, bitmap: *loaded_bitmap, height: f32, offset: hm.v3, colour: hm.v4) void {
        const size = hm.V2(height * bitmap.widthOverHeight, height);
        const alignment: hm.v2 = hm.Hammard(bitmap.alignPercentage, size);
        const p = hm.Sub(offset, hm.ToV3(alignment, 0));

        const basis: entity_basis_p_result = GetRenderEntityBasisP(&self.transform, p);
        if (basis.valid) {
            if (PushRenderElements(self, .Bitmap)) |entry| {
                entry.bitmap = bitmap;
                entry.p = basis.p;
                entry.colour = hm.Scale(colour, self.globalAlpha);
                entry.size = hm.Scale(size, basis.scale);
            }
        }
    }

    /// Defaults: ```colour = .{ 1.0, 1.0, 1.0, 1.0 }```
    pub inline fn PushRect(self: *Self, offset: hm.v3, dim: hm.v2, colour: hm.v4) void {
        const p = hm.Sub(offset, hm.ToV3(hm.Scale(dim, 0.5), 0));
        const basis: entity_basis_p_result = GetRenderEntityBasisP(&self.transform, p);

        if (basis.valid) {
            if (PushRenderElements(self, .Rectangle)) |rect| {
                rect.p = basis.p;
                rect.colour = colour;
                rect.dim = hm.Scale(dim, basis.scale);
            }
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
                            top: ?*environment_map, middle: ?*environment_map, bottom: ?*environment_map) void 
    // zig fmt: on
    {
        _ = bottom;
        _ = middle;
        _ = top;
        _ = normalMap;
        _ = texture;
        _ = colour;
        _ = yAxis;
        _ = xAxis;
        _ = origin;
        _ = self;
        // const basis: entity_basis_p_result = GetRenderEntityBasisP(self, &entry.entityBasis, screenDim);
        // if (basis.valid) {
        //     const entryElement = PushRenderElements(self, .CoordinateSystem);
        //     if (entryElement) |entry| {
        //         entry.origin = origin;
        //         entry.xAxis = xAxis;
        //         entry.yAxis = yAxis;
        //         entry.colour = colour;
        //         entry.texture = texture;
        //         entry.normalMap = normalMap;
        //         entry.top = top;
        //         entry.middle = middle;
        //         entry.bottom = bottom;
        //     }
        // }
    }

    fn RenderGroupToOutput(self: *Self, outputTarget: *loaded_bitmap, clipRect: hm.rect2i, even: bool) void {
        platform.BEGIN_TIMED_BLOCK(.RenderGroupToOutput);
        defer platform.END_TIMED_BLOCK(.RenderGroupToOutput);

        const nullPixelsToMeters = 1;

        var baseAddress = @as(u32, 0);
        while (baseAddress < self.pushBufferSize) {
            const ptr: [*]u8 = self.pushBufferBase + baseAddress;
            const header = @as(*render_group_entry_header, @alignCast(@ptrCast(ptr)));
            baseAddress += @sizeOf(render_group_entry_header);

            const data: [*]u8 = ptr + @sizeOf(render_group_entry_header);

            switch (header.entryType) {
                .Clear => {
                    const entry = @as(*align(@alignOf(u8)) render_entry_clear, @ptrCast(data));
                    var colour: hm.v4 = entry.colour;
                    outputTarget.DrawRectangle(
                        .{ 0, 0 },
                        .{ @as(f32, @floatFromInt(outputTarget.width)), @as(f32, @floatFromInt(outputTarget.height)) },
                        colour,
                        clipRect,
                        even,
                    );

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },

                .Bitmap => {
                    const entry = @as(*align(@alignOf(u8)) render_entry_bitmap, @ptrCast(data));

                    const xAxis = hm.v2{ 1, 0 };
                    const yAxis = hm.v2{ 0, 1 };

                    if (!NOT_IGNORE) {
                        // outputTarget.DrawBitmap(entry.bitmap, hm.X(basis.p), hm.Y(basis.p), hm.A(entry.colour));
                        outputTarget.DrawRectangleSlowly(
                            entry.p,
                            hm.V2(hm.X(entry.size), 0),
                            hm.V2(0, hm.Y(entry.size)),
                            entry.colour,
                            entry.bitmap,
                            null,
                            null,
                            null,
                            null,
                            nullPixelsToMeters,
                        );
                    } else {
                        outputTarget.DrawRectangleQuickly(
                            entry.p,
                            hm.Scale(xAxis, hm.X(entry.size)),
                            hm.Scale(yAxis, hm.Y(entry.size)),
                            entry.colour,
                            entry.bitmap,
                            nullPixelsToMeters,
                            clipRect,
                            even,
                        );
                    }

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },

                .Rectangle => {
                    const entry = @as(*align(@alignOf(u8)) render_entry_rectangle, @ptrCast(data));
                    outputTarget.DrawRectangle(entry.p, hm.Add(entry.p, entry.dim), entry.colour, clipRect, even);

                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },

                .CoordinateSystem => {
                    const entry = @as(*align(@alignOf(u8)) render_entry_coordinate_system, @ptrCast(data));
                    if (!NOT_IGNORE) {
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
                            nullPixelsToMeters,
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

                    }
                    baseAddress += @sizeOf(@TypeOf(entry.*));
                },
            }
        }
    }

    const tile_render_work = struct {
        renderGroup: *render_group = undefined,
        outputTarget: *loaded_bitmap = undefined,
        clipRect: hm.rect2i = .{},
    };

    pub fn DoTiledRenderWork(_: ?*platform.work_queue, data: *anyopaque) void {
        comptime {
            if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(DoTiledRenderWork)) {
                @compileError("Function signature mismatch!");
            }
        }
        const work: *tile_render_work = @as(*tile_render_work, @alignCast(@ptrCast(data)));

        work.renderGroup.RenderGroupToOutput(work.outputTarget, work.clipRect, false);
        work.renderGroup.RenderGroupToOutput(work.outputTarget, work.clipRect, true);
    }

    pub fn NonTiledRenderGroupToOutput(self: *Self, outputTarget: *loaded_bitmap) void {
        assert((@intFromPtr(outputTarget.memory) & 15) == 0); // TODO (Manav): use alignment as a requirement in the stuct itself?

        var clipRect = hm.rect2i{
            .xMin = 0,
            .xMax = outputTarget.width,
            .yMin = 0,
            .yMax = outputTarget.height,
        };

        var work = tile_render_work{
            .renderGroup = self,
            .outputTarget = outputTarget,
            .clipRect = clipRect,
        };

        DoTiledRenderWork(null, &work);
    }

    pub fn TiledRenderGroupToOutput(self: *Self, renderQueue: *platform.work_queue, outputTarget: *loaded_bitmap) void {
        const tileCountX = 4;
        const tileCountY = 4;
        var workArray: [tileCountX * tileCountY]tile_render_work = [1]tile_render_work{.{}} ** (tileCountX * tileCountY);

        assert((@intFromPtr(outputTarget.memory) & 15) == 0); // TODO (Manav): use alignment as a requirement in the stuct itself?

        var tileWidth = @divTrunc(outputTarget.width, tileCountX);
        const tileHeight = @divTrunc(outputTarget.height, tileCountY);

        tileWidth = @divTrunc(tileWidth + 3, 4) * 4;

        var workCount = @as(u32, 0);
        var tileY = @as(i32, 0);
        while (tileY < tileCountY) : (tileY += 1) {
            var tileX = @as(i32, 0);
            while (tileX < tileCountX) : (tileX += 1) {
                var work: *tile_render_work = &workArray[workCount];
                workCount += 1;

                var clipRect = hm.rect2i{};
                clipRect.xMin = tileX * tileWidth;
                clipRect.xMax = clipRect.xMin + tileWidth;
                clipRect.yMin = tileY * tileHeight;
                clipRect.yMax = clipRect.yMin + tileHeight;

                if (tileX == tileCountX - 1) {
                    clipRect.xMax = outputTarget.width;
                }
                if (tileY == tileCountY - 1) {
                    clipRect.yMax = outputTarget.height;
                }

                work.renderGroup = self;
                work.outputTarget = outputTarget;
                work.clipRect = clipRect;

                if (NOT_IGNORE) {
                    hd.PlatformAddEntry(renderQueue, DoTiledRenderWork, work);
                } else {
                    DoTiledRenderWork(renderQueue, work);
                }
            }
        }

        hd.PlatformCompleteAllWork(renderQueue);
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
        @as(f32, @floatFromInt(((packedValue >> 16) & 0xff))),
        @as(f32, @floatFromInt(((packedValue >> 8) & 0xff))),
        @as(f32, @floatFromInt(((packedValue >> 0) & 0xff))),
        @as(f32, @floatFromInt(((packedValue >> 24) & 0xff))),
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
    const lodIndex: u32 = @as(u32, @intFromFloat(roughness * @as(f32, @floatFromInt(map.lod.len - 1)) + 0.5));
    assert(lodIndex < map.lod.len);

    const lod: *loaded_bitmap = &map.lod[lodIndex];

    const uvPerMeter = 0.1;
    const c: f32 = (uvPerMeter * distanceFromMapInZ) / hm.Y(sampleDirection);
    const offset: hm.v2 = hm.Scale(hm.v2{ hm.X(sampleDirection), hm.Z(sampleDirection) }, c);

    var uv: hm.v2 = hm.Add(offset, screenSpaceUV);

    uv = hm.ClampV201(uv);

    const tX: f32 = (hm.X(uv) * @as(f32, @floatFromInt(lod.width - 2)));
    const tY: f32 = (hm.Y(uv) * @as(f32, @floatFromInt(lod.height - 2)));

    const x: i32 = @as(i32, @intFromFloat(tX));
    const y: i32 = @as(i32, @intFromFloat(tY));

    const fX: f32 = tX - @as(f32, @floatFromInt(x));
    const fY: f32 = tY - @as(f32, @floatFromInt(y));

    assert((x >= 0) and (x < lod.width));
    assert((y >= 0) and (y < lod.height));

    if (!NOT_IGNORE) {
        const ptrOffset = y * lod.pitch + x * @sizeOf(u32);
        const texelPtr = if (ptrOffset > 0) lod.memory + @as(usize, @intCast(ptrOffset)) else lod.memory - @as(usize, @intCast(-ptrOffset));
        const ptr = @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr));
        ptr.* = 0xffffffff;
    }

    const sample: bilinear_sample = BilinearSample(lod, x, y);
    const result: hm.v3 = hm.XYZ(SRGBBilinearBlend(sample, fX, fY));

    return result;
}

const bilinear_sample = struct { a: u32 = 0, b: u32 = 0, c: u32 = 0, d: u32 = 0 };

inline fn BilinearSample(texture: *const loaded_bitmap, x: i32, y: i32) bilinear_sample {
    const ptrOffset = y * texture.pitch + x * @sizeOf(u32);
    const texelPtr = if (ptrOffset > 0) texture.memory + @as(usize, @intCast(ptrOffset)) else texture.memory - @as(usize, @intCast(-ptrOffset));
    const pitchOffset = if (texture.pitch > 0) texelPtr + @as(usize, @intCast(texture.pitch)) else texelPtr - @as(usize, @intCast(-texture.pitch));

    const result = bilinear_sample{
        .a = @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr)).*,
        .b = @as(*align(@alignOf(u8)) u32, @ptrCast(texelPtr + @sizeOf(u32))).*,
        .c = @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset)).*,
        .d = @as(*align(@alignOf(u8)) u32, @ptrCast(pitchOffset + @sizeOf(u32))).*,
    };

    return result;
}

pub inline fn Unproject(group: *const render_group, projectedXY: hm.v2, atDistanceFromCamera: f32) hm.v2 {
    const worldXY = hm.Scale(projectedXY, atDistanceFromCamera / group.transform.focalLength);

    return worldXY;
}

pub inline fn GetCameraRectangleAtDistance(group: *render_group, distanceFromCamera: f32) hm.rect2 {
    const rawXY = Unproject(group, group.monitorHalfDimInMeters, distanceFromCamera);

    const result = hm.rect2.InitCenterHalfDim(.{ 0, 0 }, rawXY);

    return result;
}

pub inline fn GetCameraRectangleAtTarget(group: *render_group) hm.rect2 {
    const result = GetCameraRectangleAtDistance(group, group.transform.distanceAboveTarget);
    return result;
}

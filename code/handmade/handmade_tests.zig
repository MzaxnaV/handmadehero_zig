const std = @import("std");
const testing = std.testing;

const h = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
};

const simd = @import("simd");

test "language" {
    try testing.expectEqual(@divTrunc(-10, 21), 0);
    try testing.expectEqual(@divTrunc(-11, 2), -5);
    try testing.expectEqual(@divTrunc(11, -2), -5);

    // Little endian
    try testing.expectEqual(@as(u32, 0xaabbccdd), @as(u32, @bitCast([4]u8{ 0xdd, 0xcc, 0xbb, 0xaa })));
}

test "intrinsics" {
    try testing.expectEqual(h.AbsoluteValue(-0.2), 0.2);
    try testing.expectEqual(h.AbsoluteValue(0.2), 0.2);

    try testing.expectEqual(h.RoundF32ToInt(u32, -0.2), 0);
    try testing.expectEqual(h.RoundF32ToInt(u32, 0.2), 0);

    try testing.expectEqual(h.CeilF32ToI32(2.34), 3);
    try testing.expectEqual(h.CeilF32ToI32(-2.34), -2);

    try testing.expectEqual(h.TruncateF32ToI32(1.2), 1);
    try testing.expectEqual(h.TruncateF32ToI32(-0.2), 0);
    try testing.expectEqual(h.TruncateF32ToI32(-1.2), -1);

    try testing.expectEqual(h.FloorF32ToI32(1.2), 1);
    try testing.expectEqual(h.FloorF32ToI32(0.2), 0);
    try testing.expectEqual(h.FloorF32ToI32(-0.2), -1);

    try testing.expectEqual(h.FindLeastSignificantSetBit(0b00000010), 1);
    try testing.expectEqual(h.FindLeastSignificantSetBit(0b01000000), 6);

    // TODO (Manav): add RotateLeft tests when the issue is fixed

    try testing.expectEqual(h.SquareRoot(0.04), 0.2);
    try testing.expectEqual(h.SquareRoot(25.0), 5.0);
}

test "math" {
    var vec1 = h.v2{ 1, 2 };
    const vec2 = h.v2{ 5, 1 };

    try testing.expectEqual(h.V2(5.0, 1.0), vec2);
    try testing.expectEqual(h.V2(1, 2), vec1);

    try testing.expectEqual(h.Add(vec1, vec2), h.v2{ 6, 3 });
    try testing.expectEqual(h.Sub(vec1, vec2), h.v2{ -4, 1 });
    try testing.expectEqual(h.Scale(vec1, -1), h.v2{ -1, -2 });

    try testing.expectEqual(h.Inner(vec1, vec2), 7);
    try testing.expectEqual(h.LengthSq(vec1), 5);
    try testing.expectEqual(h.Length(h.v2{ 4, 3 }), 5);

    h.AddTo(&vec1, vec2);
    try testing.expectEqual(vec1, h.v2{ 6, 3 });
    h.SubFrom(&vec1, vec2);
    try testing.expectEqual(vec1, h.v2{ 1, 2 });

    const c3 = h.v3{ 3, 2, 1 };
    try testing.expectEqual(h.X(c3), c3[0]);
    try testing.expectEqual(h.Y(c3), c3[1]);
    try testing.expectEqual(h.Z(c3), c3[2]);
    try testing.expectEqual(h.R(c3), h.X(c3));
    try testing.expectEqual(h.G(c3), h.Y(c3));
    try testing.expectEqual(h.B(c3), h.Z(c3));

    const c4 = h.v4{ 4, 3, 2, 1 };
    try testing.expectEqual(h.X(c4), c4[0]);
    try testing.expectEqual(h.Y(c4), c4[1]);
    try testing.expectEqual(h.Z(c4), c4[2]);
    try testing.expectEqual(h.W(c4), c4[3]);
    try testing.expectEqual(h.R(c4), h.X(c4));
    try testing.expectEqual(h.G(c4), h.Y(c4));
    try testing.expectEqual(h.B(c4), h.Z(c4));
    try testing.expectEqual(h.A(c4), h.W(c4));
    try testing.expectEqual(h.XY(c4), h.v2{ c4[0], c4[1] });
    try testing.expectEqual(h.XYZ(c4), h.RGB(c4));
    try testing.expectEqual(h.Sub(h.RGB(c4), h.v3{ 1, 1, 1 }), c3);

    try testing.expectEqual(h.Length(h.Normalize(c4)), 1.0); // float precision problems

    try testing.expectEqual(h.rect2.InitMinDim(.{ 3, 2 }, .{ 4, 3 }), h.rect2.InitMinDim(h.XY(c3), h.XY(c4)));

    try testing.expectEqual(h.AddI32ToU32(30, 2), 32);
    try testing.expectEqual(h.AddI32ToU32(32, -30), 2);
    try testing.expectEqual(h.AddI32ToU32(std.math.maxInt(u32), -2147483647), 2147483648);

    // NOTE (Manav): avoid empty array initialization of @Vector, it's the same as using undefined
    const r = h.rect2.InitMinDim(h.v2{ 0, 0 }, h.v2{ 3, 3 });
    const r1 = h.rect2.InitCenterDim(h.v2{ 1.5, 1.5 }, h.v2{ 3, 3 });
    const r2 = h.rect2.InitCenterHalfDim(h.v2{ 1.5, 1.5 }, h.v2{ 1.5, 1.5 });

    try testing.expectEqual(r, r1);
    try testing.expectEqual(r, r2);

    try testing.expectEqual(r1.GetMinCorner(), h.v2{ 0, 0 });
    try testing.expectEqual(r2.GetMaxCorner(), h.v2{ 3, 3 });
    try testing.expectEqual(r.GetCenter(), h.v2{ 1.5, 1.5 });

    try testing.expectEqual(r.IsInRect(h.v2{ 3, 3 }), false);
    try testing.expectEqual(r.IsInRect(h.v2{ 1, 3 }), false);
    try testing.expectEqual(r.IsInRect(h.v2{ 0, 0 }), true);
    try testing.expectEqual(r.IsInRect(h.v2{ 2, 2 }), true);

    try testing.expectEqual(r.AddRadius(h.v2{ 1, 2 }), h.rect2{ .min = h.v2{ -1, -2 }, .max = h.v2{ 4, 5 } });

    const r3 = h.rect3.InitMinDim(h.v3{ 0, 0, 0 }, h.v3{ 3, 3, 3 });
    const r31 = h.rect3.InitCenterDim(h.v3{ 1.5, 1.5, 1.5 }, h.v3{ 3, 3, 3 });
    const r32 = h.rect3.InitCenterHalfDim(h.v3{ 1.5, 1.5, 1.5 }, h.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3, r31);
    try testing.expectEqual(r3, r32);

    try testing.expectEqual(r31.GetMinCorner(), h.v3{ 0, 0, 0 }); // should be h.v3{ 0, 1, 0 }
    try testing.expectEqual(r32.GetMaxCorner(), h.v3{ 3, 3, 3 });
    try testing.expectEqual(r3.GetCenter(), h.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3.IsInRect(h.v3{ 3, 3, 3 }), false);
    try testing.expectEqual(r3.IsInRect(h.v3{ 1, 3, 3 }), false);
    try testing.expectEqual(r3.IsInRect(h.v3{ 0, 0, 0 }), true);
    try testing.expectEqual(r3.IsInRect(h.v3{ 2, 2, 2 }), true);

    try testing.expectEqual(r3.AddRadius(.{ 1, 2, 3 }), h.rect3{ .min = h.v3{ -1, -2, -3 }, .max = h.v3{ 4, 5, 6 } });

    try testing.expectEqual(r3.GetBarycentric(r3.GetCenter()), h.v3{ 0.5, 0.5, 0.5 });
    try testing.expectEqual(r3.GetBarycentric(r3.GetMinCorner()), h.v3{ 0, 0, 0 });
    try testing.expectEqual(r3.GetBarycentric(r3.GetMaxCorner()), h.v3{ 1, 1, 1 });
    try testing.expectEqual(r3.GetBarycentric(.{ 2, 2, 2 }), @as(@Vector(3, f32), @splat(@as(f32, 2.0 / 3.0))));

    try testing.expectEqual(h.ClampV301(.{ 0.2, -0.4, 1.2 }), h.v3{ 0.2, 0, 1 });
}

test "rand" {
    var series = h.RandomSeed(124);

    try testing.expect(series.RandomChoice(2) < 2);
    try testing.expectEqual(series.index, 125);
}

test "handmade_misc" {
    var memRegion = [1]u8{0} ** 1024;

    var mem: h.memory_arena = undefined;
    mem.Initialize(1024, &memRegion);
    try testing.expectEqual(mem.used, 0);

    const x = mem.PushStruct(u8);
    x.* = 24;
    try testing.expectEqual(x.*, @as([*]u8, @ptrFromInt(mem.base_addr))[0]);
    try testing.expectEqual(@intFromPtr(x), mem.base_addr);
    try testing.expectEqual(@as(usize, 1), mem.used);

    var sub_mem: h.memory_arena = undefined;
    sub_mem.SubArena(&mem, @alignOf(u8), 10);
    try testing.expectEqual(sub_mem.base_addr, mem.base_addr + @sizeOf(u8));

    const y = sub_mem.PushArray(u8, sub_mem.size);
    y[0] = 35;
    try testing.expectEqual(y[0], @as([*]u8, @ptrFromInt(sub_mem.base_addr))[0]);
    try testing.expectEqual(sub_mem.used, sub_mem.size);
}

test "simd" {
    const v1: simd.f32x4 = .{ 1.1, 2.2, 3.3, 4.4 };
    const v2: simd.f32x4 = .{ -4.4, -5.5, -6.6, -7.7 };

    const zc1: simd.i32x4 = simd.z._mm_cvtps_epi32(v1);
    const zc2: simd.i32x4 = simd.z._mm_cvtps_epi32(v2);
    const zc3: simd.i32x4 = simd.z._mm_cvttps_epi32(v2);

    const ic1: simd.i32x4 = simd.i._mm_cvtps_epi32(v1);
    const ic2: simd.i32x4 = simd.i._mm_cvtps_epi32(v2);
    const ic3: simd.i32x4 = simd.i._mm_cvttps_epi32(v2);

    try testing.expectEqual(zc1, ic1);
    try testing.expectEqual(zc2, ic2);
    try testing.expectEqual(zc3, ic3);

    try testing.expectEqual(simd.i32x4{ 1, 2, 3, 4 }, zc1);
    try testing.expectEqual(simd.i32x4{ -4, -6, -7, -8 }, ic2);
    try testing.expectEqual(simd.i32x4{ -4, -5, -6, -7 }, ic3);

    const zc1i: simd.f32x4 = simd.z._mm_cvtepi32_ps(zc1);
    const zc2i: simd.f32x4 = simd.z._mm_cvtepi32_ps(zc2);
    const zc3i: simd.f32x4 = simd.z._mm_cvtepi32_ps(zc3);

    const ic1i: simd.f32x4 = simd.i._mm_cvtepi32_ps(ic1);
    const ic2i: simd.f32x4 = simd.i._mm_cvtepi32_ps(ic2);
    const ic3i: simd.f32x4 = simd.i._mm_cvtepi32_ps(ic3);

    try testing.expectEqual(zc1i, ic1i);
    try testing.expectEqual(zc2i, ic2i);
    try testing.expectEqual(zc3i, ic3i);

    try testing.expectEqual(simd.f32x4{ 1, 2, 3, 4 }, zc1i);
    try testing.expectEqual(simd.f32x4{ -4, -6, -7, -8 }, ic2i);
    try testing.expectEqual(simd.f32x4{ -4, -5, -6, -7 }, ic3i);

    const a1: simd.i32x4 = .{ 0x01020304, 0x05060708, 0x090a0b0c, 0x0d0e0f00 };
    const a2: simd.i32x4 = .{
        @as(i32, @bitCast(@as(u32, 0xd0e0f000))),
        @as(i32, @bitCast(@as(u32, 0x90a0b0c0))),
        @as(i32, @bitCast(@as(u32, 0x50607080))),
        @as(i32, @bitCast(@as(u32, 0x10203040))),
    };

    try testing.expectEqual(simd.z._mm_mullo_epi16(a1, a2), simd.i32x4{
        @as(i32, @bitCast(@as(u32, 0x81c0c000))),
        @as(i32, @bitCast(@as(u32, 0x83c0c600))),
        @as(i32, @bitCast(@as(u32, 0x83c0c600))),
        @as(i32, @bitCast(@as(u32, 0x81c0c000))),
    });
    try testing.expectEqual(simd.z._mm_mulhi_epi16(a1, a2), simd.i32x4{
        @as(i32, @bitCast(@as(u32, 0xffd0ffcf))),
        @as(i32, @bitCast(@as(u32, 0xfdd0fdd2))),
        @as(i32, @bitCast(@as(u32, 0x02d604da))),
        @as(i32, @bitCast(@as(u32, 0x00d202d3))),
    });

    try testing.expectEqual(simd.i._mm_mullo_epi16(ic1, ic2), simd.z._mm_mullo_epi16(zc1, zc2));
    try testing.expectEqual(simd.i._mm_mulhi_epi16(ic1, ic2), simd.z._mm_mulhi_epi16(zc1, zc2));

    try testing.expectEqual(simd.i._mm_srli_epi32(ic1, 2), simd.z._mm_srli_epi32(zc1, 2));
    try testing.expectEqual(simd.i._mm_srli_epi32(ic2, 2), simd.z._mm_srli_epi32(zc2, 2));

    // const rsqrtv1 = simd.i._mm_rsqrt_ps(v1);
    // const rsqrtv2 = simd.i._mm_rsqrt_ps(v2);
}

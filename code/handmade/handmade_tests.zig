const std = @import("std");
const testing = std.testing;

const hi = @import("handmade_intrinsics.zig");
const hd = @import("handmade_data.zig");
const hm = @import("handmade_math.zig");
const hr = @import("handmade_random.zig");

const simd = @import("simd");

test "language" {
    try testing.expectEqual(@divTrunc(-10, 21), 0);
    try testing.expectEqual(@divTrunc(-11, 2), -5);
    try testing.expectEqual(@divTrunc(11, -2), -5);
}

test "intrinsics" {
    try testing.expectEqual(hi.AbsoluteValue(-0.2), 0.2);
    try testing.expectEqual(hi.AbsoluteValue(0.2), 0.2);

    try testing.expectEqual(hi.RoundF32ToInt(u32, -0.2), 0);
    try testing.expectEqual(hi.RoundF32ToInt(u32, 0.2), 0);

    try testing.expectEqual(hi.CeilF32ToI32(2.34), 3);
    try testing.expectEqual(hi.CeilF32ToI32(-2.34), -2);

    try testing.expectEqual(hi.TruncateF32ToI32(1.2), 1);
    try testing.expectEqual(hi.TruncateF32ToI32(-0.2), 0);
    try testing.expectEqual(hi.TruncateF32ToI32(-1.2), -1);

    try testing.expectEqual(hi.FloorF32ToI32(1.2), 1);
    try testing.expectEqual(hi.FloorF32ToI32(0.2), 0);
    try testing.expectEqual(hi.FloorF32ToI32(-0.2), -1);

    try testing.expectEqual(hi.FindLeastSignificantSetBit(0b00000010), 1);
    try testing.expectEqual(hi.FindLeastSignificantSetBit(0b01000000), 6);

    // TODO (Manav): add RotateLeft tests when the issue is fixed

    try testing.expectEqual(hi.SquareRoot(0.04), 0.2);
    try testing.expectEqual(hi.SquareRoot(25.0), 5.0);
}

test "math" {
    var vec1 = hm.v2{ 1, 2 };
    const vec2 = hm.v2{ 5, 1 };

    try testing.expectEqual(hm.V2(5.0, 1.0), vec2);
    try testing.expectEqual(hm.V2(1, 2), vec1);

    try testing.expectEqual(hm.Add(vec1, vec2), hm.v2{ 6, 3 });
    try testing.expectEqual(hm.Sub(vec1, vec2), hm.v2{ -4, 1 });
    try testing.expectEqual(hm.Scale(vec1, -1), hm.v2{ -1, -2 });

    try testing.expectEqual(hm.Inner(vec1, vec2), 7);
    try testing.expectEqual(hm.LengthSq(vec1), 5);
    try testing.expectEqual(hm.Length(hm.v2{ 4, 3 }), 5);

    hm.AddTo(&vec1, vec2);
    try testing.expectEqual(vec1, hm.v2{ 6, 3 });
    hm.SubFrom(&vec1, vec2);
    try testing.expectEqual(vec1, hm.v2{ 1, 2 });

    const c3 = hm.v3{ 3, 2, 1 };
    try testing.expectEqual(hm.X(c3), c3[0]);
    try testing.expectEqual(hm.Y(c3), c3[1]);
    try testing.expectEqual(hm.Z(c3), c3[2]);
    try testing.expectEqual(hm.R(c3), hm.X(c3));
    try testing.expectEqual(hm.G(c3), hm.Y(c3));
    try testing.expectEqual(hm.B(c3), hm.Z(c3));

    const c4 = hm.v4{ 4, 3, 2, 1 };
    try testing.expectEqual(hm.X(c4), c4[0]);
    try testing.expectEqual(hm.Y(c4), c4[1]);
    try testing.expectEqual(hm.Z(c4), c4[2]);
    try testing.expectEqual(hm.W(c4), c4[3]);
    try testing.expectEqual(hm.R(c4), hm.X(c4));
    try testing.expectEqual(hm.G(c4), hm.Y(c4));
    try testing.expectEqual(hm.B(c4), hm.Z(c4));
    try testing.expectEqual(hm.A(c4), hm.W(c4));
    try testing.expectEqual(hm.XY(c4), hm.v2{ c4[0], c4[1] });
    try testing.expectEqual(hm.XYZ(c4), hm.RGB(c4));
    try testing.expectEqual(hm.Sub(hm.RGB(c4), hm.v3{ 1, 1, 1 }), c3);

    try testing.expectEqual(hm.Length(hm.Normalize(c4)), 1.0); // float precision problems

    try testing.expectEqual(hm.rect2.InitMinDim(.{ 3, 2 }, .{ 4, 3 }), hm.rect2.InitMinDim(hm.XY(c3), hm.XY(c4)));

    try testing.expectEqual(hm.AddI32ToU32(30, 2), 32);
    try testing.expectEqual(hm.AddI32ToU32(32, -30), 2);
    try testing.expectEqual(hm.AddI32ToU32(std.math.maxInt(u32), -2147483647), 2147483648);

    // NOTE (Manav): avoid empty array initialization of @Vector, it's the same as using undefined
    const r = hm.rect2.InitMinDim(hm.v2{ 0, 0 }, hm.v2{ 3, 3 });
    const r1 = hm.rect2.InitCenterDim(hm.v2{ 1.5, 1.5 }, hm.v2{ 3, 3 });
    const r2 = hm.rect2.InitCenterHalfDim(hm.v2{ 1.5, 1.5 }, hm.v2{ 1.5, 1.5 });

    try testing.expectEqual(r, r1);
    try testing.expectEqual(r, r2);

    try testing.expectEqual(r1.GetMinCorner(), hm.v2{ 0, 0 });
    try testing.expectEqual(r2.GetMaxCorner(), hm.v2{ 3, 3 });
    try testing.expectEqual(r.GetCenter(), hm.v2{ 1.5, 1.5 });

    try testing.expectEqual(r.IsInRect(hm.v2{ 3, 3 }), false);
    try testing.expectEqual(r.IsInRect(hm.v2{ 1, 3 }), false);
    try testing.expectEqual(r.IsInRect(hm.v2{ 0, 0 }), true);
    try testing.expectEqual(r.IsInRect(hm.v2{ 2, 2 }), true);

    try testing.expectEqual(r.AddRadius(hm.v2{ 1, 2 }), hm.rect2{ .min = hm.v2{ -1, -2 }, .max = hm.v2{ 4, 5 } });

    const r3 = hm.rect3.InitMinDim(hm.v3{ 0, 0, 0 }, hm.v3{ 3, 3, 3 });
    const r31 = hm.rect3.InitCenterDim(hm.v3{ 1.5, 1.5, 1.5 }, hm.v3{ 3, 3, 3 });
    const r32 = hm.rect3.InitCenterHalfDim(hm.v3{ 1.5, 1.5, 1.5 }, hm.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3, r31);
    try testing.expectEqual(r3, r32);

    try testing.expectEqual(r31.GetMinCorner(), hm.v3{ 0, 0, 0 }); // should be hm.v3{ 0, 1, 0 }
    try testing.expectEqual(r32.GetMaxCorner(), hm.v3{ 3, 3, 3 });
    try testing.expectEqual(r3.GetCenter(), hm.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3.IsInRect(hm.v3{ 3, 3, 3 }), false);
    try testing.expectEqual(r3.IsInRect(hm.v3{ 1, 3, 3 }), false);
    try testing.expectEqual(r3.IsInRect(hm.v3{ 0, 0, 0 }), true);
    try testing.expectEqual(r3.IsInRect(hm.v3{ 2, 2, 2 }), true);

    try testing.expectEqual(r3.AddRadius(.{ 1, 2, 3 }), hm.rect3{ .min = hm.v3{ -1, -2, -3 }, .max = hm.v3{ 4, 5, 6 } });

    try testing.expectEqual(r3.GetBarycentric(r3.GetCenter()), hm.v3{ 0.5, 0.5, 0.5 });
    try testing.expectEqual(r3.GetBarycentric(r3.GetMinCorner()), hm.v3{ 0, 0, 0 });
    try testing.expectEqual(r3.GetBarycentric(r3.GetMaxCorner()), hm.v3{ 1, 1, 1 });
    try testing.expectEqual(r3.GetBarycentric(.{ 2, 2, 2 }), @as(@Vector(3, f32), @splat(@as(f32, 2.0 / 3.0))));

    try testing.expectEqual(hm.ClampV301(.{ 0.2, -0.4, 1.2 }), hm.v3{ 0.2, 0, 1 });
}

test "rand" {
    var series = hr.RandomSeed(124);

    try testing.expect(series.RandomChoice(2) < 2);
    try testing.expectEqual(series.index, 125);
}

test "handmade_misc" {
    var memRegion = [1]u8{0} ** 1024;

    var mem: hd.memory_arena = undefined;
    mem.Initialize(1024, &memRegion);
    try testing.expectEqual(mem.used, 0);

    const x = mem.PushStruct(u8);
    x.* = 24;
    try testing.expectEqual(x.*, @as([*]u8, @ptrFromInt(mem.base_addr))[0]);
    try testing.expectEqual(@intFromPtr(x), mem.base_addr);
    try testing.expectEqual(@as(usize, 1), mem.used);

    var sub_mem: hd.memory_arena = undefined;
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

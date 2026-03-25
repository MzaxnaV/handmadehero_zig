const std = @import("std");

const h = @import("handmade_all.zig");

const testing = std.testing;

const intrinsics = h.Intrinsics;
const data = h.Data;
const math = h.Math;
const random = h.Random;

test "language" {
    try testing.expectEqual(@divTrunc(-10, 21), 0);
    try testing.expectEqual(@divTrunc(-11, 2), -5);
    try testing.expectEqual(@divTrunc(11, -2), -5);

    // Little endian
    try testing.expectEqual(@as(u32, 0xaabbccdd), @as(u32, @bitCast([4]u8{ 0xdd, 0xcc, 0xbb, 0xaa })));
}

test "intrinsics" {
    try testing.expectEqual(intrinsics.AbsoluteValue(-0.2), 0.2);
    try testing.expectEqual(intrinsics.AbsoluteValue(0.2), 0.2);

    try testing.expectEqual(intrinsics.RoundF32ToInt(u32, -0.2), 0);
    try testing.expectEqual(intrinsics.RoundF32ToInt(u32, 0.2), 0);

    try testing.expectEqual(intrinsics.CeilF32ToI32(2.34), 3);
    try testing.expectEqual(intrinsics.CeilF32ToI32(-2.34), -2);

    try testing.expectEqual(intrinsics.TruncateF32ToI32(1.2), 1);
    try testing.expectEqual(intrinsics.TruncateF32ToI32(-0.2), 0);
    try testing.expectEqual(intrinsics.TruncateF32ToI32(-1.2), -1);

    try testing.expectEqual(intrinsics.FloorF32ToI32(1.2), 1);
    try testing.expectEqual(intrinsics.FloorF32ToI32(0.2), 0);
    try testing.expectEqual(intrinsics.FloorF32ToI32(-0.2), -1);

    var r = intrinsics.FindLeastSignificantSetBit(0b00000010);
    try testing.expect(r.found);
    try testing.expectEqual(@as(u32, 1), r.index);

    r = intrinsics.FindLeastSignificantSetBit(0b01000000);
    try testing.expect(r.found);
    try testing.expectEqual(@as(u32, 6), r.index);

    try testing.expect(!intrinsics.FindLeastSignificantSetBit(0).found);

    // TODO (Manav): add RotateLeft tests when the issue is fixed

    try testing.expectEqual(intrinsics.SquareRoot(0.04), 0.2);
    try testing.expectEqual(intrinsics.SquareRoot(25.0), 5.0);
}

test "math" {
    var vec1 = math.v2{ 1, 2 };
    const vec2 = math.v2{ 5, 1 };

    try testing.expectEqual(math.V2(5.0, 1.0), vec2);
    try testing.expectEqual(math.V2(1, 2), vec1);

    try testing.expectEqual(math.Add(vec1, vec2), math.v2{ 6, 3 });
    try testing.expectEqual(math.Sub(vec1, vec2), math.v2{ -4, 1 });
    try testing.expectEqual(math.Scale(vec1, -1), math.v2{ -1, -2 });

    try testing.expectEqual(math.Inner(vec1, vec2), 7);
    try testing.expectEqual(math.LengthSq(vec1), 5);
    try testing.expectEqual(math.Length(math.v2{ 4, 3 }), 5);

    math.AddTo(&vec1, vec2);
    try testing.expectEqual(vec1, math.v2{ 6, 3 });
    math.SubFrom(&vec1, vec2);
    try testing.expectEqual(vec1, math.v2{ 1, 2 });

    const c3 = math.v3{ 3, 2, 1 };
    try testing.expectEqual(math.X(c3), c3[0]);
    try testing.expectEqual(math.Y(c3), c3[1]);
    try testing.expectEqual(math.Z(c3), c3[2]);
    try testing.expectEqual(math.R(c3), math.X(c3));
    try testing.expectEqual(math.G(c3), math.Y(c3));
    try testing.expectEqual(math.B(c3), math.Z(c3));

    const c4 = math.v4{ 4, 3, 2, 1 };
    try testing.expectEqual(math.X(c4), c4[0]);
    try testing.expectEqual(math.Y(c4), c4[1]);
    try testing.expectEqual(math.Z(c4), c4[2]);
    try testing.expectEqual(math.W(c4), c4[3]);
    try testing.expectEqual(math.R(c4), math.X(c4));
    try testing.expectEqual(math.G(c4), math.Y(c4));
    try testing.expectEqual(math.B(c4), math.Z(c4));
    try testing.expectEqual(math.A(c4), math.W(c4));
    try testing.expectEqual(math.XY(c4), math.v2{ c4[0], c4[1] });
    try testing.expectEqual(math.XYZ(c4), math.RGB(c4));
    try testing.expectEqual(math.Sub(math.RGB(c4), math.v3{ 1, 1, 1 }), c3);

    var c4v = c4;

    math.SetX(&c4v, 9);
    try testing.expectEqual(c4v, math.v4{ 9, math.Y(c4v), math.Z(c4v), math.W(c4v) });
    math.SetY(&c4v, 8);
    try testing.expectEqual(c4v, math.v4{ math.X(c4v), 8, math.Z(c4v), math.W(c4v) });
    math.SetZ(&c4v, 7);
    try testing.expectEqual(c4v, math.v4{ math.X(c4v), math.Y(c4v), 7, math.W(c4v) });
    math.SetW(&c4v, 6);
    try testing.expectEqual(c4v, math.v4{ math.X(c4v), math.Y(c4v), math.Z(c4v), 6 });

    try testing.expectEqual(math.Length(math.Normalize(c4)), 1.0); // float precision problems

    try testing.expectEqual(math.rect2.InitMinDim(.{ 3, 2 }, .{ 4, 3 }), math.rect2.InitMinDim(math.XY(c3), math.XY(c4)));

    try testing.expectEqual(math.AddI32ToU32(30, 2), 32);
    try testing.expectEqual(math.AddI32ToU32(32, -30), 2);
    try testing.expectEqual(math.AddI32ToU32(std.math.maxInt(u32), -2147483647), 2147483648);

    // NOTE (Manav): avoid empty array initialization of @Vector, it's the same as using undefined
    const r = math.rect2.InitMinDim(math.v2{ 0, 0 }, math.v2{ 3, 3 });
    const r1 = math.rect2.InitCenterDim(math.v2{ 1.5, 1.5 }, math.v2{ 3, 3 });
    const r2 = math.rect2.InitCenterHalfDim(math.v2{ 1.5, 1.5 }, math.v2{ 1.5, 1.5 });

    try testing.expectEqual(r, r1);
    try testing.expectEqual(r, r2);

    try testing.expectEqual(r1.GetMinCorner(), math.v2{ 0, 0 });
    try testing.expectEqual(r2.GetMaxCorner(), math.v2{ 3, 3 });
    try testing.expectEqual(r.GetCenter(), math.v2{ 1.5, 1.5 });

    try testing.expectEqual(r.IsInRect(math.v2{ 3, 3 }), false);
    try testing.expectEqual(r.IsInRect(math.v2{ 1, 3 }), false);
    try testing.expectEqual(r.IsInRect(math.v2{ 0, 0 }), true);
    try testing.expectEqual(r.IsInRect(math.v2{ 2, 2 }), true);

    try testing.expectEqual(r.AddRadius(math.v2{ 1, 2 }), math.rect2{ .min = math.v2{ -1, -2 }, .max = math.v2{ 4, 5 } });

    const r3 = math.rect3.InitMinDim(math.v3{ 0, 0, 0 }, math.v3{ 3, 3, 3 });
    const r31 = math.rect3.InitCenterDim(math.v3{ 1.5, 1.5, 1.5 }, math.v3{ 3, 3, 3 });
    const r32 = math.rect3.InitCenterHalfDim(math.v3{ 1.5, 1.5, 1.5 }, math.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3, r31);
    try testing.expectEqual(r3, r32);

    try testing.expectEqual(r31.GetMinCorner(), math.v3{ 0, 0, 0 }); // should be math.v3{ 0, 1, 0 }
    try testing.expectEqual(r32.GetMaxCorner(), math.v3{ 3, 3, 3 });
    try testing.expectEqual(r3.GetCenter(), math.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3.IsInRect(math.v3{ 3, 3, 3 }), false);
    try testing.expectEqual(r3.IsInRect(math.v3{ 1, 3, 3 }), false);
    try testing.expectEqual(r3.IsInRect(math.v3{ 0, 0, 0 }), true);
    try testing.expectEqual(r3.IsInRect(math.v3{ 2, 2, 2 }), true);

    try testing.expectEqual(r3.AddRadius(.{ 1, 2, 3 }), math.rect3{ .min = math.v3{ -1, -2, -3 }, .max = math.v3{ 4, 5, 6 } });

    try testing.expectEqual(r3.GetBarycentric(r3.GetCenter()), math.v3{ 0.5, 0.5, 0.5 });
    try testing.expectEqual(r3.GetBarycentric(r3.GetMinCorner()), math.v3{ 0, 0, 0 });
    try testing.expectEqual(r3.GetBarycentric(r3.GetMaxCorner()), math.v3{ 1, 1, 1 });
    try testing.expectEqual(r3.GetBarycentric(.{ 2, 2, 2 }), @as(@Vector(3, f32), @splat(@as(f32, 2.0 / 3.0))));

    try testing.expectEqual(math.ClampV301(.{ 0.2, -0.4, 1.2 }), math.v3{ 0.2, 0, 1 });
}

test "rand" {
    var series = random.RandomSeed(124);

    try testing.expect(series.RandomChoice(2) < 2);
    try testing.expectEqual(series.index, 125);
}

test "handmade_misc" {
    var memRegion = [1]u8{0} ** 1024;

    var mem: data.memory_arena = undefined;
    mem.Initialize(1024, &memRegion);
    try testing.expectEqual(mem.used, 0);

    const x = mem.PushStruct(u8);
    x.* = 24;
    try testing.expectEqual(x.*, @as([*]u8, @ptrFromInt(mem.base_addr))[0]);
    try testing.expectEqual(@intFromPtr(x), mem.base_addr);
    try testing.expectEqual(@as(usize, 1), mem.used);

    var sub_mem: data.memory_arena = undefined;
    sub_mem.SubArena(&mem, @alignOf(u8), 10);
    try testing.expectEqual(sub_mem.base_addr, mem.base_addr + @sizeOf(u8));

    const y = sub_mem.PushArray(u8, sub_mem.size);
    y[0] = 35;
    try testing.expectEqual(y[0], @as([*]u8, @ptrFromInt(sub_mem.base_addr))[0]);
    try testing.expectEqual(sub_mem.used, sub_mem.size);

    const str1 = "hello world";
    const str2 = mem.PushString(str1);

    try testing.expectEqualStrings(str1[0..12], str2[0..12]);
    try testing.expectEqualSentinel(u8, 0, str1, str2[0..11 :0]);
}

test "simd" {
    {
        const v1 = intrinsics.f32x4{ 0.1, 1.4, 2.5, 3.6 };
        const v2 = intrinsics.f32x4{ -0.1, -1.4, -2.5, -3.6 };

        // _mm_cvtps_epi32
        const ic1: intrinsics.i32x4 = intrinsics.i._mm_cvtps_epi32(v1);
        const ic2: intrinsics.i32x4 = intrinsics.i._mm_cvtps_epi32(v2);
        try testing.expectEqual(intrinsics.i32x4{ 0, 1, 2, 4 }, ic1);
        try testing.expectEqual(intrinsics.i32x4{ 0, -1, -2, -4 }, ic2);

        // _mm_cvttps_epi32
        const ic3: intrinsics.i32x4 = intrinsics.i._mm_cvttps_epi32(v1);
        const ic4: intrinsics.i32x4 = intrinsics.i._mm_cvttps_epi32(v2);
        try testing.expectEqual(intrinsics.i32x4{ 0, 1, 2, 3 }, ic3);
        try testing.expectEqual(intrinsics.i32x4{ 0, -1, -2, -3 }, ic4);

        const zc3: intrinsics.i32x4 = intrinsics.z._mm_cvttps_epi32(v1);
        const zc4: intrinsics.i32x4 = intrinsics.z._mm_cvttps_epi32(v2);
        try testing.expectEqual(ic3, zc3);
        try testing.expectEqual(ic4, zc4);

        // _mm_cvtepi32_ps
        const ic3i: intrinsics.f32x4 = intrinsics.i._mm_cvtepi32_ps(ic3);
        const ic4i: intrinsics.f32x4 = intrinsics.i._mm_cvtepi32_ps(ic4);
        try testing.expectEqual(intrinsics.f32x4{ 0, 1, 2, 3 }, ic3i);
        try testing.expectEqual(intrinsics.f32x4{ 0, -1, -2, -3 }, ic4i);

        const zc3i: intrinsics.f32x4 = intrinsics.z._mm_cvtepi32_ps(zc3);
        const zc4i: intrinsics.f32x4 = intrinsics.z._mm_cvtepi32_ps(zc4);
        try testing.expectEqual(ic3i, zc3i);
        try testing.expectEqual(ic4i, zc4i);

        // __mm_srli_epi32
        try testing.expectEqual(intrinsics.i._mm_srli_epi32(ic3, 2), intrinsics.z._mm_srli_epi32(zc3, 2));
        try testing.expectEqual(intrinsics.i._mm_srli_epi32(ic4, 2), intrinsics.z._mm_srli_epi32(zc4, 2));
    }

    {
        const v1 = intrinsics.i32x4{ 0x01020304, 0x05060708, 0x090a0b0c, 0x0d0e0f00 };
        const v2 = intrinsics.i32x4{
            @as(i32, @bitCast(@as(u32, 0xd0e0f000))),
            @as(i32, @bitCast(@as(u32, 0x90a0b0c0))),
            @as(i32, @bitCast(@as(u32, 0x50607080))),
            @as(i32, @bitCast(@as(u32, 0x10203040))),
        };

        // _mm_mullo_epi16
        try testing.expectEqual(intrinsics.i32x4{
            @as(i32, @bitCast(@as(u32, 0x81c0c000))),
            @as(i32, @bitCast(@as(u32, 0x83c0c600))),
            @as(i32, @bitCast(@as(u32, 0x83c0c600))),
            @as(i32, @bitCast(@as(u32, 0x81c0c000))),
        }, intrinsics.i._mm_mullo_epi16(v1, v2));
        try testing.expectEqual(intrinsics.i._mm_mullo_epi16(v1, v2), intrinsics.z._mm_mullo_epi16(v1, v2));

        // _mm_mulhi_epi16
        try testing.expectEqual(intrinsics.i32x4{
            @as(i32, @bitCast(@as(u32, 0xffd0ffcf))),
            @as(i32, @bitCast(@as(u32, 0xfdd0fdd2))),
            @as(i32, @bitCast(@as(u32, 0x02d604da))),
            @as(i32, @bitCast(@as(u32, 0x00d202d3))),
        }, intrinsics.i._mm_mulhi_epi16(v1, v2));
        try testing.expectEqual(intrinsics.i._mm_mulhi_epi16(v1, v2), intrinsics.z._mm_mulhi_epi16(v1, v2));
    }

    {
        const v1 = intrinsics.i32x4{ 0x64, -0x64, std.math.maxInt(i16), std.math.minInt(i16) };
        const v2 = intrinsics.i32x4{ 0xc350, -0xc350, std.math.maxInt(i32), std.math.minInt(i32) };

        // ___mm_packs_epi32
        try testing.expectEqual(intrinsics.i16x8{
            @as(i16, @bitCast(@as(u16, 0x0064))),
            @as(i16, @bitCast(@as(u16, 0xff9c))), // -0x0064
            @as(i16, @bitCast(@as(u16, 0x7fff))),
            @as(i16, @bitCast(@as(u16, 0x8000))),
            @as(i16, @bitCast(@as(u16, 0x7fff))),
            @as(i16, @bitCast(@as(u16, 0x8000))),
            @as(i16, @bitCast(@as(u16, 0x7fff))),
            @as(i16, @bitCast(@as(u16, 0x8000))),
        }, intrinsics.i._mm_packs_epi32(v1, v2));
    }

    // const rsqrtv1 = intrinsics.i._mm_rsqrt_ps(v1);
    // const rsqrtv2 = intrinsics.i._mm_rsqrt_ps(v2);
}

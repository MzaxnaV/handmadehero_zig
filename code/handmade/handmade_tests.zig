const std = @import("std");
const testing = std.testing;

const intrinsics = @import("handmade_intrinsics.zig");
const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");
const hr = @import("handmade_random.zig");

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

    try testing.expectEqual(intrinsics.FindLeastSignificantSetBit(0b00000010), 1);
    try testing.expectEqual(intrinsics.FindLeastSignificantSetBit(0b01000000), 6);

    // TODO (Manav): add RotateLeft tests when the issue is fixed

    try testing.expectEqual(intrinsics.SquareRoot(0.04), 0.2);
    try testing.expectEqual(intrinsics.SquareRoot(25.0), 5.0);
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

    try testing.expectEqual(hm.IsInRect2(r, hm.v2{ 3, 3 }), false);
    try testing.expectEqual(hm.IsInRect2(r, hm.v2{ 1, 3 }), false);
    try testing.expectEqual(hm.IsInRect2(r, hm.v2{ 0, 0 }), true);
    try testing.expectEqual(hm.IsInRect2(r, hm.v2{ 2, 2 }), true);

    try testing.expectEqual(hm.AddRadiusToRect2(r, hm.v2{ 1, 2 }), hm.rect2{ .min = hm.v2{ -1, -2 }, .max = hm.v2{ 4, 5 } });

    const r3 = hm.rect3.InitMinDim(hm.v3{ 0, 0, 0 }, hm.v3{ 3, 3, 3 });
    const r31 = hm.rect3.InitCenterDim(hm.v3{ 1.5, 1.5, 1.5 }, hm.v3{ 3, 3, 3 });
    const r32 = hm.rect3.InitCenterHalfDim(hm.v3{ 1.5, 1.5, 1.5 }, hm.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3, r31);
    try testing.expectEqual(r3, r32);

    try testing.expectEqual(r31.GetMinCorner(), hm.v3{ 0, 0, 0 });
    try testing.expectEqual(r32.GetMaxCorner(), hm.v3{ 3, 3, 3 });
    try testing.expectEqual(r3.GetCenter(), hm.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(hm.IsInRect3(r3, hm.v3{ 3, 3, 3 }), false);
    try testing.expectEqual(hm.IsInRect3(r3, hm.v3{ 1, 3, 3 }), false);
    try testing.expectEqual(hm.IsInRect3(r3, hm.v3{ 0, 0, 0 }), true);
    try testing.expectEqual(hm.IsInRect3(r3, hm.v3{ 2, 2, 2 }), true);

    try testing.expectEqual(hm.AddRadiusToRect3(r3, .{ 1, 2, 3 }), hm.rect3{ .min = hm.v3{ -1, -2, -3 }, .max = hm.v3{ 4, 5, 6 } });

    try testing.expectEqual(hm.GetBarycentricV3(r3, r3.GetCenter()), hm.v3{ 0.5, 0.5, 0.5 });
    try testing.expectEqual(hm.GetBarycentricV3(r3, r3.GetMinCorner()), hm.v3{ 0, 0, 0 });
    try testing.expectEqual(hm.GetBarycentricV3(r3, r3.GetMaxCorner()), hm.v3{ 1, 1, 1 });
    try testing.expectEqual(hm.GetBarycentricV3(r3, .{ 2, 2, 2 }), @splat(3, @as(f32, 2.0 / 3.0)));

    try testing.expectEqual(hm.ClampV301(.{ 0.2, -0.4, 1.2 }), hm.v3{ 0.2, 0, 1 });
}

test "rand" {
    var series = hr.RandomSeed(124);

    try testing.expect(series.RandomChoice(2) < 2);
    try testing.expectEqual(series.index, 125);
}

test "handmade_misc" {
    var memRegion = [1]u8{0} ** 1024;

    var mem: hi.memory_arena = undefined;
    mem.Initialize(1024, &memRegion);
    try testing.expectEqual(mem.used, 0);

    const x = mem.PushStruct(u8);
    x.* = 24;
    try testing.expectEqual(x.*, @intToPtr([*]u8, mem.base_addr)[0]);
    try testing.expectEqual(@as(usize, 1), mem.used);
}

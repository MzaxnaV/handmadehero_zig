const std = @import("std");
const testing = std.testing;

const intrinsics = @import("handmade_intrinsics.zig");
const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");

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

    try testing.expectEqual(vec1 + vec2, hm.v2{ 6, 3 });
    try testing.expectEqual(vec1 - vec2, hm.v2{ -4, 1 });
    try testing.expectEqual(-vec1, hm.v2{ -1, -2 });

    try testing.expectEqual(hm.Inner(2, vec1, vec2), 7);
    try testing.expectEqual(hm.LengthSq(2, vec1), 5);
    try testing.expectEqual(hm.Length(2, hm.v2{ 4, 3 }), 5);

    const c3 = hm.v3{ 3, 2, 1 };
    try testing.expectEqual(hm.X(3, c3), c3[0]);
    try testing.expectEqual(hm.Y(3, c3), c3[1]);
    try testing.expectEqual(hm.Z(3, c3), c3[2]);
    try testing.expectEqual(hm.R(3, c3), hm.X(3, c3));
    try testing.expectEqual(hm.G(3, c3), hm.Y(3, c3));
    try testing.expectEqual(hm.B(3, c3), hm.Z(3, c3));

    const c4 = hm.v4{ 4, 3, 2, 1 };
    try testing.expectEqual(hm.X(4, c4), c4[0]);
    try testing.expectEqual(hm.Y(4, c4), c4[1]);
    try testing.expectEqual(hm.Z(4, c4), c4[2]);
    try testing.expectEqual(hm.W(4, c4), c4[3]);
    try testing.expectEqual(hm.R(4, c4), hm.X(4, c4));
    try testing.expectEqual(hm.G(4, c4), hm.Y(4, c4));
    try testing.expectEqual(hm.B(4, c4), hm.Z(4, c4));
    try testing.expectEqual(hm.A(4, c4), hm.W(4, c4));

    try testing.expectEqual(hm.AddI32ToU32(30, 2), 32);
    try testing.expectEqual(hm.AddI32ToU32(32, -30), 2);
    try testing.expectEqual(hm.AddI32ToU32(std.math.maxInt(u32), -2147483647), 2147483648);

    // NOTE (Manav): avoid emoty array initialization of @Vector, it's the same as using undefined
    const r = hm.rect2.InitMinDim(.{ 0, 0 }, .{ 3, 3 });
    const r1 = hm.rect2.InitCenterDim(.{ 1.5, 1.5 }, .{ 3, 3 });
    const r2 = hm.rect2.InitCenterHalfDim(.{ 1.5, 1.5 }, .{ 1.5, 1.5 });

    try testing.expectEqual(r, r1);
    try testing.expectEqual(r, r2);

    try testing.expectEqual(r1.GetMinCorner(), hm.v2{ 0, 0 });
    try testing.expectEqual(r2.GetMaxCorner(), hm.v2{ 3, 3 });
    try testing.expectEqual(r.GetCenter(), hm.v2{ 1.5, 1.5 });

    try testing.expectEqual(hm.IsInRect2(r, .{ 3, 3 }), false);
    try testing.expectEqual(hm.IsInRect2(r, .{ 1, 3 }), false);
    try testing.expectEqual(hm.IsInRect2(r, .{ 0, 0 }), true);
    try testing.expectEqual(hm.IsInRect2(r, .{ 2, 2 }), true);

    try testing.expectEqual(hm.AddRadiusToRect2(r, .{ 1, 2 }), hm.rect2{ .min = .{ -1, -2 }, .max = .{ 4, 5 } });

    const r3 = hm.rect3.InitMinDim(.{ 0, 0, 0 }, .{ 3, 3, 3 });
    const r31 = hm.rect3.InitCenterDim(.{ 1.5, 1.5, 1.5 }, .{ 3, 3, 3 });
    const r32 = hm.rect3.InitCenterHalfDim(.{ 1.5, 1.5, 1.5 }, .{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(r3, r31);
    try testing.expectEqual(r3, r32);

    try testing.expectEqual(r31.GetMinCorner(), hm.v3{ 0, 0, 0 });
    try testing.expectEqual(r32.GetMaxCorner(), hm.v3{ 3, 3, 3 });
    try testing.expectEqual(r3.GetCenter(), hm.v3{ 1.5, 1.5, 1.5 });

    try testing.expectEqual(hm.IsInRect3(r3, .{ 3, 3, 3 }), false);
    try testing.expectEqual(hm.IsInRect3(r3, .{ 1, 3, 3 }), false);
    try testing.expectEqual(hm.IsInRect3(r3, .{ 0, 0, 0 }), true);
    try testing.expectEqual(hm.IsInRect3(r3, .{ 2, 2, 2 }), true);

    try testing.expectEqual(hm.AddRadiusToRect3(r3, .{ 1, 2, 3 }), hm.rect3{ .min = .{ -1, -2, -3 }, .max = .{ 4, 5, 6 } });
}

test "misc_language" {
    var memRegion = [1]u8{0} ** 1024;

    var mem: hi.memory_arena = undefined;
    mem.Initialize(1024, &memRegion);
    try testing.expectEqual(mem.used, 0);

    const x = mem.PushStruct(u8);
    x.* = 24;
    try testing.expectEqual(x.*, mem.base[0]);
    try testing.expectEqual(@as(usize, 1), mem.used);
}

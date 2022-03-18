const std = @import("std");
const testing = std.testing;

const intrinsics = @import("handmade_intrinsics.zig");
const math = @import("handmade_math.zig");

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
    var vec1 = math.v2{ .x = 1, .y = 2 };
    const vec2 = math.v2{ .x = 5, .y = 1 };

    try testing.expectEqual(math.Add(vec1, vec2), .{ .x = 6, .y = 3 });
    try testing.expectEqual(math.Sub(vec1, vec2), .{ .x = -4, .y = 1 });
    try testing.expectEqual(math.Neg(vec1), .{ .x = -1, .y = -2 });
    try testing.expectEqual(math.Scale(vec1, 2), .{ .x = 2, .y = 4 });

    try testing.expectEqual(math.Inner(vec1, vec2), 7);

    try testing.expectEqual(math.Add(vec1, vec2), vec1.Add(vec2).*);
    try testing.expectEqual(math.Sub(vec1, vec2), vec1.Sub(vec2).*);
    try testing.expectEqual(math.Neg(vec1), vec1.Neg().*);
    try testing.expectEqual(math.Scale(vec1, 2), vec1.Scale(2).*);

    try testing.expectEqual(math.AddI32ToU32(30, 2), 32);
    try testing.expectEqual(math.AddI32ToU32(32, -30), 2);
    try testing.expectEqual(math.AddI32ToU32(std.math.maxInt(u32), -2147483647), 2147483648);

    const r = math.rect2.InitMinDim(.{}, .{ .x = 3, .y = 3 });

    try testing.expectEqual(math.IsInRectangle(r, .{ .x = 3, .y = 3 }), false);
    try testing.expectEqual(math.IsInRectangle(r, .{ .x = 1, .y = 3 }), false);
    try testing.expectEqual(math.IsInRectangle(r, math.v2{}), true);
    try testing.expectEqual(math.IsInRectangle(r, .{ .x = 2, .y = 2 }), true);

    const c3 = math.v3{ .e = [_]f32{ 3, 2, 1 } };
    try testing.expectEqual(c3.c.g, c3.e[1]);
    try testing.expectEqual(c3.c.g, c3.p.y);

    const c4 = math.v4{ .e = [_]f32{ 1, 2, 3, 4 } };
    try testing.expectEqual(c4.c.g, c4.e[1]);
    try testing.expectEqual(c4.c.g, c4.p.y);
}

const print = @import("std").debug.print;
const testing = @import("std").testing;
const handmade_math = @import("handmade_math.zig");

test "handmade_math" {
    const v2 = handmade_math.v2;
    const add = handmade_math.add;
    const sub = handmade_math.sub;
    const neg = handmade_math.neg;
    const scale = handmade_math.scale;

    var vec1 = v2{ .x = 1, .y = 2 };
    const vec2 = v2{ .x = 5, .y = 0 };

    try testing.expectEqual(add(vec1, vec2).x, 6);
    try testing.expectEqual(add(vec1, vec2).y, 2);

    try testing.expectEqual(sub(vec1, vec2).x, -4);
    try testing.expectEqual(sub(vec1, vec2).y, 2);

    try testing.expectEqual(neg(vec1).x, -1);
    try testing.expectEqual(neg(vec1).y, -2);

    try testing.expectEqual(scale(vec1, 2).x, 2);
    try testing.expectEqual(scale(vec1, 2).y, 4);

    try testing.expectEqual(add(vec1, vec2), vec1.add(vec2).*);
    try testing.expectEqual(sub(vec1, vec2), vec1.sub(vec2).*);
    try testing.expectEqual(neg(vec1), vec1.neg().*);
    try testing.expectEqual(scale(vec1, 2), vec1.scale(2).*);
}

const std = @import("std");
const math = std.math;

// intrinsics -----------------------------------------------------------------------------------------------------------------------------

pub inline fn SignOf(value: i32) i32 {
    const result = if (value >= 0) @as(i32, 1) else @as(i32, -1);
    return result;
}

pub inline fn SquareRoot(float32: f32) f32 {
    const result = if (float32 > 0) @sqrt(float32) else blk: {
        break :blk 0;
    };
    return result;
}

pub inline fn AbsoluteValue(float32: f32) f32 {
    const result = @fabs(float32);
    return result;
}

pub inline fn RotateLeft(value: u32, amount: i8) u32 {

    // NOTE (Manav): this is hacky atm
    // const amt: u5 = 31 & @truncate(u5, @bitCast(u8, amount));
    // const result = (value << amt) | (value >> @truncate(u5, 32 - @as(u6, amt)));

    const result = math.rotl(u32, value, amount);

    // NOTE (Manav): Inline asm below is buggy, doesn't work with inlining calls
    // const result = asm ("rol %%cl, %[val]"
    //     : [ret] "=r" (-> u32),
    //     : [val] "r" (value),
    //       [amount] "{cl}" (amount),
    // );

    return result;
}

pub inline fn RotateRight(value: u32, amount: i8) u32 {

    // NOTE (Manav): this is hacky atm
    // const amt: u5 = 31 & @truncate(u5, @bitCast(u8, amount));
    // const result = (value >> amt) | (value << @truncate(u5, 32 - @as(u6, amt)));

    const result = math.rotr(u32, value, amount);
    return result;
}

pub inline fn RoundF32ToInt(comptime T: type, float32: f32) T {
    const result: T = @intFromFloat(math.round(float32)); // use @round()?
    return result;
}

pub inline fn CeilF32ToI32(float32: f32) i32 {
    const result: i32 = @intFromFloat(@ceil(float32));
    return result;
}

pub inline fn TruncateF32ToI32(float32: f32) i32 {
    const result: i32 = @intFromFloat(float32);
    return result;
}

pub inline fn FloorF32ToI32(float32: f32) i32 {
    const result: i32 = @intFromFloat(@floor(float32));
    return result;
}

pub inline fn Sin(angle: f32) f32 {
    const result = @sin(angle);
    return result;
}

pub inline fn Cos(angle: f32) f32 {
    const result = @cos(angle);
    return result;
}

pub inline fn Atan2(y: f32, x: f32) f32 {
    const result = math.atan2(y, x);
    return result;
}

// NOTE (Manav): Read this. https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=_BitScanForward&expand=375&ig_expand=465,5629,463
pub inline fn FindLeastSignificantSetBit(value: u32) u32 {
    const result = asm ("bsf %[val], %[ret]"
        : [ret] "=r" (-> u32),
        : [val] "rm" (value),
    );

    return result;
}

/// Performs a strong atomic compare exchange operation. It's the equivalent of this code, except atomic:
///
/// ```
/// fn CompareExchange(comptime T: type, ptr: *T, expected_value: T, new_value: T) ?T {
///    const old_value = ptr.*;
///    if (old_value == expected_value) {
///        ptr.* = new_value;
///        return old_value;
///    } else {
///        return null;
///    }
/// }
/// ```
pub inline fn AtomicCompareExchange(comptime T: type, ptr: *T, expected_value: T, new_value: T) ?T {
    return if (@cmpxchgStrong(T, ptr, expected_value, new_value, .SeqCst, .SeqCst)) |_| expected_value else null;
}

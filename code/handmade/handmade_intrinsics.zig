const math = @import("std").math;

// intrinsics -----------------------------------------------------------------------------------------------------------------------------

pub inline fn SignOf(value: i32) i32 {
    const result = if (value >= 0) @as(i32, 1) else @as(i32, -1);
    return result;
}

pub inline fn SquareRoot(float32: f32) f32 {
    const result = @sqrt(float32);
    return result;
}

pub inline fn AbsoluteValue(float32: f32) f32 {
    const result = @fabs(float32);
    return result;
}

pub inline fn RotateLeft(value: u32, amount: i8) u32 {
    const result = math.rotl(u32, value, amount);

    // NOTE (Manav): Inline asm below is buggy, doesn't work with inlining calls
    // const result = asm ("rol %[amt], %[val]"
    //     : [ret] "=r" (-> u32),
    //     : [val] "r" (value),
    //       [amt] "{cl}" (amount),
    // );

    return result;
}

pub inline fn RotateRight(value: u32, amount: i8) u32 {
    const result = math.rotr(u32, value, amount);
    return result;
}

pub inline fn RoundF32ToInt(comptime T: type, float32: f32) T {
    const result = @floatToInt(T, math.round(float32)); // use @round()?
    return result;
}

pub inline fn CeilF32ToI32(float32: f32) i32 {
    const result = @floatToInt(i32, @ceil(float32));
    return result;
}

pub inline fn TruncateF32ToI32(float32: f32) i32 {
    const result = @floatToInt(i32, float32);
    return result;
}

pub inline fn FloorF32ToI32(float32: f32) i32 {
    const result = @floatToInt(i32, @floor(float32));
    return result;
}

pub inline fn sin(angle: f32) f32 {
    const result = @sin(angle);
    return result;
}

pub inline fn cos(angle: f32) f32 {
    const result = @cos(angle);
    return result;
}

pub inline fn atan2(y: f32, x: f32) f32 {
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

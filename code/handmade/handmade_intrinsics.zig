const math = @import("std").math;

// intrinsics -----------------------------------------------------------------------------------------------------------------------------

pub inline fn RoundF32ToInt(comptime T: type, float32: f32) T {
    const result = @floatToInt(T, math.round(float32)); // use @round()?
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

// NOTE: (Manav) Read this. https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=_BitScanForward&expand=375&ig_expand=465,5629,463
pub inline fn FindLeastSignificantSetBit(value: u32) u32 {
    return asm ("bsf %[value], %[ret]"
        : [ret] "=r" (-> u32),
        : [value] "rm" (value),
    );
}

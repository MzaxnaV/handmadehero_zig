const math = @import("std").math;

const platform = @import("handmade_platform");

// constants ------------------------------------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------

pub const f64x2 = @Vector(2, f64);
pub const i64x2 = @Vector(2, i64);
pub const u64x2 = @Vector(2, u64);

pub const f32x4 = @Vector(4, f32);
pub const i32x4 = @Vector(4, i32);
pub const u32x4 = @Vector(4, u32);

pub const f16x8 = @Vector(8, f16);
pub const i16x8 = @Vector(8, i16);
pub const u16x8 = @Vector(8, u16);

pub const i8x16 = @Vector(16, i8);
pub const u8x16 = @Vector(16, u8);

pub const u1x4 = @Vector(4, u1);
pub const bx4 = @Vector(4, bool);

const maxInt = math.maxInt(i16);
const minInt = math.minInt(i16);

// functions ------------------------------------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------

pub inline fn SignOf(comptime T: type, value: T) T {
    const result = if (value >= 0) @as(T, 1) else @as(T, -1);
    return result;
}

pub inline fn SquareRoot(float32: f32) f32 {
    const result = if (float32 > 0) @sqrt(float32) else blk: {
        break :blk 0;
    };
    return result;
}

pub inline fn AbsoluteValue(float32: f32) f32 {
    const result = @abs(float32);
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

pub const __rdtsc = platform.__rdtsc;

/// Performs a strong atomic compare exchange operation. It's the equivalent of this code, except atomic:
///
/// ```
/// fn CompareExchange(comptime T: type, ptr: *T, new_value: T, expected_value: T) ?T {
///     const old_value = ptr.*;
///     if (old_value == expected_value) {
///         ptr.* = new_value;
///         return null;        // successful exchange
///     } else {
///         return old_value;   // otherwise
///     }
/// }
/// ```
pub inline fn AtomicCompareExchange(comptime T: type, ptr: *T, new_value: T, expected_value: T) ?T {
    return @cmpxchgStrong(T, ptr, expected_value, new_value, .seq_cst, .seq_cst);
}

/// Performs an atomic add and returns the previous value
pub inline fn AtomicAdd(comptime T: type, ptr: *T, addend: T) T {
    return @atomicRmw(T, ptr, .Add, addend, .seq_cst);
}

pub inline fn AtomicExchange(comptime T: type, ptr: *T, new_value: T) T {
    return @atomicRmw(T, ptr, .Xchg, new_value, .seq_cst);
}

// simd -----------------------------------------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------

/// simd intrinsics implemented using language features, use these when possible
pub const z = struct {
    // TODO (Manav): untested
    pub fn _mm_storeu_ps(ptr: [*]f32, vec: f32x4) void {
        @as(*align(1) f32x4, @alignCast(@ptrCast(ptr))).* = vec;
    }

    // TODO (Manav): untested
    pub fn _mm_store_ps(ptr: [*]f32, vec: f32x4) void {
        @as(*f32x4, @alignCast(@ptrCast(ptr))).* = vec;
    }

    // TODO (Manav): untested
    pub fn _mm_load_ps(ptr: [*]const f32) f32x4 {
        return @as(*const f32x4, @alignCast(@ptrCast(ptr))).*;
    }

    // TODO (Manav): untested
    pub fn _mm_loadu_ps(ptr: [*]const f32) f32x4 {
        return @as(*align(1) const f32x4, @alignCast(@ptrCast(ptr))).*;
    }

    pub fn _mm_cvttps_epi32(v: f32x4) i32x4 {
        var result = i32x4{ 0, 0, 0, 0 };

        inline for (0..4) |index| {
            result[index] = @as(i32, @intFromFloat(v[index]));
        }

        return result;
    }

    pub fn _mm_cvtepi32_ps(v: i32x4) f32x4 {
        var result = f32x4{ 0, 0, 0, 0 };

        inline for (0..4) |index| {
            result[index] = @as(f32, @floatFromInt(v[index]));
        }

        return result;
    }

    // TODO (Manav): untested
    pub fn _mm_unpacklo_epi32(a: i32x4, b: i32x4) i32x4 {
        return @shuffle(i32, a, b, i32x4{ 0, ~@as(i32, 0), 1, ~@as(i32, 1) });
    }

    // TODO (Manav): untested
    pub fn _mm_unpackhi_epi32(a: i32x4, b: i32x4) i32x4 {
        return @shuffle(i32, a, b, i32x4{ 2, ~@as(i32, 2), 3, ~@as(i32, 3) });
    }

    // TODO (Manav): untested
    pub fn _mm_unpacklo_ps(a: f32x4, b: f32x4) f32x4 {
        return @shuffle(f32, a, b, i32x4{ 0, ~@as(i32, 0), 1, ~@as(i32, 1) });
    }

    // TODO (Manav): untested
    pub fn _mm_unpackhi_ps(a: f32x4, b: f32x4) f32x4 {
        return @shuffle(f32, a, b, i32x4{ 2, ~@as(i32, 2), 3, ~@as(i32, 3) });
    }

    /// Convert packed signed 32-bit integers from `a` and `b` to packed 16-bit integers using signed saturation, and returns the results.
    ///
    /// It uses `packssdw` SSE2 instruction
    pub fn _mm_packs_epi32(a: i32x4, b: i32x4) i16x8 {
        var result: i16x8 = undefined;

        for (0..4) |index| {
            result[index] = @intCast(@max(minInt, @min(a[index], maxInt)));
        }

        for (0..4) |index| {
            result[index + 4] = @intCast(@max(minInt, @min(b[index], maxInt)));
        }

        return result;
    }

    pub fn _mm_mullo_epi16(a: i32x4, b: i32x4) i32x4 {
        const __a = @as(i16x8, @bitCast(a));
        const __b = @as(i16x8, @bitCast(b));

        var result = u16x8{ 0, 0, 0, 0, 0, 0, 0, 0 };

        inline for (0..8) |index| {
            result[index] = @as(u16, @truncate(@as(u32, @bitCast(@as(i32, __a[index]) * @as(i32, __b[index])))));
        }

        return @as(i32x4, @bitCast(result));
    }

    pub fn _mm_mulhi_epi16(a: i32x4, b: i32x4) i32x4 {
        const __a = @as(i16x8, @bitCast(a));
        const __b = @as(i16x8, @bitCast(b));

        var result = u16x8{ 0, 0, 0, 0, 0, 0, 0, 0 };

        inline for (0..8) |index| {
            // NOTE: for some reason not storing these gives erros when function inlines
            const __ai = @as(i32, __a[index]);
            const __bi = @as(i32, __b[index]);
            result[index] = @as(u16, @truncate(@as(u32, @bitCast(__ai * __bi >> 16))));
        }

        return @as(i32x4, @bitCast(result));
    }

    pub fn _mm_srli_epi32(v: i32x4, imm8: u5) i32x4 {
        return @as(i32x4, @bitCast((@as(u32x4, @bitCast(v)) >> @splat(imm8))));
    }
};

/// simd intrinsics implemented using inline assembly, not using contraints
pub const i = struct {
    /// Convert packed single-precision (32-bit) floating-point elements in `v` to packed 32-bit integers, and return the results.
    ///
    /// It uses the `cvtps2dq` SSE2 instruction.
    pub inline fn _mm_cvtps_epi32(v: f32x4) i32x4 {
        var result: i32x4 = @splat(0);
        asm volatile ("cvtps2dq %[v], %[result]"
            : [result] "=x" (result),
            : [v] "x" (v),
        );

        return result;
    }

    // TODO (Manav): this is busted _-_
    pub inline fn _mm_packs_epi32(a: i32x4, b: i32x4) i16x8 {
        var result: i16x8 = @splat(0);
        asm ("packssdw %[b], %[a]"
            : [result] "=x" (result),
            : [a] "x" (a),
              [b] "x" (b),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_cvttps_epi32(v: f32x4) i32x4 {
        var result: i32x4 = @splat(0);
        asm volatile ("cvttps2dq %[vec], %[ret]"
            : [ret] "=x" (result),
            : [vec] "x" (v),
        );
        return result;
    }

    // pub inline fn _mm_cvttps_epi32(v: f32x4) i32x4 {
    //     const result = asm ("cvttps2dq  %[v], %[v]"
    //         : [ret] "=&{xmm0}" (-> i32x4),
    //         : [v] "{xmm0}" (v),
    //     );

    //     return result;
    // }

    // TODO (Manav): untested
    pub inline fn _mm_cvtepi32_ps(v: i32x4) f32x4 {
        const result = asm ("cvtdq2ps %[v], %[v]"
            : [ret] "=&{xmm0}" (-> f32x4),
            : [v] "{xmm0}" (v),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpacklo_epi32(a: i32x4, b: i32x4) i32x4 {
        var result: i32x4 = @splat(0);
        asm volatile ("punpckldq %[b], %[a]"
            : [result] "=x" (result),
            : [a] "x" (a),
              [b] "x" (b),
        );
        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_epi32(a: i32x4, b: i32x4) i32x4 {
        var result: i32x4 = @splat(0);
        asm volatile ("punpckhdq %[b], %[a]"
            : [result] "=x" (result),
            : [a] "x" (a),
              [b] "x" (b),
        );
        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_mullo_epi16(a: i32x4, b: i32x4) i32x4 {
        const result = asm ("pmullw %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> i32x4),
            : [arg0] "{xmm0}" (a),
              [arg1] "{xmm1}" (b),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_mulhi_epi16(a: i32x4, b: i32x4) i32x4 {
        const result = asm ("pmulhw %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> i32x4),
            : [arg0] "{xmm0}" (a),
              [arg1] "{xmm1}" (b),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_rsqrt_ps(v: f32x4) f32x4 {
        const result = asm ("rsqrtps %[v], %[v]"
            : [ret] "=&{xmm0}" (-> f32x4),
            : [v] "{xmm0}" (v),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_srli_epi32(v: i32x4, imm8: u32) i32x4 {
        const result = asm ("psrld %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> i32x4),
            : [arg1] "{xmm1}" (imm8),
              [arg0] "{xmm0}" (v),
        );

        return result;
    }
};

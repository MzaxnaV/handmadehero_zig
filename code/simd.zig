// TODO (Manav): move this to handmade_platform??

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

pub const perf_analyzer = struct {
    /// DO NOT USE `defer` on `End()`.
    const method = enum {
        LLVM_MCA,
    };

    pub inline fn Start(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .LLVM_MCA => asm volatile ("# LLVM-MCA-BEGIN " ++ region ::: "memory"),
        }
    }

    pub inline fn End(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .LLVM_MCA => asm volatile ("# LLVM-MCA-END " ++ region ::: "memory"),
        }
    }
};

/// simd intrinsics implemented using language features, use these when possible
pub const z = struct {
    // TODO (Manav): untested
    pub inline fn _mm_storeu_ps(ptr: [*]f32, vec: f32x4) void {
        @as(*align(1) f32x4, @alignCast(@ptrCast(ptr))).* = vec;
    }

    // TODO (Manav): untested
    pub inline fn _mm_store_ps(ptr: [*]f32, vec: f32x4) void {
        @as(*f32x4, @alignCast(@ptrCast(ptr))).* = vec;
    }

    // TODO (Manav): untested
    pub inline fn _mm_load_ps(ptr: [*]const f32) f32x4 {
        return @as(*const f32x4, @alignCast(@ptrCast(ptr))).*;
    }

    // TODO (Manav): untested
    pub inline fn _mm_loadu_ps(ptr: [*]const f32) f32x4 {
        return @as(*align(1) const f32x4, @alignCast(@ptrCast(ptr))).*;
    }

    pub inline fn _mm_cvttps_epi32(v: f32x4) i32x4 {
        var result = i32x4{ 0, 0, 0, 0 };

        inline for (0..4) |index| {
            result[index] = @as(i32, @intFromFloat(v[index]));
        }

        return result;
    }

    pub inline fn _mm_cvtepi32_ps(v: i32x4) f32x4 {
        var result = f32x4{ 0, 0, 0, 0 };

        inline for (0..4) |index| {
            result[index] = @as(f32, @floatFromInt(v[index]));
        }

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpacklo_epi32(a: i32x4, b: i32x4) i32x4 {
        return @shuffle(i32, a, b, i32x4{ 0, ~@as(i32, 0), 1, ~@as(i32, 1) });
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_epi32(a: i32x4, b: i32x4) i32x4 {
        return @shuffle(i32, a, b, i32x4{ 2, ~@as(i32, 2), 3, ~@as(i32, 3) });
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpacklo_ps(a: f32x4, b: f32x4) f32x4 {
        return @shuffle(f32, a, b, i32x4{ 0, -1, 1, -2 });
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_ps(a: f32x4, b: f32x4) f32x4 {
        return @shuffle(f32, a, b, i32x4{ 2, -3, 3, -4 });
    }

    pub inline fn _mm_mullo_epi16(a: i32x4, b: i32x4) i32x4 {
        const __a = @as(i16x8, @bitCast(a));
        const __b = @as(i16x8, @bitCast(b));

        var result = u16x8{ 0, 0, 0, 0, 0, 0, 0, 0 };

        inline for (0..8) |index| {
            result[index] = @as(u16, @truncate(@as(u32, @bitCast(@as(i32, __a[index]) * @as(i32, __b[index])))));
        }

        return @as(i32x4, @bitCast(result));
    }

    pub inline fn _mm_mulhi_epi16(a: i32x4, b: i32x4) i32x4 {
        const __a = @as(i16x8, @bitCast(a));
        const __b = @as(i16x8, @bitCast(b));

        var result = u16x8{ 0, 0, 0, 0, 0, 0, 0, 0 };

        inline for (0..8) |index| {
            // NOTE: for some reason not storing these gives erros when function inlines
            var __ai = @as(i32, __a[index]);
            var __bi = @as(i32, __b[index]);
            result[index] = @as(u16, @truncate(@as(u32, @bitCast(__ai * __bi >> 16))));
        }

        return @as(i32x4, @bitCast(result));
    }

    pub inline fn _mm_srli_epi32(v: i32x4, imm8: u5) i32x4 {
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

    /// Convert packed signed 32-bit integers from `a` and `b` to packed 16-bit integers using signed saturation, and returns the results.
    ///
    /// It uses `packssdw` SSE2 instruction
    pub inline fn _mm_packs_epi32(a: i32x4, b: i32x4) i16x8 {
        var result: i16x8 = @splat(0);
        asm ("packssdw %[b], %[a]"
            : [result] "=x" (result),
            : [a] "x" (a),
              [b] "x" (b),
        );

        return result;
    }

    pub inline fn _mm_cvttps_epi32(v: f32x4) i32x4 {
        const result = asm ("cvttps2dq  %[v], %[v]"
            : [ret] "=&{xmm0}" (-> i32x4),
            : [v] "{xmm0}" (v),
        );

        return result;
    }

    pub inline fn _mm_cvtepi32_ps(v: i32x4) f32x4 {
        const result = asm ("cvtdq2ps %[v], %[v]"
            : [ret] "=&{xmm0}" (-> f32x4),
            : [v] "{xmm0}" (v),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpacklo_epi32(a: i32x4, b: i32x4) i32x4 {
        const result = asm ("punpckldq %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> i32x4),
            : [arg0] "{xmm0}" (b),
              [arg1] "{xmm1}" (a),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_epi32(a: i32x4, b: i32x4) i32x4 {
        const result = asm ("punpckhdq %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> i32x4),
            : [arg0] "{xmm0}" (a),
              [arg1] "{xmm1}" (b),
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

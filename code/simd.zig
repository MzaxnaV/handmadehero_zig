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

/// simd intrinsics implemented using language features
pub const z = struct {
    pub inline fn _mm_cvtps_epi32(v: f32x4) i32x4 {
        var result = i32x4{};
        comptime var index = 0;

        inline while (index < 4) : (index += 1) {
            result[index] = @floatToInt(i32, @round(v[index]));
        }

        return result;
    }

    pub inline fn _mm_cvttps_epi32(v: f32x4) i32x4 {
        var result = i32x4{};
        comptime var index = 0;

        inline while (index < 4) : (index += 1) {
            result[index] = @floatToInt(i32, v[index]);
        }

        return result;
    }

    pub inline fn _mm_cvtepi32_ps(v: i32x4) f32x4 {
        var result = f32x4{};
        comptime var index = 0;

        inline while (index < 4) : (index += 1) {
            result[index] = @intToFloat(f32, v[index]);
        }

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpacklo_epi32(a: i64x2, b: i64x2) i64x2 {
        return @bitCast(i64x2, @shuffle(i32, @bitCast(i32x4, a), @bitCast(i32x4, b), i32x4{ 0, -1, 1, -2 }));
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_epi32(a: i64x2, b: i64x2) i64x2 {
        return @bitCast(i64x2, @shuffle(i32, @bitCast(i32x4, a), @bitCast(i32x4, b), i32x4{ 2, -3, 3, -4 }));
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpacklo_ps(a: f32x4, b: f32x4) f32x4 {
        return @shuffle(f32, a, b, i32x4{ 0, -1, 1, -2 });
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_ps(a: f32x4, b: f32x4) f32x4 {
        return @shuffle(f32, a, b, i32x4{ 2, -3, 3, -4 });
    }

    // TODO (Manav): untested
    pub inline fn _mm_mullo_epi16(a: i32x4, b: i32x4) i32x4 {
        return @bitCast(i32x4, @bitCast(u16x8, a) * @bitCast(u16x8, b));
    }
};

/// simd intrinsics implemented using inline assembly
pub const i = struct {
    pub inline fn _mm_cvtps_epi32(v: f32x4) i32x4 {
        const result = asm ("cvtps2dq %[v], %[v]"
            : [ret] "=&{xmm0}" (-> i32x4),
            : [v] "{xmm0}" (v),
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
    pub inline fn _mm_unpacklo_epi32(a: f32x4, b: f32x4) f32x4 {
        const result: f32x4 = asm volatile ("punpckldq %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> f32x4),
            : [arg0] "{xmm0}" (b),
              [arg1] "{xmm1}" (a),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_unpackhi_epi32(a: f32x4, b: f32x4) f32x4 {
        const result = asm ("punpckhdq %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> @Vector(4, f32)),
            : [arg0] "{xmm0}" (a),
              [arg1] "{xmm1}" (b),
        );
        return result;
    }

    // TODO (Manav): untested
    pub inline fn _mm_mullo_epi16_(a: i32x4, b: i32x4) i32x4 {
        const result = asm ("pmullw %[arg1], %[arg0]"
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
    pub export fn _mm_srli_epi32(v: i32x4, imm8: u32) i32x4 {
        const result = asm ("psrld %[arg1], %[arg0]"
            : [ret] "={xmm0}" (-> i32x4),
            : [arg1] "{xmm1}" (imm8),
              [arg0] "{xmm0}" (v),
        );

        return result;
    }
};

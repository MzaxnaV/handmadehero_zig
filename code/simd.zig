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
};

/// simd intrinsics implemented using inline assembly
pub const i = struct {
    pub inline fn cvtps(v: f32x4) i32x4 {
        const result = asm ("cvtps2dq %[v], %[v]"
            : [ret] "=&{xmm0}" (-> i32x4),
            : [v] "{xmm0}" (v),
        );

        return result;
    }

    pub inline fn cvttps(v: f32x4) i32x4 {
        const result = asm ("cvttps2dq  %[v], %[v]"
            : [ret] "=&{xmm0}" (-> i32x4),
            : [v] "{xmm0}" (v),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn unpacklo(a: f32x4, b: f32x4) f32x4 {
        const result: f32x4 = asm volatile ("punpckldq %[a], %[b]"
            : [ret] "={xmm1}" (-> f32x4),
            : [b] "{xmm1}" (b),
              [a] "{xmm0}" (a),
        );

        return result;
    }

    // TODO (Manav): untested
    pub inline fn unpackhi(a: f32x4, b: f32x4) f32x4 {
        const result = asm ("punpckhdq %[arg1], %[arg2]"
            : [ret] "={xmm0}" (-> @Vector(4, f32)),
            : [arg1] "{xmm1}" (b),
              [arg2] "{xmm0}" (a),
        );
        return result;
    }
};

const SquareRoot = @import("handmade_intrinsics.zig").SquareRoot;

// data types -----------------------------------------------------------------------------------------------------------------------------

pub const v2 = @Vector(2, f32);
pub const v3 = @Vector(3, f32);
pub const v4 = @Vector(4, f32);

const vector = enum { V2, V3, V4 };

pub const v = union(vector) {
    const Self = @This();

    V2: v2,
    V3: v3,
    V4: v4,

    pub inline fn X(self: Self) f32 {
        return switch (self) {
            .V2 => self.V2[0],
            .V3 => self.V3[0],
            .V4 => self.V4[0],
        };
    }

    pub inline fn Y(self: Self) f32 {
        return switch (self) {
            .V2 => self.V2[1],
            .V3 => self.V3[1],
            .V4 => self.V4[1],
        };
    }

    pub inline fn Z(self: Self) f32 {
        return switch (self) {
            .V3 => self.V3[2],
            .V4 => self.V4[2],
            else => unreachable,
        };
    }

    pub inline fn W(self: Self) f32 {
        return switch (self) {
            .V4 => self.V4[3],
            else => unreachable,
        };
    }

    pub const R = X;
    pub const G = Y;
    pub const B = Z;
    pub const A = W;
};

/// function to get v containing v2
pub inline fn VN2(a: v2) v {
    return v{ .V2 = a };
}

/// function to get v containing v3
pub inline fn VN3(a: v3) v {
    return v{ .V3 = a };
}

/// function to get v containing v4
pub inline fn VN4(a: v4) v {
    return v{ .V4 = a };
}

pub inline fn Inner(a: v, b: v) f32 {
    return switch (a) {
        .V2 => @reduce(.Add, a.V2 * b.V2),
        .V3 => @reduce(.Add, a.V3 * b.V3),
        .V4 => @reduce(.Add, a.V4 * b.V4),
    };
}

pub const rect2 = struct {
    min: v2 = v2{ 0, 0 },
    max: v2 = v2{ 0, 0 },

    pub inline fn InitMinDim(min: v2, dim: v2) rect2 {
        const result = rect2{
            .min = min,
            .max = min + dim,
        };
        return result;
    }

    pub inline fn InitCenterHalfDim(center: v2, halfDim: v2) rect2 {
        const result = rect2{
            .min = center - halfDim,
            .max = center + halfDim,
        };
        return result;
    }

    pub inline fn InitCenterDim(center: v2, dim: v2) rect2 {
        const result = InitCenterHalfDim(center, dim * @splat(2, @as(f32, 0.5)));
        return result;
    }

    pub inline fn GetMinCorner(self: *const rect2) v2 {
        const result = self.min;
        return result;
    }

    pub inline fn GetMaxCorner(self: *const rect2) v2 {
        const result = self.max;
        return result;
    }

    pub inline fn GetCenter(self: *const rect2) v2 {
        const result = (self.max + self.min) * @splat(2, @as(f32, 0.5));
        return result;
    }
};

pub inline fn IsInRectangle(rectangle: rect2, testP: v2) bool {
    const result = ((testP[0] >= rectangle.min[0]) and
        (testP[1] >= rectangle.min[1]) and
        (testP[0] < rectangle.max[0]) and
        (testP[1] < rectangle.max[1]));
    return result;
}

pub inline fn AddRadiusTo(rectangle: rect2, radiusW: f32, radiusH: f32) rect2 {
    const result = rect2{
        .min = rectangle.min - v2{ radiusW, radiusH },
        .max = rectangle.max + v2{ radiusW, radiusH },
    };
    return result;
}

pub inline fn Square(a: f32) f32 {
    const result = a * a;
    return result;
}

pub inline fn LengthSq(a: v2) f32 {
    const result = Inner(VN2(a), VN2(a));
    return result;
}

pub inline fn Length(a: v2) f32 {
    const result = SquareRoot(LengthSq(a));
    return result;
}

pub inline fn AddI32ToU32(a: u32, b: i32) u32 {
    const result = if (b > 0) a + @intCast(u32, b) else a - @intCast(u32, -b);
    return result;
}

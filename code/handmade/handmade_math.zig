const SquareRoot = @import("handmade_intrinsics.zig").SquareRoot;

// private functions ----------------------------------------------------------------------------------------------------------------------

inline fn checkVector(comptime t: type) comptime_int {
    comptime {
        return switch (@typeInfo(t)) {
            .Vector => |value| value.len,
            else => -1,
        };
    }
}

// defs -----------------------------------------------------------------------------------------------------------------------------------

pub const v2 = @Vector(2, f32);
pub const v3 = @Vector(3, f32);
pub const v4 = @Vector(4, f32);

// data types -----------------------------------------------------------------------------------------------------------------------------

pub const rect2 = struct {
    const Self = @This();

    min: v2 = v2{ 0, 0 },
    max: v2 = v2{ 0, 0 },

    pub inline fn InitMinDim(min: v2, dim: v2) Self {
        const result = Self{
            .min = min,
            .max = min + dim,
        };
        return result;
    }

    pub inline fn InitCenterHalfDim(center: v2, halfDim: v2) Self {
        const result = Self{
            .min = center - halfDim,
            .max = center + halfDim,
        };
        return result;
    }

    pub inline fn InitCenterDim(center: v2, dim: v2) Self {
        const result = InitCenterHalfDim(center, dim * @splat(2, @as(f32, 0.5)));
        return result;
    }

    pub inline fn GetMinCorner(self: *const Self) v2 {
        const result = self.min;
        return result;
    }

    pub inline fn GetMaxCorner(self: *const Self) v2 {
        const result = self.max;
        return result;
    }

    pub inline fn GetCenter(self: *const Self) v2 {
        const result = (self.max + self.min) * @splat(2, @as(f32, 0.5));
        return result;
    }
};

pub const rect3 = struct {
    const Self = @This();

    min: v3 = v3{ 0, 0, 0 },
    max: v3 = v3{ 0, 0, 0 },

    pub inline fn InitMinDim(min: v3, dim: v3) Self {
        const result = Self{
            .min = min,
            .max = min + dim,
        };
        return result;
    }

    pub inline fn InitCenterHalfDim(center: v3, halfDim: v3) Self {
        const result = Self{
            .min = center - halfDim,
            .max = center + halfDim,
        };
        return result;
    }

    pub inline fn InitCenterDim(center: v3, dim: v3) Self {
        const result = InitCenterHalfDim(center, dim * @splat(3, @as(f32, 0.5)));
        return result;
    }

    pub inline fn GetMinCorner(self: *const Self) v3 {
        const result = self.min;
        return result;
    }

    pub inline fn GetMaxCorner(self: *const Self) v3 {
        const result = self.max;
        return result;
    }

    pub inline fn GetCenter(self: *const Self) v3 {
        const result = (self.max + self.min) * @splat(3, @as(f32, 0.5));
        return result;
    }
};

// functions (vector operations)-----------------------------------------------------------------------------------------------------------

pub inline fn V2(x: anytype, y: @TypeOf(x)) v2 {
    comptime var t = switch (@TypeOf(x)) {
        f32, comptime_float, comptime_int => 1,
        i32, u32 => 2,
        else => @compileError("Invalid type"),
    };

    return switch (t) {
        1 => v2{ x, y },
        2 => v2{ @intToFloat(f32, x), @intToFloat(f32, y) },
        else => unreachable,
    };
}

pub inline fn X(vec: anytype) f32 {
    comptime {
        if (checkVector(@TypeOf(vec)) < 0) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[0];
}

pub inline fn Y(vec: anytype) f32 {
    comptime {
        if (checkVector(@TypeOf(vec)) < 1) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[1];
}

pub inline fn Z(vec: anytype) f32 {
    comptime {
        if (checkVector(@TypeOf(vec)) < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[2];
}

pub inline fn W(vec: anytype) f32 {
    comptime {
        if (checkVector(@TypeOf(vec)) < 3) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[3];
}

pub const R = X;
pub const G = Y;
pub const B = Z;
pub const A = W;

pub inline fn XY(vec: anytype) v2 {
    comptime {
        if (checkVector(@TypeOf(vec)) < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }

    return v2{ vec[0], vec[1] };
}

pub inline fn Inner(a: anytype, b: @TypeOf(a)) f32 {
    comptime {
        if (checkVector(@TypeOf(a)) < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return @reduce(.Add, a * b);
}

pub inline fn LengthSq(a: anytype) f32 {
    const result = Inner(a, a);
    return result;
}

pub inline fn Length(a: anytype) f32 {
    const result = SquareRoot(LengthSq(a));
    return result;
}

// functions (rects operations)------------------------------------------------------------------------------------------------------------

pub inline fn IsInRect2(rectangle: rect2, testP: v2) bool {
    const result = ((testP[0] >= rectangle.min[0]) and
        (testP[1] >= rectangle.min[1]) and
        (testP[0] < rectangle.max[0]) and
        (testP[1] < rectangle.max[1]));
    return result;
}

pub inline fn AddRadiusToRect2(rectangle: rect2, radius: v2) rect2 {
    const result = rect2{
        .min = rectangle.min - radius,
        .max = rectangle.max + radius,
    };
    return result;
}

pub inline fn GetBarycentricV2(a: rect2, p: v2) v2 {
    var result: v2 = .{
        SafeRatiof0(p[0] - a.min[0], a.max[0] - a.min[0]),
        SafeRatiof0(p[1] - a.min[1], a.max[1] - a.min[1]),
    };

    return result;
}

pub inline fn IsInRect3(rectangle: rect3, testP: v3) bool {
    const result = @reduce(.And, testP >= rectangle.min) and @reduce(.And, testP < rectangle.max);
    return result;
}

pub inline fn AddRadiusToRect3(rectangle: rect3, radius: v3) rect3 {
    const result = rect3{
        .min = rectangle.min - radius,
        .max = rectangle.max + radius,
    };
    return result;
}

pub inline fn GetBarycentricV3(a: rect3, p: v3) v3 {
    var result: v3 = .{
        SafeRatiof0(p[0] - a.min[0], a.max[0] - a.min[0]),
        SafeRatiof0(p[1] - a.min[1], a.max[1] - a.min[1]),
        SafeRatiof0(p[2] - a.min[2], a.max[2] - a.min[2]),
    };

    return result;
}

pub inline fn RectanglesIntersect(a: rect3, b: rect3) bool {
    const result = !(@reduce(.Or, b.max <= a.min) or @reduce(.Or, b.min >= a.max));
    return result;
}

pub inline fn ToRectXY(a: rect3) rect2 {
    const result = rect2{
        .min = XY(a.mix),
        .max = XY(a.max),
    };
    return result;
}

// functions (scalar operations) ----------------------------------------------------------------------------------------------------------

pub inline fn AddI32ToU32(a: u32, b: i32) u32 {
    const result = if (b > 0) a + @intCast(u32, b) else a - @intCast(u32, -b);
    return result;
}

pub inline fn Square(a: f32) f32 {
    const result = a * a;
    return result;
}

pub inline fn Clamp(min: f32, value: f32, max: f32) f32 {
    var result = value;

    if (result < min) {
        result = min;
    } else if (result > max) {
        result = max;
    }

    return result;
}

pub inline fn Clampf01(value: f32) f32 {
    const result = Clamp(0, value, 1);
    return result;
}

pub inline fn ClampV301(value: v3) v3 {
    const result = v3{
        Clampf01(value[0]),
        Clampf01(value[1]),
        Clampf01(value[2]),
    };

    return result;
}

pub inline fn ClampV201(value: v2) v2 {
    const result = v2{
        Clampf01(value[0]),
        Clampf01(value[1]),
    };

    return result;
}

pub inline fn Lerp(a: f32, t: f32, b: f32) f32 {
    const result = (1 - t) * a + t * b;
    return result;
}

pub inline fn SafeRatioN(num: f32, div: f32, n: f32) f32 {
    var result = if (div != 0) num / div else n;
    return result;
}

pub inline fn SafeRatiof0(num: f32, div: f32) f32 {
    var result = SafeRatioN(num, div, 0);
    return result;
}

pub inline fn SafeRatiof1(num: f32, div: f32) f32 {
    var result = SafeRatioN(num, div, 1);
    return result;
}

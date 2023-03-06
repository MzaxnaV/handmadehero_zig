const SquareRoot = @import("handmade_intrinsics.zig").SquareRoot;
const MaxInt = @import("std").math.maxInt;

// data types -----------------------------------------------------------------------------------------------------------------------------------

pub const v2 = Vector(2);
pub const v3 = Vector(3);
pub const v4 = Vector(4);

pub const rect2 = Rectangle(2);
pub const rect3 = Rectangle(3);

pub const rect2i = struct {
    const Self = @This();

    xMin: i32 = 0,
    yMin: i32 = 0,
    xMax: i32 = 0,
    yMax: i32 = 0,

    pub inline fn Intersect(self: *Self, other: Self) void {
        self.xMin = if (self.xMin < other.xMin) other.xMin else self.xMin;
        self.yMin = if (self.yMin < other.yMin) other.yMin else self.yMin;
        self.xMax = if (self.xMax > other.xMax) other.xMax else self.xMax;
        self.yMax = if (self.yMax > other.yMax) other.yMax else self.yMax;
    }

    pub inline fn Union(self: *const Self, other: Self) void {
        self.xMin = if (self.xMin < other.xMin) self.xMin else other.xMin;
        self.yMin = if (self.yMin < other.yMin) self.yMin else other.yMin;
        self.xMax = if (self.xMax > other.xMax) self.xMax else other.xMax;
        self.yMax = if (self.yMax > other.yMax) self.yMax else other.yMax;
    }

    pub fn GetClampedRectArea(self: *const Self) i32 {
        const width = (self.xMax - self.xMin);
        const height = (self.yMax - self.yMin);
        const result = if ((width > 0) and (height > 0)) width * height else 0;

        return result;
    }

    pub inline fn HasArea(self: *const Self) bool {
        const result = (self.xMin < self.xMax) and (self.yMin < self.yMax);

        return result;
    }

    pub inline fn InvertedInfinityRectangle() Self {
        var result = Self{
            .xMin = MaxInt(i32),
            .yMin = MaxInt(i32),
            .xMax = -MaxInt(i32),
            .yMax = -MaxInt(i32),
        };

        return result;
    }
};

// generator functions ----------------------------------------------------------------------------------------------------------------------

inline fn ToF32(a: anytype) f32 {
    return switch (@TypeOf(a)) {
        f32, comptime_float, comptime_int => @as(f32, a),
        i32, u32 => @intToFloat(f32, a),
        else => @compileError("Invalid type"),
    };
}

inline fn Vector(comptime n: comptime_int) type {
    comptime {
        if (n < 2) {
            @compileError("Invalid vector dimension, should be >= 2");
        }
    }
    return [n]f32;
}

inline fn Rectangle(comptime n: comptime_int) type {
    comptime {
        if (n > 3 or n < 2) {
            @compileError("Invalid rectangle dimension, should be 2 or 3");
        }
    }
    return struct {
        const Self = @This();

        const v = Vector(n);

        min: v = [1]f32{0} ** n,
        max: v = [1]f32{0} ** n,

        pub inline fn InitMinDim(min: v, dim: v) Self {
            const result = Self{
                .min = min,
                .max = Add(min, dim),
            };
            return result;
        }

        pub inline fn InitCenterHalfDim(center: v, halfDim: v) Self {
            const result = Self{
                .min = Sub(center, halfDim),
                .max = Add(center, halfDim),
            };
            return result;
        }

        pub inline fn InitCenterDim(center: v, dim: v) Self {
            const result = InitCenterHalfDim(center, Scale(dim, 0.5));
            return result;
        }

        pub inline fn GetMinCorner(self: *const Self) v {
            const result = self.min;
            return result;
        }

        pub inline fn GetMaxCorner(self: *const Self) v {
            const result = self.max;
            return result;
        }

        pub inline fn GetCenter(self: *const Self) v {
            const result = Scale(Add(self.max, self.min), 0.5);
            return result;
        }

        pub inline fn GetDim(self: *const Self) v {
            const result = Sub(self.max, self.min);
            return result;
        }

        /// return a new rectangle expanded by the given radius
        pub inline fn AddRadius(self: *const Self, radius: v) Self {
            const result = Self{
                .min = Sub(self.min, radius),
                .max = Add(self.max, radius),
            };
            return result;
        }

        pub inline fn IsInRect(self: *const Self, testP: v) bool {
            var result = true;

            comptime var i = 0;
            inline while (i < n) : (i += 1) {
                result = result and ((testP[i] >= self.min[i]) and (testP[i] < self.max[i]));
            }

            return result;
        }

        pub inline fn GetBarycentric(self: *const Self, p: v) v {
            var result: v = [1]f32{0} ** n;

            comptime var i = 0;
            inline while (i < n) : (i += 1) {
                result[i] = SafeRatiof0(p[i] - self.min[i], self.max[i] - self.min[i]);
            }

            return result;
        }
    };
}

// functions (vector operations)-----------------------------------------------------------------------------------------------------------

pub inline fn Add(a: anytype, b: [a.len]f32) [a.len]f32 {
    var result = [1]f32{0} ** a.len;

    comptime var i = 0;
    inline while (i < result.len) : (i += 1) {
        result[i] = a[i] + b[i];
    }

    return result;
}

pub inline fn AddTo(vec: anytype, other: [vec.len]f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32) {
            @compileError("vec should be of the type *[N]f32");
        }
    }

    comptime var i = 0;
    inline while (i < vec.len) : (i += 1) {
        (vec.*)[i] += other[i];
    }
}

pub inline fn Sub(a: anytype, b: [a.len]f32) [a.len]f32 {
    var result = [1]f32{0} ** a.len;

    comptime var i = 0;
    inline while (i < result.len) : (i += 1) {
        result[i] = a[i] - b[i];
    }

    return result;
}

pub inline fn SubFrom(vec: anytype, other: [vec.len]f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32) {
            @compileError("vec should be of the type *[N]f32");
        }

        comptime var i = 0;
        // TODO (Manav): check the performance vs normal while
        inline while (i < vec.len) : (i += 1) {
            (vec.*)[i] -= other[i];
        }
    }
}

pub inline fn Scale(vec: anytype, val: f32) [vec.len]f32 {
    var result = [1]f32{0} ** vec.len;

    comptime var i = 0;
    inline while (i < result.len) : (i += 1) {
        result[i] = val * vec[i];
    }

    return result;
}

pub inline fn Hammard(a: anytype, b: [a.len]f32) [a.len]f32 {
    var result = [1]f32{0} ** a.len;

    comptime var i = 0;
    inline while (i < result.len) : (i += 1) {
        result[i] = a[i] * b[i];
    }

    return result;
}

pub inline fn V2(x: anytype, y: anytype) v2 {
    return v2{ ToF32(x), ToF32(y) };
}

pub inline fn V3(x: anytype, y: anytype, z: anytype) v3 {
    return v3{ ToF32(x), ToF32(y), ToF32(z) };
}

pub inline fn V4(x: anytype, y: anytype, z: anytype, w: anytype) v4 {
    return v4{ ToF32(x), ToF32(y), ToF32(z), ToF32(w) };
}

pub inline fn X(vec: anytype) f32 {
    return vec[0];
}

pub inline fn Y(vec: anytype) f32 {
    comptime {
        if (vec.len < 1) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[1];
}

pub inline fn Z(vec: anytype) f32 {
    comptime {
        if (vec.len < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[2];
}

/// w in xyzw
pub inline fn W(vec: anytype) f32 {
    comptime {
        if (vec.len < 3) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[3];
}

pub const R = X;
pub const G = Y;
pub const B = Z;
pub const A = W;

pub const U = X;
pub const V = Y;

pub inline fn XY(vec: anytype) v2 {
    comptime {
        if (vec.len < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }

    return vec[0..2].*;
}

pub inline fn XYZ(vec: anytype) v3 {
    comptime {
        if (vec.len < 3) {
            @compileError("Invalid operand type or vector size");
        }
    }

    return vec[0..3].*;
}

pub const UV = XY;
pub const RGB = XYZ;

pub inline fn ToV3(xy: v2, z: anytype) v3 {
    return v3{ xy[0], xy[1], ToF32(z) };
}

pub inline fn ToV4(xyz: v3, w: anytype) v4 {
    return v4{ xyz[0], xyz[1], xyz[2], ToF32(w) };
}

pub inline fn Inner(a: anytype, b: [a.len]f32) f32 {
    comptime {
        if (a.len < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }
    var result = @as(f32, 0);

    var i = @as(u32, 0);
    while (i < a.len) : (i += 1) {
        result += a[i] * b[i];
    }

    return result;
}

pub inline fn Normalize(a: anytype) [a.len]f32 {
    const result = Scale(a, 1.0 / Length(a));
    return result;
}

pub inline fn LengthSq(a: anytype) f32 {
    const result = Inner(a, a);
    return result;
}

pub inline fn Length(a: anytype) f32 {
    const result = SquareRoot(LengthSq(a));
    return result;
}

pub inline fn Perp(a: v2) v2 {
    const result = v2{ -Y(a), X(a) };
    return result;
}

pub inline fn LerpV(a: anytype, t: f32, b: [a.len]f32) [a.len]f32 {
    comptime {
        if (a.len < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }
    const result = Add(Scale(a, (1 - t)), Scale(b, t));
    return result;
}

// functions (rect operations)------------------------------------------------------------------------------------------------------------

pub inline fn Offset(a: rect3, offset: v3) rect3 {
    const result = rect3{
        .min = Add(a.min, offset),
        .max = Add(a.max, offset),
    };

    return result;
}

pub inline fn RectanglesIntersect(a: rect3, b: rect3) bool {
    const result = !(b.max[0] <= a.min[0] or
        b.max[1] <= a.min[1] or
        b.max[2] <= a.min[2] or
        b.min[0] >= a.max[0] or
        b.min[1] >= a.max[1] or
        b.min[2] >= a.max[2]);

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

pub inline fn ClampMapToRange(min: f32, t: f32, max: f32) f32 {
    const range = max - min;
    const result = if (range != 0) Clampf01((t - min) / range) else 0;

    return result;
}

pub inline fn Clampf01(value: f32) f32 {
    const result = Clamp(0, value, 1);
    return result;
}

pub inline fn ClampV201(value: v2) v2 {
    const result = v2{
        Clampf01(value[0]),
        Clampf01(value[1]),
    };

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

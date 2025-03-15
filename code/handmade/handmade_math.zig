const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("intrinsics");
};

// const MaxInt = @import("std").math.maxInt;

// TODO: (Manav) change vectors to be structs ?

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

    pub inline fn Union(self: *Self, other: Self) Self {
        const result = Self{
            .xMin = if (self.xMin < other.xMin) self.xMin else other.xMin,
            .yMin = if (self.yMin < other.yMin) self.yMin else other.yMin,
            .xMax = if (self.xMax > other.xMax) self.xMax else other.xMax,
            .yMax = if (self.yMax > other.yMax) self.yMax else other.yMax,
        };

        return result;
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
        const result = Self{
            .xMin = platform.MAXINT32,
            .yMin = platform.MAXINT32,
            .xMax = -platform.MAXINT32,
            .yMax = -platform.MAXINT32,
        };

        return result;
    }
};

// generator functions ----------------------------------------------------------------------------------------------------------------------

inline fn ToF32(a: anytype) f32 {
    return switch (@TypeOf(a)) {
        f32, comptime_float, comptime_int => a,
        i32, u32 => @floatFromInt(a),
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

        pub inline fn InitMinMax(min: v, max: v) Self {
            const result = Self{
                .min = min,
                .max = max,
            };
            return result;
        }

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

            inline for (0..n) |i| {
                result = result and ((testP[i] >= self.min[i]) and (testP[i] < self.max[i]));
            }

            return result;
        }

        pub inline fn GetBarycentric(self: *const Self, p: v) v {
            var result: v = [1]f32{0} ** n;

            inline for (0..n) |i| {
                result[i] = SafeRatiof0(p[i] - self.min[i], self.max[i] - self.min[i]);
            }

            return result;
        }

        pub inline fn InvertedInfinity() Self {
            const result = Self{
                .min = .{ platform.F32MAXIMUM, platform.F32MAXIMUM },
                .max = .{ -platform.F32MAXIMUM, -platform.F32MAXIMUM },
            };

            return result;
        }

        pub inline fn Union(a: Self, b: Self) Self {
            const result = Self{ .min = .{
                if (X(a.min) < X(b.min)) X(a.min) else X(b.min),
                if (Y(a.min) < Y(b.min)) Y(a.min) else Y(b.min),
            }, .max = .{
                if (X(a.max) > X(b.max)) X(a.max) else X(b.max),
                if (Y(a.max) > Y(b.max)) Y(a.max) else Y(b.max),
            } };

            return result;
        }

        pub inline fn Offset(a: Self, offset: v) Self {
            const result = Self{
                .min = Add(a.min, offset),
                .max = Add(a.max, offset),
            };

            return result;
        }
    };
}

// functions (vector operations)-----------------------------------------------------------------------------------------------------------

/// returns `a + b`
pub inline fn Add(a: anytype, b: [a.len]f32) [a.len]f32 {
    var result = [1]f32{0} ** a.len;

    inline for (0..result.len) |i| {
        result[i] = a[i] + b[i];
    }

    return result;
}

/// returns `vec += other`
pub inline fn AddTo(vec: anytype, other: [vec.len]f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32) {
            @compileError("vec should be of the type *[N]f32, but it is of type: " ++ @typeName(@TypeOf(vec)));
        }
    }

    inline for (0..vec.len) |i| {
        (vec.*)[i] += other[i];
    }
}

/// returns `-vec`
pub inline fn Neg(vec: anytype) [vec.len]f32 {
    const result = Sub(v3{ 0, 0, 0 }, vec);

    return result;
}

/// returns `a - b`
pub inline fn Sub(a: anytype, b: [a.len]f32) [a.len]f32 {
    var result = [1]f32{0} ** a.len;

    inline for (0..result.len) |i| {
        result[i] = a[i] - b[i];
    }

    return result;
}

/// returns `vec -= other`
pub inline fn SubFrom(vec: anytype, other: [vec.len]f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32) {
            @compileError("vec should be of the type *[N]f32");
        }
    }

    // TODO (Manav): check the performance vs normal for
    inline for (0..vec.len) |i| {
        (vec.*)[i] -= other[i];
    }
}

pub inline fn Scale(vec: anytype, val: f32) [vec.len]f32 {
    var result = [1]f32{0} ** vec.len;

    inline for (0..result.len) |i| {
        result[i] = val * vec[i];
    }

    return result;
}

pub inline fn Hammard(a: anytype, b: [a.len]f32) [a.len]f32 {
    var result = [1]f32{0} ** a.len;

    inline for (0..result.len) |i| {
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

pub inline fn SetX(vec: anytype, val: f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32) {
            @compileError("vec should be of the type *[N]f32");
        }
    }
    vec[0] = val;
}

pub inline fn Y(vec: anytype) f32 {
    comptime {
        if (vec.len < 1) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[1];
}

pub inline fn SetY(vec: anytype, val: f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32 and vec.len < 1) {
            @compileError("vec should be of the type *[N]f32 where N >= 1");
        }
    }
    vec[1] = val;
}

pub inline fn Z(vec: anytype) f32 {
    comptime {
        if (vec.len < 2) {
            @compileError("Invalid operand type or vector size");
        }
    }
    return vec[2];
}

pub inline fn SetZ(vec: anytype, val: f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32 and vec.len < 2) {
            @compileError("vec should be of the type *[N]f32 where N >= 2");
        }
    }
    vec[2] = val;
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

pub inline fn SetW(vec: anytype, val: f32) void {
    comptime {
        if (@TypeOf(vec) != *[vec.len]f32 and vec.len < 3) {
            @compileError("vec should be of the type *[N]f32 where N >= 3");
        }
    }
    vec[3] = val;
}

pub const R = X;
pub const SetR = SetX;
pub const G = Y;
pub const SetG = SetY;
pub const B = Z;
pub const SetB = SetZ;
pub const A = W;
pub const SetA = SetW;

pub const U = X;
pub const SetU = SetX;
pub const V = Y;
pub const SetV = SetY;

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

    for (0..a.len) |i| {
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
    const result = h.SquareRoot(LengthSq(a));
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

// functions (utility operations) ----------------------------------------------------------------------------------------------------------

pub inline fn AddI32ToU32(a: u32, b: i32) u32 {
    const result = if (b > 0) a + @as(u32, @intCast(b)) else a - @as(u32, @intCast(-b));
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

pub inline fn ClampV401(value: v4) v4 {
    const result = v4{
        Clampf01(value[0]),
        Clampf01(value[1]),
        Clampf01(value[2]),
        Clampf01(value[3]),
    };

    return result;
}

pub inline fn Arm2(angle: f32) v2 {
    const result = v2{ h.Cos(angle), h.Sin(angle) };

    return result;
}

pub inline fn Lerp(a: f32, t: f32, b: f32) f32 {
    const result = (1 - t) * a + t * b;
    return result;
}

pub inline fn SafeRatioN(num: f32, div: f32, comptime n: comptime_float) f32 {
    const result = if (div != 0) num / div else n;
    return result;
}

pub inline fn SafeRatiof0(num: f32, div: f32) f32 {
    const result = SafeRatioN(num, div, 0);
    return result;
}

pub inline fn SafeRatiof1(num: f32, div: f32) f32 {
    const result = SafeRatioN(num, div, 1);
    return result;
}

pub inline fn SRGB255ToLinear1(c: v4) v4 {
    const inv255 = 1.0 / 255.0;
    const result = v4{
        Square(inv255 * R(c)),
        Square(inv255 * G(c)),
        Square(inv255 * B(c)),
        inv255 * A(c),
    };

    return result;
}

pub inline fn Linear1ToSRGB255(c: v4) v4 {
    const one255 = 255;
    const result = v4{
        one255 * h.SquareRoot(R(c)),
        one255 * h.SquareRoot(G(c)),
        one255 * h.SquareRoot(B(c)),
        one255 * A(c),
    };

    return result;
}

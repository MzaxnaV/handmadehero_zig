pub const v2 = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub inline fn Scale(self: *v2, scalar: f32) *v2 {
        self.x *= scalar;
        self.y *= scalar;

        return self;
    }

    pub inline fn Add(self: *v2, other: v2) *v2 {
        self.x += other.x;
        self.y += other.y;

        return self;
    }

    pub inline fn Sub(self: *v2, other: v2) *v2 {
        self.x -= other.x;
        self.y -= other.y;

        return self;
    }

    pub inline fn Neg(self: *v2) *v2 {
        return self.Scale(-1);
    }
};

pub inline fn Scale(a: v2, scalar: f32) v2 {
    const result = .{
        .x = a.x * scalar,
        .y = a.y * scalar,
    };

    return result;
}

pub inline fn Add(a: v2, b: v2) v2 {
    const result = .{
        .x = a.x + b.x,
        .y = a.y + b.y,
    };

    return result;
}

pub inline fn Sub(a: v2, b: v2) v2 {
    const result = .{
        .x = a.x - b.x,
        .y = a.y - b.y,
    };

    return result;
}

pub inline fn Neg(a: v2) v2 {
    const result = Scale(a, -1);

    return result;
}

pub inline fn Inner(a: v2, b: v2) f32 {
    const result = a.x * b.x + a.y * b.y;

    return result;
}

pub const rect2 = struct {
    min: v2 = .{},
    max: v2 = .{},

    pub inline fn InitMinDim(min: v2, dim: v2) rect2 {
        const result = rect2{
            .min = min,
            .max = Add(min, dim),
        };

        return result;
    }

    pub inline fn InitCenterHalfDim(center: v2, halfDim: v2) rect2 {
        const result = rect2{
            .min = Sub(center, halfDim),
            .max = Add(center, halfDim),
        };

        return result;
    }

    pub inline fn InitCenterDim(center: v2, dim: v2) rect2 {
        const result = InitCenterHalfDim(center, Scale(dim, 0.5));

        return result;
    }

    pub inline fn GetMinCorner(self: *rect2) v2 {
        const result = self.min;

        return result;
    }

    pub inline fn GetMaxCorner(self: *rect2) v2 {
        const result = self.max;

        return result;
    }

    pub inline fn GetCenter(self: *rect2) v2 {
        const result = Scale(Add(self.max, self.min), 0.5);

        return result;
    }
};

pub inline fn IsInRectangle(rectangle: rect2, testP: v2) bool {
    const result = ((testP.x >= rectangle.min.x) and
        (testP.y >= rectangle.min.y) and
        (testP.x < rectangle.max.x) and
        (testP.y < rectangle.max.y));

    return result;
}

pub inline fn Square(a: f32) f32 {
    const result = a * a;

    return result;
}

pub inline fn LengthSq(a: v2) f32 {
    const result = Inner(a, a);

    return result;
}

pub inline fn AddI32ToU32(a: u32, b: i32) u32 {
    const result = if (b > 0) a + @intCast(u32, b) else a - @intCast(u32, -b);

    return result;
}

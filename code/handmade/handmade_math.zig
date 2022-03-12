pub const v2 = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub inline fn scale(self: *v2, scalar: f32) *v2 {
        self.x *= scalar;
        self.y *= scalar;

        return self;
    }

    pub inline fn add(self: *v2, other: v2) *v2 {
        self.x += other.x;
        self.y += other.y;

        return self;
    }

    pub inline fn sub(self: *v2, other: v2) *v2 {
        self.x -= other.x;
        self.y -= other.y;

        return self;
    }

    pub inline fn neg(self: *v2) *v2 {
        return self.scale(-1);
    }
};

pub inline fn scale(a: v2, scalar: f32) v2 {
    const result = .{
        .x = a.x * scalar,
        .y = a.y * scalar,
    };

    return result;
}

pub inline fn add(a: v2, b: v2) v2 {
    const result = .{
        .x = a.x + b.x,
        .y = a.y + b.y,
    };

    return result;
}

pub inline fn sub(a: v2, b: v2) v2 {
    const result = .{
        .x = a.x - b.x,
        .y = a.y - b.y,
    };

    return result;
}

pub inline fn neg(a: v2) v2 {
    const result = scale(a, -1);

    return result;
}

pub inline fn inner(a: v2, b: v2) f32 {
    const result = a.x * b.x + a.y * b.y;

    return result;
}

pub const rect2 = struct {
    min: v2 = .{},
    max: v2 = .{},

    pub inline fn initMinDim(min: v2, dim: v2) rect2 {
        const result = rect2{
            .min = min,
            .max = add(min, dim),
        };

        return result;
    }

    pub inline fn initCenterHalfDim(center: v2, halfDim: v2) rect2 {
        const result = rect2{
            .min = sub(center, halfDim),
            .max = add(center, halfDim),
        };

        return result;
    }

    pub inline fn initCenterDim(center: v2, dim: v2) rect2 {
        const result = initCenterHalfDim(center, scale(dim, 0.5));

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
    const result = inner(a, a);

    return result;
}

pub inline fn AddI32ToU32(a: u32, b: i32) u32 {
    const result = if (b > 0) a + @intCast(u32, b) else a - @intCast(u32, -b);

    return result;
}

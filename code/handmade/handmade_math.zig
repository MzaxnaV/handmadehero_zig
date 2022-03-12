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

pub inline fn square(a: f32) f32 {
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

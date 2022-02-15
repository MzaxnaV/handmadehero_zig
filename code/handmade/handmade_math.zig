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
    return v2 {
        .x = a.x * scalar,
        .y = a.y * scalar,
    };
}

pub inline fn add(a: v2, b: v2) v2 {
    return v2{
        .x = a.x + b.x,
        .y = a.y + b.y,
    };
}

pub inline fn sub(a: v2, b: v2) v2 {
    return v2{
        .x = a.x - b.x,
        .y = a.y - b.y,
    };
}

pub inline fn neg(a: v2) v2 {
    return scale(a, -1);
}

const DefaultPrng = @import("std").rand.DefaultPrng;

var rand_impl = DefaultPrng.init(32); // NOTE (Manav): fixed for now :)

pub const RandInt = rand_impl.random().int;
pub const RandFloat = rand_impl.random().float;

pub var fixed_rand: struct {
    const size = 1000;

    floats: [size]f32 = [1]f32{0} ** size,
    ints: [size]u32 = [1]u32{0} ** size,
    index: usize = 0,

    const Self = @This();

    pub fn shuffle(self: *Self) void {
        var i = @as(u32, 0);
        while (i < self.floats.len) : (i += 1) {
            self.floats[i] = RandFloat(f32);
            self.ints[i] = RandInt(u32);
        }
    }

    pub inline fn nextFloat(self: *Self) f32 {
        self.index = (self.index + 1) % self.floats.len;
        return self.floats[self.index];
    }

    pub inline fn nextInt(self: *Self) u32 {
        self.index = (self.index + 1) % self.ints.len;
        return self.ints[self.index];
    }
} = .{};

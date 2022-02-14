const DefaultPrng = @import("std").rand.DefaultPrng;

var rand_impl = DefaultPrng.init(21312); // fixed for now :)

pub const RandInt = rand_impl.random().int;

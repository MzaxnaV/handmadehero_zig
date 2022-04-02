const DefaultPrng = @import("std").rand.DefaultPrng;

var rand_impl = DefaultPrng.init(4); // NOTE (Manav): fixed for now :)

pub const RandInt = rand_impl.random().int;

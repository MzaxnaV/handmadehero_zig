const DefaultPrng = @import("std").rand.DefaultPrng;

var rand_impl = DefaultPrng.init(64); // NOTE (Manav): fixed for now :)

pub const RandInt = rand_impl.random().int;

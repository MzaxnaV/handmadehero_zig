const hm = @import("handmade_math.zig");
const hs = @import("handmade_sim_region.zig");

// constants ------------------------------------------------------------------------------------------------------------------------------

pub const Invalid = hm.v3{ 100000, 100000, 100000 };

// functions ------------------------------------------------------------------------------------------------------------------------------

pub inline fn IsSet(entity: *hs.sim_entity, flag: u32) bool {
    const result = entity.flags & flag;

    return (result != 0);
}

pub inline fn AddFlags(entity: *hs.sim_entity, flag: u32) void {
    entity.flags |= flag;
}

pub inline fn ClearFlags(entity: *hs.sim_entity, flag: u32) void {
    entity.flags &= ~flag;
}

pub inline fn MakeEntityNonSpatial(entity: *hs.sim_entity) void {
    AddFlags(entity, @enumToInt(hs.sim_entity_flags.NonSpatial));
    entity.p = Invalid;
}

pub inline fn MakeEntitySpatial(entity: *hs.sim_entity, p: hm.v3, dP: hm.v3) void {
    ClearFlags(entity, @enumToInt(hs.sim_entity_flags.NonSpatial));
    entity.p = p;
    entity.dP = dP;
}

pub inline fn DefaultMoveSpec() hs.move_spec {
    const result = hs.move_spec{
        .unitMaxAccelVector = false,
        .speed = 1,
        .drag = 0,
    };

    return result;
}

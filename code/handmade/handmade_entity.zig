const h = @import("handmade_all.zig");

// imported types -------------------------------------------------------------------------------------------------------------------------------
const platform = @import("platform");
const assert = platform.Assert;
const math = h.math_ns;

const sim_entity = h.sim_region_ns.sim_entity;
const sim_entity_flags = h.sim_region_ns.sim_entity_flags;

// constants ------------------------------------------------------------------------------------------------------------------------------

pub const Invalid = h.v3{ 100000, 100000, 100000 };

// functions ------------------------------------------------------------------------------------------------------------------------------

pub inline fn IsSet(entity: *sim_entity, flag: u32) bool {
    const result = entity.flags & flag;

    return (result != 0);
}

pub inline fn AddFlags(entity: *sim_entity, flag: u32) void {
    entity.flags |= flag;
}

pub inline fn ClearFlags(entity: *sim_entity, flag: u32) void {
    entity.flags &= ~flag;
}

pub inline fn MakeEntityNonSpatial(entity: *sim_entity) void {
    AddFlags(entity, @intFromEnum(sim_entity_flags.NonSpatial));
    entity.p = Invalid;
}

pub inline fn MakeEntitySpatial(entity: *sim_entity, p: h.v3, dP: h.v3) void {
    ClearFlags(entity, @intFromEnum(sim_entity_flags.NonSpatial));
    entity.p = p;
    entity.dP = dP;
}

pub inline fn GetEntityGroundPointForEntityP(_: *sim_entity, forEntityP: h.v3) h.v3 {
    const result = forEntityP;
    return result;
}

pub inline fn GetEntityGroundPoint(entity: *sim_entity) h.v3 {
    const result = GetEntityGroundPointForEntityP(entity, entity.p);
    return result;
}

pub inline fn GetStairGround(entity: *sim_entity, atGroundPoint: h.v3) f32 {
    assert(entity.entityType == .Stairwell);
    const regionRect = h.rect2.InitCenterDim(h.XY(entity.p), entity.walkableDim);
    const bary = h.math_ns.ClampV201(regionRect.GetBarycentric(h.XY(atGroundPoint)));
    const result = h.Z(entity.p) + h.Y(bary) * entity.walkableHeight;

    return result;
}

pub inline fn DefaultMoveSpec() h.sim_region_ns.move_spec {
    const result = h.sim_region_ns.move_spec{
        .unitMaxAccelVector = false,
        .speed = 1,
        .drag = 0,
    };

    return result;
}

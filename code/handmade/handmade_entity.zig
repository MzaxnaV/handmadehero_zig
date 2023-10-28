const assert = @import("handmade_platform").Assert;

const h = struct {
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_sim_region.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

pub const Invalid = h.v3{ 100000, 100000, 100000 };

// functions ------------------------------------------------------------------------------------------------------------------------------

pub inline fn IsSet(entity: *h.sim_entity, flag: u32) bool {
    const result = entity.flags & flag;

    return (result != 0);
}

pub inline fn AddFlags(entity: *h.sim_entity, flag: u32) void {
    entity.flags |= flag;
}

pub inline fn ClearFlags(entity: *h.sim_entity, flag: u32) void {
    entity.flags &= ~flag;
}

pub inline fn MakeEntityNonSpatial(entity: *h.sim_entity) void {
    AddFlags(entity, @intFromEnum(h.sim_entity_flags.NonSpatial));
    entity.p = Invalid;
}

pub inline fn MakeEntitySpatial(entity: *h.sim_entity, p: h.v3, dP: h.v3) void {
    ClearFlags(entity, @intFromEnum(h.sim_entity_flags.NonSpatial));
    entity.p = p;
    entity.dP = dP;
}

pub inline fn GetEntityGroundPointForEntityP(_: *h.sim_entity, forEntityP: h.v3) h.v3 {
    const result = forEntityP;
    return result;
}

pub inline fn GetEntityGroundPoint(entity: *h.sim_entity) h.v3 {
    const result = GetEntityGroundPointForEntityP(entity, entity.p);
    return result;
}

pub inline fn GetStairGround(entity: *h.sim_entity, atGroundPoint: h.v3) f32 {
    assert(entity.entityType == .Stairwell);
    const regionRect = h.rect2.InitCenterDim(h.XY(entity.p), entity.walkableDim);
    const bary = h.ClampV201(regionRect.GetBarycentric(h.XY(atGroundPoint)));
    const result = h.Z(entity.p) + h.Y(bary) * entity.walkableHeight;

    return result;
}

pub inline fn DefaultMoveSpec() h.move_spec {
    const result = h.move_spec{
        .unitMaxAccelVector = false,
        .speed = 1,
        .drag = 0,
    };

    return result;
}

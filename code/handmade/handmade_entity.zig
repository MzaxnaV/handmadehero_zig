const hw = @import("handmade_world.zig");
const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");
const hs = @import("handmade_sim_region.zig");

const SquareRoot = @import("handmade_intrinsics.zig").SquareRoot;

// constants ------------------------------------------------------------------------------------------------------------------------------

pub const Invalid = hm.v2{ .x = 100000, .y = 100000 };

// functions ------------------------------------------------------------------------------------------------------------------------------

pub inline fn IsSet(entity: *hs.sim_entity, flag: u32) bool {
    const result = entity.flags & flag;

    return (result != 0);
}

pub inline fn AddFlag(entity: *hs.sim_entity, flag: u32) void {
    entity.flags |= flag;
}

pub inline fn ClearFlag(entity: *hs.sim_entity, flag: u32) void {
    entity.flags &= ~flag;
}

pub inline fn MakeEntityNonSpatial(entity: *hs.sim_entity) void {
    AddFlag(entity, @enumToInt(hs.sim_entity_flags.NonSpatial));
    entity.p = Invalid;
}

pub inline fn MakeEntitySpatial(entity: *hs.sim_entity, p: hm.v2, dP: hm.v2) void {
    ClearFlag(entity, @enumToInt(hs.sim_entity_flags.NonSpatial));
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

pub inline fn UpdateFamiliar(simRegion: *hs.sim_region, entity: *hs.sim_entity, dt: f32) void {
    var closestHero: ?*hs.sim_entity = null;
    var closestHeroDSq = hm.Square(10);

    const testEntity: *hs.sim_entity = &simRegion.entities[0];
    var testEntityIndex = @as(u32, 0);
    while (testEntityIndex < simRegion.entityCount) : (testEntityIndex += 1) {
        if (testEntity.entityType == .Hero) {
            var testDSq = hm.LengthSq(hm.Sub(testEntity.p, entity.p));
            if (testEntity.entityType == .Hero) {
                testDSq *= 0.75;
            }

            if (closestHeroDSq > testDSq) {
                closestHero = testEntity;
                closestHeroDSq = testDSq;
            }
        }
    }

    var dPP: hm.v2 = .{};
    if (closestHero) |hero| {
        if (closestHeroDSq > hm.Square(3)) {
            const accelaration = 0.5;
            const oneOverLength = accelaration / SquareRoot(closestHeroDSq);
            dPP = hm.Scale(hm.Sub(hero.p, entity.p), oneOverLength);
        }
    }

    var moveSpec = DefaultMoveSpec();
    moveSpec.unitMaxAccelVector = true;
    moveSpec.speed = 50;
    moveSpec.drag = 8;

    hs.MoveEntity(simRegion, entity, dt, &moveSpec, dPP);
}

pub inline fn UpdateMonstar(_: *hs.sim_region, _: *hs.sim_entity, _: f32) void {}

pub inline fn UpdateSword(simRegion: *hs.sim_region, entity: *hs.sim_entity, dt: f32) void {
    if (IsSet(entity, @enumToInt(hs.sim_entity_flags.NonSpatial))) {} else {
        var moveSpec = DefaultMoveSpec();
        moveSpec.unitMaxAccelVector = false;
        moveSpec.speed = 0;
        moveSpec.drag = 0;

        const oldP = entity.p;
        hs.MoveEntity(simRegion, entity, dt, &moveSpec, .{});
        const distanceTravelled = hm.Length(hm.Sub(entity.p, oldP));

        entity.distanceRemaining -= distanceTravelled;
        if (entity.distanceRemaining < 0) {
            MakeEntityNonSpatial(entity);
        }
    }
}

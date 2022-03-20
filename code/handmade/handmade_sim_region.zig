const std = @import("std");

const hw = @import("handmade_world.zig");
const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");
const he = @import("handmade_entity.zig");

const AbsoluteValue = @import("handmade_intrinsics.zig").AbsoluteValue;
const SquareRoot = @import("handmade_intrinsics.zig").SquareRoot;

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;

pub const HIT_POINT_SUB_COUNT = 4;

// sim region data types ------------------------------------------------------------------------------------------------------------------

pub const move_spec = struct {
    unitMaxAccelVector: bool,
    speed: f32,
    drag: f32,
};

pub const entity_type = enum {
    Null,

    Hero,
    Wall,
    Familiar,
    Monstar,
    Sword,
};

pub const hit_point = struct {
    flags: u8 = 0,
    filledAmount: u8 = 0,
};

const entity_ref_tag = enum {
    ptr,
    index,
};

pub const entity_reference = union(entity_ref_tag) {
    ptr: *sim_entity,
    index: u32,
};

pub const sim_entity_flags = enum(u32) {
    Collides = 1 << 1,
    NonSpatial = 1 << 2,

    Simming = 1 << 30,
};

pub const sim_entity = struct {
    storageIndex: u32 = 0,

    entityType: entity_type,
    flags: u32 = 0,

    p: hm.v2 = .{},
    dP: hm.v2 = .{},

    z: f32 = 0,
    dZ: f32 = 0,

    chunkZ: u32 = 0,

    width: f32 = 0,
    height: f32 = 0,

    facingDirection: u32 = 0,
    tBob: f32 = 0,

    dAbsTileZ: i32 = 0,

    hitPointMax: u32 = 0,
    hitPoint: [16]hit_point = [1]hit_point{.{}} ** 16,

    sword: entity_reference = .{ .index = 0 },
    distanceRemaining: f32 = 0,
};

pub const sim_entity_hash = struct {
    ptr: ?*sim_entity,
    index: u32,
};

pub const sim_region = struct {
    world: *hw.world,

    origin: hw.world_position,
    bounds: hm.rect2,

    maxEntityCount: u32,
    entityCount: u32,
    entities: [*]sim_entity,

    hash: [4096]sim_entity_hash,
};

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn GetHashFromStorageIndex(simRegion: *sim_region, storageIndex: u32) *sim_entity_hash {
    std.debug.assert(storageIndex > 0);

    var result: *sim_entity_hash = undefined;

    const hashValue = storageIndex;
    var offset = @as(u32, 0);
    while (offset < simRegion.hash.len) : (offset += 1) {
        const hashMask = (simRegion.hash.len - 1);
        const hashIndex = (hashValue + offset) & hashMask;
        const entity = &simRegion.hash[hashIndex];
        if ((entity.index == 0) or (entity.index == storageIndex)) {
            result = entity;
            break;
        }
    }

    return result;
}

pub inline fn GetEntityByStorageIndex(simRegion: *sim_region, storageIndex: u32) ?*sim_entity {
    var entry = GetHashFromStorageIndex(simRegion, storageIndex);
    const result = entry.ptr;
    return result;
}

pub inline fn LoadEntityReference(gameState: *hi.state, simRegion: *sim_region, ref: *entity_reference) void {
    switch (ref.*) {
        .index => {
            if (ref.index > 0) {
                var entry = GetHashFromStorageIndex(simRegion, ref.index);
                if (entry.ptr) |_| {} else {
                    entry.index = ref.index;
                    entry.ptr = AddEntity(gameState, simRegion, ref.index, hi.GetLowEntity(gameState, ref.index), null);
                }

                ref.* = entity_reference{ .ptr = entry.ptr.? };
            }
        },

        else => {},
    }
}

pub inline fn StoreEntityReference(ref: *entity_reference) void {
    switch (ref.*) {
        .ptr => {
            const ptr = ref.ptr;
            ref.* = entity_reference{ .index = ptr.storageIndex };
        },

        else => {},
    }
}

pub fn AddEntityRaw(gameState: *hi.state, simRegion: *sim_region, storageIndex: u32, source: ?*hi.low_entity) ?*sim_entity {
    std.debug.assert(storageIndex > 0);
    var entity: ?*sim_entity = null;

    const entry = GetHashFromStorageIndex(simRegion, storageIndex);

    if (entry.ptr) |_| {} else {
        if (simRegion.entityCount < simRegion.maxEntityCount) {
            entity = &simRegion.entities[simRegion.entityCount];
            simRegion.entityCount += 1;

            entry.index = storageIndex;
            entry.ptr = entity;

            if (source) |lowEntity| {
                entity.?.* = lowEntity.sim;
                LoadEntityReference(gameState, simRegion, &entity.?.sword);

                std.debug.assert(!he.IsSet(&lowEntity.sim, @enumToInt(sim_entity_flags.Simming)));
                he.AddFlag(&lowEntity.sim, @enumToInt(sim_entity_flags.Simming));
            }

            entity.?.storageIndex = storageIndex;
        } else {
            unreachable;
        }
    }

    return entity;
}

pub inline fn GetSimSpaceP(simRegion: *sim_region, stored: *hi.low_entity) hm.v2 {
    var result = he.Invalid;
    if (!he.IsSet(&stored.sim, @enumToInt(sim_entity_flags.NonSpatial))) {
        const diff = hw.Substract(simRegion.world, &stored.p, &simRegion.origin);
        result = diff.dXY;
    }

    return result;
}

pub fn AddEntity(gameState: *hi.state, simRegion: *sim_region, storageIndex: u32, source: ?*hi.low_entity, simP: ?*hm.v2) ?*sim_entity {
    var dest = AddEntityRaw(gameState, simRegion, storageIndex, source);
    if (dest) |_| {
        if (simP) |_| {
            dest.?.p = simP.?.*;
        } else {
            dest.?.p = GetSimSpaceP(simRegion, source.?);
        }
    }

    return dest;
}

pub fn BeginSim(simArena: *hi.memory_arena, gameState: *hi.state, world: *hw.world, origin: hw.world_position, bounds: hm.rect2) *sim_region {
    var simRegion: *sim_region = simArena.PushStruct(sim_region);
    hi.ZeroStruct([4096]sim_entity_hash, &simRegion.hash);
    simRegion.world = world;
    simRegion.origin = origin;
    simRegion.bounds = bounds;

    simRegion.maxEntityCount = 4096;
    simRegion.entityCount = 0;
    simRegion.entities = simArena.PushArrayPtr(sim_entity, simRegion.maxEntityCount);

    const minChunkP = hw.MapIntoChunkSpace(world, simRegion.origin, simRegion.bounds.GetMinCorner());
    const maxChunkP = hw.MapIntoChunkSpace(world, simRegion.origin, simRegion.bounds.GetMaxCorner());

    var chunkY = minChunkP.chunkY;
    while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
        var chunkX = minChunkP.chunkX;
        while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
            if (hw.GetWorldChunk(null, world, chunkX, chunkY, simRegion.origin.chunkZ)) |chunk| {
                // @breakpoint();
                var block: ?*hw.world_entity_block = &chunk.firstBlock;
                while (block) |b| : (block = b.next) {
                    var entityIndexIndex = @as(u32, 0);
                    while (entityIndexIndex < b.entityCount) : (entityIndexIndex += 1) {
                        const lowEntityIndex = b.lowEntityIndex[entityIndexIndex];
                        const low = &gameState.lowEntities[lowEntityIndex];
                        if (!he.IsSet(&low.sim, @enumToInt(sim_entity_flags.NonSpatial))) {
                            var simSpaceP = GetSimSpaceP(simRegion, low);
                            if (hm.IsInRectangle(simRegion.bounds, simSpaceP)) {
                                _ = AddEntity(gameState, simRegion, lowEntityIndex, low, &simSpaceP);
                            }
                        }
                    }
                }
            }
        }
    }

    return simRegion;
}

pub fn EndSim(region: *sim_region, gameState: *hi.state) void {
    var entityIndex = @as(u32, 0);
    while (entityIndex < region.entityCount) : (entityIndex += 1) {
        const entity: *sim_entity = &region.entities[entityIndex];
        const stored = &gameState.lowEntities[entity.storageIndex];

        std.debug.assert(he.IsSet(&stored.sim, @enumToInt(sim_entity_flags.Simming)));
        stored.sim = entity.*;
        std.debug.assert(!he.IsSet(&stored.sim, @enumToInt(sim_entity_flags.Simming)));

        StoreEntityReference(&stored.sim.sword);

        const newP = if (he.IsSet(entity, @enumToInt(sim_entity_flags.NonSpatial)))
            hw.NullPosition()
        else
            hw.MapIntoChunkSpace(gameState.world, region.origin, entity.p);
        hw.ChangeEntityLocation(&gameState.worldArena, gameState.world, entity.storageIndex, stored, newP);

        if (entity.storageIndex == gameState.cameraFollowingEntityIndex) {
            var newCameraP = gameState.cameraP;
            newCameraP.chunkZ = stored.p.chunkZ;

            if (!NOT_IGNORE) {
                // if (cameraFollowingEntity.high.?.p.x > (9 * world.tileSideInMeters)) {
                //     newCameraP.absTileX += 17;
                // }
                // if (cameraFollowingEntity.high.?.p.x < -(9 * world.tileSideInMeters)) {
                //     newCameraP.absTileX -%= 17;
                // }
                // if (cameraFollowingEntity.high.?.p.y > (5 * world.tileSideInMeters)) {
                //     newCameraP.absTileY += 9;
                // }
                // if (cameraFollowingEntity.high.?.p.y < -(5 * world.tileSideInMeters)) {
                //     newCameraP.absTileY -%= 9;
                // }
            } else {
                newCameraP = stored.p;
            }

            gameState.cameraP = newCameraP;
        }
    }
}

pub fn TestWall(wallX: f32, relX: f32, relY: f32, playerDeltaX: f32, playerDeltaY: f32, tMin: *f32, minY: f32, maxY: f32) bool {
    var hit = false;

    const tEpsilon = 0.001;
    if (playerDeltaX != 0) {
        const tResult = (wallX - relX) / playerDeltaX;
        const y = relY + tResult * playerDeltaY;

        if ((tResult >= 0) and (tMin.* > tResult)) {
            if ((y >= minY) and (y <= maxY)) {
                tMin.* = @maximum(0, tResult - tEpsilon);
                hit = true;
            }
        }
    }

    return hit;
}

pub fn MoveEntity(simRegion: *sim_region, entity: *sim_entity, dt: f32, moveSpec: *const move_spec, accelaration: hm.v2) void {
    std.debug.assert(!he.IsSet(entity, @enumToInt(sim_entity_flags.NonSpatial)));

    var ddP = accelaration;
    // const world = gameState.world;

    if (moveSpec.unitMaxAccelVector) {
        const ddPLength = hm.LengthSq(ddP);
        if (ddPLength > 1.0) {
            _ = ddP.Scale(1.0 / SquareRoot(ddPLength));
        }
    }

    _ = ddP.Scale(moveSpec.speed);

    _ = ddP.Add(hm.Scale(entity.dP, -moveSpec.drag)); // NOTE (Manav): ddP += -moveSpec.drag * entity.dP;

    // const oldPlayerP = entity.p;
    // NOTE (Manav): playerDelta = (0.5 * ddP * square(dt)) + entity.dP * dt;
    var playerDelta = hm.Add(hm.Scale(ddP, 0.5 * hm.Square(dt)), hm.Scale(entity.dP, dt));
    _ = entity.dP.Add(hm.Scale(ddP, dt)); // NOTE (Manav): entity.dP += ddP * dt;
    // const newPlayerP = hm.Add(oldPlayerP, playerDelta);

    var iteration = @as(u32, 0);
    while (iteration < 4) : (iteration += 1) {
        var tMin = @as(f32, 1.0);
        var wallNormal = hm.v2{};
        var hitEntity: ?*sim_entity = null;

        const desiredPosition = hm.Add(entity.p, playerDelta);

        if (he.IsSet(entity, @enumToInt(sim_entity_flags.Collides)) and !he.IsSet(entity, @enumToInt(sim_entity_flags.NonSpatial))) {
            var testHighEntityIndex = @as(u32, 0);
            while (testHighEntityIndex < simRegion.entityCount) : (testHighEntityIndex += 1) {
                const testEntity = &simRegion.entities[testHighEntityIndex];
                if (entity != testEntity) {
                    if (he.IsSet(testEntity, @enumToInt(sim_entity_flags.Collides)) and !he.IsSet(entity, @enumToInt(sim_entity_flags.NonSpatial))) {
                        const diameterW = testEntity.width + entity.width;
                        const diameterH = testEntity.height + entity.height;

                        const minCorner = hm.v2{ .x = -0.5 * diameterW, .y = -0.5 * diameterH };
                        const maxCorner = hm.v2{ .x = 0.5 * diameterW, .y = 0.5 * diameterH };

                        const rel = hm.Sub(entity.p, testEntity.p);

                        if (TestWall(minCorner.x, rel.x, rel.y, playerDelta.x, playerDelta.y, &tMin, minCorner.y, maxCorner.y)) {
                            wallNormal = .{ .x = -1, .y = 0 };
                            hitEntity = testEntity;
                        }
                        if (TestWall(maxCorner.x, rel.x, rel.y, playerDelta.x, playerDelta.y, &tMin, minCorner.y, maxCorner.y)) {
                            wallNormal = .{ .x = 1, .y = 0 };
                            hitEntity = testEntity;
                        }
                        if (TestWall(minCorner.y, rel.y, rel.x, playerDelta.y, playerDelta.x, &tMin, minCorner.x, maxCorner.x)) {
                            wallNormal = .{ .x = 0, .y = -1 };
                            hitEntity = testEntity;
                        }
                        if (TestWall(maxCorner.y, rel.y, rel.x, playerDelta.y, playerDelta.x, &tMin, minCorner.x, maxCorner.x)) {
                            wallNormal = .{ .x = 0, .y = 1 };
                            hitEntity = testEntity;
                        }
                    }
                }
            }
        }

        _ = entity.p.Add(hm.Scale(playerDelta, tMin));
        if (hitEntity) |_| {
            // NOTE (Manav): entity.dP -= (1 * Inner(entity.dP, wallNormal))*wallNormal;
            _ = entity.dP.Sub(hm.Scale(wallNormal, 1 * hm.Inner(entity.dP, wallNormal)));
            playerDelta = hm.Sub(desiredPosition, entity.p);
            // NOTE (Manav): playerDelta -= (1 * Inner(playerDelta, wallNormal))*wallNormal;
            _ = playerDelta.Sub(hm.Scale(wallNormal, 1 * hm.Inner(playerDelta, wallNormal)));

            // entity.absTileZ = hm.AddI32ToU32(entity.absTileZ, hitLow.dAbsTileZ);
        } else {
            break;
        }
    }

    if ((entity.dP.x == 0) and (entity.dP.y == 0)) {
        // NOTE(casey): Leave FacingDirection whatever it was
    } else if (AbsoluteValue(entity.dP.x) > AbsoluteValue(entity.dP.y)) {
        if (entity.dP.x > 0) {
            entity.facingDirection = 0;
        } else {
            entity.facingDirection = 2;
        }
    } else {
        if (entity.dP.y > 0) {
            entity.facingDirection = 1;
        } else {
            entity.facingDirection = 3;
        }
    }
}

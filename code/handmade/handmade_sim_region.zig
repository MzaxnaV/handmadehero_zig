const assert = @import("std").debug.assert;

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
    Stairwell,
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
    Collides = 1 << 0,
    NonSpatial = 1 << 1,
    Movable = 1 << 2,

    Simming = 1 << 30,
};

pub const sim_entity = struct {
    storageIndex: u32 = 0,
    updatable: bool = false,

    entityType: entity_type,
    flags: u32 = 0,

    p: hm.v3 = hm.v3{ 0, 0, 0 },
    dP: hm.v3 = hm.v3{ 0, 0, 0 },

    distanceLimit: f32 = 0,
    dim: hm.v3 = hm.v3{ 0, 0, 0 },

    facingDirection: u32 = 0,
    tBob: f32 = 0,

    dAbsTileZ: i32 = 0,

    hitPointMax: u32 = 0,
    hitPoint: [16]hit_point = [1]hit_point{.{}} ** 16,

    sword: entity_reference = .{ .index = 0 },
};

pub const sim_entity_hash = struct {
    ptr: ?*sim_entity,
    index: u32,
};

pub const sim_region = struct {
    world: *hw.world,
    maxEntityRadius: f32,
    maxEntityVelocity: f32,

    origin: hw.world_position,
    bounds: hm.rect3,
    updatableBounds: hm.rect3,

    maxEntityCount: u32,
    entityCount: u32,
    entities: [*]sim_entity,

    hash: [4096]sim_entity_hash,
};

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn GetHashFromStorageIndex(simRegion: *sim_region, storageIndex: u32) *sim_entity_hash {
    assert(storageIndex > 0);

    var result: *sim_entity_hash = undefined;

    const hashValue = storageIndex;
    var offset = @as(u32, 0);
    while (offset < simRegion.hash.len) : (offset += 1) {
        const hashMask = (simRegion.hash.len - 1);
        const hashIndex = (hashValue + offset) & hashMask;
        const entry = &simRegion.hash[hashIndex];
        if ((entry.index == 0) or (entry.index == storageIndex)) {
            result = entry;
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
                    const lowEntity = hi.GetLowEntity(gameState, ref.index);
                    const p = GetSimSpaceP(simRegion, lowEntity.?);
                    entry.ptr = AddEntity(gameState, simRegion, ref.index, hi.GetLowEntity(gameState, ref.index), &p);
                }

                ref.* = entity_reference{ .ptr = entry.ptr.? };
            }
        },

        .ptr => {},
    }
}

pub inline fn StoreEntityReference(ref: *entity_reference) void {
    switch (ref.*) {
        .ptr => {
            const ptr = ref.ptr;
            ref.* = entity_reference{ .index = ptr.storageIndex };
        },

        .index => {},
    }
}

fn AddEntityRaw(gameState: *hi.state, simRegion: *sim_region, storageIndex: u32, source: ?*hi.low_entity) ?*sim_entity {
    assert(storageIndex > 0);
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

                assert(!he.IsSet(&lowEntity.sim, @enumToInt(sim_entity_flags.Simming)));
                he.AddFlags(&lowEntity.sim, @enumToInt(sim_entity_flags.Simming));
            }

            entity.?.storageIndex = storageIndex;
            entity.?.updatable = false;
        } else {
            unreachable;
        }
    }

    return entity;
}

pub inline fn EntityOverlapsRectangle(p: hm.v3, dim: hm.v3, rect: hm.rect3) bool {
    const grown = hm.AddRadiusToRect3(rect, dim * @splat(3, @as(f32, 0.5)));
    const result = hm.IsInRect3(grown, p);
    return result;
}

pub fn AddEntity(gameState: *hi.state, simRegion: *sim_region, storageIndex: u32, source: ?*hi.low_entity, simP: ?*const hm.v3) ?*sim_entity {
    var dest = AddEntityRaw(gameState, simRegion, storageIndex, source);
    if (dest) |_| {
        if (simP) |_| {
            dest.?.p = simP.?.*;
            dest.?.updatable = EntityOverlapsRectangle(dest.?.p, dest.?.dim, simRegion.updatableBounds);
        } else {
            dest.?.p = GetSimSpaceP(simRegion, source.?);
        }
    }

    return dest;
}

pub inline fn GetSimSpaceP(simRegion: *sim_region, stored: *hi.low_entity) hm.v3 {
    var result = he.Invalid;
    if (!he.IsSet(&stored.sim, @enumToInt(sim_entity_flags.NonSpatial))) {
        result = hw.Substract(simRegion.world, &stored.p, &simRegion.origin);
    }

    return result;
}

pub fn BeginSim(simArena: *hi.memory_arena, gameState: *hi.state, world: *hw.world, origin: hw.world_position, bounds: hm.rect3, dt: f32) *sim_region {
    var simRegion: *sim_region = simArena.PushStruct(sim_region);
    hi.ZeroStruct([4096]sim_entity_hash, &simRegion.hash);

    simRegion.maxEntityRadius = 5.0;
    simRegion.maxEntityVelocity = 30.0;
    const updateSafetyMargin = simRegion.maxEntityRadius + dt * simRegion.maxEntityVelocity;
    const updateSafetyMarginZ = 1.0;

    simRegion.world = world;
    simRegion.origin = origin;
    simRegion.updatableBounds = hm.AddRadiusToRect3(bounds, .{ simRegion.maxEntityRadius, simRegion.maxEntityRadius, simRegion.maxEntityRadius });
    simRegion.bounds = hm.AddRadiusToRect3(simRegion.updatableBounds, .{ updateSafetyMargin, updateSafetyMargin, updateSafetyMarginZ });

    simRegion.maxEntityCount = 4096;
    simRegion.entityCount = 0;
    simRegion.entities = simArena.PushArrayPtr(sim_entity, simRegion.maxEntityCount);

    const minChunkP = hw.MapIntoChunkSpace(world, simRegion.origin, simRegion.bounds.GetMinCorner());
    const maxChunkP = hw.MapIntoChunkSpace(world, simRegion.origin, simRegion.bounds.GetMaxCorner());

    var chunkZ = minChunkP.chunkZ;
    while (chunkZ <= maxChunkP.chunkZ) : (chunkZ += 1) {
        var chunkY = minChunkP.chunkY;
        while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
            var chunkX = minChunkP.chunkX;
            while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
                if (hw.GetWorldChunk(null, world, chunkX, chunkY, chunkZ)) |chunk| {
                    var block: ?*hw.world_entity_block = &chunk.firstBlock;
                    while (block) |b| : (block = b.next) {
                        var entityIndexIndex = @as(u32, 0);
                        while (entityIndexIndex < b.entityCount) : (entityIndexIndex += 1) {
                            const lowEntityIndex = b.lowEntityIndex[entityIndexIndex];
                            const low = &gameState.lowEntities[lowEntityIndex];
                            if (!he.IsSet(&low.sim, @enumToInt(sim_entity_flags.NonSpatial))) {
                                var simSpaceP = GetSimSpaceP(simRegion, low);
                                if (EntityOverlapsRectangle(simSpaceP, low.sim.dim, simRegion.bounds)) {
                                    _ = AddEntity(gameState, simRegion, lowEntityIndex, low, &simSpaceP);
                                }
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

        assert(he.IsSet(&stored.sim, @enumToInt(sim_entity_flags.Simming)));
        stored.sim = entity.*;
        assert(!he.IsSet(&stored.sim, @enumToInt(sim_entity_flags.Simming)));

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
                // if (cameraFollowingEntity.high.?.p[0] > (9 * world.tileSideInMeters)) {
                //     newCameraP.absTileX += 17;
                // }
                // if (cameraFollowingEntity.high.?.p[0] < -(9 * world.tileSideInMeters)) {
                //     newCameraP.absTileX -%= 17;
                // }
                // if (cameraFollowingEntity.high.?.p[1] > (5 * world.tileSideInMeters)) {
                //     newCameraP.absTileY += 9;
                // }
                // if (cameraFollowingEntity.high.?.p[1] < -(5 * world.tileSideInMeters)) {
                //     newCameraP.absTileY -%= 9;
                // }
            } else {
                const camZOffset = newCameraP.offset_[2];
                newCameraP = stored.p;
                newCameraP.offset_[2] = camZOffset;
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

fn CanCollide(gameState: *hi.state, unsortedA: *sim_entity, unsortedB: *sim_entity) bool {
    var result = false;

    var a = unsortedA;
    var b = unsortedB;

    if (a != b) {
        if (a.storageIndex > b.storageIndex) {
            b = unsortedA;
            a = unsortedB;
        }

        if (!he.IsSet(a, @enumToInt(sim_entity_flags.NonSpatial)) and
            !he.IsSet(b, @enumToInt(sim_entity_flags.NonSpatial)))
        {
            result = true;
        }

        if ((a.entityType == .Stairwell)) {
            result = false;
        }

        const hashBucket = a.storageIndex & (gameState.collisionRuleHash.len - 1);
        var rule: ?*hi.pairwise_collision_rule = gameState.collisionRuleHash[hashBucket];
        while (rule) |r| : (rule = r.nextInHash) {
            if ((r.storageIndexA == a.storageIndex) and (r.storageIndexB == b.storageIndex)) {
                result = r.canCollide;
                break;
            }
        }
    }

    return result;
}

fn HandleCollision(gameState: *hi.state, unsortedA: *sim_entity, unsortedB: *sim_entity) bool {
    var stopsOnCollision = false;

    if (unsortedA.entityType == .Sword) {
        hi.AddCollisionRule(gameState, unsortedA.storageIndex, unsortedB.storageIndex, false);
        stopsOnCollision = false;
    } else {
        stopsOnCollision = true;
    }

    var a = unsortedA;
    var b = unsortedB;
    if (@enumToInt(a.entityType) > @enumToInt(b.entityType)) {
        b = unsortedA;
        a = unsortedB;
    }

    if ((a.entityType == .Monstar) and (b.entityType == .Sword)) {
        if (a.hitPointMax > 0) {
            a.hitPointMax -= 1;
        }
    }

    // entity.absTileZ = hm.AddI32ToU32(entity.absTileZ, hitLow.dAbsTileZ);

    return stopsOnCollision;
}

pub fn CanOverlap(_: *hi.state, mover: *sim_entity, region: *sim_entity) bool {
    var result = false;

    if (mover != region) {
        if (region.entityType == .Stairwell) {
            result = true;
        }
    }

    return result;
}

pub fn HandleOverlap(_: *hi.state, mover: *sim_entity, region: *sim_entity, _: f32, ground: *f32) void {
    if (region.entityType == .Stairwell) {
        const regionRect = hm.rect3.InitCenterDim(region.p, region.dim);
        const bary = hm.ClampV01(hm.VN3(hm.GetBarycentric(regionRect, mover.p)));
        ground.* = hm.Lerp(hm.VN3(regionRect.min).Z(), bary.Y(), hm.VN3(regionRect.max).Z());
    }
}

pub fn MoveEntity(gameState: *hi.state, simRegion: *sim_region, entity: *sim_entity, dt: f32, moveSpec: *const move_spec, accelaration: hm.v3) void {
    assert(!he.IsSet(entity, @enumToInt(sim_entity_flags.NonSpatial)));

    var ddP = accelaration;
    // const world = gameState.world;

    if (moveSpec.unitMaxAccelVector) {
        const ddPLength = hm.LengthSq(hm.VN3(ddP));
        if (ddPLength > 1.0) {
            ddP *= @splat(3, 1.0 / SquareRoot(ddPLength));
        }
    }

    ddP *= hm.v3{ moveSpec.speed, moveSpec.speed, moveSpec.speed };
    ddP += entity.dP * hm.v3{ -moveSpec.drag, -moveSpec.drag, -moveSpec.drag };
    ddP += hm.v3{ 0, 0, -9.8 };

    // const oldPlayerP = entity.p;
    // NOTE (Manav): playerDelta = (0.5 * ddP * square(dt)) + entity.dP * dt;
    var playerDelta = (ddP * @splat(3, 0.5 * hm.Square(dt))) + entity.dP * hm.v3{ dt, dt, dt };
    entity.dP += ddP * hm.v3{ dt, dt, dt };
    assert(hm.LengthSq(hm.VN3(entity.dP)) <= hm.Square(simRegion.maxEntityVelocity));
    // const newPlayerP = oldPlayerP + playerDelta;

    var distanceRemaining = entity.distanceLimit;
    if (distanceRemaining == 0) {
        distanceRemaining = 10000.0;
    }

    var iteration = @as(u32, 0);
    while (iteration < 4) : (iteration += 1) {
        var tMin = @as(f32, 1.0);
        const playerDeltaLength = hm.Length(hm.VN3(playerDelta));
        if (playerDeltaLength > 0) {
            if (playerDeltaLength > distanceRemaining) {
                tMin = distanceRemaining / playerDeltaLength;
            }
            var wallNormal = hm.v3{ 0, 0, 0 };
            var hitEntity: ?*sim_entity = null;

            const desiredPosition = entity.p + playerDelta;

            if (!he.IsSet(entity, @enumToInt(sim_entity_flags.NonSpatial))) {
                var testHighEntityIndex = @as(u32, 0);
                while (testHighEntityIndex < simRegion.entityCount) : (testHighEntityIndex += 1) {
                    const testEntity = &simRegion.entities[testHighEntityIndex];
                    if (CanCollide(gameState, entity, testEntity) and (testEntity.p[2] == entity.p[2])) {
                        const testEntityDim = hm.VN3(testEntity.dim);
                        const entityDim = hm.VN3(entity.dim);
                        const minkowskiDiameter: hm.v3 = .{
                            testEntityDim.X() + entityDim.X(),
                            testEntityDim.Y() + entityDim.Y(),
                            testEntityDim.Z() + entityDim.Z(),
                        };

                        const minCorner = hm.v3{ -0.5, -0.5, -0.5 } * minkowskiDiameter;
                        const maxCorner = hm.v3{ 0.5, 0.5, 0.5 } * minkowskiDiameter;

                        const rel = entity.p - testEntity.p;

                        if (TestWall(minCorner[0], rel[0], rel[1], playerDelta[0], playerDelta[1], &tMin, minCorner[1], maxCorner[1])) {
                            wallNormal = .{ -1, 0, 0 };
                            hitEntity = testEntity;
                        }
                        if (TestWall(maxCorner[0], rel[0], rel[1], playerDelta[0], playerDelta[1], &tMin, minCorner[1], maxCorner[1])) {
                            wallNormal = .{ 1, 0, 0 };
                            hitEntity = testEntity;
                        }
                        if (TestWall(minCorner[1], rel[1], rel[0], playerDelta[1], playerDelta[0], &tMin, minCorner[0], maxCorner[0])) {
                            wallNormal = .{ 0, -1, 0 };
                            hitEntity = testEntity;
                        }
                        if (TestWall(maxCorner[1], rel[1], rel[0], playerDelta[1], playerDelta[0], &tMin, minCorner[0], maxCorner[0])) {
                            wallNormal = .{ 0, 1, 0 };
                            hitEntity = testEntity;
                        }
                    }
                }
            }

            entity.p += hm.v3{ tMin, tMin, tMin } * playerDelta;
            distanceRemaining -= tMin * playerDeltaLength;
            if (hitEntity) |_| {
                playerDelta = desiredPosition - entity.p;

                const stopsOnCollision = HandleCollision(gameState, entity, hitEntity.?);
                if (stopsOnCollision) {
                    // NOTE (Manav): playerDelta -= (1 * Inner(playerDelta, wallNormal))*wallNormal;
                    playerDelta -= @splat(3, 1 * hm.Inner(hm.VN3(playerDelta), hm.VN3(wallNormal))) * wallNormal;
                    // NOTE (Manav): entity.dP -= (1 * Inner(entity.dP, wallNormal))*wallNormal;
                    entity.dP -= @splat(3, 1 * hm.Inner(hm.VN3(entity.dP), hm.VN3(wallNormal))) * wallNormal;
                }
            } else {
                break;
            }
        } else {
            break;
        }
    }

    var ground = @as(f32, 0);

    {
        const entityRect = hm.rect3.InitCenterDim(entity.p, entity.dim);
        var testHighEntityIndex = @as(u32, 0);
        while (testHighEntityIndex < simRegion.entityCount) : (testHighEntityIndex += 1) {
            const testEntity = &simRegion.entities[testHighEntityIndex];
            if (CanOverlap(gameState, entity, testEntity)) {
                const testEntityRect = hm.rect3.InitCenterDim(testEntity.p, testEntity.dim);
                if (hm.RectanglesIntersect(entityRect, testEntityRect)) {
                    HandleOverlap(gameState, entity, testEntity, dt, &ground);
                }
            }
        }
        _ = entityRect;
    }

    if (entity.p[2] < ground) {
        entity.p[2] = ground;
        entity.dP[2] = 0;
    }

    if (entity.distanceLimit != 0) {
        entity.distanceLimit = distanceRemaining;
    }

    if ((entity.dP[0] == 0) and (entity.dP[1] == 0)) {
        // NOTE(casey): Leave FacingDirection whatever it was
    } else if (AbsoluteValue(entity.dP[0]) > AbsoluteValue(entity.dP[1])) {
        if (entity.dP[0] > 0) {
            entity.facingDirection = 0;
        } else {
            entity.facingDirection = 2;
        }
    } else {
        if (entity.dP[1] > 0) {
            entity.facingDirection = 1;
        } else {
            entity.facingDirection = 3;
        }
    }
}

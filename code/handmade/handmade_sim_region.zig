const platform = @import("handmade_platform");

const assert = platform.Assert;

const h = struct {
    usingnamespace @import("handmade_world.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_entity.zig");
    usingnamespace @import("handmade_intrinsics.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = platform.NOT_IGNORE;

pub const HIT_POINT_SUB_COUNT = 4;

// sim region data types ------------------------------------------------------------------------------------------------------------------

pub const move_spec = struct {
    unitMaxAccelVector: bool,
    speed: f32,
    drag: f32,
};

pub const entity_type = enum {
    Null,

    Space,

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
    ZSupported = 1 << 3,
    Traversable = 1 << 4,

    Simming = 1 << 30,
};

pub const sim_entity_collision_volume = struct {
    offsetP: h.v3,
    dim: h.v3,
};

pub const sim_entity_collision_volume_group = struct {
    totalVolume: sim_entity_collision_volume,

    volumeCount: u32,
    volumes: [*]sim_entity_collision_volume,
};

pub const sim_entity = struct {
    storageIndex: u32 = 0,
    updatable: bool = false,

    entityType: entity_type,
    flags: u32 = 0,

    p: h.v3 = h.v3{ 0, 0, 0 },
    dP: h.v3 = h.v3{ 0, 0, 0 },

    distanceLimit: f32 = 0,
    collision: *sim_entity_collision_volume_group,

    facingDirection: f32 = 0,
    tBob: f32 = 0,

    dAbsTileZ: i32 = 0,

    hitPointMax: u32 = 0,
    hitPoint: [16]hit_point = [1]hit_point{.{}} ** 16,

    sword: entity_reference = .{ .index = 0 },

    walkableDim: h.v2 = h.v2{ 0, 0 },
    walkableHeight: f32 = 0,
};

pub const sim_entity_hash = struct {
    ptr: ?*sim_entity,
    index: u32,
};

pub const sim_region = struct {
    world: *h.world,
    maxEntityRadius: f32,
    maxEntityVelocity: f32,

    origin: h.world_position,
    bounds: h.rect3,
    updatableBounds: h.rect3,

    maxEntityCount: u32,
    entityCount: u32,
    entities: [*]sim_entity,

    groundZBase: f32,

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

pub inline fn LoadEntityReference(gameState: *h.game_state, simRegion: *sim_region, ref: *entity_reference) void {
    switch (ref.*) {
        .index => {
            if (ref.index > 0) {
                var entry = GetHashFromStorageIndex(simRegion, ref.index);
                if (entry.ptr) |_| {} else {
                    entry.index = ref.index;
                    const lowEntity = h.GetLowEntity(gameState, ref.index);
                    const p = GetSimSpaceP(simRegion, lowEntity.?);
                    entry.ptr = AddEntity(gameState, simRegion, ref.index, h.GetLowEntity(gameState, ref.index), &p);
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

fn AddEntityRaw(gameState: *h.game_state, simRegion: *sim_region, storageIndex: u32, source: ?*h.low_entity) ?*sim_entity {
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

                assert(!h.IsSet(&lowEntity.sim, @intFromEnum(sim_entity_flags.Simming)));
                h.AddFlags(&lowEntity.sim, @intFromEnum(sim_entity_flags.Simming));
            }

            entity.?.storageIndex = storageIndex;
            entity.?.updatable = false;
        } else {
            platform.InvalidCodePath("");
        }
    }

    return entity;
}

pub inline fn EntityOverlapsRectangle(p: h.v3, volume: sim_entity_collision_volume, rect: h.rect3) bool {
    const grown = rect.AddRadius(h.Scale(volume.dim, 0.5));
    const result = grown.IsInRect(h.Add(p, volume.offsetP));
    return result;
}

pub fn AddEntity(gameState: *h.game_state, simRegion: *sim_region, storageIndex: u32, source: ?*h.low_entity, simP: ?*const h.v3) ?*sim_entity {
    var dest = AddEntityRaw(gameState, simRegion, storageIndex, source);
    if (dest) |_| {
        if (simP) |_| {
            dest.?.p = simP.?.*;
            dest.?.updatable = EntityOverlapsRectangle(dest.?.p, dest.?.collision.totalVolume, simRegion.updatableBounds);
        } else {
            dest.?.p = GetSimSpaceP(simRegion, source.?);
        }
    }

    return dest;
}

pub inline fn GetSimSpaceP(simRegion: *sim_region, stored: *h.low_entity) h.v3 {
    var result = h.Invalid;
    if (!h.IsSet(&stored.sim, @intFromEnum(sim_entity_flags.NonSpatial))) {
        result = h.Substract(simRegion.world, &stored.p, &simRegion.origin);
    }

    return result;
}

pub fn BeginSim(simArena: *h.memory_arena, gameState: *h.game_state, world: *h.world, origin: h.world_position, bounds: h.rect3, dt: f32) *sim_region {
    var simRegion: *sim_region = simArena.PushStruct(sim_region);
    h.ZeroStruct([4096]sim_entity_hash, &simRegion.hash);

    simRegion.maxEntityRadius = 5.0;
    simRegion.maxEntityVelocity = 30.0;
    const updateSafetyMargin = simRegion.maxEntityRadius + dt * simRegion.maxEntityVelocity;
    const updateSafetyMarginZ = 1.0;

    simRegion.world = world;
    simRegion.origin = origin;
    simRegion.updatableBounds = bounds.AddRadius(.{ simRegion.maxEntityRadius, simRegion.maxEntityRadius, 0 });
    simRegion.bounds = simRegion.updatableBounds.AddRadius(.{ updateSafetyMargin, updateSafetyMargin, updateSafetyMarginZ });

    simRegion.maxEntityCount = 4096;
    simRegion.entityCount = 0;
    simRegion.entities = simArena.PushArray(sim_entity, simRegion.maxEntityCount);

    const minChunkP = h.MapIntoChunkSpace(world, simRegion.origin, simRegion.bounds.GetMinCorner());
    const maxChunkP = h.MapIntoChunkSpace(world, simRegion.origin, simRegion.bounds.GetMaxCorner());

    var chunkZ = minChunkP.chunkZ;
    while (chunkZ <= maxChunkP.chunkZ) : (chunkZ += 1) {
        var chunkY = minChunkP.chunkY;
        while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
            var chunkX = minChunkP.chunkX;
            while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
                if (h.GetWorldChunk(null, world, chunkX, chunkY, chunkZ)) |chunk| {
                    var block: ?*h.world_entity_block = &chunk.firstBlock;
                    while (block) |b| : (block = b.next) {
                        var entityIndexIndex = @as(u32, 0);
                        while (entityIndexIndex < b.entityCount) : (entityIndexIndex += 1) {
                            const lowEntityIndex = b.lowEntityIndex[entityIndexIndex];
                            const low = &gameState.lowEntities[lowEntityIndex];
                            if (!h.IsSet(&low.sim, @intFromEnum(sim_entity_flags.NonSpatial))) {
                                var simSpaceP = GetSimSpaceP(simRegion, low);
                                if (EntityOverlapsRectangle(simSpaceP, low.sim.collision.totalVolume, simRegion.bounds)) {
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

pub fn EndSim(region: *sim_region, gameState: *h.game_state) void {
    var entityIndex = @as(u32, 0);
    while (entityIndex < region.entityCount) : (entityIndex += 1) {
        const entity: *sim_entity = &region.entities[entityIndex];
        const stored = &gameState.lowEntities[entity.storageIndex];

        assert(h.IsSet(&stored.sim, @intFromEnum(sim_entity_flags.Simming)));
        stored.sim = entity.*;
        assert(!h.IsSet(&stored.sim, @intFromEnum(sim_entity_flags.Simming)));

        StoreEntityReference(&stored.sim.sword);

        const newP = if (h.IsSet(entity, @intFromEnum(sim_entity_flags.NonSpatial)))
            h.NullPosition()
        else
            h.MapIntoChunkSpace(gameState.world, region.origin, entity.p);
        h.ChangeEntityLocation(&gameState.worldArena, gameState.world, entity.storageIndex, stored, newP);

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
                // const camZOffset = h.Z(newCameraP.offset_);
                newCameraP = stored.p;
                // newCameraP.offset_[2] = camZOffset;
            }

            gameState.cameraP = newCameraP;
        }
    }
}

const test_wall = struct {
    x: f32,
    relX: f32,
    relY: f32,
    deltaX: f32,
    deltaY: f32,
    minY: f32,
    maxY: f32,
    normal: h.v3,
};

pub fn TestWall(wallX: f32, relX: f32, relY: f32, playerDeltaX: f32, playerDeltaY: f32, tMin: *f32, minY: f32, maxY: f32) bool {
    var hit = false;

    const tEpsilon = 0.001;
    if (playerDeltaX != 0) {
        const tResult = (wallX - relX) / playerDeltaX;
        const y = relY + tResult * playerDeltaY;

        if ((tResult >= 0) and (tMin.* > tResult)) {
            if ((y >= minY) and (y <= maxY)) {
                tMin.* = @max(0, tResult - tEpsilon);
                hit = true;
            }
        }
    }

    return hit;
}

fn CanCollide(gameState: *h.game_state, unsortedA: *sim_entity, unsortedB: *sim_entity) bool {
    var result = false;

    var a = unsortedA;
    var b = unsortedB;

    if (a != b) {
        if (a.storageIndex > b.storageIndex) {
            b = unsortedA;
            a = unsortedB;
        }

        if (h.IsSet(a, @intFromEnum(sim_entity_flags.Collides)) and
            h.IsSet(b, @intFromEnum(sim_entity_flags.Collides)))
        {
            if (!h.IsSet(a, @intFromEnum(sim_entity_flags.NonSpatial)) and
                !h.IsSet(b, @intFromEnum(sim_entity_flags.NonSpatial)))
            {
                result = true;
            }

            const hashBucket = a.storageIndex & (gameState.collisionRuleHash.len - 1);
            var rule: ?*h.pairwise_collision_rule = gameState.collisionRuleHash[hashBucket];
            while (rule) |r| : (rule = r.nextInHash) {
                if ((r.storageIndexA == a.storageIndex) and (r.storageIndexB == b.storageIndex)) {
                    result = r.canCollide;
                    break;
                }
            }
        }
    }

    return result;
}

fn HandleCollision(gameState: *h.game_state, unsortedA: *sim_entity, unsortedB: *sim_entity) bool {
    var stopsOnCollision = false;

    if (unsortedA.entityType == .Sword) {
        h.AddCollisionRule(gameState, unsortedA.storageIndex, unsortedB.storageIndex, false);
        stopsOnCollision = false;
    } else {
        stopsOnCollision = true;
    }

    var a = unsortedA;
    var b = unsortedB;
    if (@intFromEnum(a.entityType) > @intFromEnum(b.entityType)) {
        b = unsortedA;
        a = unsortedB;
    }

    if ((a.entityType == .Monstar) and (b.entityType == .Sword)) {
        if (a.hitPointMax > 0) {
            a.hitPointMax -= 1;
        }
    }

    // entity.absTileZ = h.AddI32ToU32(entity.absTileZ, hitLow.dAbsTileZ);

    return stopsOnCollision;
}

pub fn CanOverlap(_: *h.game_state, mover: *sim_entity, region: *sim_entity) bool {
    var result = false;

    if (mover != region) {
        if (region.entityType == .Stairwell) {
            result = true;
        }
    }

    return result;
}

pub fn HandleOverlap(_: *h.game_state, mover: *sim_entity, region: *sim_entity, _: f32, ground: *f32) void {
    if (region.entityType == .Stairwell) {
        ground.* = h.GetStairGround(region, h.GetEntityGroundPoint(mover));
    }
}

pub fn SpeculativeCollide(mover: *sim_entity, region: *sim_entity, testP: h.v3) bool {
    var result = true;

    if (region.entityType == .Stairwell) {
        const stepHeight = 0.1;
        const moverGroundPoint = h.GetEntityGroundPointForEntityP(mover, testP);
        const ground = h.GetStairGround(region, moverGroundPoint);

        // !NOT_IGNORE
        // result = (h.AbsoluteValue(h.Z(h.GetEntityGroundPoint(mover)) - ground) > stepHeight) or ((h.Y(bary) > 0.1) and (h.Y(bary) < 0.9));
        result = (h.AbsoluteValue(h.Z(h.GetEntityGroundPoint(mover)) - ground) > stepHeight);
    }

    return result;
}

pub fn EntitiesOverlap(entity: *sim_entity, testEntity: *sim_entity, epsilon: h.v3) bool {
    var result = false;
    var volumeIndex = @as(u32, 0);
    while (!result and (volumeIndex < entity.collision.volumeCount)) : (volumeIndex += 1) {
        var volume = entity.collision.volumes[volumeIndex];

        var testVolumeIndex = @as(u32, 0);
        while (!result and testVolumeIndex < (testEntity.collision.volumeCount)) : (testVolumeIndex += 1) {
            var testVolume = testEntity.collision.volumes[testVolumeIndex];

            const entityRect = h.rect3.InitCenterDim(h.Add(entity.p, volume.offsetP), h.Add(volume.dim, epsilon));
            const testEntityRect = h.rect3.InitCenterDim(h.Add(testEntity.p, testVolume.offsetP), testVolume.dim);
            result = h.RectanglesIntersect(entityRect, testEntityRect);
        }
    }

    return result;
}

pub fn MoveEntity(gameState: *h.game_state, simRegion: *sim_region, entity: *sim_entity, dt: f32, moveSpec: *const move_spec, accelaration: h.v3) void {
    assert(!h.IsSet(entity, @intFromEnum(sim_entity_flags.NonSpatial)));

    var ddP = accelaration;
    // const world = gameState.world;

    if (moveSpec.unitMaxAccelVector) {
        const ddPLength = h.LengthSq(ddP);
        if (ddPLength > 1.0) {
            ddP = h.Scale(ddP, 1.0 / h.SquareRoot(ddPLength));
        }
    }

    ddP = h.Scale(ddP, moveSpec.speed);
    h.AddTo(&ddP, h.Scale(entity.dP, -moveSpec.drag));
    if (!h.IsSet(entity, @intFromEnum(sim_entity_flags.ZSupported))) {
        h.AddTo(&ddP, h.v3{ 0, 0, -9.8 });
    }

    // NOTE (Manav): playerDelta = (0.5 * ddP * square(dt)) + entity.dP * dt;
    var playerDelta = h.Add((h.Scale(ddP, 0.5 * h.Square(dt))), h.Scale(entity.dP, dt));
    h.AddTo(&entity.dP, h.Scale(ddP, dt));
    assert(h.LengthSq(entity.dP) <= h.Square(simRegion.maxEntityVelocity));

    var distanceRemaining = entity.distanceLimit;
    if (distanceRemaining == 0) {
        distanceRemaining = 10000.0;
    }

    var iteration = @as(u32, 0);
    while (iteration < 4) : (iteration += 1) {
        var tMin = @as(f32, 1.0);
        var tMax = @as(f32, 0.0);
        const playerDeltaLength = h.Length(playerDelta);
        if (playerDeltaLength > 0) {
            if (playerDeltaLength > distanceRemaining) {
                tMin = distanceRemaining / playerDeltaLength;
            }

            var wallNormalMin = h.v3{ 0, 0, 0 };
            var wallNormalMax = h.v3{ 0, 0, 0 };
            var hitEntityMin: ?*sim_entity = null;
            var hitEntityMax: ?*sim_entity = null;

            const desiredPosition = h.Add(entity.p, playerDelta);

            if (!h.IsSet(entity, @intFromEnum(sim_entity_flags.NonSpatial))) {
                var testHighEntityIndex = @as(u32, 0);
                while (testHighEntityIndex < simRegion.entityCount) : (testHighEntityIndex += 1) {
                    const testEntity = &simRegion.entities[testHighEntityIndex];

                    const overlapEpsilon = 0.001;
                    if (((h.IsSet(testEntity, @intFromEnum(sim_entity_flags.Traversable)) and
                        EntitiesOverlap(entity, testEntity, .{ overlapEpsilon, overlapEpsilon, overlapEpsilon })) or
                        CanCollide(gameState, entity, testEntity)))
                    {
                        var volumeIndex = @as(u32, 0);
                        while (volumeIndex < entity.collision.volumeCount) : (volumeIndex += 1) {
                            var volume = entity.collision.volumes[volumeIndex];
                            var testVolumeIndex = @as(u32, 0);
                            while (testVolumeIndex < testEntity.collision.volumeCount) : (testVolumeIndex += 1) {
                                var testVolume = testEntity.collision.volumes[testVolumeIndex];
                                const minkowskiDiameter: h.v3 = .{
                                    h.X(testVolume.dim) + h.X(volume.dim),
                                    h.Y(testVolume.dim) + h.Y(volume.dim),
                                    h.Z(testVolume.dim) + h.Z(volume.dim),
                                };

                                const minCorner = h.Scale(minkowskiDiameter, -0.5);
                                const maxCorner = h.Scale(minkowskiDiameter, 0.5);

                                const rel = h.Sub(h.Add(entity.p, volume.offsetP), h.Add(testEntity.p, testVolume.offsetP));

                                if ((h.Z(rel) >= h.Z(minCorner)) and (h.Z(rel) < h.Z(maxCorner))) {
                                    const walls: [4]test_wall = .{
                                        test_wall{ .x = h.X(minCorner), .relX = h.X(rel), .relY = h.Y(rel), .deltaX = h.X(playerDelta), .deltaY = h.Y(playerDelta), .minY = h.Y(minCorner), .maxY = h.Y(maxCorner), .normal = h.v3{ -1, 0, 0 } },
                                        test_wall{ .x = h.X(maxCorner), .relX = h.X(rel), .relY = h.Y(rel), .deltaX = h.X(playerDelta), .deltaY = h.Y(playerDelta), .minY = h.Y(minCorner), .maxY = h.Y(maxCorner), .normal = h.v3{ 1, 0, 0 } },
                                        test_wall{ .x = h.Y(minCorner), .relX = h.Y(rel), .relY = h.X(rel), .deltaX = h.Y(playerDelta), .deltaY = h.X(playerDelta), .minY = h.X(minCorner), .maxY = h.X(maxCorner), .normal = h.v3{ 0, -1, 0 } },
                                        test_wall{ .x = h.Y(maxCorner), .relX = h.Y(rel), .relY = h.X(rel), .deltaX = h.Y(playerDelta), .deltaY = h.X(playerDelta), .minY = h.X(minCorner), .maxY = h.X(maxCorner), .normal = h.v3{ 0, 1, 0 } },
                                    };

                                    if (h.IsSet(testEntity, @intFromEnum(sim_entity_flags.Traversable))) {
                                        var tMaxTest = tMax;
                                        var hitThis = false;

                                        var testWallNormal = h.v3{ 0, 0, 0 };
                                        var wallIndex = @as(u32, 0);
                                        while (wallIndex < walls.len) : (wallIndex += 1) {
                                            const wall = walls[wallIndex];

                                            const tEpsilon = 0.001;
                                            if (wall.deltaX != 0) {
                                                const tResult = (wall.x - wall.relX) / wall.deltaX;
                                                const y = wall.relY + tResult * wall.deltaY;

                                                if ((tResult >= 0) and (tMaxTest < tResult)) {
                                                    if ((y >= wall.minY) and (y <= wall.maxY)) {
                                                        tMaxTest = @max(0, tResult - tEpsilon);
                                                        testWallNormal = wall.normal;
                                                        hitThis = true;
                                                    }
                                                }
                                            }
                                        }
                                        if (hitThis) {
                                            tMax = tMaxTest;
                                            wallNormalMax = testWallNormal;
                                            hitEntityMax = testEntity;
                                        }
                                    } else {
                                        var tMinTest = tMin;
                                        var hitThis = false;

                                        var testWallNormal = h.v3{ 0, 0, 0 };
                                        var wallIndex = @as(u32, 0);
                                        while (wallIndex < walls.len) : (wallIndex += 1) {
                                            const wall = walls[wallIndex];

                                            const tEpsilon = 0.001;
                                            if (wall.deltaX != 0) {
                                                const tResult = (wall.x - wall.relX) / wall.deltaX;
                                                const y = wall.relY + tResult * wall.deltaY;

                                                if ((tResult >= 0) and (tMinTest > tResult)) {
                                                    if ((y >= wall.minY) and (y <= wall.maxY)) {
                                                        tMinTest = @max(0, tResult - tEpsilon);
                                                        testWallNormal = wall.normal;
                                                        hitThis = true;
                                                    }
                                                }
                                            }
                                        }

                                        if (hitThis) {
                                            var testP = h.Add(entity.p, h.Scale(playerDelta, tMinTest));
                                            if (SpeculativeCollide(entity, testEntity, testP)) {
                                                tMin = tMinTest;
                                                wallNormalMin = testWallNormal;
                                                hitEntityMin = testEntity;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            var wallNormal = if (tMin < tMax) wallNormalMin else wallNormalMax;
            var hitEntity: ?*sim_entity = if (tMin < tMax) hitEntityMin else hitEntityMax;
            var tStop = if (tMin < tMax) tMin else tMax;

            h.AddTo(&entity.p, h.Scale(playerDelta, tStop));
            distanceRemaining -= tStop * playerDeltaLength;
            if (hitEntity) |_| {
                playerDelta = h.Sub(desiredPosition, entity.p);

                const stopsOnCollision = HandleCollision(gameState, entity, hitEntity.?);
                if (stopsOnCollision) {
                    // NOTE (Manav): playerDelta -= (1 * Inner(playerDelta, wallNormal))*wallNormal;
                    h.SubFrom(&playerDelta, h.Scale(wallNormal, 1 * h.Inner(playerDelta, wallNormal)));
                    // NOTE (Manav): entity.dP -= (1 * Inner(entity.dP, wallNormal))*wallNormal;
                    h.SubFrom(&entity.dP, h.Scale(wallNormal, 1 * h.Inner(entity.dP, wallNormal)));
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
        var testHighEntityIndex = @as(u32, 0);
        while (testHighEntityIndex < simRegion.entityCount) : (testHighEntityIndex += 1) {
            const testEntity = &simRegion.entities[testHighEntityIndex];
            if (CanOverlap(gameState, entity, testEntity) and EntitiesOverlap(entity, testEntity, .{ 0, 0, 0 })) {
                HandleOverlap(gameState, entity, testEntity, dt, &ground);
            }
        }
    }

    ground += h.Z(entity.p) - h.Z(h.GetEntityGroundPoint(entity));
    if ((h.Z(entity.p) <= ground) or
        (h.IsSet(entity, @intFromEnum(sim_entity_flags.ZSupported)) and
        (h.Z(entity.dP) == 0)))
    {
        entity.p[2] = ground;
        entity.dP[2] = 0;
        h.AddFlags(entity, @intFromEnum(sim_entity_flags.ZSupported));
    } else {
        h.ClearFlags(entity, @intFromEnum(sim_entity_flags.ZSupported));
    }

    if (entity.distanceLimit != 0) {
        entity.distanceLimit = distanceRemaining;
    }

    if ((h.X(entity.dP) == 0) and (h.Y(entity.dP) == 0)) {
        // NOTE(casey): Leave FacingDirection whatever it was
    } else {
        entity.facingDirection = h.Atan2(h.Y(entity.dP), h.X(entity.dP));
        // if (entity.facingDirection < 0) {
        //     entity.facingDirection += platform.Tau32;
        // }
    }
}

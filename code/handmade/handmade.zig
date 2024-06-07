const platform = @import("handmade_platform");
const h = struct {
    usingnamespace @import("handmade_audio.zig");
    usingnamespace @import("handmade_asset.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_entity.zig");
    usingnamespace @import("handmade_file_formats.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade_sim_region.zig");
    usingnamespace @import("handmade_world.zig");

    usingnamespace @import("handmade_asset_type_id");
};

const assert = platform.Assert;
const handmade_internal = platform.handmade_internal;

// build constants ------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = platform.NOT_IGNORE;
const HANDMADE_INTERNAL = platform.HANDMADE_INTERNAL;

// local functions ------------------------------------------------------------------------------------------------------------------------

const add_low_entity_result = struct {
    low: *h.low_entity,
    lowIndex: u32,
};

fn AddLowEntity(gameState: *h.game_state, entityType: h.entity_type, pos: h.world_position) add_low_entity_result {
    assert(gameState.lowEntityCount < gameState.lowEntities.len);
    const entityIndex = gameState.lowEntityCount;
    gameState.lowEntityCount += 1;

    const entityLow = &gameState.lowEntities[entityIndex];

    entityLow.* = .{
        .sim = .{
            .entityType = entityType,
            .collision = gameState.nullCollision,
        },
        .p = h.NullPosition(),
    };

    h.ChangeEntityLocation(&gameState.worldArena, gameState.world, entityIndex, entityLow, pos);

    const result = .{
        .low = entityLow,
        .lowIndex = entityIndex,
    };

    return result;
}

fn AddGroundedEntity(gameState: *h.game_state, entityType: h.entity_type, p: h.world_position, collision: *h.sim_entity_collision_volume_group) add_low_entity_result {
    const entity = AddLowEntity(gameState, entityType, p);
    entity.low.sim.collision = collision;
    return entity;
}

fn AddStandardRoom(gameState: *h.game_state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Space, p, gameState.standardRoomCollision);

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Traversable));

    return entity;
}

fn AddWall(gameState: *h.game_state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Wall, p, gameState.wallCollision);

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Collides));

    return entity;
}

fn AddStairs(gameState: *h.game_state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Stairwell, p, gameState.stairCollision);

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Collides));
    entity.low.sim.walkableDim = .{ h.X(entity.low.sim.collision.totalVolume.dim), h.Y(entity.low.sim.collision.totalVolume.dim) };
    entity.low.sim.walkableHeight = gameState.typicalFloorHeight;

    return entity;
}

fn InitHitPoints(entityLow: *h.low_entity, hitPointCount: u32) void {
    assert(hitPointCount <= entityLow.sim.hitPoint.len);
    entityLow.sim.hitPointMax = hitPointCount;

    var hitPointIndex = @as(u32, 0);
    while (hitPointIndex < entityLow.sim.hitPointMax) : (hitPointIndex += 1) {
        const hitPoint = &entityLow.sim.hitPoint[hitPointIndex];
        hitPoint.flags = 0;
        hitPoint.filledAmount = h.HIT_POINT_SUB_COUNT;
    }
}

fn AddSword(gameState: *h.game_state) add_low_entity_result {
    var entity = AddLowEntity(gameState, .Sword, h.NullPosition());

    entity.low.sim.collision = gameState.swordCollision;

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Movable));

    return entity;
}

fn AddPlayer(gameState: *h.game_state) add_low_entity_result {
    const p = gameState.cameraP;
    var entity = AddGroundedEntity(gameState, .Hero, p, gameState.playerCollision);

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Collides) | @intFromEnum(h.sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    const sword = AddSword(gameState);
    entity.low.sim.sword.index = sword.lowIndex;

    if (gameState.cameraFollowingEntityIndex == 0) {
        gameState.cameraFollowingEntityIndex = entity.lowIndex;
    }

    return entity;
}

fn AddMonstar(gameState: *h.game_state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), @as(i32, @intCast(absTileZ)), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Monstar, p, gameState.monstarCollision);

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Collides) | @intFromEnum(h.sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    return entity;
}

fn AddFamiliar(gameState: *h.game_state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), @as(i32, @intCast(absTileZ)), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Familiar, p, gameState.familiarCollision);

    h.AddFlags(&entity.low.sim, @intFromEnum(h.sim_entity_flags.Collides) | @intFromEnum(h.sim_entity_flags.Movable));

    return entity;
}

fn DrawHitpoints(entity: *h.sim_entity, pieceGroup: *h.render_group) void {
    if (entity.hitPointMax >= 1) {
        const healthDim = h.v2{ 0.2, 0.2 };
        const spacingX = 1.5 * h.X(healthDim);
        var hitP = h.v2{
            -0.5 * @as(f32, @floatFromInt(entity.hitPointMax - 1)) * spacingX,
            -0.25,
        };
        const dHitP = h.v2{ spacingX, 0 };
        var healthIndex = @as(u32, 0);
        while (healthIndex < entity.hitPointMax) : (healthIndex += 1) {
            const hitPoint = entity.hitPoint[healthIndex];
            var colour = h.v4{ 1, 0, 0, 1 };
            if (hitPoint.filledAmount == 0) {
                colour = .{ 0.2, 0.2, 0.2, 1 };
            }

            pieceGroup.PushRect(h.ToV3(hitP, 0), healthDim, colour);
            h.AddTo(&hitP, dHitP);
        }
    }
}

fn MakeSimpleGroundedCollision(gameState: *h.game_state, dimX: f32, dimY: f32, dimZ: f32) *h.sim_entity_collision_volume_group {
    const group: *h.sim_entity_collision_volume_group = gameState.worldArena.PushStruct(h.sim_entity_collision_volume_group);

    const volumeCount = 1;
    group.volumes = gameState.worldArena.PushSlice(h.sim_entity_collision_volume, volumeCount);
    group.totalVolume.offsetP = h.v3{ 0, 0, 0.5 * dimZ };
    group.totalVolume.dim = h.v3{ dimX, dimY, dimZ };
    group.volumes[0] = group.totalVolume;

    return group;
}

fn MakeNullCollision(gameState: *h.game_state) *h.sim_entity_collision_volume_group {
    const group: *h.sim_entity_collision_volume_group = gameState.worldArena.PushStruct(h.sim_entity_collision_volume_group);

    const volumeCount = 0;
    group.volumes = undefined; // TODO (Manav): change type from,  []sim_entity_collision_volume to ?[]sim_entity_collision_volume
    group.volumes.len = volumeCount;
    group.totalVolume.offsetP = h.v3{ 0, 0, 0 };
    group.totalVolume.dim = h.v3{ 0, 0, 0 };

    return group;
}

pub fn BeginTaskWithMemory(tranState: *h.transient_state) ?*h.task_with_memory {
    var foundTask: ?*h.task_with_memory = null;

    var taskIndex: u32 = 0;
    while (taskIndex < tranState.tasks.len) : (taskIndex += 1) {
        var task: *h.task_with_memory = &tranState.tasks[taskIndex];
        if (!task.beingUsed) {
            foundTask = task;
            task.beingUsed = true;
            task.memoryFlush = h.BeginTemporaryMemory(&task.arena);
            break;
        }
    }

    return foundTask;
}

pub fn EndTaskWithMemory(task: *h.task_with_memory) void {
    h.EndTemporaryMemory(task.memoryFlush);

    @fence(.seq_cst);

    task.beingUsed = false;
}

const fill_ground_chunk_work = struct {
    renderGroup: *h.render_group,
    buffer: *h.loaded_bitmap,
    task: *h.task_with_memory,
};

pub fn FillGroundChunkWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(FillGroundChunkWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *fill_ground_chunk_work = @alignCast(@ptrCast(data));

    work.renderGroup.NonTiledRenderGroupToOutput(work.buffer);

    EndTaskWithMemory(work.task);
}

fn FillGroundChunk(
    tranState: *h.transient_state,
    gameState: *h.game_state,
    groundBuffer: *h.ground_buffer,
    chunkP: *const h.world_position,
) void {
    if (BeginTaskWithMemory(tranState)) |task| {
        var work: *fill_ground_chunk_work = task.arena.PushStruct(fill_ground_chunk_work);

        var buffer = &groundBuffer.bitmap;
        buffer.alignPercentage = h.v2{ 0.5, 0.5 };
        buffer.widthOverHeight = 1.0;

        const width = h.X(gameState.world.chunkDimInMeters);
        const height = h.Y(gameState.world.chunkDimInMeters);
        assert(width == height);
        const haldDim = h.Scale(.{ width, height }, 0.5);

        const renderGroup = h.render_group.Allocate(tranState.assets, &task.arena, 0, true);
        renderGroup.Orthographic(
            @intCast(buffer.width),
            @intCast(buffer.height),
            @as(f32, @floatFromInt(buffer.width - 2)) / width,
        );
        renderGroup.Clear(.{ 1, 0, 1, 1 });

        work.renderGroup = renderGroup;
        work.buffer = buffer;
        work.task = task;

        {
            var chunkOffsetY: i32 = -1;
            while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
                var chunkOffsetX: i32 = -1;
                while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
                    const chunkX = chunkP.chunkX + chunkOffsetX;
                    const chunkY = chunkP.chunkY + chunkOffsetY;
                    const chunkZ = chunkP.chunkZ;

                    var series = h.RandomSeed(@as(u32, @bitCast(139 * chunkX + 593 * chunkY + 329 * chunkZ)));

                    var colour = h.v4{ 1, 1, 1, 1 };

                    if (!NOT_IGNORE) {
                        colour = h.v4{ 1, 0, 0, 1 };
                        if (@mod(chunkX, 2) == @mod(chunkY, 2)) {
                            colour = h.v4{ 0, 0, 1, 1 };
                        }
                    }

                    const center = h.v2{ @as(f32, @floatFromInt(chunkOffsetX)) * width, @as(f32, @floatFromInt(chunkOffsetY)) * height };

                    var grassIndex: u32 = 0;
                    while (grassIndex < 50) : (grassIndex += 1) {
                        const stamp = h.GetRandomBitmapFrom(tranState.assets, if (series.RandomChoice(2) == 1) .Asset_Grass else .Asset_Stone, &series);

                        const p = h.Add(center, h.Hammard(haldDim, .{ series.RandomBilateral(), series.RandomBilateral() }));
                        renderGroup.PushBitmap2(stamp, 2.5, h.ToV3(p, 0), colour);
                    }
                }
            }
        }

        {
            var chunkOffsetY = @as(i32, -1);
            while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
                var chunkOffsetX = @as(i32, -1);
                while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
                    const chunkX = chunkP.chunkX + chunkOffsetX;
                    const chunkY = chunkP.chunkY + chunkOffsetY;
                    const chunkZ = chunkP.chunkZ;

                    var series = h.RandomSeed(@as(u32, @bitCast(139 * chunkX + 593 * chunkY + 329 * chunkZ)));

                    const center = h.v2{ @as(f32, @floatFromInt(chunkOffsetX)) * width, @as(f32, @floatFromInt(chunkOffsetY)) * height };

                    var grassIndex = @as(u32, 0);
                    while (grassIndex < 50) : (grassIndex += 1) {
                        const stamp: h.bitmap_id = h.GetRandomBitmapFrom(tranState.assets, .Asset_Tuft, &series);

                        const p = h.Add(center, h.Hammard(haldDim, .{ series.RandomBilateral(), series.RandomBilateral() }));
                        renderGroup.PushBitmap2(stamp, 0.1, h.ToV3(p, 0), .{ 1, 1, 1, 1 });
                    }
                }
            }
        }

        if (renderGroup.AllResourcesPresent()) {
            groundBuffer.p = chunkP.*;

            h.platformAPI.AddEntry(tranState.lowPriorityQueue, FillGroundChunkWork, work);
        } else {
            EndTaskWithMemory(work.task);
        }
    }
}

fn ClearBitmap(bitmap: *h.loaded_bitmap) void {
    const totalBitmapSize = @as(usize, @intCast(bitmap.width * bitmap.height * platform.BITMAP_BYTES_PER_PIXEL));
    h.ZeroSize(totalBitmapSize, bitmap.memory);
}

fn MakeEmptyBitmap(arena: *h.memory_arena, width: i32, height: i32, clearToZero: bool) h.loaded_bitmap {
    var result = h.loaded_bitmap{};

    result.width = width;
    result.height = height;
    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;
    const totalBitmapSize: usize = @intCast(@as(i32, result.width) * @as(i32, result.height) * platform.BITMAP_BYTES_PER_PIXEL);
    result.memory = arena.PushSizeAlign(16, totalBitmapSize); // NOTE (Manav): force alignment by design, make aligned loaded bitmap ?
    if (clearToZero) {
        ClearBitmap(&result);
    }

    return result;
}

/// Defaults: ```cX = 1.0, cY = 1.0```
fn MakeSphereDiffuseMap(bitmap: *const h.loaded_bitmap, cX: f32, cY: f32) void {
    const invWidth = 1.0 / (@as(f32, @floatFromInt(bitmap.width)) - 1);
    const invHeight = 1.0 / (@as(f32, @floatFromInt(bitmap.height)) - 1);

    var row = bitmap.memory;

    var y = @as(u32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(u32, 0);
        var pixel = @as([*]u32, @alignCast(@ptrCast(row)));
        while (x < bitmap.width) : (x += 1) {
            const bitmapUV = h.v2{ invWidth * @as(f32, @floatFromInt(x)), invHeight * @as(f32, @floatFromInt(y)) };

            const nX = cX * (2 * h.X(bitmapUV) - 1);
            const nY = cY * (2 * h.Y(bitmapUV) - 1);
            const nZ_sq = 1 - nX * nX - nY * nY;

            var alpha = @as(f32, 0);

            if (nZ_sq >= 0) {
                alpha = 1;
            }

            const baseColour: h.v3 = .{ 0, 0, 0 };
            alpha *= 255;
            const colour: h.v4 = .{
                alpha * h.X(baseColour),
                alpha * h.Y(baseColour),
                alpha * h.Z(baseColour),
                alpha,
            };

            pixel[x] = (@as(u32, @intFromFloat(h.A(colour) + 0.5)) << 24) |
                (@as(u32, @intFromFloat(h.R(colour) + 0.5)) << 16) |
                (@as(u32, @intFromFloat(h.G(colour) + 0.5)) << 8) |
                (@as(u32, @intFromFloat(h.B(colour) + 0.5)) << 0);

            // pixel += 1;
        }
        row += @as(usize, @intCast(bitmap.pitch));
    }
}

/// Defaults: ```cX = 1.0, cY = 1.0```
fn MakeSphereNormalMap(bitmap: *const h.loaded_bitmap, roughness: f32, cX: f32, cY: f32) void {
    const invWidth = 1.0 / (@as(f32, @floatFromInt(bitmap.width)) - 1);
    const invHeight = 1.0 / (@as(f32, @floatFromInt(bitmap.height)) - 1);

    var row = bitmap.memory;

    var y = @as(u32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(u32, 0);
        var pixel = @as([*]u32, @alignCast(@ptrCast(row)));
        while (x < bitmap.width) : (x += 1) {
            const bitmapUV = h.v2{ invWidth * @as(f32, @floatFromInt(x)), invHeight * @as(f32, @floatFromInt(y)) };

            const nX = cX * (2 * h.X(bitmapUV) - 1);
            const nY = cY * (2 * h.Y(bitmapUV) - 1);
            const nZ_sq = 1 - nX * nX - nY * nY;

            const normal: h.v3 = if (nZ_sq >= 0) .{ nX, nY, h.SquareRoot(nZ_sq) } else .{ 0, 0.70710678118, 0.70710678118 };

            const colour = h.v4{
                255 * (0.5 * (h.X(normal) + 1)),
                255 * (0.5 * (h.Y(normal) + 1)),
                255 * (0.5 * (h.Z(normal) + 1)),
                255 * roughness,
            };

            pixel[x] = (@as(u32, @intFromFloat(h.A(colour) + 0.5)) << 24) |
                (@as(u32, @intFromFloat(h.R(colour) + 0.5)) << 16) |
                (@as(u32, @intFromFloat(h.G(colour) + 0.5)) << 8) |
                (@as(u32, @intFromFloat(h.B(colour) + 0.5)) << 0);

            // pixel += 1;
        }
        row += @as(usize, @intCast(bitmap.pitch));
    }
}

fn MakePyramidNormalMap(bitmap: *const h.loaded_bitmap, roughness: f32) void {
    // const invWidth = 1.0 / (@intToFloat(f32, bitmap.width) - 1);
    // const invHeight = 1.0 / (@intToFloat(f32, bitmap.height) - 1);

    var row = bitmap.memory;

    var y = @as(i32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(i32, 0);
        var pixel = @as([*]u32, @alignCast(@ptrCast(row)));
        while (x < bitmap.width) : (x += 1) {
            // const bitmapUV = game.v2{ invWidth * @intToFloat(f32, x), invHeight * @intToFloat(f32, y) };

            const invX = (bitmap.width - 1) - x;
            const seven = 0.70710678118;
            var normal: h.v3 = .{ 0, 0, seven };
            if (x < y) {
                if (invX < y) {
                    normal[0] = -seven;
                } else {
                    normal[1] = seven;
                }
            } else {
                if (invX < y) {
                    normal[1] = -seven;
                } else {
                    normal[0] = seven;
                }
            }

            const colour = h.v4{
                255 * (0.5 * (h.X(normal) + 1)),
                255 * (0.5 * (h.Y(normal) + 1)),
                255 * (0.5 * (h.Z(normal) + 1)),
                255 * roughness,
            };

            pixel.* = (@as(u32, @intFromFloat(h.A(colour) + 0.5)) << 24) |
                (@as(u32, @intFromFloat(h.R(colour) + 0.5)) << 16) |
                (@as(u32, @intFromFloat(h.G(colour) + 0.5)) << 8) |
                (@as(u32, @intFromFloat(h.B(colour) + 0.5)) << 0);

            pixel += 1;
        }
        row += @as(usize, @intCast(bitmap.pitch));
    }
}

pub inline fn ChunkPosFromTilePos(w: *h.world, absTileX: i32, absTileY: i32, absTileZ: i32, additionalOffset: h.v3) h.world_position {
    const basePos: h.world_position = .{};

    const tileSideInMeters = 1.4;
    const tileDepthInMeters = 3.0;

    const tileDim = h.v3{ tileSideInMeters, tileSideInMeters, tileDepthInMeters };
    const offset = h.Hammard(tileDim, h.V3(absTileX, absTileY, absTileZ));

    const result: h.world_position = h.MapIntoChunkSpace(w, basePos, h.Add(offset, additionalOffset));

    assert(h.IsCanonical(w, result.offset_));

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(
    gameMemory: *platform.memory,
    gameInput: *platform.input,
    buffer: *platform.offscreen_buffer,
) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(platform.UpdateAndRenderFnPtrType).Pointer.child != @TypeOf(UpdateAndRender)) {
            @compileError("Function signature mismatch!");
        }
    }

    h.platformAPI = gameMemory.platformAPI;

    if (HANDMADE_INTERNAL) {
        handmade_internal.debugGlobalMemory = gameMemory;
    }

    platform.BEGIN_TIMED_BLOCK(.UpdateAndRender);
    defer platform.END_TIMED_BLOCK(.UpdateAndRender);

    assert(@sizeOf(h.game_state) <= gameMemory.permanentStorageSize);
    const gameState: *h.game_state = @alignCast(@ptrCast(gameMemory.permanentStorage));

    const groundBufferWidth = 256.0;
    const groundBufferHeight = 256.0;
    const pixelsToMeters = 1.0 / 42.0;

    if (!gameState.isInitialized) {
        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

        gameState.typicalFloorHeight = 3.0;
        gameState.effectsEntropy = h.RandomSeed(1234);

        const worldChunkDimInMeters = h.v3{
            pixelsToMeters * groundBufferWidth,
            pixelsToMeters * groundBufferHeight,
            gameState.typicalFloorHeight,
        };

        gameState.worldArena.Initialize(
            gameMemory.permanentStorageSize - @sizeOf(h.game_state),
            gameMemory.permanentStorage + @sizeOf(h.game_state),
        );

        h.InitializeAudioState(&gameState.audioState, &gameState.worldArena);

        _ = AddLowEntity(gameState, .Null, h.NullPosition());

        gameState.world = gameState.worldArena.PushStruct(h.world);
        const world = gameState.world;
        h.InitializeWorld(world, worldChunkDimInMeters);

        const tileSideInMeters = 1.4;
        const tileDepthInMeters = gameState.typicalFloorHeight;

        gameState.nullCollision = MakeNullCollision(gameState);
        gameState.swordCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.1);
        gameState.stairCollision = MakeSimpleGroundedCollision(gameState, tileSideInMeters, 2 * tileSideInMeters, 1.1 * tileDepthInMeters);
        gameState.playerCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 1.2);
        gameState.monstarCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.5);
        gameState.familiarCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.5);
        gameState.wallCollision = MakeSimpleGroundedCollision(gameState, tileSideInMeters, tileSideInMeters, tileDepthInMeters);

        gameState.standardRoomCollision = MakeSimpleGroundedCollision(
            gameState,
            tilesPerWidth * tileSideInMeters,
            tilesPerHeight * tileSideInMeters,
            0.9 * tileDepthInMeters,
        );

        var series = h.RandomSeed(1234);

        const screenBaseX = @as(u32, 0);
        const screenBaseY = @as(u32, 0);
        const screenBaseZ = @as(u32, 0);
        var screenX = screenBaseX;
        var screenY = screenBaseY;
        var absTileZ = @as(i32, screenBaseZ);

        var doorLeft = false;
        var doorRight = false;
        var doorTop = false;
        var doorBottom = false;
        var doorUp = false;
        var doorDown = false;

        var screenIndex: u32 = 0;
        while (screenIndex < 2000) : (screenIndex += 1) {
            var doorDirection = @as(u32, 0);
            if (NOT_IGNORE) {
                doorDirection = series.RandomChoice(if (doorUp or doorDown) 2 else 4);
            } else {
                doorDirection = series.RandomChoice(2);
            }

            // doorDirection = 3;

            var createdZDoor = false;
            if (doorDirection == 3) {
                createdZDoor = true;
                doorDown = true;
            } else if (doorDirection == 2) {
                createdZDoor = true;
                doorUp = true;
            } else if (doorDirection == 1) {
                doorRight = true;
            } else {
                doorTop = true;
            }

            _ = AddStandardRoom(
                gameState,
                screenX * tilesPerWidth + tilesPerWidth / 2,
                screenY * tilesPerHeight + tilesPerHeight / 2,
                absTileZ,
            );

            var tileY = @as(u32, 0);
            while (tileY < tilesPerHeight) : (tileY += 1) {
                var tileX = @as(u32, 0);
                while (tileX < tilesPerWidth) : (tileX += 1) {
                    const absTileX = screenX * tilesPerWidth + tileX;
                    const absTileY = screenY * tilesPerHeight + tileY;

                    var shouldBeDoor = false;
                    if ((tileX == 0) and (!doorLeft or (tileY != (tilesPerHeight / 2)))) {
                        shouldBeDoor = true;
                    }

                    if ((tileX == (tilesPerWidth - 1)) and (!doorRight or (tileY != (tilesPerHeight / 2)))) {
                        shouldBeDoor = true;
                    }

                    if ((tileY == 0) and (!doorBottom or (tileX != (tilesPerWidth / 2)))) {
                        shouldBeDoor = true;
                    }

                    if ((tileY == (tilesPerHeight - 1)) and (!doorTop or (tileX != (tilesPerWidth / 2)))) {
                        shouldBeDoor = true;
                    }

                    if (shouldBeDoor) {
                        _ = AddWall(gameState, absTileX, absTileY, absTileZ);
                    } else if (createdZDoor) {
                        if (((@rem(absTileZ, 2) != 0) and (tileX == 10) and (tileY == 5)) or
                            ((@rem(absTileZ, 2) == 0) and (tileX == 4) and (tileY == 5)))
                        {
                            // TODO (Manav): absTileZ has integer overflow, tolerate it for now.
                            _ = AddStairs(gameState, absTileX, absTileY, if (doorDown) absTileZ - 1 else absTileZ);
                        }
                    }
                }
            }

            doorLeft = doorRight;
            doorBottom = doorTop;

            if (createdZDoor) {
                doorDown = !doorDown;
                doorUp = !doorUp;
            } else {
                doorDown = false;
                doorUp = false;
            }

            doorRight = false;
            doorTop = false;

            if (doorDirection == 3) {
                absTileZ -= 1;
            } else if (doorDirection == 2) {
                absTileZ += 1;
            } else if (doorDirection == 1) {
                screenX += 1;
            } else {
                screenY += 1;
            }
        }

        if (!NOT_IGNORE) {
            while (gameState.lowEntityCount < (gameState.lowEntities.len - 16)) {
                const coordinate = 1024 + gameState.lowEntityCount;
                AddWall(gameState, coordinate, coordinate, coordinate);
            }
        }

        const cameraTileX = screenBaseX * tilesPerWidth + 17 / 2;
        const cameraTileY = screenBaseY * tilesPerHeight + 9 / 2;
        const cameraTileZ = screenBaseZ;

        const newCameraP = ChunkPosFromTilePos(gameState.world, cameraTileX, cameraTileY, cameraTileZ, .{ 0, 0, 0 });

        gameState.cameraP = newCameraP;

        _ = AddMonstar(gameState, cameraTileX - 3, cameraTileY + 2, cameraTileZ);
        var familiarIndex = @as(u32, 0);
        while (familiarIndex < 1) : (familiarIndex += 1) {
            const familiarOffsetX = series.RandomBetweenI32(-7, 7);
            const familiarOffsetY = series.RandomBetweenI32(-3, -1);

            if ((familiarOffsetX != 0) or (familiarOffsetY != 0)) {
                _ = AddFamiliar(
                    gameState,
                    @intCast(@as(i32, @intCast(cameraTileX)) + familiarOffsetX),
                    @intCast(@as(i32, @intCast(cameraTileY)) + familiarOffsetY),
                    cameraTileZ,
                );
            }
        }

        gameState.isInitialized = true;
    }

    assert(@sizeOf(h.transient_state) <= gameMemory.transientStorageSize);
    const tranState = @as(*h.transient_state, @alignCast(@ptrCast(gameMemory.transientStorage)));
    if (!tranState.initialized) {
        tranState.tranArena.Initialize(
            gameMemory.transientStorageSize - @sizeOf(h.transient_state),
            gameMemory.transientStorage + @sizeOf(h.transient_state),
        );

        tranState.highPriorityQueue = gameMemory.highPriorityQueue;
        tranState.lowPriorityQueue = gameMemory.lowPriorityQueue;

        for (0..tranState.tasks.len) |taskIndex| {
            var task = &tranState.tasks[taskIndex];

            task.beingUsed = false;
            task.arena.SubArena(&tranState.tranArena, 16, platform.MegaBytes(1));
        }

        tranState.assets = h.game_assets.AllocateGameAssets(&tranState.tranArena, platform.MegaBytes(16), tranState);

        gameState.music = h.PlaySound(&gameState.audioState, h.GetFirstSoundFrom(tranState.assets, .Asset_Music));

        const groundBufferCount = 256; // 64
        tranState.groundBuffers = tranState.tranArena.PushSlice(h.ground_buffer, groundBufferCount);
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBuffers.len) : (groundBufferIndex += 1) {
            var groundBuffer: *h.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.bitmap = MakeEmptyBitmap(&tranState.tranArena, groundBufferWidth, groundBufferHeight, false);
            groundBuffer.p = h.NullPosition();
        }

        gameState.testDiffuse = MakeEmptyBitmap(&tranState.tranArena, 256, 256, false);
        gameState.testNormal = MakeEmptyBitmap(&tranState.tranArena, gameState.testDiffuse.width, gameState.testDiffuse.height, false);

        MakeSphereNormalMap(&gameState.testNormal, 0, 1, 1);
        MakeSphereDiffuseMap(&gameState.testDiffuse, 1, 1);
        // MakePyramidNormalMap(&gameState.testNormal, 0);

        tranState.envMapWidth = 512;
        tranState.envMapHeight = 256;
        for (&tranState.envMaps) |*map| {
            var width = tranState.envMapWidth;
            var height = tranState.envMapHeight;
            var lodIndex = @as(u32, 0);
            while (lodIndex < map.lod.len) : (lodIndex += 1) {
                map.lod[lodIndex] = MakeEmptyBitmap(&tranState.tranArena, @as(i32, @intCast(width)), @as(i32, @intCast(height)), false);
                width >>= 1;
                height >>= 1;
            }
        }

        tranState.initialized = true;
    }

    if (!NOT_IGNORE and gameInput.executableReloaded) {
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBuffers.len) : (groundBufferIndex += 1) {
            var groundBuffer: *h.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.p = h.NullPosition();
        }
    }

    {
        var musicVolume: h.v2 = .{ 0, 0 };
        musicVolume[1] = h.SafeRatiof0(@floatFromInt(gameInput.mouseX), @floatFromInt(buffer.width));
        musicVolume[0] = 1 - musicVolume[1];

        h.ChangeVolume(&gameState.audioState, gameState.music, 0.01, musicVolume);
    }

    const world = gameState.world;

    for (gameInput.controllers, 0..) |controller, controllerIndex| {
        const conHero = &gameState.controlledHeroes[controllerIndex];
        if (conHero.entityIndex == 0) {
            if (controller.buttons.mapped.start.endedDown != 0) {
                conHero.* = .{};
                conHero.entityIndex = AddPlayer(gameState).lowIndex;
            }
        } else {
            conHero.dZ = 0;
            conHero.dSword = .{ 0, 0 };
            conHero.ddP = .{ 0, 0 };

            if (controller.isAnalog) {
                conHero.ddP = .{ controller.stickAverageX, controller.stickAverageX };
            } else {
                if (controller.buttons.mapped.moveUp.endedDown != 0) {
                    conHero.ddP[1] = 1.0;
                }
                if (controller.buttons.mapped.moveDown.endedDown != 0) {
                    conHero.ddP[1] = -1.0;
                }
                if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                    conHero.ddP[0] = -1.0;
                }
                if (controller.buttons.mapped.moveRight.endedDown != 0) {
                    conHero.ddP[0] = 1.0;
                }
            }

            if (controller.buttons.mapped.start.endedDown != 0) {
                conHero.dZ = 3.0;
            }

            conHero.dSword = .{ 0, 0 };

            if (controller.buttons.mapped.actionUp.endedDown != 0) {
                h.ChangeVolume(&gameState.audioState, gameState.music, 10, .{ 1, 1 });
                conHero.dSword[1] = 1.0;
            }
            if (controller.buttons.mapped.actionDown.endedDown != 0) {
                h.ChangeVolume(&gameState.audioState, gameState.music, 10, .{ 0, 0 });
                conHero.dSword[1] = -1.0;
            }
            if (controller.buttons.mapped.actionLeft.endedDown != 0) {
                h.ChangeVolume(&gameState.audioState, gameState.music, 5, .{ 1, 0 });

                conHero.dSword[0] = -1.0;
            }
            if (controller.buttons.mapped.actionRight.endedDown != 0) {
                h.ChangeVolume(&gameState.audioState, gameState.music, 5, .{ 0, 1 });

                conHero.dSword[0] = 1.0;
            }
        }
    }

    var drawBuffer_ = h.loaded_bitmap{
        .width = @intCast(buffer.width),
        .height = @intCast(buffer.height),
        .pitch = @intCast(buffer.pitch),
        .memory = @as([*]u8, @ptrCast(buffer.memory.?)),
    };
    const drawBuffer = &drawBuffer_;

    if (!NOT_IGNORE) {
        drawBuffer.width = 1279;
        drawBuffer.height = 719;
    }

    const renderMemory = h.BeginTemporaryMemory(&tranState.tranArena);
    const renderGroup = h.render_group.Allocate(tranState.assets, &tranState.tranArena, platform.MegaBytes(4), false);

    const widthOfMonitorInMeters = 0.635;
    const metersToPixels = @as(f32, @floatFromInt(drawBuffer.width)) * widthOfMonitorInMeters;

    const focalLength = 0.6;
    const distanceAboveTarget = 9.0;

    renderGroup.Perspective(@intCast(drawBuffer.width), @intCast(drawBuffer.height), metersToPixels, focalLength, distanceAboveTarget);

    renderGroup.Clear(h.v4{ 0.25, 0.25, 0.25, 0 });

    const screenCenter = h.v2{
        0.5 * @as(f32, @floatFromInt(drawBuffer.width)),
        0.5 * @as(f32, @floatFromInt(drawBuffer.height)),
    };

    const screenBounds = h.GetCameraRectangleAtTarget(renderGroup);
    var cameraBoundsInMeters = h.rect3{ .min = h.ToV3(screenBounds.min, 0), .max = h.ToV3(screenBounds.max, 0) };
    cameraBoundsInMeters.min[2] = -3 * gameState.typicalFloorHeight;
    cameraBoundsInMeters.max[2] = 1 * gameState.typicalFloorHeight;

    if (NOT_IGNORE) {
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBuffers.len) : (groundBufferIndex += 1) {
            var groundBuffer: *h.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            if (h.IsValid(groundBuffer.p)) {
                const bitmap = &groundBuffer.bitmap;
                const delta = h.Substract(world, &groundBuffer.p, &gameState.cameraP);

                if ((h.Z(delta) >= -1.0) and (h.Z(delta) < 1.0)) {
                    const groundSideInMeters = h.X(world.chunkDimInMeters);
                    renderGroup.PushBitmap(bitmap, 1.0 * groundSideInMeters, delta, .{ 1, 1, 1, 1 });
                    if (!NOT_IGNORE) {
                        renderGroup.PushRectOutline(delta, .{ groundSideInMeters, groundSideInMeters }, .{ 1, 1, 0, 1 });
                    }
                }
            }
        }

        {
            const minChunkP = h.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMinCorner());
            const maxChunkP = h.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMaxCorner());

            var chunkZ = minChunkP.chunkZ;
            while (chunkZ <= maxChunkP.chunkZ) : (chunkZ += 1) {
                var chunkY = minChunkP.chunkY;
                while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
                    var chunkX = minChunkP.chunkX;
                    while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
                        // if (game.GetWorldChunk(null, world, )) |chunk|
                        {
                            const chunkCenterP = h.CenteredChunkPoint(chunkX, chunkY, chunkZ);
                            const relP = h.Substract(world, &chunkCenterP, &gameState.cameraP);
                            _ = relP;

                            var furthestBufferLengthSq = @as(f32, 0);
                            var furthestBuffer: ?*h.ground_buffer = null;
                            var index = @as(u32, 0);
                            while (index < tranState.groundBuffers.len) : (index += 1) {
                                const groundBuffer = &tranState.groundBuffers[index];
                                if (h.AreInSameChunk(world, &groundBuffer.p, &chunkCenterP)) {
                                    furthestBuffer = null;
                                    break;
                                } else if (h.IsValid(groundBuffer.p)) {
                                    const distance = h.Substract(world, &groundBuffer.p, &gameState.cameraP);
                                    const bufferLengthSq = h.LengthSq(h.XY(distance));
                                    if (furthestBufferLengthSq < bufferLengthSq) {
                                        furthestBufferLengthSq = bufferLengthSq;
                                        furthestBuffer = groundBuffer;
                                    }
                                } else {
                                    furthestBufferLengthSq = platform.F32MAXIMUM;
                                    furthestBuffer = groundBuffer;
                                }
                            }

                            if (furthestBuffer != null) {
                                FillGroundChunk(tranState, gameState, furthestBuffer.?, &chunkCenterP);
                            }
                        }
                    }
                }
            }
        }
    }

    const simBoundsExpansion = h.v3{ 15, 15, 0 };
    const simBounds = cameraBoundsInMeters.AddRadius(simBoundsExpansion);
    const simMemory = h.BeginTemporaryMemory(&tranState.tranArena);
    const simCenterP = gameState.cameraP;
    const simRegion = h.BeginSim(&tranState.tranArena, gameState, gameState.world, simCenterP, simBounds, gameInput.dtForFrame);

    const cameraP: h.v3 = h.Substract(world, &gameState.cameraP, &simCenterP);

    renderGroup.PushRectOutline(.{ 0, 0, 0 }, screenBounds.GetDim(), .{ 1, 1, 0, 1 });
    // renderGroup.PushRectOutline( .{0, 0, 0}, game.XY(cameraBoundsInMeters.GetDim()), .{1, 1, 1, 1});
    renderGroup.PushRectOutline(.{ 0, 0, 0 }, h.XY(simBounds.GetDim()), .{ 0, 1, 1, 1 });
    renderGroup.PushRectOutline(.{ 0, 0, 0 }, h.XY(simRegion.bounds.GetDim()), .{ 1, 0, 1, 1 });
    // renderGroup.PushRectOutline( .{ 0, 0, 0 }, game.XY(simRegion.updatableBounds.GetDim()), .{ 1, 1, 1, 1 });

    var entityIndex = @as(u32, 0);
    while (entityIndex < simRegion.entityCount) : (entityIndex += 1) {
        const entity: *h.sim_entity = &simRegion.entities[entityIndex];

        if (entity.updatable) {
            const dt = gameInput.dtForFrame;

            const alpha = 1 - 0.5 * h.Z(entity.p);
            const shadowAlpha = h.Clampf01(alpha);

            var moveSpec = h.DefaultMoveSpec();
            var ddP = h.v3{ 0, 0, 0 };

            const cameraRelativeGroundP: h.v3 = h.Sub(h.GetEntityGroundPoint(entity), cameraP);
            const fadeTopEndZ = 0.75 * gameState.typicalFloorHeight;
            const fadeTopStartZ = 0.5 * gameState.typicalFloorHeight;
            const fadeBottomStartZ = -2 * gameState.typicalFloorHeight;
            const fadeBottomEndZ = -2.5 * gameState.typicalFloorHeight;
            renderGroup.globalAlpha = 1.0;
            if (h.Z(cameraRelativeGroundP) > fadeTopStartZ) {
                renderGroup.globalAlpha = h.ClampMapToRange(fadeTopEndZ, h.Z(cameraRelativeGroundP), fadeTopStartZ);
            } else if (h.Z(cameraRelativeGroundP) < fadeBottomStartZ) {
                renderGroup.globalAlpha = h.ClampMapToRange(fadeBottomEndZ, h.Z(cameraRelativeGroundP), fadeBottomStartZ);
            }

            var matchVector = h.asset_vector{};
            matchVector.e[@intFromEnum(h.asset_tag_id.Tag_FacingDirection)] = entity.facingDirection;

            var weightVector = h.asset_vector{};
            weightVector.e[@intFromEnum(h.asset_tag_id.Tag_FacingDirection)] = 1.0;

            // if (entity.facingDirection != 0) {
            //     @import("std").debug.print("{}, {}, {}\n", .{
            //         entity.facingDirection,
            //         h.asset_tag_id.Tag_FacingDirection,
            //         matchVector.e[@intFromEnum(h.asset_tag_id.Tag_FacingDirection)],
            //     });
            //     @import("std").debug.print("{}, {}, {}\n", .{
            //         entity.facingDirection,
            //         h.asset_tag_id.Tag_FacingDirection,
            //         weightVector.e[@intFromEnum(h.asset_tag_id.Tag_FacingDirection)],
            //     });
            // }

            // Update (pre-physics entity)
            const heroBitmaps = h.hero_bitmap_ids{
                .head = h.GetBestMatchBitmapFrom(tranState.assets, .Asset_Head, &matchVector, &weightVector),
                .cape = h.GetBestMatchBitmapFrom(tranState.assets, .Asset_Cape, &matchVector, &weightVector),
                .torso = h.GetBestMatchBitmapFrom(tranState.assets, .Asset_Torso, &matchVector, &weightVector),
            };

            switch (entity.entityType) {
                .Hero => {
                    for (gameState.controlledHeroes) |conHero| {
                        if (entity.storageIndex == conHero.entityIndex) {
                            if (conHero.dZ != 0) {
                                entity.dP[2] = conHero.dZ;
                            }

                            moveSpec.unitMaxAccelVector = true;
                            moveSpec.speed = 50;
                            moveSpec.drag = 8;
                            ddP = .{ h.X(conHero.ddP), h.Y(conHero.ddP), 0 };
                            if ((h.X(conHero.dSword) != 0) or (h.Y(conHero.dSword) != 0)) {
                                switch (entity.sword) {
                                    .ptr => {
                                        const sword = entity.sword.ptr;
                                        if (h.IsSet(sword, @intFromEnum(h.sim_entity_flags.NonSpatial))) {
                                            sword.distanceLimit = 5.0;
                                            const dSwordV3 = h.v3{ h.X(conHero.dSword), h.Y(conHero.dSword), 0 };
                                            h.MakeEntitySpatial(sword, entity.p, h.Add(entity.dP, (h.Scale(dSwordV3, 5))));
                                            h.AddCollisionRule(gameState, sword.storageIndex, entity.storageIndex, false);

                                            _ = h.PlaySound(&gameState.audioState, h.GetRandomSoundFrom(tranState.assets, .Asset_Bloop, &gameState.effectsEntropy));
                                        }
                                    },

                                    .index => {
                                        platform.InvalidCodePath("");
                                    },
                                }
                            }
                        }
                    }
                },

                .Sword => {
                    moveSpec.unitMaxAccelVector = false;
                    moveSpec.speed = 0;
                    moveSpec.drag = 0;

                    if (entity.distanceLimit == 0) {
                        h.ClearCollisionRulesFor(gameState, entity.storageIndex);
                        h.MakeEntityNonSpatial(entity);
                    } else {
                        // NOTE (Manav): invalid z position causes float overflow down the line when drawing bitmap because of zFudge,
                        // so not pushing bitmap when entity becomes non spatial
                    }
                },

                .Familiar => {
                    var closestHero: ?*h.sim_entity = null;
                    var closestHeroDSq = h.Square(10);
                    if (!NOT_IGNORE) {
                        var testEntityIndex = @as(u32, 0);
                        while (testEntityIndex < simRegion.entityCount) : (testEntityIndex += 1) {
                            const testEntity: *h.sim_entity = &simRegion.entities[testEntityIndex];
                            if (testEntity.entityType == .Hero) {
                                const testDSq = h.LengthSq(3, testEntity.p - entity.p);

                                if (closestHeroDSq > testDSq) {
                                    closestHero = testEntity;
                                    closestHeroDSq = testDSq;
                                }
                            }
                        }
                    }

                    if (closestHero) |hero| {
                        if (closestHeroDSq > h.Square(3)) {
                            const accelaration = 0.5;
                            const oneOverLength = accelaration / h.SquareRoot(closestHeroDSq);
                            ddP = h.Scale(h.Sub(hero.p, entity.p), oneOverLength);
                        }
                    }

                    moveSpec.unitMaxAccelVector = true;
                    moveSpec.speed = 50;
                    moveSpec.drag = 8;
                },

                .Null => {
                    platform.InvalidCodePath("");
                },

                else => {},
            }

            if (!h.IsSet(entity, @intFromEnum(h.sim_entity_flags.NonSpatial)) and
                h.IsSet(entity, @intFromEnum(h.sim_entity_flags.Movable)))
            {
                h.MoveEntity(gameState, simRegion, entity, gameInput.dtForFrame, &moveSpec, ddP);
            }

            renderGroup.transform.offsetP = h.GetEntityGroundPoint(entity);

            // Render (post-physics entity)
            switch (entity.entityType) {
                .Hero => {
                    const heroSizeC = 2.5;
                    renderGroup.PushBitmap2(h.GetFirstBitmapFrom(tranState.assets, .Asset_Shadow), heroSizeC * 1.0, .{ 0, 0, 0 }, .{ 1, 1, 1, shadowAlpha });
                    renderGroup.PushBitmap2(heroBitmaps.torso, heroSizeC * 1.2, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                    renderGroup.PushBitmap2(heroBitmaps.cape, heroSizeC * 1.2, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                    renderGroup.PushBitmap2(heroBitmaps.head, heroSizeC * 1.2, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });

                    for (0..2) |_| {
                        const particle: *h.particle = &gameState.particles[gameState.nextParticle];
                        gameState.nextParticle += 1;

                        if (gameState.nextParticle >= gameState.particles.len) {
                            gameState.nextParticle = 0;
                        }

                        particle.p = .{ gameState.effectsEntropy.RandomBetweenF32(-0.05, 0.05), 0, 0 };
                        particle.dP = .{
                            gameState.effectsEntropy.RandomBetweenF32(-0.01, 0.01),
                            7 * gameState.effectsEntropy.RandomBetweenF32(0.7, 1),
                            0,
                        };
                        particle.ddP = .{ 0, -9.8, 0 };
                        particle.colour = .{
                            gameState.effectsEntropy.RandomBetweenF32(0.75, 1),
                            gameState.effectsEntropy.RandomBetweenF32(0.75, 1),
                            gameState.effectsEntropy.RandomBetweenF32(0.75, 1),
                            1.0,
                        };
                        particle.dColour = .{ 0, 0, 0, -0.25 };
                        particle.bitmapID = h.GetRandomBitmapFrom(tranState.assets, .Asset_Head, &gameState.effectsEntropy);
                    }

                    h.ZeroStruct(@TypeOf(gameState.particleCels), &gameState.particleCels);

                    const gridScale = 0.25;
                    const invGridScale = 1.0 / gridScale;
                    const gridOrigin = h.v3{ -0.5 * gridScale * h.PARTICLE_CEL_DIM, 0, 0 };

                    for (0..gameState.particles.len) |i| {
                        const particle: *h.particle = &gameState.particles[i];

                        const p = h.Scale(h.Sub(particle.p, gridOrigin), invGridScale);

                        var x = h.TruncateF32ToI32(h.X(p));
                        var y = h.TruncateF32ToI32(h.Y(p));

                        if (x < 0) {
                            x = 0;
                        }
                        if (x > h.PARTICLE_CEL_DIM - 1) {
                            x = h.PARTICLE_CEL_DIM - 1;
                        }

                        if (y < 0) {
                            y = 0;
                        }
                        if (y > h.PARTICLE_CEL_DIM - 1) {
                            y = h.PARTICLE_CEL_DIM - 1;
                        }

                        const cel: *h.particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x)];
                        const density = h.A(particle.colour);
                        cel.density += density;
                        // cel.velocityTimesDensity += density * particle.dP
                        h.AddTo(&cel.velocityTimesDensity, h.Scale(particle.dP, density));
                    }

                    if (!NOT_IGNORE) {
                        for (0..h.PARTICLE_CEL_DIM) |y| {
                            for (0..h.PARTICLE_CEL_DIM) |x| {
                                const cel: *h.particle_cel = &gameState.particleCels[y][x];

                                const a = h.Clampf01(0.1 * cel.density);

                                renderGroup.PushRect(
                                    h.Add(gridOrigin, h.Scale(h.v3{ @floatFromInt(x), @floatFromInt(y), 0 }, gridScale)),
                                    .{ gridScale * 1, gridScale * 1 },
                                    .{ a, a, a, 1 },
                                );
                            }
                        }
                    }

                    for (0..gameState.particles.len) |i| {
                        const particle: *h.particle = &gameState.particles[i];

                        const p = h.Scale(h.Sub(particle.p, gridOrigin), invGridScale);

                        var x = h.TruncateF32ToI32(h.X(p));
                        var y = h.TruncateF32ToI32(h.Y(p));

                        if (x < 1) {
                            x = 1;
                        }
                        if (x > h.PARTICLE_CEL_DIM - 2) {
                            x = h.PARTICLE_CEL_DIM - 2;
                        }

                        if (y < 1) {
                            y = 1;
                        }
                        if (y > h.PARTICLE_CEL_DIM - 2) {
                            y = h.PARTICLE_CEL_DIM - 2;
                        }

                        const celCenter: *h.particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x)];
                        const celLeft: *h.particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x - 1)];
                        const celRight: *h.particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x + 1)];
                        const celDown: *h.particle_cel = &gameState.particleCels[@intCast(y - 1)][@intCast(x)];
                        const celUp: *h.particle_cel = &gameState.particleCels[@intCast(y + 1)][@intCast(x)];

                        const dc = 1.0;
                        var dispersion = h.v3{ 0, 0, 0 };
                        // dispersion += dc * (celCenter.density - celLeft.density) * h.v3{ -1, 0, 0 };
                        h.AddTo(&dispersion, h.Scale(h.v3{ -1, 0, 0 }, dc * (celCenter.density - celLeft.density)));
                        // dispersion += dc * (celCenter.density - celRight.density) * h.v3{ 1, 0, 0 };
                        h.AddTo(&dispersion, h.Scale(h.v3{ 1, 0, 0 }, dc * (celCenter.density - celRight.density)));
                        // dispersion += dc * (celCenter.density - celDown.density) * h.v3{ 0, -1, 0 };
                        h.AddTo(&dispersion, h.Scale(h.v3{ 0, -1, 0 }, dc * (celCenter.density - celDown.density)));
                        // dispersion += dc * (celCenter.density - celUp.density) * h.v3{ 0, 1, 0 };
                        h.AddTo(&dispersion, h.Scale(h.v3{ 0, 1, 0 }, dc * (celCenter.density - celUp.density)));

                        const particleDDP = h.Add(particle.ddP, dispersion);

                        // particle.p += 0.5* Square(gameInput.dtForFrame) * particleDDP + particle.dp * gameInput.dtForFrame;
                        h.AddTo(&particle.p, h.Add(h.Scale(particleDDP, 0.5 * h.Square(gameInput.dtForFrame)), h.Scale(particle.dP, gameInput.dtForFrame)));

                        // particle.dp += particleDDP * gameInput.dtForFrame;
                        h.AddTo(&particle.dP, h.Scale(particleDDP, gameInput.dtForFrame));

                        // particle.colour += particle.dColour * gameInput.dtForFrame;
                        h.AddTo(&particle.colour, h.Scale(particle.dColour, gameInput.dtForFrame));

                        if (h.Y(particle.p) < 0) {
                            const coefficientOfRestitution = 0.3;
                            const coefficientOfFriction = 0.7;
                            h.SetY(&particle.p, -h.Y(particle.p));
                            h.SetY(&particle.dP, -coefficientOfRestitution * h.Y(particle.dP));
                            h.SetX(&particle.dP, coefficientOfFriction * h.X(particle.dP));
                        }

                        var colour: h.v4 = h.ClampV401(particle.colour);

                        if (h.A(colour) > 0.9) {
                            h.SetA(&colour, 0.9 * h.ClampMapToRange(1, h.A(colour), 0.9));
                        }
                        renderGroup.PushBitmap2(particle.bitmapID, 1.0, particle.p, colour);
                    }

                    DrawHitpoints(entity, renderGroup);
                },

                .Wall => {
                    renderGroup.PushBitmap2(h.GetFirstBitmapFrom(tranState.assets, .Asset_Tree), 2.5, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                },

                .Stairwell => {
                    renderGroup.PushRect(.{ 0, 0, 0 }, entity.walkableDim, .{ 1, 0.5, 0, 1 });
                    renderGroup.PushRect(.{ 0, 0, entity.walkableHeight }, entity.walkableDim, .{ 1, 1, 0, 1 });
                },

                .Sword => {
                    renderGroup.PushBitmap2(h.GetFirstBitmapFrom(tranState.assets, .Asset_Shadow), 0.5, .{ 0, 0, 0 }, .{ 1, 1, 1, shadowAlpha });
                    renderGroup.PushBitmap2(h.GetFirstBitmapFrom(tranState.assets, .Asset_Sword), 0.5, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                },

                .Familiar => {
                    entity.tBob += dt;
                    if (entity.tBob > platform.Tau32) {
                        entity.tBob -= platform.Tau32;
                    }
                    const bobSin = h.Sin(2 * entity.tBob);
                    renderGroup.PushBitmap2(h.GetFirstBitmapFrom(tranState.assets, .Asset_Shadow), 2.5, .{ 0, 0, 0 }, .{ 1, 1, 1, (0.5 * shadowAlpha) + (0.2 * bobSin) });
                    renderGroup.PushBitmap2(heroBitmaps.head, 2.5, .{ 0, 0, 0.25 * bobSin }, .{ 1, 1, 1, 1 });
                },

                .Monstar => {
                    renderGroup.PushBitmap2(h.GetFirstBitmapFrom(tranState.assets, .Asset_Shadow), 4.5, .{ 0, 0, 0 }, .{ 1, 1, 1, shadowAlpha });
                    renderGroup.PushBitmap2(heroBitmaps.torso, 4.5, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });

                    DrawHitpoints(entity, renderGroup);
                },

                .Space => {
                    if (!NOT_IGNORE) {
                        var volumeIndex = @as(u32, 0);
                        while (volumeIndex < entity.collision.volumeCount) : (volumeIndex += 1) {
                            const volume = entity.collision.volumes[volumeIndex];
                            renderGroup.PushRectOutline(h.Sub(volume.offsetP, .{ 0, 0, 0.5 * h.Z(volume.dim) }), h.XY(volume.dim), .{ 0, 0.5, 1, 1 });
                        }
                    }
                },

                .Null => {
                    platform.InvalidCodePath("");
                },
            }
        }
    }

    renderGroup.globalAlpha = 1.0;

    if (!NOT_IGNORE) {
        gameState.time += gameInput.dtForFrame;

        const mapColour = [_]h.v3{
            .{ 1, 0, 0 },
            .{ 0, 1, 0 },
            .{ 0, 0, 1 },
        };

        {
            var mapIndex = @as(u32, 0);
            while (mapIndex < tranState.envMaps.len) : (mapIndex += 1) {
                const map = &tranState.envMaps[mapIndex];
                const lod = &map.lod[0];
                var rowCheckerOn = false;
                const checkerWidth = @as(i32, 16);
                const checkerHeight = @as(i32, 16);

                var y = @as(i32, 0);
                while (y < lod.height) : (y += checkerHeight) {
                    var checkerOn = rowCheckerOn;
                    var x = @as(i32, 0);
                    while (x < lod.width) : (x += checkerWidth) {
                        const colour: h.v4 = if (checkerOn) h.ToV4(mapColour[mapIndex], 1) else h.v4{ 0, 0, 0, 1 };
                        const minP = h.V2(x, y);
                        const maxP: h.v2 = h.Add(minP, h.V2(checkerWidth, checkerHeight));
                        h.DrawRectangle(lod, minP, maxP, colour);
                        checkerOn = !checkerOn;
                    }
                    rowCheckerOn = !rowCheckerOn;
                }
            }
        }
        tranState.envMaps[0].pZ = -1.5;
        tranState.envMaps[1].pZ = 0;
        tranState.envMaps[2].pZ = 1.5;

        h.DrawBitmap(&tranState.envMaps[0].lod[0], &tranState.groundBuffers[tranState.groundBuffers.len - 1].bitmap, 125, 25, 1);

        // angle = 0;

        const origin = screenCenter;

        const angle = 0.1 * gameState.time;
        const disp: h.v2 = if (NOT_IGNORE) .{ 100 * h.Cos(5 * angle), 100 * h.Sin(3 * angle) } else .{ 0, 0 };

        var xAxis: h.v2 = undefined;
        var yAxis: h.v2 = undefined;
        if (NOT_IGNORE) {
            xAxis = h.Scale(h.v2{ h.Cos(10 * angle), h.Sin(10 * angle) }, 100);
            yAxis = h.Perp(xAxis);
        } else {
            xAxis = h.v2{ 100, 0 };
            yAxis = h.v2{ 0, 100 };
        }

        const cAngle = 5 * angle;

        var colour: h.v4 = undefined;

        if (!NOT_IGNORE) {
            colour = .{
                0.5 + 0.5 * h.Sin(cAngle),
                0.5 + 0.5 * h.Sin(2.9 * cAngle),
                0.5 + 0.5 * h.Cos(9.9 * cAngle),
                0.5 + 0.5 * h.Sin(10 * cAngle),
            };
        } else {
            colour = .{ 1, 1, 1, 1 };
        }

        h.CoordinateSystem(
            renderGroup,
            h.Sub(h.Add(disp, origin), h.Scale(h.Add(xAxis, yAxis), 0.5)),
            xAxis,
            yAxis,
            colour,
            &gameState.testDiffuse,
            &gameState.testNormal,
            &tranState.envMaps[2],
            &tranState.envMaps[1],
            &tranState.envMaps[0],
        );

        var mapP: h.v2 = .{ 0, 0 };
        {
            var index = @as(u32, 0);
            while (index < tranState.envMaps.len) : (index += 1) {
                const lod = &tranState.envMaps[index].lod[0];

                xAxis = h.v2{ 0.5 * @as(f32, @floatFromInt(lod.width)), 0 };
                yAxis = h.v2{ 0, 0.5 * @as(f32, @floatFromInt(lod.height)) };

                h.CoordinateSystem(renderGroup, mapP, xAxis, yAxis, .{ 1, 1, 1, 1 }, lod, null, null, null, null);
                h.AddTo(&mapP, h.Add(yAxis, h.v2{ 0, 6 }));
            }
        }

        // game.Saturation(renderGroup, 0.5 + 0.5 * game.Sin(10 * gameState.time));
    }

    renderGroup.TiledRenderGroupToOutput(tranState.highPriorityQueue, drawBuffer);

    h.EndSim(simRegion, gameState); // TODO (Manav): use defer
    h.EndTemporaryMemory(simMemory);
    h.EndTemporaryMemory(renderMemory);

    gameState.worldArena.CheckArena();
    tranState.tranArena.CheckArena();
}

pub export fn GetSoundSamples(gameMemory: *platform.memory, soundBuffer: *platform.sound_output_buffer) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(platform.GetSoundSamplesFnPtrType).Pointer.child != @TypeOf(GetSoundSamples)) {
            @compileError("Function signature mismatch!");
        }
    }

    const gameState: *h.game_state = @alignCast(@ptrCast(gameMemory.permanentStorage));
    const tranState: *h.transient_state = @alignCast(@ptrCast(gameMemory.transientStorage));

    h.OutputPlayingSounds(&gameState.audioState, soundBuffer, tranState.assets, &tranState.tranArena);
    // h.OutputTestSineWave(gameState, soundBuffer, 400);
}

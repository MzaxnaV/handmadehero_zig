const Debug = @import("handmade_debug.zig");
const Config = @import("handmade_config.zig");
const h = @import("handmade_all.zig");

const Platform = @import("platform");

const Assert = Platform.Assert;
const IGNORE = Platform.IGNORE;
const HANDMADE_INTERNAL = Platform.HANDMADE_INTERNAL;

// imported types -------------------------------------------------------------------------------------------------------------------------------
const PARTICLE_CEL_DIM = h.Data.PARTICLE_CEL_DIM;

const game_state = h.Data.game_state;
const sim_entity_flags = h.SimRegion.sim_entity_flags;
const sim_entity_collision_volume_group = h.SimRegion.sim_entity_collision_volume_group;
const world_position = h.World.world_position;
const transient_state = h.Data.transient_state;
const ground_buffer = h.Data.ground_buffer;
const loaded_bitmap = h.RenderGroup.loaded_bitmap;
const asset_tag_id = h.FileFormats.asset_tag_id;

const NullPosition = h.World.NullPosition;
const AddFlags = h.Entity.AddFlags;
const GetFirstBitmapFrom = h.Asset.GetFirstBitmapFrom;

// local functions ------------------------------------------------------------------------------------------------------------------------
const add_low_entity_result = struct {
    low: *h.Data.low_entity,
    lowIndex: u32,
};

fn AddLowEntity(gameState: *game_state, entityType: h.SimRegion.entity_type, pos: world_position) add_low_entity_result {
    Assert(gameState.lowEntityCount < gameState.lowEntities.len);
    const entityIndex = gameState.lowEntityCount;
    gameState.lowEntityCount += 1;

    const entityLow = &gameState.lowEntities[entityIndex];

    entityLow.* = .{
        .sim = .{
            .entityType = entityType,
            .collision = gameState.nullCollision,
        },
        .p = NullPosition(),
    };

    h.World.ChangeEntityLocation(&gameState.worldArena, gameState.world, entityIndex, entityLow, pos);

    const result = add_low_entity_result{
        .low = entityLow,
        .lowIndex = entityIndex,
    };

    return result;
}

fn AddGroundedEntity(gameState: *game_state, entityType: h.SimRegion.entity_type, p: world_position, collision: *sim_entity_collision_volume_group) add_low_entity_result {
    const entity = AddLowEntity(gameState, entityType, p);
    entity.low.sim.collision = collision;
    return entity;
}

fn AddStandardRoom(gameState: *game_state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = h.Data.ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Space, p, gameState.standardRoomCollision);

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Traversable));

    return entity;
}

fn AddWall(gameState: *game_state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = h.Data.ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Wall, p, gameState.wallCollision);

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Collides));

    return entity;
}

fn AddStairs(gameState: *game_state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = h.Data.ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Stairwell, p, gameState.stairCollision);

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Collides));
    entity.low.sim.walkableDim = .{ h.X(entity.low.sim.collision.totalVolume.dim), h.Y(entity.low.sim.collision.totalVolume.dim) };
    entity.low.sim.walkableHeight = gameState.typicalFloorHeight;

    return entity;
}

fn InitHitPoints(entityLow: *h.Data.low_entity, hitPointCount: u32) void {
    Assert(hitPointCount <= entityLow.sim.hitPoint.len);
    entityLow.sim.hitPointMax = hitPointCount;

    var hitPointIndex = @as(u32, 0);
    while (hitPointIndex < entityLow.sim.hitPointMax) : (hitPointIndex += 1) {
        const hitPoint = &entityLow.sim.hitPoint[hitPointIndex];
        hitPoint.flags = 0;
        hitPoint.filledAmount = h.SimRegion.HIT_POINT_SUB_COUNT;
    }
}

fn AddSword(gameState: *game_state) add_low_entity_result {
    var entity = AddLowEntity(gameState, .Sword, NullPosition());

    entity.low.sim.collision = gameState.swordCollision;

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Movable));

    return entity;
}

fn AddPlayer(gameState: *game_state) add_low_entity_result {
    const p = gameState.cameraP;
    var entity = AddGroundedEntity(gameState, .Hero, p, gameState.playerCollision);

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Collides) | @intFromEnum(sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    const sword = AddSword(gameState);
    entity.low.sim.sword.index = sword.lowIndex;

    if (gameState.cameraFollowingEntityIndex == 0) {
        gameState.cameraFollowingEntityIndex = entity.lowIndex;
    }

    return entity;
}

fn AddMonstar(gameState: *game_state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = h.Data.ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), @as(i32, @intCast(absTileZ)), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Monstar, p, gameState.monstarCollision);

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Collides) | @intFromEnum(sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    return entity;
}

fn AddFamiliar(gameState: *game_state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = h.Data.ChunkPosFromTilePos(gameState.world, @as(i32, @intCast(absTileX)), @as(i32, @intCast(absTileY)), @as(i32, @intCast(absTileZ)), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Familiar, p, gameState.familiarCollision);

    AddFlags(&entity.low.sim, @intFromEnum(sim_entity_flags.Collides) | @intFromEnum(sim_entity_flags.Movable));

    return entity;
}

fn DrawHitpoints(entity: *h.SimRegion.sim_entity, pieceGroup: *h.RenderGroup.render_group) void {
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

fn MakeSimpleGroundedCollision(gameState: *game_state, dimX: f32, dimY: f32, dimZ: f32) *sim_entity_collision_volume_group {
    const group: *sim_entity_collision_volume_group = gameState.worldArena.PushStruct(sim_entity_collision_volume_group);

    const volumeCount = 1;
    group.volumes = gameState.worldArena.PushSlice(h.SimRegion.sim_entity_collision_volume, volumeCount);
    group.totalVolume.offsetP = h.v3{ 0, 0, 0.5 * dimZ };
    group.totalVolume.dim = h.v3{ dimX, dimY, dimZ };
    group.volumes[0] = group.totalVolume;

    return group;
}

fn MakeNullCollision(gameState: *game_state) *sim_entity_collision_volume_group {
    const group: *sim_entity_collision_volume_group = gameState.worldArena.PushStruct(sim_entity_collision_volume_group);

    const volumeCount = 0;
    group.volumes = undefined; // TODO (Manav): change type from,  []sim_entity_collision_volume to ?[]sim_entity_collision_volume
    group.volumes.len = volumeCount;
    group.totalVolume.offsetP = h.v3{ 0, 0, 0 };
    group.totalVolume.dim = h.v3{ 0, 0, 0 };

    return group;
}

const fill_ground_chunk_work = struct {
    tranState: *transient_state,
    gameState: *game_state,
    groundBuffer: *ground_buffer,
    chunkP: world_position,

    task: *h.Data.task_with_memory,
};

fn FillGroundChunkWork(_: ?*Platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(Platform.work_queue_callback).pointer.child != @TypeOf(FillGroundChunkWork)) {
            @compileError("Function signature mismatch!");
        }
    }

    Debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__8 = Debug.TIMED_FUNCTION__impl(8, @src()).Init(.{});
    defer __t_blk__8.End();
    // AUTOGENERATED ----------------------------------------------------------

    const work: *fill_ground_chunk_work = @ptrCast(@alignCast(data));

    var buffer = &work.groundBuffer.bitmap;
    buffer.alignPercentage = h.v2{ 0.5, 0.5 };
    buffer.widthOverHeight = 1.0;

    const width = h.X(work.gameState.world.chunkDimInMeters);
    const height = h.Y(work.gameState.world.chunkDimInMeters);
    Assert(width == height);
    const haldDim = h.Scale(.{ width, height }, 0.5);

    const renderGroup = h.RenderGroup.render_group.Allocate(work.tranState.assets, &work.task.arena, 0, true);
    h.RenderGroup.BeginRender(renderGroup);
    renderGroup.Orthographic(
        @intCast(buffer.width),
        @intCast(buffer.height),
        @as(f32, @floatFromInt(buffer.width - 2)) / width,
    );
    renderGroup.Clear(.{ 1, 0, 1, 1 });

    {
        var chunkOffsetY: i32 = -1;
        while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
            var chunkOffsetX: i32 = -1;
            while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
                const chunkX = work.chunkP.chunkX + chunkOffsetX;
                const chunkY = work.chunkP.chunkY + chunkOffsetY;
                const chunkZ = work.chunkP.chunkZ;

                var series = h.Random.RandomSeed(@as(u32, @bitCast(139 * chunkX + 593 * chunkY + 329 * chunkZ)));

                var colour = h.v4{ 1, 1, 1, 1 };

                if (Config.DEBUGUI_GroundChunkCheckerboards) {
                    colour = h.v4{ 1, 0, 0, 1 };
                    if (@mod(chunkX, 2) == @mod(chunkY, 2)) {
                        colour = h.v4{ 0, 0, 1, 1 };
                    }
                }

                const center = h.v2{ @as(f32, @floatFromInt(chunkOffsetX)) * width, @as(f32, @floatFromInt(chunkOffsetY)) * height };

                var grassIndex: u32 = 0;
                while (grassIndex < 50) : (grassIndex += 1) {
                    const stamp = h.Asset.GetRandomBitmapFrom(work.tranState.assets, if (series.RandomChoice(2) == 1) .Grass else .Stone, &series);

                    const p = h.Add(center, h.Math.Hammard(haldDim, .{ series.RandomBilateral(), series.RandomBilateral() }));
                    renderGroup.PushBitmap2(stamp, 2.5, h.ToV3(p, 0), .{ .colour = colour, .cAlign = 1.0 });
                }
            }
        }
    }

    {
        var chunkOffsetY = @as(i32, -1);
        while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
            var chunkOffsetX = @as(i32, -1);
            while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
                const chunkX = work.chunkP.chunkX + chunkOffsetX;
                const chunkY = work.chunkP.chunkY + chunkOffsetY;
                const chunkZ = work.chunkP.chunkZ;

                var series = h.Random.RandomSeed(@as(u32, @bitCast(139 * chunkX + 593 * chunkY + 329 * chunkZ)));

                const center = h.v2{ @as(f32, @floatFromInt(chunkOffsetX)) * width, @as(f32, @floatFromInt(chunkOffsetY)) * height };

                var grassIndex = @as(u32, 0);
                while (grassIndex < 50) : (grassIndex += 1) {
                    const stamp: h.FileFormats.bitmap_id = h.Asset.GetRandomBitmapFrom(work.tranState.assets, .Tuft, &series);

                    const p = h.Add(center, h.Math.Hammard(haldDim, .{ series.RandomBilateral(), series.RandomBilateral() }));
                    renderGroup.PushBitmap2(stamp, 0.1, h.ToV3(p, 0), .{});
                }
            }
        }
    }

    Assert(renderGroup.AllResourcesPresent());

    renderGroup.NonTiledRenderGroupToOutput(buffer);
    h.RenderGroup.EndRender(renderGroup);

    h.Data.EndTaskWithMemory(work.task);
}

fn FillGroundChunk(
    tranState: *transient_state,
    gameState: *game_state,
    groundBuffer: *ground_buffer,
    chunkP: *const world_position,
) void {
    if (h.Data.BeginTaskWithMemory(tranState)) |task| {
        var work: *fill_ground_chunk_work = task.arena.PushStruct(fill_ground_chunk_work);
        work.task = task;
        work.tranState = tranState;
        work.gameState = gameState;
        work.groundBuffer = groundBuffer;
        work.chunkP = chunkP.*;
        groundBuffer.p = chunkP.*;

        h.Data.platformAPI.AddEntry(tranState.lowPriorityQueue, FillGroundChunkWork, work);
    }
}

fn ClearBitmap(bitmap: *loaded_bitmap) void {
    const totalBitmapSize = @as(usize, @intCast(bitmap.width * bitmap.height * Platform.BITMAP_BYTES_PER_PIXEL));
    h.Data.ZeroSize(totalBitmapSize, bitmap.memory);
}

fn MakeEmptyBitmap(arena: *h.Data.memory_arena, width: i32, height: i32, clearToZero: bool) loaded_bitmap {
    var result = loaded_bitmap{
        .alignPercentage = .{ 0.5, 0.5 },
        .widthOverHeight = h.Math.SafeRatiof1(@floatFromInt(width), @floatFromInt(height)),
        .width = width,
        .height = height,
    };

    result.pitch = result.width * Platform.BITMAP_BYTES_PER_PIXEL;
    const totalBitmapSize: usize = @intCast(@as(i32, result.width) * @as(i32, result.height) * Platform.BITMAP_BYTES_PER_PIXEL);
    result.memory = arena.PushSizeAlign(16, totalBitmapSize); // NOTE (Manav): force alignment by design, make aligned loaded bitmap ?
    if (clearToZero) {
        ClearBitmap(&result);
    }

    return result;
}

/// Defaults: ```cX = 1.0, cY = 1.0```
fn MakeSphereDiffuseMap(bitmap: *const loaded_bitmap, cX: f32, cY: f32) void {
    const invWidth = 1.0 / (@as(f32, @floatFromInt(bitmap.width)) - 1);
    const invHeight = 1.0 / (@as(f32, @floatFromInt(bitmap.height)) - 1);

    var row = bitmap.memory;

    var y = @as(u32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(u32, 0);
        var pixel = @as([*]u32, @ptrCast(@alignCast(row)));
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
fn MakeSphereNormalMap(bitmap: *const loaded_bitmap, roughness: f32, cX: f32, cY: f32) void {
    const invWidth = 1.0 / (@as(f32, @floatFromInt(bitmap.width)) - 1);
    const invHeight = 1.0 / (@as(f32, @floatFromInt(bitmap.height)) - 1);

    var row = bitmap.memory;

    var y = @as(u32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(u32, 0);
        var pixel = @as([*]u32, @ptrCast(@alignCast(row)));
        while (x < bitmap.width) : (x += 1) {
            const bitmapUV = h.v2{ invWidth * @as(f32, @floatFromInt(x)), invHeight * @as(f32, @floatFromInt(y)) };

            const nX = cX * (2 * h.X(bitmapUV) - 1);
            const nY = cY * (2 * h.Y(bitmapUV) - 1);
            const nZ_sq = 1 - nX * nX - nY * nY;

            const normal: h.v3 = if (nZ_sq >= 0) .{ nX, nY, h.Intrinsics.SquareRoot(nZ_sq) } else .{ 0, 0.70710678118, 0.70710678118 };

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

fn MakePyramidNormalMap(bitmap: *const loaded_bitmap, roughness: f32) void {
    // const invWidth = 1.0 / (@intToFloat(f32, bitmap.width) - 1);
    // const invHeight = 1.0 / (@intToFloat(f32, bitmap.height) - 1);

    var row = bitmap.memory;

    var y = @as(i32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(i32, 0);
        var pixel = @as([*]u32, @ptrCast(@alignCast(row)));
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

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(
    gameMemory: *Platform.memory,
    gameInput: *Platform.input,
    buffer: *Platform.offscreen_buffer,
) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(Platform.UpdateAndRenderFnPtrType).pointer.child != @TypeOf(UpdateAndRender)) {
            @compileError("Function signature mismatch!");
        }
    }

    const particle_cel = h.Data.particle_cel;

    h.Data.platformAPI = gameMemory.platformAPI;

    if (HANDMADE_INTERNAL) {
        Platform.debugGlobalMemory = gameMemory;
    }

    Debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__9 = Debug.TIMED_FUNCTION__impl(9, @src()).Init(.{});
    defer __t_blk__9.End();
    // AUTOGENERATED ----------------------------------------------------------

    Assert(@sizeOf(game_state) <= gameMemory.permanentStorageSize);
    const gameState: *game_state = @ptrCast(@alignCast(gameMemory.permanentStorage));

    const groundBufferWidth = 256.0;
    const groundBufferHeight = 256.0;
    const pixelsToMeters = 1.0 / 42.0;

    if (!gameState.isInitialized) {
        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

        gameState.typicalFloorHeight = 3.0;
        gameState.effectsEntropy = h.Random.RandomSeed(1234);

        const worldChunkDimInMeters = h.v3{
            pixelsToMeters * groundBufferWidth,
            pixelsToMeters * groundBufferHeight,
            gameState.typicalFloorHeight,
        };

        gameState.worldArena.Initialize(
            gameMemory.permanentStorageSize - @sizeOf(game_state),
            gameMemory.permanentStorage + @sizeOf(game_state),
        );

        h.Audio.InitializeAudioState(&gameState.audioState, &gameState.worldArena);

        _ = AddLowEntity(gameState, .Null, NullPosition());

        gameState.world = gameState.worldArena.PushStruct(h.World.world);
        const world = gameState.world;
        h.World.InitializeWorld(world, worldChunkDimInMeters);

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

        var series = h.Random.RandomSeed(1234);

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
            if (!IGNORE) {
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

        if (IGNORE) {
            while (gameState.lowEntityCount < (gameState.lowEntities.len - 16)) {
                const coordinate = 1024 + gameState.lowEntityCount;
                AddWall(gameState, coordinate, coordinate, coordinate);
            }
        }

        const cameraTileX = screenBaseX * tilesPerWidth + 17 / 2;
        const cameraTileY = screenBaseY * tilesPerHeight + 9 / 2;
        const cameraTileZ = screenBaseZ;

        const newCameraP = h.Data.ChunkPosFromTilePos(gameState.world, cameraTileX, cameraTileY, cameraTileZ, .{ 0, 0, 0 });

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

    Assert(@sizeOf(transient_state) <= gameMemory.transientStorageSize);
    const tranState = @as(*transient_state, @ptrCast(@alignCast(gameMemory.transientStorage)));
    if (!tranState.initialized) {
        tranState.tranArena.Initialize(
            gameMemory.transientStorageSize - @sizeOf(transient_state),
            gameMemory.transientStorage + @sizeOf(transient_state),
        );

        tranState.highPriorityQueue = gameMemory.highPriorityQueue;
        tranState.lowPriorityQueue = gameMemory.lowPriorityQueue;

        for (0..tranState.tasks.len) |taskIndex| {
            var task = &tranState.tasks[taskIndex];

            task.beingUsed = false;
            task.arena.SubArena(&tranState.tranArena, 16, Platform.MegaBytes(1));
        }

        tranState.assets = h.Asset.game_assets.AllocateGameAssets(&tranState.tranArena, Platform.MegaBytes(16), tranState);

        // gameState.music = h.PlaySound(&gameState.audioState, h.GetFirstSoundFrom(tranState.assets, .Asset_Music));

        const groundBufferCount = 256; // 64
        tranState.groundBuffers = tranState.tranArena.PushSlice(h.Data.ground_buffer, groundBufferCount);
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBuffers.len) : (groundBufferIndex += 1) {
            var groundBuffer: *h.Data.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.bitmap = MakeEmptyBitmap(&tranState.tranArena, groundBufferWidth, groundBufferHeight, false);
            groundBuffer.p = NullPosition();
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

    Debug.Start(tranState.assets, buffer.width, buffer.height);

    if (Config.DEBUGUI_RecomputeGroundChunksOnExeChange) {
        if (gameMemory.executableReloaded) {
            var groundBufferIndex = @as(u32, 0);
            while (groundBufferIndex < tranState.groundBuffers.len) : (groundBufferIndex += 1) {
                var groundBuffer: *ground_buffer = &tranState.groundBuffers[groundBufferIndex];
                groundBuffer.p = NullPosition();
            }
        }
    }

    {
        var musicVolume: h.v2 = .{ 0, 0 };
        musicVolume[1] = h.Math.SafeRatiof0(gameInput.mouseX, @floatFromInt(buffer.width));
        musicVolume[0] = 1 - musicVolume[1];

        h.Audio.ChangeVolume(&gameState.audioState, gameState.music, 0.01, musicVolume);
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
                h.Audio.ChangeVolume(&gameState.audioState, gameState.music, 10, .{ 1, 1 });
                conHero.dSword[1] = 1.0;
            }
            if (controller.buttons.mapped.actionDown.endedDown != 0) {
                h.Audio.ChangeVolume(&gameState.audioState, gameState.music, 10, .{ 0, 0 });
                conHero.dSword[1] = -1.0;
            }
            if (controller.buttons.mapped.actionLeft.endedDown != 0) {
                h.Audio.ChangeVolume(&gameState.audioState, gameState.music, 5, .{ 1, 0 });

                conHero.dSword[0] = -1.0;
            }
            if (controller.buttons.mapped.actionRight.endedDown != 0) {
                h.Audio.ChangeVolume(&gameState.audioState, gameState.music, 5, .{ 0, 1 });

                conHero.dSword[0] = 1.0;
            }
        }
    }

    var drawBuffer_ = loaded_bitmap{
        .width = @intCast(buffer.width),
        .height = @intCast(buffer.height),
        .pitch = @intCast(buffer.pitch),
        .memory = @as([*]u8, @ptrCast(buffer.memory.?)),
    };
    const drawBuffer = &drawBuffer_;

    if (Config.DEBUGUI_TestWeirdDrawBufferSize) {
        drawBuffer.width = 1279;
        drawBuffer.height = 719;
    }

    const renderMemory = h.Data.BeginTemporaryMemory(&tranState.tranArena);
    const renderGroup = h.RenderGroup.render_group.Allocate(tranState.assets, &tranState.tranArena, Platform.MegaBytes(4), false);
    h.RenderGroup.BeginRender(renderGroup);

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

    const screenBounds = h.RenderGroup.GetCameraRectangleAtTarget(renderGroup);
    var cameraBoundsInMeters = h.rect3{ .min = h.ToV3(screenBounds.min, 0), .max = h.ToV3(screenBounds.max, 0) };
    cameraBoundsInMeters.min[2] = -3 * gameState.typicalFloorHeight;
    cameraBoundsInMeters.max[2] = 1 * gameState.typicalFloorHeight;

    if (!IGNORE) {
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBuffers.len) : (groundBufferIndex += 1) {
            var groundBuffer: *ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            if (h.World.IsValid(groundBuffer.p)) {
                const bitmap = &groundBuffer.bitmap;
                const delta = h.World.Substract(world, &groundBuffer.p, &gameState.cameraP);

                if ((h.Z(delta) >= -1.0) and (h.Z(delta) < 1.0)) {
                    const groundSideInMeters = h.X(world.chunkDimInMeters);
                    renderGroup.PushBitmap(bitmap, 1.0 * groundSideInMeters, delta, .{});
                    if (Config.DEBUGUI_GroundChunkOutlines) {
                        renderGroup.PushRectOutline(delta, .{ groundSideInMeters, groundSideInMeters }, .{ 1, 1, 0, 1 });
                    }
                }
            }
        }

        {
            const minChunkP = h.World.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMinCorner());
            const maxChunkP = h.World.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMaxCorner());

            var chunkZ = minChunkP.chunkZ;
            while (chunkZ <= maxChunkP.chunkZ) : (chunkZ += 1) {
                var chunkY = minChunkP.chunkY;
                while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
                    var chunkX = minChunkP.chunkX;
                    while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
                        // if (game.GetWorldChunk(null, world, )) |chunk|
                        {
                            const chunkCenterP = h.World.CenteredChunkPoint(chunkX, chunkY, chunkZ);
                            const relP = h.World.Substract(world, &chunkCenterP, &gameState.cameraP);
                            _ = relP;

                            var furthestBufferLengthSq = @as(f32, 0);
                            var furthestBuffer: ?*ground_buffer = null;
                            var index = @as(u32, 0);
                            while (index < tranState.groundBuffers.len) : (index += 1) {
                                const groundBuffer = &tranState.groundBuffers[index];
                                if (h.World.AreInSameChunk(world, &groundBuffer.p, &chunkCenterP)) {
                                    furthestBuffer = null;
                                    break;
                                } else if (h.World.IsValid(groundBuffer.p)) {
                                    const distance = h.World.Substract(world, &groundBuffer.p, &gameState.cameraP);
                                    const bufferLengthSq = h.Math.LengthSq(h.XY(distance));
                                    if (furthestBufferLengthSq < bufferLengthSq) {
                                        furthestBufferLengthSq = bufferLengthSq;
                                        furthestBuffer = groundBuffer;
                                    }
                                } else {
                                    furthestBufferLengthSq = Platform.F32MAXIMUM;
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
    const simMemory = h.Data.BeginTemporaryMemory(&tranState.tranArena);
    const simCenterP = gameState.cameraP;
    const simRegion = h.SimRegion.BeginSim(&tranState.tranArena, gameState, gameState.world, simCenterP, simBounds, gameInput.dtForFrame);

    const cameraP: h.v3 = h.World.Substract(world, &gameState.cameraP, &simCenterP);

    renderGroup.PushRectOutline(.{ 0, 0, 0 }, screenBounds.GetDim(), .{ 1, 1, 0, 1 });
    // renderGroup.PushRectOutline( .{0, 0, 0}, game.XY(cameraBoundsInMeters.GetDim()), .{1, 1, 1, 1});
    renderGroup.PushRectOutline(.{ 0, 0, 0 }, h.XY(simBounds.GetDim()), .{ 0, 1, 1, 1 });
    renderGroup.PushRectOutline(.{ 0, 0, 0 }, h.XY(simRegion.bounds.GetDim()), .{ 1, 0, 1, 1 });
    // renderGroup.PushRectOutline( .{ 0, 0, 0 }, game.XY(simRegion.updatableBounds.GetDim()), .{ 1, 1, 1, 1 });

    var entityIndex = @as(u32, 0);
    while (entityIndex < simRegion.entityCount) : (entityIndex += 1) {
        const entity: *h.SimRegion.sim_entity = &simRegion.entities[entityIndex];

        if (entity.updatable) {
            const dt = gameInput.dtForFrame;

            const alpha = 1 - 0.5 * h.Z(entity.p);
            const shadowAlpha = h.Clampf01(alpha);

            var moveSpec = h.Entity.DefaultMoveSpec();
            var ddP = h.v3{ 0, 0, 0 };

            const cameraRelativeGroundP: h.v3 = h.Sub(h.Entity.GetEntityGroundPoint(entity), cameraP);
            const fadeTopEndZ = 0.75 * gameState.typicalFloorHeight;
            const fadeTopStartZ = 0.5 * gameState.typicalFloorHeight;
            const fadeBottomStartZ = -2 * gameState.typicalFloorHeight;
            const fadeBottomEndZ = -2.5 * gameState.typicalFloorHeight;
            renderGroup.globalAlpha = 1.0;
            if (h.Z(cameraRelativeGroundP) > fadeTopStartZ) {
                renderGroup.globalAlpha = h.Math.ClampMapToRange(fadeTopEndZ, h.Z(cameraRelativeGroundP), fadeTopStartZ);
            } else if (h.Z(cameraRelativeGroundP) < fadeBottomStartZ) {
                renderGroup.globalAlpha = h.Math.ClampMapToRange(fadeBottomEndZ, h.Z(cameraRelativeGroundP), fadeBottomStartZ);
            }

            var matchVector = h.Asset.asset_vector{};
            matchVector.e[@intFromEnum(asset_tag_id.FacingDirection)] = entity.facingDirection;

            var weightVector = h.Asset.asset_vector{};
            weightVector.e[@intFromEnum(asset_tag_id.FacingDirection)] = 1.0;

            // if (entity.facingDirection != 0) {
            //     @import("std").debug.print("{}, {}, {}\n", .{
            //         entity.facingDirection,
            //         asset_tag_id.FacingDirection,
            //         matchVector.e[@intFromEnum(asset_tag_id.FacingDirection)],
            //     });
            //     @import("std").debug.print("{}, {}, {}\n", .{
            //         entity.facingDirection,
            //         asset_tag_id.FacingDirection,
            //         weightVector.e[@intFromEnum(asset_tag_id.FacingDirection)],
            //     });
            // }

            // Update (pre-physics entity)
            const heroBitmaps = h.Data.hero_bitmap_ids{
                .head = h.Asset.GetBestMatchBitmapFrom(tranState.assets, .Head, &matchVector, &weightVector),
                .cape = h.Asset.GetBestMatchBitmapFrom(tranState.assets, .Cape, &matchVector, &weightVector),
                .torso = h.Asset.GetBestMatchBitmapFrom(tranState.assets, .Torso, &matchVector, &weightVector),
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
                                        if (h.Entity.IsSet(sword, @intFromEnum(sim_entity_flags.NonSpatial))) {
                                            sword.distanceLimit = 5.0;
                                            const dSwordV3 = h.v3{ h.X(conHero.dSword), h.Y(conHero.dSword), 0 };
                                            h.Entity.MakeEntitySpatial(sword, entity.p, h.Add(entity.dP, (h.Scale(dSwordV3, 5))));
                                            h.Data.AddCollisionRule(gameState, sword.storageIndex, entity.storageIndex, false);

                                            _ = h.Audio.PlaySound(&gameState.audioState, h.Asset.GetRandomSoundFrom(tranState.assets, .Bloop, &gameState.effectsEntropy));
                                        }
                                    },

                                    .index => {
                                        Platform.InvalidCodePath("");
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
                        h.Data.ClearCollisionRulesFor(gameState, entity.storageIndex);
                        h.Entity.MakeEntityNonSpatial(entity);
                    } else {
                        // NOTE (Manav): invalid z position causes float overflow down the line when drawing bitmap because of zFudge,
                        // so not pushing bitmap when entity becomes non spatial
                    }
                },

                .Familiar => {
                    var closestHero: ?*h.SimRegion.sim_entity = null;
                    var closestHeroDSq = h.Math.Square(10);
                    if (Config.DEBUGUI_FamiliarFollowsHero) {
                        var testEntityIndex = @as(u32, 0);
                        while (testEntityIndex < simRegion.entityCount) : (testEntityIndex += 1) {
                            const testEntity: *h.SimRegion.sim_entity = &simRegion.entities[testEntityIndex];
                            if (testEntity.entityType == .Hero) {
                                const testDSq = h.Math.LengthSq(h.Sub(testEntity.p, entity.p));

                                if (closestHeroDSq > testDSq) {
                                    closestHero = testEntity;
                                    closestHeroDSq = testDSq;
                                }
                            }
                        }
                    }

                    if (closestHero) |hero| {
                        if (closestHeroDSq > h.Math.Square(3)) {
                            const accelaration = 0.5;
                            const oneOverLength = accelaration / h.Intrinsics.SquareRoot(closestHeroDSq);
                            ddP = h.Scale(h.Sub(hero.p, entity.p), oneOverLength);
                        }
                    }

                    moveSpec.unitMaxAccelVector = true;
                    moveSpec.speed = 50;
                    moveSpec.drag = 8;
                },

                .Null => {
                    Platform.InvalidCodePath("");
                },

                else => {},
            }

            if (!h.Entity.IsSet(entity, @intFromEnum(sim_entity_flags.NonSpatial)) and
                h.Entity.IsSet(entity, @intFromEnum(sim_entity_flags.Movable)))
            {
                h.SimRegion.MoveEntity(gameState, simRegion, entity, gameInput.dtForFrame, &moveSpec, ddP);
            }

            renderGroup.transform.offsetP = h.Entity.GetEntityGroundPoint(entity);

            // Render (post-physics entity)
            switch (entity.entityType) {
                .Hero => {
                    const heroSizeC = 2.5;
                    renderGroup.PushBitmap2(GetFirstBitmapFrom(tranState.assets, .Shadow), heroSizeC * 1.0, .{ 0, 0, 0 }, .{ .colour = .{ 1, 1, 1, shadowAlpha }, .cAlign = 1.0 });
                    renderGroup.PushBitmap2(heroBitmaps.torso, heroSizeC * 1.2, .{ 0, 0, 0 }, .{});
                    renderGroup.PushBitmap2(heroBitmaps.cape, heroSizeC * 1.2, .{ 0, 0, 0 }, .{});
                    renderGroup.PushBitmap2(heroBitmaps.head, heroSizeC * 1.2, .{ 0, 0, 0 }, .{});

                    if (Config.DEBUGUI_ParticleTest) {
                        for (0..3) |_| {
                            const particle: *h.Data.particle = &gameState.particles[gameState.nextParticle];
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

                            var matchVectorFont = h.Asset.asset_vector{};
                            var weightVectorFont = h.Asset.asset_vector{};

                            const nothings = "NOTHINGS";

                            matchVectorFont.e[@intFromEnum(asset_tag_id.UnicodeCodepoint)] = @floatFromInt(nothings[gameState.effectsEntropy.RandomChoice(nothings.len)]);
                            weightVectorFont.e[@intFromEnum(asset_tag_id.UnicodeCodepoint)] = 1.0;

                            particle.bitmapID = heroBitmaps.head; // h.Asset.GetBestMatchBitmapFrom(tranState.assets, .Asset_Font, &matchVectorFont, &weightVectorFont);
                            // particle.bitmapID = h.Asset.GetRandomBitmapFrom(tranState.assets, .Asset_Font, &gameState.effectsEntropy);
                        }
                    }

                    h.Data.ZeroStruct(@TypeOf(gameState.particleCels), &gameState.particleCels);

                    const gridScale = 0.25;
                    const invGridScale = 1.0 / gridScale;
                    const gridOrigin = h.v3{ -0.5 * gridScale * PARTICLE_CEL_DIM, 0, 0 };

                    for (0..gameState.particles.len) |i| {
                        const particle: *h.Data.particle = &gameState.particles[i];

                        const p = h.Scale(h.Sub(particle.p, gridOrigin), invGridScale);

                        var x = h.Intrinsics.TruncateF32ToI32(h.X(p));
                        var y = h.Intrinsics.TruncateF32ToI32(h.Y(p));

                        if (x < 0) {
                            x = 0;
                        }
                        if (x > PARTICLE_CEL_DIM - 1) {
                            x = PARTICLE_CEL_DIM - 1;
                        }

                        if (y < 0) {
                            y = 0;
                        }
                        if (y > PARTICLE_CEL_DIM - 1) {
                            y = PARTICLE_CEL_DIM - 1;
                        }

                        const cel: *particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x)];
                        const density = h.A(particle.colour);
                        cel.density += density;
                        // cel.velocityTimesDensity += density * particle.dP
                        h.AddTo(&cel.velocityTimesDensity, h.Scale(particle.dP, density));
                    }

                    if (Config.DEBUGUI_ParticleGrid) {
                        for (0..PARTICLE_CEL_DIM) |y| {
                            for (0..PARTICLE_CEL_DIM) |x| {
                                const cel: *particle_cel = &gameState.particleCels[y][x];

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
                        const particle: *h.Data.particle = &gameState.particles[i];

                        const p = h.Scale(h.Sub(particle.p, gridOrigin), invGridScale);

                        var x = h.Intrinsics.TruncateF32ToI32(h.X(p));
                        var y = h.Intrinsics.TruncateF32ToI32(h.Y(p));

                        if (x < 1) {
                            x = 1;
                        }
                        if (x > PARTICLE_CEL_DIM - 2) {
                            x = PARTICLE_CEL_DIM - 2;
                        }

                        if (y < 1) {
                            y = 1;
                        }
                        if (y > PARTICLE_CEL_DIM - 2) {
                            y = PARTICLE_CEL_DIM - 2;
                        }

                        const celCenter: *particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x)];
                        const celLeft: *particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x - 1)];
                        const celRight: *particle_cel = &gameState.particleCels[@intCast(y)][@intCast(x + 1)];
                        const celDown: *particle_cel = &gameState.particleCels[@intCast(y - 1)][@intCast(x)];
                        const celUp: *particle_cel = &gameState.particleCels[@intCast(y + 1)][@intCast(x)];

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

                        // particle.p += 0.5* h.Math.Square(gameInput.dtForFrame) * particleDDP + particle.dp * gameInput.dtForFrame;
                        h.AddTo(&particle.p, h.Add(h.Scale(particleDDP, 0.5 * h.Math.Square(gameInput.dtForFrame)), h.Scale(particle.dP, gameInput.dtForFrame)));

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

                        var colour: h.v4 = h.Math.ClampV401(particle.colour);

                        if (h.A(colour) > 0.9) {
                            h.Math.SetA(&colour, 0.9 * h.Math.ClampMapToRange(1, h.A(colour), 0.9));
                        }
                        renderGroup.PushBitmap2(particle.bitmapID, 1, particle.p, .{ .colour = colour, .cAlign = 1.0 });
                    }

                    DrawHitpoints(entity, renderGroup);
                },

                .Wall => {
                    renderGroup.PushBitmap2(GetFirstBitmapFrom(tranState.assets, .Tree), 2.5, .{ 0, 0, 0 }, .{});
                },

                .Stairwell => {
                    renderGroup.PushRect(.{ 0, 0, 0 }, entity.walkableDim, .{ 1, 0.5, 0, 1 });
                    renderGroup.PushRect(.{ 0, 0, entity.walkableHeight }, entity.walkableDim, .{ 1, 1, 0, 1 });
                },

                .Sword => {
                    renderGroup.PushBitmap2(GetFirstBitmapFrom(tranState.assets, .Shadow), 0.5, .{ 0, 0, 0 }, .{ .colour = .{ 1, 1, 1, shadowAlpha }, .cAlign = 1.0 });
                    renderGroup.PushBitmap2(GetFirstBitmapFrom(tranState.assets, .Sword), 0.5, .{ 0, 0, 0 }, .{});
                },

                .Familiar => {
                    entity.tBob += dt;
                    if (entity.tBob > Platform.Tau32) {
                        entity.tBob -= Platform.Tau32;
                    }
                    const bobSin = h.Intrinsics.Sin(2 * entity.tBob);

                    renderGroup.PushBitmap2(GetFirstBitmapFrom(tranState.assets, .Shadow), 2.5, .{ 0, 0, 0 }, .{ .colour = .{ 1, 1, 1, (0.5 * shadowAlpha) + (0.2 * bobSin) }, .cAlign = 1.0 });
                    renderGroup.PushBitmap2(heroBitmaps.head, 2.5, .{ 0, 0, 0.25 * bobSin }, .{});
                },

                .Monstar => {
                    renderGroup.PushBitmap2(GetFirstBitmapFrom(tranState.assets, .Shadow), 4.5, .{ 0, 0, 0 }, .{ .colour = .{ 1, 1, 1, shadowAlpha }, .cAlign = 1.0 });
                    renderGroup.PushBitmap2(heroBitmaps.torso, 4.5, .{ 0, 0, 0 }, .{});

                    DrawHitpoints(entity, renderGroup);
                },

                .Space => {
                    if (Config.DEBUGUI_UseSpaceOutlines) {
                        var volumeIndex = @as(u32, 0);
                        while (volumeIndex < entity.collision.volumes.len) : (volumeIndex += 1) {
                            const volume = entity.collision.volumes[volumeIndex];
                            renderGroup.PushRectOutline(h.Sub(volume.offsetP, .{ 0, 0, 0.5 * h.Z(volume.dim) }), h.XY(volume.dim), .{ 0, 0.5, 1, 1 });
                        }
                    }
                },

                .Null => {
                    Platform.InvalidCodePath("");
                },
            }
        }
    }

    renderGroup.globalAlpha = 1.0;

    if (IGNORE) {
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

                const clipRect = h.rect2i{ .xMin = 0, .xMax = lod.width, .yMin = 0, .yMax = lod.height };

                var y = @as(i32, 0);
                while (y < lod.height) : (y += checkerHeight) {
                    var checkerOn = rowCheckerOn;
                    var x = @as(i32, 0);
                    while (x < lod.width) : (x += checkerWidth) {
                        const colour: h.v4 = if (checkerOn) h.ToV4(mapColour[mapIndex], 1) else h.v4{ 0, 0, 0, 1 };
                        const minP = h.V2(x, y);
                        const maxP: h.v2 = h.Add(minP, h.V2(checkerWidth, checkerHeight));
                        lod.DrawRectangle(minP, maxP, colour, clipRect, true);
                        lod.DrawRectangle(minP, maxP, colour, clipRect, false);
                        checkerOn = !checkerOn;
                    }
                    rowCheckerOn = !rowCheckerOn;
                }
            }
        }
        tranState.envMaps[0].pZ = -1.5;
        tranState.envMaps[1].pZ = 0;
        tranState.envMaps[2].pZ = 1.5;

        tranState.envMaps[0].lod[0].DrawBitmap(&tranState.groundBuffers[tranState.groundBuffers.len - 1].bitmap, 125, 25, 1);

        // angle = 0;

        const origin = screenCenter;

        const angle = 0.1 * gameState.time;
        const disp: h.v2 = if (!IGNORE) .{ 100 * h.Intrinsics.Cos(5 * angle), 100 * h.Intrinsics.Sin(3 * angle) } else .{ 0, 0 };

        var xAxis: h.v2 = undefined;
        var yAxis: h.v2 = undefined;
        if (!IGNORE) {
            xAxis = h.Scale(h.v2{ h.Intrinsics.Cos(10 * angle), h.Intrinsics.Sin(10 * angle) }, 100);
            yAxis = h.Perp(xAxis);
        } else {
            xAxis = h.v2{ 100, 0 };
            yAxis = h.v2{ 0, 100 };
        }

        const cAngle = 5 * angle;

        var colour: h.v4 = undefined;

        if (IGNORE) {
            colour = .{
                0.5 + 0.5 * h.Intrinsics.Sin(cAngle),
                0.5 + 0.5 * h.Intrinsics.Sin(2.9 * cAngle),
                0.5 + 0.5 * h.Intrinsics.Cos(9.9 * cAngle),
                0.5 + 0.5 * h.Intrinsics.Sin(10 * cAngle),
            };
        } else {
            colour = .{ 1, 1, 1, 1 };
        }

        renderGroup.CoordinateSystem(
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

                renderGroup.CoordinateSystem(mapP, xAxis, yAxis, .{ 1, 1, 1, 1 }, lod, null, null, null, null);
                h.AddTo(&mapP, h.Add(yAxis, h.v2{ 0, 6 }));
            }
        }

        // game.Saturation(renderGroup, 0.5 + 0.5 * game.Sin(10 * gameState.time));
    }

    renderGroup.TiledRenderGroupToOutput(tranState.highPriorityQueue, drawBuffer);
    h.RenderGroup.EndRender(renderGroup);

    h.SimRegion.EndSim(simRegion, gameState); // TODO (Manav): use defer
    h.Data.EndTemporaryMemory(simMemory);
    h.Data.EndTemporaryMemory(renderMemory);

    gameState.worldArena.CheckArena();
    tranState.tranArena.CheckArena();

    Debug.End(gameInput, drawBuffer);
}

pub export fn GetSoundSamples(gameMemory: *Platform.memory, soundBuffer: *Platform.sound_output_buffer) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(Platform.GetSoundSamplesFnPtrType).pointer.child != @TypeOf(GetSoundSamples)) {
            @compileError("Function signature mismatch!");
        }
    }

    const gameState: *game_state = @ptrCast(@alignCast(gameMemory.permanentStorage));
    const tranState: *h.Data.transient_state = @ptrCast(@alignCast(gameMemory.transientStorage));

    h.Audio.OutputPlayingSounds(&gameState.audioState, soundBuffer, tranState.assets, &tranState.tranArena);
    // h.Audio.OutputTestSineWave(gameState, soundBuffer, 400);
}

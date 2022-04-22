const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_entity.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_internals.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_sim_region.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade_world.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;

// local functions ------------------------------------------------------------------------------------------------------------------------

fn OutputSound(_: *game.state, soundBuffer: *platform.sound_output_buffer, toneHz: u32) void {
    const toneVolume = 3000;
    _ = toneVolume;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);
    _ = wavePeriod;

    var sampleOut = soundBuffer.samples;
    var sampleIndex = @as(u32, 0);
    while (sampleIndex < soundBuffer.sampleCount) : (sampleIndex += 1) {
        // !NOT_IGNORE:
        // const sineValue = @sin(gameState.tSine);
        // const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, toneVolume);

        const sampleValue = 0;
        sampleOut.* = sampleValue;
        sampleOut += 1;
        sampleOut.* = sampleValue;
        sampleOut += 1;

        // !NOT_IGNORE:
        // gameState.tSine += 2.0 * platform.PI32 * 1.0 / @intToFloat(f32, wavePeriod);
        // if (gameState.tSine > 2.0 * platform.PI32) {
        //     gameState.tSine -= 2.0 * platform.PI32;
        // }
    }
}


fn DEBUGLoadBMP(thread: *platform.thread_context, ReadEntireFile: platform.debug_platform_read_entire_file, fileName: [*:0]const u8) game.loaded_bitmap {
    const bitmap_header = packed struct {
        fileType: u16,
        fileSize: u32,
        reserved1: u16,
        reserved2: u16,
        bitmapOffset: u32,
        size: u32,
        width: i32,
        height: i32,
        planes: u16,
        bitsPerPixel: u16,
        compression: u32,
        sizeOfBitmap: u32,
        horzResolution: u32,
        vertResolution: u32,
        colorsUsed: u32,
        colorsImportant: u32,

        redMask: u32,
        greenMask: u32,
        blueMask: u32,
    };

    var result = game.loaded_bitmap{};

    const readResult = ReadEntireFile(thread, fileName);
    if (readResult.contentSize != 0) {
        const header = @ptrCast(*bitmap_header, readResult.contents);
        const pixels = readResult.contents + header.bitmapOffset;
        result.width = header.width;
        result.height = header.height;
        result.memory = pixels;

        std.debug.assert(header.compression == 3);

        const redMask = header.redMask;
        const greenMask = header.greenMask;
        const blueMask = header.blueMask;
        const alphaMask = ~(redMask | greenMask | blueMask);

        const redScan = game.FindLeastSignificantSetBit(redMask);
        const greenScan = game.FindLeastSignificantSetBit(greenMask);
        const blueScan = game.FindLeastSignificantSetBit(blueMask);
        const alphaScan = game.FindLeastSignificantSetBit(alphaMask);

        const redShiftDown = @intCast(u5, redScan);
        const greenShiftDown = @intCast(u5, greenScan);
        const blueShiftDown = @intCast(u5, blueScan);
        const alphaShiftDown = @intCast(u5, alphaScan);

        const sourceDest = @ptrCast([*]align(1) u32, result.memory);

        var index = @as(u32, 0);
        while (index < @intCast(u32, header.height * header.width)) : (index += 1) {
            const c = sourceDest[index];

            var r = @intToFloat(f32, (c & redMask) >> redShiftDown);
            var g = @intToFloat(f32, (c & greenMask) >> greenShiftDown);
            var b = @intToFloat(f32, (c & blueMask) >> blueShiftDown);
            var a = @intToFloat(f32, (c & alphaMask) >> alphaShiftDown);

            const aN = (a / 255.0);

            r = r * aN;
            g = g * aN;
            b = b * aN;

            sourceDest[index] = (@floatToInt(u32, (a + 0.5)) << 24 |
                @floatToInt(u32, (r + 0.5)) << 16 |
                @floatToInt(u32, (g + 0.5)) << 8 |
                @floatToInt(u32, (b + 0.5)) << 0);
        }
    }

    result.pitch = -result.width * platform.BITMAP_BYTES_PER_PIXEL;
    result.memory += @intCast(usize, -result.pitch * (result.height - 1));

    return result;
}

const add_low_entity_result = struct {
    low: *game.low_entity,
    lowIndex: u32,
};

fn AddLowEntity(gameState: *game.state, entityType: game.entity_type, pos: game.world_position) add_low_entity_result {
    std.debug.assert(gameState.lowEntityCount < gameState.lowEntities.len);
    const entityIndex = gameState.lowEntityCount;
    gameState.lowEntityCount += 1;

    const entityLow = &gameState.lowEntities[entityIndex];

    entityLow.* = .{
        .sim = .{
            .entityType = entityType,
            .collision = gameState.nullCollision,
        },
        .p = game.NullPosition(),
    };

    game.ChangeEntityLocation(&gameState.worldArena, gameState.world, entityIndex, entityLow, pos);

    const result = .{
        .low = entityLow,
        .lowIndex = entityIndex,
    };

    return result;
}

fn AddGroundedEntity(gameState: *game.state, entityType: game.entity_type, p: game.world_position, collision: *game.sim_entity_collision_volume_group) add_low_entity_result {
    const entity = AddLowEntity(gameState, entityType, p);
    entity.low.sim.collision = collision;
    return entity;
}

fn AddStandardRoom(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Space, p, gameState.standardRoomCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Traversable));

    return entity;
}

fn AddWall(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Wall, p, gameState.wallCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides));

    return entity;
}

fn AddStairs(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Stairwell, p, gameState.stairCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides));
    entity.low.sim.walkableDim = .{ game.X(entity.low.sim.collision.totalVolume.dim), game.Y(entity.low.sim.collision.totalVolume.dim) };
    entity.low.sim.walkableHeight = gameState.typicalFloorHeight;

    return entity;
}

fn InitHitPoints(entityLow: *game.low_entity, hitPointCount: u32) void {
    std.debug.assert(hitPointCount <= entityLow.sim.hitPoint.len);
    entityLow.sim.hitPointMax = hitPointCount;

    var hitPointIndex = @as(u32, 0);
    while (hitPointIndex < entityLow.sim.hitPointMax) : (hitPointIndex += 1) {
        const hitPoint = &entityLow.sim.hitPoint[hitPointIndex];
        hitPoint.flags = 0;
        hitPoint.filledAmount = game.HIT_POINT_SUB_COUNT;
    }
}

fn AddSword(gameState: *game.state) add_low_entity_result {
    var entity = AddLowEntity(gameState, .Sword, game.NullPosition());

    entity.low.sim.collision = gameState.swordCollision;

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Movable));

    return entity;
}

fn AddPlayer(gameState: *game.state) add_low_entity_result {
    const p = gameState.cameraP;
    var entity = AddGroundedEntity(gameState, .Hero, p, gameState.playerCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides) | @enumToInt(game.sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    const sword = AddSword(gameState);
    entity.low.sim.sword.index = sword.lowIndex;

    if (gameState.cameraFollowingEntityIndex == 0) {
        gameState.cameraFollowingEntityIndex = entity.lowIndex;
    }

    return entity;
}

fn AddMonstar(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Monstar, p, gameState.monstarCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides) | @enumToInt(game.sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    return entity;
}

fn AddFamiliar(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Familiar, p, gameState.familiarCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides) | @enumToInt(game.sim_entity_flags.Movable));

    return entity;
}

fn DrawHitpoints(entity: *game.sim_entity, pieceGroup: *game.render_group) void {
    if (entity.hitPointMax >= 1) {
        const healthDim = game.v2{ 0.2, 0.2 };
        const spacingX = 1.5 * game.X(healthDim);
        var hitP = game.v2{
            -0.5 * @intToFloat(f32, entity.hitPointMax - 1) * spacingX,
            -0.25,
        };
        const dHitP = game.v2{ spacingX, 0 };
        var healthIndex = @as(u32, 0);
        while (healthIndex < entity.hitPointMax) : (healthIndex += 1) {
            const hitPoint = entity.hitPoint[healthIndex];
            var colour = game.v4{ 1, 0, 0, 1 };
            if (hitPoint.filledAmount == 0) {
                colour = .{ 0.2, 0.2, 0.2, 1 };
            }

            game.PushRect(pieceGroup, hitP, 0, healthDim, colour, 0);
            hitP += dHitP;
        }
    }
}

fn MakeSimpleGroundedCollision(gameState: *game.state, dimX: f32, dimY: f32, dimZ: f32) *game.sim_entity_collision_volume_group {
    const group: *game.sim_entity_collision_volume_group = gameState.worldArena.PushStruct(game.sim_entity_collision_volume_group);

    group.volumeCount = 1;
    group.volumes = gameState.worldArena.PushArray(game.sim_entity_collision_volume, group.volumeCount);
    group.totalVolume.offsetP = game.v3{ 0, 0, 0.5 * dimZ };
    group.totalVolume.dim = game.v3{ dimX, dimY, dimZ };
    group.volumes[0] = group.totalVolume;

    return group;
}

fn MakeNullCollision(gameState: *game.state) *game.sim_entity_collision_volume_group {
    const group: *game.sim_entity_collision_volume_group = gameState.worldArena.PushStruct(game.sim_entity_collision_volume_group);

    group.volumeCount = 0;
    group.volumes = undefined; // TODO (Manav): change type from,  [*]sim_entity_collision_volume to ?[*]sim_entity_collision_volume
    group.totalVolume.offsetP = game.v3{ 0, 0, 0 };
    group.totalVolume.dim = game.v3{ 0, 0, 0 };

    return group;
}

fn FillGroundChunk(_: *game.transient_state, gameState: *game.state, groundBuffer: *game.ground_buffer, chunkP: *const game.world_position) void {
    var buffer = &groundBuffer.bitmap;

    groundBuffer.p = chunkP.*;

    const width = @intToFloat(f32, buffer.width);
    const height = @intToFloat(f32, buffer.height);

    var chunkOffsetY = @as(i32, -1);
    while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
        var chunkOffsetX = @as(i32, -1);
        while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
            const chunkX = chunkP.chunkX + chunkOffsetX;
            const chunkY = chunkP.chunkY + chunkOffsetY;
            const chunkZ = chunkP.chunkZ;

            var series = game.RandomSeed(@bitCast(u32, 139 * chunkX + 593 * chunkY + 329 * chunkZ));
            // TODO (Manav): inspect why 0.5 is needed as offset
            const center = game.v2{ (0.5 + @intToFloat(f32, chunkOffsetX)) * width, (0.5 - @intToFloat(f32, chunkOffsetY)) * height };

            var grassIndex = @as(u32, 0);
            while (grassIndex < 100) : (grassIndex += 1) {
                const stamp = if (series.RandomChoice(2) == 1)
                    &gameState.grass[series.RandomChoice(gameState.grass.len)]
                else
                    &gameState.stones[series.RandomChoice(gameState.stones.len)];

                const bitmapCenter = game.V2(0.5, 0.5) * game.V2(stamp.width, stamp.height);
                const offset = game.v2{ width * series.RandomBilateral(), height * series.RandomBilateral() };
                const p = center + offset - bitmapCenter;
                game.DrawBitmap(buffer, stamp, game.X(p), game.Y(p), 1.0);
            }
        }
    }

    chunkOffsetY = -1;
    while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
        var chunkOffsetX = @as(i32, -1);
        while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
            const chunkX = chunkP.chunkX + chunkOffsetX;
            const chunkY = chunkP.chunkY + chunkOffsetY;
            const chunkZ = chunkP.chunkZ;

            var series = game.RandomSeed(@bitCast(u32, 139 * chunkX + 593 * chunkY + 329 * chunkZ));
            // TODO (Manav): inspect why 0.5 is needed as offset
            const center = game.v2{ (0.5 + @intToFloat(f32, chunkOffsetX)) * width, (0.5 - @intToFloat(f32, chunkOffsetY)) * height };

            var grassIndex = @as(u32, 0);
            while (grassIndex < 100) : (grassIndex += 1) {
                const stamp = &gameState.tufts[series.RandomChoice(gameState.tufts.len)];

                const bitmapCenter = game.V2(0.5, 0.5) * game.V2(stamp.width, stamp.height);
                const offset = game.v2{ width * series.RandomBilateral(), height * series.RandomBilateral() };
                const p = center + offset - bitmapCenter;

                game.DrawBitmap(buffer, stamp, game.X(p), game.Y(p), 1.0);
            }
        }
    }
}

fn ClearBitmap(bitmap: *game.loaded_bitmap) void {
    const totalBitmapSize = @intCast(usize, bitmap.width * bitmap.height * platform.BITMAP_BYTES_PER_PIXEL);
    game.ZeroSize(totalBitmapSize, bitmap.memory);
}

fn MakeEmptyBitmap(arena: *game.memory_arena, width: i32, height: i32, clearToZero: bool) game.loaded_bitmap {
    var result = game.loaded_bitmap{};

    result.width = width;
    result.height = height;
    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;
    const totalBitmapSize = @intCast(usize, result.width * result.height * platform.BITMAP_BYTES_PER_PIXEL);
    result.memory = arena.PushSize(@alignOf(u8), totalBitmapSize);
    if (clearToZero) {
        ClearBitmap(&result);
    }

    return result;
}

// fn RequestGroundBuffers(centerP: game.world_position, bounds: game.rect3) void {
//     bounds = game.Offset(bounds, centerP.offset_);
//     centerP.offset_ = .{0, 0, 0};

//     var

//     FillGroundChunk(tranState, gameState, &tranState.groundBuffers[0], &gameState.cameraP);
// }

pub inline fn ChunkPosFromTilePos(w: *game.world, absTileX: i32, absTileY: i32, absTileZ: i32, additionalOffset: game.v3) game.world_position {
    const basePos: game.world_position = .{};

    const tileSideInMeters = 1.4;
    const tileDepthInMeters = 3.0;

    const tileDim = game.v3{ tileSideInMeters, tileSideInMeters, tileDepthInMeters };
    const offset = tileDim * game.v3{ @intToFloat(f32, absTileX), @intToFloat(f32, absTileY), @intToFloat(f32, absTileZ) };

    const result: game.world_position = game.MapIntoChunkSpace(w, basePos, offset + additionalOffset);

    std.debug.assert(game.IsCanonical(w, result.offset_));

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(
    thread: *platform.thread_context,
    gameMemory: *platform.memory,
    gameInput: *platform.input,
    buffer: *platform.offscreen_buffer,
) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args.len != @typeInfo(platform.UpdateAndRenderType).Fn.args.len or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[0].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[0].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[1].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[1].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[2].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[2].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[3].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[3].arg_type.?) or
            @typeInfo(@TypeOf(UpdateAndRender)).Fn.return_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.return_type.?)
        {
            @compileError("Function signature mismatch!");
        }
    }

    std.debug.assert(@sizeOf(game.state) <= gameMemory.permanentStorageSize);
    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));

    const groundBufferWidth = 256;
    const groundBufferHeight = 256;

    if (!gameMemory.isInitialized) {
        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

        gameState.typicalFloorHeight = 3.0;
        gameState.metersToPixels = 42;
        gameState.pixelsToMeters = 1.0 / gameState.metersToPixels;

        const worldChunkDimInMeters = game.v3{
            gameState.pixelsToMeters * groundBufferWidth,
            gameState.pixelsToMeters * groundBufferHeight,
            gameState.typicalFloorHeight,
        };

        gameState.worldArena.Initialize(gameMemory.permanentStorageSize - @sizeOf(game.state), gameMemory.permanentStorage + @sizeOf(game.state));

        _ = AddLowEntity(gameState, .Null, game.NullPosition());

        gameState.world = gameState.worldArena.PushStruct(game.world);
        const world = gameState.world;
        game.InitializeWorld(world, worldChunkDimInMeters);

        const tileSideInMeters = 1.4;
        const tileDepthInMeters = gameState.typicalFloorHeight;

        gameState.nullCollision = MakeNullCollision(gameState);
        gameState.swordCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.1);
        gameState.stairCollision = MakeSimpleGroundedCollision(gameState, tileSideInMeters, 2 * tileSideInMeters, 1.1 * tileDepthInMeters);
        gameState.playerCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 1.2);
        gameState.monstarCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.5);
        gameState.familiarCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.5);
        gameState.wallCollision = MakeSimpleGroundedCollision(gameState, tileSideInMeters, tileSideInMeters, tileDepthInMeters);

        gameState.standardRoomCollision = MakeSimpleGroundedCollision(gameState, tilesPerWidth * tileSideInMeters, tilesPerHeight * tileSideInMeters, 0.9 * tileDepthInMeters);

        gameState.grass[0] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/grass00.bmp");
        gameState.grass[1] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/grass01.bmp");

        gameState.tufts[0] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tuft00.bmp");
        gameState.tufts[1] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tuft01.bmp");
        gameState.tufts[2] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tuft00.bmp");

        gameState.stones[0] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground00.bmp");
        gameState.stones[1] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground01.bmp");
        gameState.stones[2] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground02.bmp");
        gameState.stones[3] = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground03.bmp");

        gameState.backdrop = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_background.bmp");
        gameState.shadow = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_shadow.bmp");
        gameState.tree = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tree00.bmp");
        gameState.stairwell = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/rock02.bmp");
        gameState.sword = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/rock03.bmp");

        gameState.heroBitmaps[0].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_head.bmp");
        gameState.heroBitmaps[0].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_cape.bmp");
        gameState.heroBitmaps[0].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_torso.bmp");
        gameState.heroBitmaps[0].alignment = .{ 72, 182 };

        gameState.heroBitmaps[1].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_head.bmp");
        gameState.heroBitmaps[1].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_cape.bmp");
        gameState.heroBitmaps[1].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_torso.bmp");
        gameState.heroBitmaps[1].alignment = .{ 72, 182 };

        gameState.heroBitmaps[2].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_head.bmp");
        gameState.heroBitmaps[2].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_cape.bmp");
        gameState.heroBitmaps[2].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_torso.bmp");
        gameState.heroBitmaps[2].alignment = .{ 72, 182 };

        gameState.heroBitmaps[3].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_head.bmp");
        gameState.heroBitmaps[3].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_cape.bmp");
        gameState.heroBitmaps[3].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_torso.bmp");
        gameState.heroBitmaps[3].alignment = .{ 72, 182 };

        var series = game.RandomSeed(1234);

        const screenBaseX = @as(u32, 0);
        const screenBaseY = @as(u32, 0);
        const screenBaseZ = @as(u32, 0);
        var screenX = screenBaseX;
        var screenY = screenBaseY;
        var absTileZ = screenBaseZ;

        var doorLeft = false;
        var doorRight = false;
        var doorTop = false;
        var doorBottom = false;
        var doorUp = false;
        var doorDown = false;

        var screenIndex: u32 = 0;
        while (screenIndex < 2000) : (screenIndex += 1) {
            // var doorDirection = series.RandomChoice(if (doorUp or doorDown) 2 else 3);
            var doorDirection = series.RandomChoice(2);

            var createdZDoor = false;
            if (doorDirection == 2) {
                createdZDoor = true;
                if (absTileZ == screenBaseZ) {
                    doorUp = true;
                } else {
                    doorDown = true;
                }
            } else if (doorDirection == 1) {
                doorRight = true;
            } else {
                doorTop = true;
            }

            _ = AddStandardRoom(gameState, screenX * tilesPerWidth + tilesPerWidth / 2, screenY * tilesPerHeight + tilesPerHeight / 2, absTileZ);

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
                        if ((tileX == 10) and (tileY == 5)) {
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

            if (doorDirection == 2) {
                if (absTileZ == screenBaseZ) {
                    absTileZ = screenBaseZ + 1;
                } else {
                    absTileZ = screenBaseZ;
                }
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
                _ = AddFamiliar(gameState, @intCast(u32, @intCast(i32, cameraTileX) + familiarOffsetX), @intCast(u32, @intCast(i32, cameraTileY) + familiarOffsetY), cameraTileZ);
            }
        }

        gameMemory.isInitialized = true;
    }

    std.debug.assert(@sizeOf(game.transient_state) <= gameMemory.transientStorageSize);
    const tranState = @ptrCast(*game.transient_state, @alignCast(@alignOf(game.transient_state), gameMemory.transientStorage));
    if (!tranState.initialized) {
        tranState.tranArena.Initialize(
            gameMemory.transientStorageSize - @sizeOf(game.transient_state),
            gameMemory.transientStorage + @sizeOf(game.transient_state),
        );

        tranState.groundBufferCount = 64; // 128
        tranState.groundBuffers = tranState.tranArena.PushArray(game.ground_buffer, tranState.groundBufferCount);
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBufferCount) : (groundBufferIndex += 1) {
            var groundBuffer: *game.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.bitmap = MakeEmptyBitmap(&tranState.tranArena, groundBufferWidth, groundBufferHeight, false);
            groundBuffer.p = game.NullPosition();
        }

        tranState.initialized = true;
    }

    if (gameInput.executableReloaded) {
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBufferCount) : (groundBufferIndex += 1) {
            var groundBuffer: *game.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.p = game.NullPosition();
        }
    }

    const world = gameState.world;

    const metersToPixels = gameState.metersToPixels;
    const pixelsToMeters = 1.0 / gameState.metersToPixels;

    for (gameInput.controllers) |controller, controllerIndex| {
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
                conHero.dSword[1] = 1.0;
            }
            if (controller.buttons.mapped.actionDown.endedDown != 0) {
                conHero.dSword[1] = -1.0;
            }
            if (controller.buttons.mapped.actionLeft.endedDown != 0) {
                conHero.dSword[0] = -1.0;
            }
            if (controller.buttons.mapped.actionRight.endedDown != 0) {
                conHero.dSword[0] = 1.0;
            }
        }
    }

    const renderMemory = game.BeginTemporaryMemory(&tranState.tranArena);
    const renderGroup = game.AllocateRenderGroup(&tranState.tranArena, platform.MegaBytes(4), gameState.metersToPixels);

    var drawBuffer_ = game.loaded_bitmap{
        .width = @intCast(i32, buffer.width),
        .height = @intCast(i32, buffer.height),
        .pitch = @intCast(i32, buffer.pitch),
        .memory = @ptrCast([*]u8, buffer.memory.?),
    };
    const drawBuffer = &drawBuffer_;

    game.DrawRectangle(drawBuffer, .{ 0, 0 }, .{ @intToFloat(f32, drawBuffer.width), @intToFloat(f32, drawBuffer.height) }, 1.0, 0.0, 1.0);

    const screenCenter = game.v2{
        0.5 * @intToFloat(f32, drawBuffer.width),
        0.5 * @intToFloat(f32, drawBuffer.height),
    };

    const screenWidthInMeters = @intToFloat(f32, drawBuffer.width) * pixelsToMeters;
    const screenHeightInMeters = @intToFloat(f32, drawBuffer.height) * pixelsToMeters;
    const cameraBoundsInMeters = game.rect3.InitCenterDim(.{ 0, 0, 0 }, game.v3{ screenWidthInMeters, screenHeightInMeters, 0 });

    var groundBufferIndex = @as(u32, 0);
    while (groundBufferIndex < tranState.groundBufferCount) : (groundBufferIndex += 1) {
        var groundBuffer: *game.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
        if (game.IsValid(groundBuffer.p)) {
            const bitmap = &groundBuffer.bitmap;
            const delta = game.Substract(world, &groundBuffer.p, &gameState.cameraP);
            game.PushBitmap(renderGroup, bitmap, game.XY(delta), game.Z(delta), .{ 0.5 * @intToFloat(f32, bitmap.width), 0.5 * @intToFloat(f32, bitmap.height) }, 1, 1);
        }
    }

    {
        const minChunkP = game.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMinCorner());
        const maxChunkP = game.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMaxCorner());

        var chunkZ = minChunkP.chunkZ;
        while (chunkZ <= maxChunkP.chunkZ) : (chunkZ += 1) {
            var chunkY = minChunkP.chunkY;
            while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
                var chunkX = minChunkP.chunkX;
                while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
                    // if (game.GetWorldChunk(null, world, )) |chunk|
                    {
                        const chunkCenterP = game.CenteredChunkPoint(chunkX, chunkY, chunkZ);
                        const relP = game.Substract(world, &chunkCenterP, &gameState.cameraP);
                        const screenP = screenCenter + game.v2{ metersToPixels, -metersToPixels } * game.XY(relP);
                        const screenDim = game.v2{ metersToPixels, metersToPixels } * game.XY(world.chunkDimInMeters);

                        var furthestBufferLengthSq = @as(f32, 0);
                        var furthestBuffer: ?*game.ground_buffer = null;
                        var index = @as(u32, 0);
                        while (index < tranState.groundBufferCount) : (index += 1) {
                            const groundBuffer = &tranState.groundBuffers[index];
                            if (game.AreInSameChunk(world, &groundBuffer.p, &chunkCenterP)) {
                                furthestBuffer = null;
                                break;
                            } else if (game.IsValid(groundBuffer.p)) {
                                const distance = game.Substract(world, &groundBuffer.p, &gameState.cameraP);
                                const bufferLengthSq = game.LengthSq(game.XY(distance));
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

                        if (!NOT_IGNORE) {
                            game.DrawRectangleOutline(drawBuffer, screenP - game.v2{ 0.5, 0.5 } * screenDim, screenP + game.v2{ 0.5, 0.5 } * screenDim, .{ 1, 1, 0 }, 2);
                        }
                    }
                }
            }
        }
    }

    const simBoundsExpansion = game.v3{ 15, 15, 15 };
    const simBounds = game.AddRadiusToRect3(cameraBoundsInMeters, simBoundsExpansion);
    const simMemory = game.BeginTemporaryMemory(&tranState.tranArena);
    const simRegion = game.BeginSim(&tranState.tranArena, gameState, gameState.world, gameState.cameraP, simBounds, gameInput.dtForFrame);

    var entityIndex = @as(u32, 0);
    while (entityIndex < simRegion.entityCount) : (entityIndex += 1) {
        const entity: *game.sim_entity = &simRegion.entities[entityIndex];

        if (entity.updatable) {
            const dt = gameInput.dtForFrame;

            const alpha = 1 - 0.5 * game.Z(entity.p);
            const shadowAlpha = game.Clampf01(alpha);

            var moveSpec = game.DefaultMoveSpec();
            var ddP = game.v3{ 0, 0, 0 };

            const basis = tranState.tranArena.PushStruct(game.render_basis);
            renderGroup.defaultBasis = basis;

            const heroBitmaps = &gameState.heroBitmaps[entity.facingDirection];
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
                            ddP = .{ game.X(conHero.ddP), game.Y(conHero.ddP), 0 };
                            if ((game.X(conHero.dSword) != 0) or (game.Y(conHero.dSword) != 0)) {
                                switch (entity.sword) {
                                    .ptr => {
                                        const sword = entity.sword.ptr;
                                        if (game.IsSet(sword, @enumToInt(game.sim_entity_flags.NonSpatial))) {
                                            sword.distanceLimit = 5.0;
                                            const dSwordV3 = game.v3{ game.X(conHero.dSword), game.Y(conHero.dSword), 0 };
                                            game.MakeEntitySpatial(sword, entity.p, entity.dP + (dSwordV3 * @splat(3, @as(f32, 5)))); //
                                            game.AddCollisionRule(gameState, sword.storageIndex, entity.storageIndex, false);
                                        }
                                    },

                                    .index => {
                                        unreachable;
                                    },
                                }
                            }
                        }
                    }

                    game.PushBitmap(renderGroup, &gameState.shadow, .{ 0, 0 }, 0, heroBitmaps.alignment, shadowAlpha, 0.0);
                    game.PushBitmap(renderGroup, &heroBitmaps.torso, .{ 0, 0 }, 0, heroBitmaps.alignment, 1.0, 1.0);
                    game.PushBitmap(renderGroup, &heroBitmaps.cape, .{ 0, 0 }, 0, heroBitmaps.alignment, 1.0, 1.0);
                    game.PushBitmap(renderGroup, &heroBitmaps.head, .{ 0, 0 }, 0, heroBitmaps.alignment, 1.0, 1.0);

                    DrawHitpoints(entity, renderGroup);
                },

                .Wall => {
                    game.PushBitmap(renderGroup, &gameState.tree, .{ 0, 0 }, 0, .{ 40, 80 }, 1.0, 1.0);
                },

                .Stairwell => {
                    game.PushRect(renderGroup, .{ 0, 0 }, 0, entity.walkableDim, .{ 1, 0.5, 0, 1 }, 0);
                    game.PushRect(renderGroup, .{ 0, 0 }, entity.walkableHeight, entity.walkableDim, .{ 1, 1, 0, 1 }, 0);
                },

                .Sword => {
                    moveSpec.unitMaxAccelVector = false;
                    moveSpec.speed = 0;
                    moveSpec.drag = 0;

                    if (entity.distanceLimit == 0) {
                        game.ClearCollisionRulesFor(gameState, entity.storageIndex);
                        game.MakeEntityNonSpatial(entity);
                    } else {
                        // NOTE (Manav): invalid z position causes float overflow down the line when drawing bitmap because of zFudge,
                        // so not pushing bitmap when entity becomes non spatial
                        game.PushBitmap(renderGroup, &gameState.shadow, .{ 0, 0 }, 0, heroBitmaps.alignment, shadowAlpha, 0.0);
                        game.PushBitmap(renderGroup, &gameState.sword, .{ 0, 0 }, 0, .{ 29, 10 }, 1.0, 1.0);
                    }
                },

                .Familiar => {
                    var closestHero: ?*game.sim_entity = null;
                    var closestHeroDSq = game.Square(10);
                    if (!NOT_IGNORE) {
                        var testEntityIndex = @as(u32, 0);
                        while (testEntityIndex < simRegion.entityCount) : (testEntityIndex += 1) {
                            const testEntity: *game.sim_entity = &simRegion.entities[testEntityIndex];
                            if (testEntity.entityType == .Hero) {
                                var testDSq = game.LengthSq(3, testEntity.p - entity.p);

                                if (closestHeroDSq > testDSq) {
                                    closestHero = testEntity;
                                    closestHeroDSq = testDSq;
                                }
                            }
                        }
                    }

                    if (closestHero) |hero| {
                        if (closestHeroDSq > game.Square(3)) {
                            const accelaration = 0.5;
                            const oneOverLength = accelaration / game.SquareRoot(closestHeroDSq);
                            ddP = @splat(3, oneOverLength) * (hero.p - entity.p);
                        }
                    }

                    moveSpec.unitMaxAccelVector = true;
                    moveSpec.speed = 50;
                    moveSpec.drag = 8;

                    entity.tBob += dt;
                    if (entity.tBob > 2 * platform.PI32) {
                        entity.tBob -= 2 * platform.PI32;
                    }
                    const bobSin = game.Sin(2 * entity.tBob);
                    game.PushBitmap(renderGroup, &gameState.shadow, .{ 0, 0 }, 0, heroBitmaps.alignment, (0.5 * shadowAlpha) + (0.2 * bobSin), 0.0);
                    game.PushBitmap(renderGroup, &heroBitmaps.head, .{ 0, 0 }, 0.25 * bobSin, heroBitmaps.alignment, 1.0, 1.0);
                },

                .Monstar => {
                    game.PushBitmap(renderGroup, &gameState.shadow, .{ 0, 0 }, 0, heroBitmaps.alignment, shadowAlpha, 0.0);
                    game.PushBitmap(renderGroup, &heroBitmaps.torso, .{ 0, 0 }, 0, heroBitmaps.alignment, 1.0, 1.0);

                    DrawHitpoints(entity, renderGroup);
                },

                .Space => {
                    if (!NOT_IGNORE) {
                        var volumeIndex = @as(u32, 0);
                        while (volumeIndex < entity.collision.volumeCount) : (volumeIndex += 1) {
                            const volume = entity.collision.volumes[volumeIndex];
                            game.PushRectOutline(renderGroup, game.XY(volume.offsetP), 0, game.XY(volume.dim), .{ 0, 0.5, 1, 1 }, 0);
                        }
                    }
                },

                .Null => {
                    unreachable;
                },
            }

            if (!game.IsSet(entity, @enumToInt(game.sim_entity_flags.NonSpatial)) and
                game.IsSet(entity, @enumToInt(game.sim_entity_flags.Movable)))
            {
                game.MoveEntity(gameState, simRegion, entity, gameInput.dtForFrame, &moveSpec, ddP);
            }

            basis.p = game.GetEntityGroundPoint(entity);
        }
    }

    game.RenderGroupToOutput(renderGroup, drawBuffer);

    game.EndSim(simRegion, gameState); // TODO (Manav): use defer
    game.EndTemporaryMemory(simMemory);
    game.EndTemporaryMemory(renderMemory);

    gameState.worldArena.CheckArena();
    tranState.tranArena.CheckArena();
}

pub export fn GetSoundSamples(_: *platform.thread_context, gameMemory: *platform.memory, soundBuffer: *platform.sound_output_buffer) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args.len != @typeInfo(platform.GetSoundSamplesType).Fn.args.len or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[0].arg_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.args[0].arg_type.?) or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[1].arg_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.args[1].arg_type.?) or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[2].arg_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.args[2].arg_type.?) or
            @typeInfo(@TypeOf(GetSoundSamples)).Fn.return_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.return_type.?)
        {
            @compileError("Function signature mismatch!");
        }
    }

    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));
    OutputSound(gameState, soundBuffer, 400);
}

const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_internals.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_tile.zig");
    usingnamespace @import("handmade_random.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;

// local functions ------------------------------------------------------------------------------------------------------------------------

fn SetTileValue(arena: *game.memory_arena, tileMap: *game.tile_map, absTileX: u32, absTileY: u32, absTileZ: u32, tileValue: u32) void {
    const chunkPos = game.GetChunkPositionFor(tileMap, absTileX, absTileY, absTileZ);
    const tileChunk = game.GetTileChunk(tileMap, chunkPos.tileChunkX, chunkPos.tileChunkY, chunkPos.tileChunkZ);

    std.debug.assert(tileChunk != null);

    if (tileChunk.?.tiles) |_| {} else {
        const tileCount = tileMap.chunkDim * tileMap.chunkDim;
        tileChunk.?.tiles = game.PushArrayPtr(u32, tileCount, arena);

        var tileIndex: u32 = 0;
        while (tileIndex < tileCount) : (tileIndex += 1) {
            tileChunk.?.tiles.?[tileIndex] = 1;
        }
    }

    game.SetTileValue(tileMap, tileChunk, chunkPos.relTileX, chunkPos.relTileY, tileValue);
}

fn OutputSound(_: *game.state, soundBuffer: *platform.sound_output_buffer, toneHz: u32) void {
    const toneVolume = 3000;
    _ = toneVolume;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);
    _ = wavePeriod;

    var sampleOut = soundBuffer.samples;
    var sampleIndex: u32 = 0;
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

fn DrawRectangle(buffer: *platform.offscreen_buffer, vMin: game.v2, vMax: game.v2, r: f32, g: f32, b: f32) void {
    var minX = game.RoundF32ToInt(i32, vMin.x);
    var minY = game.RoundF32ToInt(i32, vMin.y);
    var maxX = game.RoundF32ToInt(i32, vMax.x);
    var maxY = game.RoundF32ToInt(i32, vMax.y);

    if (minX < 0) {
        minX = 0;
    }

    if (minY < 0) {
        minY = 0;
    }

    if (maxX > @intCast(i32, buffer.width)) {
        maxX = @intCast(i32, buffer.width);
    }

    if (maxY > @intCast(i32, buffer.height)) {
        maxY = @intCast(i32, buffer.height);
    }

    const colour: u32 = (game.RoundF32ToInt(u32, r * 255.0) << 16) | (game.RoundF32ToInt(u32, g * 255.0) << 8) | (game.RoundF32ToInt(u32, b * 255) << 0);

    var row = @ptrCast([*]u8, buffer.memory) + @intCast(u32, minX) * buffer.bytesPerPixel + @intCast(u32, minY) * buffer.pitch;

    var y = minY;
    while (y < maxY) : (y += 1) {
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        var x = minX;
        while (x < maxX) : (x += 1) {
            pixel.* = colour;
            pixel += 1;
        }
        row += buffer.pitch;
    }
}

fn DrawBitmap(buffer: *platform.offscreen_buffer, bitmap: *const game.loaded_bitmap, realX: f32, realY: f32, alignX: i32, alignY: i32, cAlpha: f32) void {
    const alignedRealX = realX - @intToFloat(f32, alignX);
    const alignedRealY = realY - @intToFloat(f32, alignY);

    var minX = game.RoundF32ToInt(i32, alignedRealX);
    var minY = game.RoundF32ToInt(i32, alignedRealY);
    var maxX = game.RoundF32ToInt(i32, alignedRealX + @intToFloat(f32, bitmap.width));
    var maxY = game.RoundF32ToInt(i32, alignedRealY + @intToFloat(f32, bitmap.height));

    var sourceOffesetX = @as(i32, 0);
    if (minX < 0) {
        sourceOffesetX = -minX;
        minX = 0;
    }

    var sourceOffesetY = @as(i32, 0);
    if (minY < 0) {
        sourceOffesetY = -minY;
        minY = 0;
    }

    if (maxX > @intCast(i32, buffer.width)) {
        maxX = @intCast(i32, buffer.width);
    }

    if (maxY > @intCast(i32, buffer.height)) {
        maxY = @intCast(i32, buffer.height);
    }

    var sourceRow = bitmap.pixels.access + @intCast(u32, bitmap.width * (bitmap.height - 1) - sourceOffesetY * bitmap.width + sourceOffesetX);
    var destRow = @ptrCast([*]u8, buffer.memory) + @intCast(u32, minX) * buffer.bytesPerPixel + @intCast(u32, minY) * buffer.pitch;

    var y = minY;
    while (y < maxY) : (y += 1) {
        const dest = @ptrCast([*]u32, @alignCast(@alignOf(u32), destRow));
        var x = minX;
        while (x < maxX) : (x += 1) {
            const index = @intCast(u32, x - minX);

            const a = (@intToFloat(f32, ((sourceRow[index] >> 24) & 0xff)) / 255.0) * cAlpha;

            const sR = @intToFloat(f32, ((sourceRow[index] >> 16) & 0xff));
            const sG = @intToFloat(f32, ((sourceRow[index] >> 8) & 0xff));
            const sB = @intToFloat(f32, ((sourceRow[index] >> 0) & 0xff));

            const dR = @intToFloat(f32, ((dest[index] >> 16) & 0xff));
            const dG = @intToFloat(f32, ((dest[index] >> 8) & 0xff));
            const dB = @intToFloat(f32, ((dest[index] >> 0) & 0xff));

            const r = (1 - a) * dR + a * sR;
            const g = (1 - a) * dG + a * sG;
            const b = (1 - a) * dB + a * sB;

            dest[index] = (@floatToInt(u32, r + 0.5) << 16) | (@floatToInt(u32, g + 0.5) << 8) | (@floatToInt(u32, b + 0.5) << 0);
        }

        destRow += buffer.pitch;
        sourceRow -= @intCast(u32, bitmap.width);
    }
}

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

fn DEBUGLoadBMP(thread: *platform.thread_context, ReadEntireFile: platform.debug_platform_read_entire_file, fileName: [*:0]const u8) game.loaded_bitmap {
    var result = game.loaded_bitmap{};

    const readResult = ReadEntireFile(thread, fileName);
    if (readResult.contentSize != 0) {
        const header = @ptrCast(*bitmap_header, readResult.contents);
        var pixels = @ptrCast([*]u8, readResult.contents) + header.bitmapOffset;
        result.width = header.width;
        result.height = header.height;
        result.pixels.colour = pixels;

        std.debug.assert(header.compression == 3);

        const redMask = header.redMask;
        const greenMask = header.greenMask;
        const blueMask = header.blueMask;
        const alphaMask = ~(redMask | greenMask | blueMask);

        const redScan = game.FindLeastSignificantSetBit(redMask);
        const greenScan = game.FindLeastSignificantSetBit(greenMask);
        const blueScan = game.FindLeastSignificantSetBit(blueMask);
        const alphaScan = game.FindLeastSignificantSetBit(alphaMask);

        const redShift = 16 - @intCast(i8, redScan);
        const greenShift = 8 - @intCast(i8, greenScan);
        const blueShift = 0 - @intCast(i8, blueScan);
        const alphaShift = 24 - @intCast(i8, alphaScan);

        const sourceDest = result.pixels.access;

        var index = @as(u32, 0);
        while (index < @intCast(u32, header.height * header.width)) : (index += 1) {
            const c = sourceDest[index];
            sourceDest[index] = (game.RotateLeft(c & redMask, redShift) |
                game.RotateLeft(c & greenMask, greenShift) |
                game.RotateLeft(c & blueMask, blueShift) |
                game.RotateLeft(c & alphaMask, alphaShift));
        }
    }

    return result;
}

fn ChangeEntityResidence(gameState: *game.state, entityIndex: u32, residence: game.entity_residence) void {
    if (residence == .High) {
        if (gameState.entityResidence[entityIndex] != .High) {
            var entityHigh = &gameState.highEntities[entityIndex];
            var entityDormant = &gameState.dormantEntities[entityIndex];

            const diff = game.Substract(gameState.world.tileMap, &entityDormant.p, &gameState.cameraP);

            entityHigh.p = diff.dXY;
            entityHigh.dP = .{};
            entityHigh.absTileZ = entityDormant.p.absTileZ;
            entityHigh.facingDirection = 0;
        }
    }

    gameState.entityResidence[entityIndex] = residence;
}

inline fn GetEntity(gameState: *game.state, residence: game.entity_residence, index: u32) game.entity {
    var entity = game.entity{
        .low = undefined,
        .dormant = undefined,
        .high = undefined,
    };

    if ((index > 0) and (index < gameState.entityCount)) {
        if (@enumToInt(gameState.entityResidence[index]) < @enumToInt(residence)) {
            ChangeEntityResidence(gameState, index, residence);
            std.debug.assert(@enumToInt(gameState.entityResidence[index]) >= @enumToInt(residence));
        }
        entity.residence = residence;
        entity.dormant = &gameState.dormantEntities[index];
        entity.low = &gameState.lowEntities[index];
        entity.high = &gameState.highEntities[index];
    }

    return entity;
}

fn InitializaPlayer(gameState: *game.state, entityIndex: u32) void {
    const entity = GetEntity(gameState, .Dormant, entityIndex);

    entity.dormant.p = .{
        .absTileX = 1,
        .absTileY = 3,
        .offset_ = .{ .x = 0, .y = 0 },
    };
    entity.dormant.height = 0.5;
    entity.dormant.width = 1.0;
    entity.dormant.collides = true;

    ChangeEntityResidence(gameState, entityIndex, .High);

    if (GetEntity(gameState, .Dormant, gameState.cameraFollowingEntityIndex).residence == .Nonexistent) {
        gameState.cameraFollowingEntityIndex = entityIndex;
    }
}

fn AddEntity(gameState: *game.state) u32 {
    const entityIndex = gameState.entityCount;
    gameState.entityCount += 1;

    std.debug.assert(gameState.entityCount < gameState.dormantEntities.len);
    std.debug.assert(gameState.entityCount < gameState.lowEntities.len);
    std.debug.assert(gameState.entityCount < gameState.highEntities.len);

    gameState.entityResidence[entityIndex] = .Dormant;
    gameState.dormantEntities[entityIndex] = .{};
    gameState.lowEntities[entityIndex] = .{};
    gameState.highEntities[entityIndex] = .{};

    return entityIndex;
}

fn TestWall(wallX: f32, relX: f32, relY: f32, playerDeltaX: f32, playerDeltaY: f32, tMin: *f32, minY: f32, maxY: f32) bool {
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

fn MovePlayer(gameState: *game.state, entity: game.entity, dt: f32, accelaration: game.v2) void {
    // const tileMap = gameState.world.tileMap;

    var ddP = accelaration;

    const ddPLength = game.LengthSq(ddP);
    if (ddPLength > 1.0) {
        _ = ddP.scale(1.0 / game.SquareRoot(ddPLength));
    }

    const playerSpeed = @as(f32, 50.0);
    _ = ddP.scale(playerSpeed);

    _ = ddP.add(game.scale(entity.high.dP, -8.0)); // NOTE (Manav): ddP += -8.0 * entity.high.dP;

    // const oldPlayerP = entity.high.p;
    // NOTE (Manav): playerDelta = (0.5 * ddP * square(dt)) + entity.dP * dt;
    var playerDelta = game.add(game.scale(ddP, 0.5 * game.square(dt)), game.scale(entity.high.dP, dt));
    _ = entity.high.dP.add(game.scale(ddP, dt)); // NOTE (Manav): entity.dP += ddP * dt;
    // const newPlayerP = game.add(oldPlayerP, playerDelta);

    // !NOT_IGNORE
    // var minTileX = @minimum(oldPlayerP.absTileX, newPlayerP.absTileX);
    // var minTileY = @minimum(oldPlayerP.absTileY, newPlayerP.absTileY);
    // var maxTileX = @maximum(oldPlayerP.absTileX, newPlayerP.absTileX);
    // var maxTileY = @maximum(oldPlayerP.absTileY, newPlayerP.absTileY);

    // const entityTileWidth = game.CeilF32ToI32(entity.dormant.width / tileMap.tileSideInMeters);
    // const entityTileHeight = game.CeilF32ToI32(entity.dormant.height / tileMap.tileSideInMeters);

    // minTileX -= @intCast(u32, entityTileWidth);
    // minTileY -= @intCast(u32, entityTileHeight);
    // maxTileX += @intCast(u32, entityTileWidth);
    // maxTileY += @intCast(u32, entityTileHeight);

    // const absTileZ = entity.high.p.absTileZ;

    var tRemaining = @as(f32, 1.0);
    var iteration = @as(u32, 0);
    while ((iteration < 4) and (tRemaining > 0)) : (iteration += 1) {
        var tMin = @as(f32, 1.0);
        var wallNormal = game.v2{};

        var hitEntityIndex = @as(u32, 0);
        var entityIndex = @as(u32, 1);
        while (entityIndex < gameState.entityCount) : (entityIndex += 1) {
            const testEntity = GetEntity(gameState, .High, entityIndex);
            if (testEntity.high != entity.high) {
                if (testEntity.dormant.collides) {
                    const diameterW = testEntity.dormant.width + entity.dormant.width;
                    const diameterH = testEntity.dormant.height + entity.dormant.height;

                    const minCorner = game.v2{ .x = -0.5 * diameterW, .y = -0.5 * diameterH };
                    const maxCorner = game.v2{ .x = 0.5 * diameterW, .y = 0.5 * diameterH };

                    const rel = game.sub(entity.high.p, testEntity.high.p); // NOTE: (Manav): entity.high.p - testEntity.high.p

                    if (TestWall(minCorner.x, rel.x, rel.y, playerDelta.x, playerDelta.y, &tMin, minCorner.y, maxCorner.y)) {
                        wallNormal = .{ .x = -1, .y = 0 };
                        hitEntityIndex = entityIndex;
                    }
                    if (TestWall(maxCorner.x, rel.x, rel.y, playerDelta.x, playerDelta.y, &tMin, minCorner.y, maxCorner.y)) {
                        wallNormal = .{ .x = 1, .y = 0 };
                        hitEntityIndex = entityIndex;
                    }
                    if (TestWall(minCorner.y, rel.y, rel.x, playerDelta.y, playerDelta.x, &tMin, minCorner.x, maxCorner.x)) {
                        wallNormal = .{ .x = 0, .y = -1 };
                        hitEntityIndex = entityIndex;
                    }
                    if (TestWall(maxCorner.y, rel.y, rel.x, playerDelta.y, playerDelta.x, &tMin, minCorner.x, maxCorner.x)) {
                        wallNormal = .{ .x = 0, .y = 1 };
                        hitEntityIndex = entityIndex;
                    }
                }
            }
        }

        // NOTE: (Manav): entity.high.p += tMin * playerDelta
        _ = entity.high.p.add(game.scale(playerDelta, tMin));
        if (hitEntityIndex != 0) {
            // NOTE (Manav): entity.high.dP -= (1 * inner(entity.high.dP, wallNormal))*wallNormal;
            _ = entity.high.dP.sub(game.scale(wallNormal, 1 * game.inner(entity.high.dP, wallNormal)));
            // NOTE (Manav): playerDelta -= (1 * inner(playerDelta, wallNormal))*wallNormal;
            _ = playerDelta.sub(game.scale(wallNormal, 1 * game.inner(playerDelta, wallNormal)));
            tRemaining -= tMin * tRemaining;

            const hitEntity = GetEntity(gameState, .Dormant, hitEntityIndex);
            entity.high.absTileZ = game.AddI32ToU32(entity.high.absTileZ, hitEntity.dormant.dAbsTileZ);
        } else {
            break;
        }
    }

    if ((entity.high.dP.x == 0) and (entity.high.dP.y == 0)) {
        // NOTE(casey): Leave FacingDirection whatever it was
    } else if (game.AbsoluteValue(entity.high.dP.x) > game.AbsoluteValue(entity.high.dP.y)) {
        if (entity.high.dP.x > 0) {
            entity.high.facingDirection = 0;
        } else {
            entity.high.facingDirection = 2;
        }
    } else {
        if (entity.high.dP.y > 0) {
            entity.high.facingDirection = 1;
        } else {
            entity.high.facingDirection = 3;
        }
    }

    entity.dormant.p = game.MapIntoTileSpace(gameState.world.tileMap, gameState.cameraP, entity.high.p);
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(thread: *platform.thread_context, gameMemory: *platform.memory, gameInput: *platform.input, buffer: *platform.offscreen_buffer) void {
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

    if (!gameMemory.isInitialized) {
        _ = AddEntity(gameState);

        gameState.backdrop = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_background.bmp");
        gameState.shadow = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_shadow.bmp");

        gameState.heroBitmaps[0].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_head.bmp");
        gameState.heroBitmaps[0].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_cape.bmp");
        gameState.heroBitmaps[0].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_torso.bmp");
        gameState.heroBitmaps[0].alignX = 72;
        gameState.heroBitmaps[0].alignY = 182;

        gameState.heroBitmaps[1].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_head.bmp");
        gameState.heroBitmaps[1].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_cape.bmp");
        gameState.heroBitmaps[1].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_torso.bmp");
        gameState.heroBitmaps[1].alignX = 72;
        gameState.heroBitmaps[1].alignY = 182;

        gameState.heroBitmaps[2].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_head.bmp");
        gameState.heroBitmaps[2].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_cape.bmp");
        gameState.heroBitmaps[2].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_torso.bmp");
        gameState.heroBitmaps[2].alignX = 72;
        gameState.heroBitmaps[2].alignY = 182;

        gameState.heroBitmaps[3].head = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_head.bmp");
        gameState.heroBitmaps[3].cape = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_cape.bmp");
        gameState.heroBitmaps[3].torso = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_torso.bmp");
        gameState.heroBitmaps[3].alignX = 72;
        gameState.heroBitmaps[3].alignY = 182;

        gameState.cameraP.absTileX = 17 / 2;
        gameState.cameraP.absTileY = 9 / 2;

        game.InitializeArena(&gameState.worldArena, gameMemory.permanentStorageSize - @sizeOf(game.state), gameMemory.permanentStorage + @sizeOf(game.state));

        gameState.world = game.PushStruct(game.world, &gameState.worldArena);

        const world = gameState.world;
        world.tileMap = game.PushStruct(game.tile_map, &gameState.worldArena);

        const tileChunkCountX = 128;
        const tileChunkCountY = 128;
        const tileChunkCountZ = 2;

        const chunkShift = 4;
        const chunkDim = @as(u32, 1) << @intCast(u5, chunkShift);

        var tileMap = world.tileMap;
        tileMap.chunkShift = chunkShift;
        tileMap.chunkMask = (@as(u32, 1) << @intCast(u5, chunkShift)) - 1;
        tileMap.chunkDim = chunkDim;

        tileMap.tileChunkCountX = tileChunkCountX;
        tileMap.tileChunkCountY = tileChunkCountY;
        tileMap.tileChunkCountZ = tileChunkCountZ;
        tileMap.tileChunks = game.PushArraySlice(game.tile_chunk, tileChunkCountX * tileChunkCountY * tileChunkCountZ, &gameState.worldArena);

        tileMap.tileSideInMeters = 1.4;

        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

        // !NOT_IGNORE
        // var screenX: u32 = std.math.maxInt(i32) / 2;
        // var screenY: u32 = std.math.maxInt(i32) / 2;
        var screenX: u32 = 0;
        var screenY: u32 = 0;

        var absTileZ: u32 = 0;

        var doorLeft = false;
        var doorRight = false;
        var doorTop = false;
        var doorBottom = false;
        var doorUp = false;
        var doorDown = false;

        var screenIndex: u32 = 0;
        while (screenIndex < 100) : (screenIndex += 1) {
            var randomChoice: u32 = 0;
            if (doorUp or doorDown) {
                randomChoice = game.RandInt(u32) % 2;
            } else {
                randomChoice = game.RandInt(u32) % 3;
            }

            var createdZDoor = false;
            if (randomChoice == 2) {
                createdZDoor = true;
                if (absTileZ == 0) {
                    doorUp = true;
                } else {
                    doorDown = true;
                }
            } else if (randomChoice == 1) {
                doorRight = true;
            } else {
                doorTop = true;
            }

            var tileY: u32 = 0;
            while (tileY < tilesPerHeight) : (tileY += 1) {
                var tileX: u32 = 0;
                while (tileX < tilesPerWidth) : (tileX += 1) {
                    const absTileX = screenX * tilesPerWidth + tileX;
                    const absTileY = screenY * tilesPerHeight + tileY;

                    var tileValue: u32 = 1;
                    if ((tileX == 0) and (!doorLeft or (tileY != (tilesPerHeight / 2)))) {
                        tileValue = 2;
                    }

                    if ((tileX == (tilesPerWidth - 1)) and (!doorRight or (tileY != (tilesPerHeight / 2)))) {
                        tileValue = 2;
                    }

                    if ((tileY == 0) and (!doorBottom or (tileX != (tilesPerWidth / 2)))) {
                        tileValue = 2;
                    }

                    if ((tileY == (tilesPerHeight - 1)) and (!doorTop or (tileX != (tilesPerWidth / 2)))) {
                        tileValue = 2;
                    }

                    if ((tileX == 10) and (tileY == 6)) {
                        if (doorUp) {
                            tileValue = 3;
                        }

                        if (doorDown) {
                            tileValue = 4;
                        }
                    }

                    SetTileValue(&gameState.worldArena, world.tileMap, absTileX, absTileY, absTileZ, tileValue);
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

            if (randomChoice == 2) {
                if (absTileZ == 0) {
                    absTileZ = 1;
                } else {
                    absTileZ = 0;
                }
            } else if (randomChoice == 1) {
                screenX += 1;
            } else {
                screenY += 1;
            }
        }

        gameMemory.isInitialized = true;
    }

    const world = gameState.world;
    const tileMap = world.tileMap;

    const tileSideInPixels = 60;
    const metersToPixels = @intToFloat(f32, tileSideInPixels) / tileMap.tileSideInMeters;

    // const lowerLeftX = -@intToFloat(f32, tileSideInPixels) / 2;
    // const lowerLeftY = @intToFloat(f32, buffer.height);

    for (gameInput.controllers) |controller, controllerIndex| {
        var controllingEntity = GetEntity(gameState, .High, gameState.playerIndexForController[controllerIndex]);

        if (controllingEntity.residence != .Nonexistent) {
            var ddP = game.v2{};
            if (controller.isAnalog) {
                ddP = .{ .x = controller.stickAverageX, .y = controller.stickAverageX };
            } else {
                if (controller.buttons.mapped.moveUp.endedDown != 0) {
                    ddP.y = 1.0;
                }
                if (controller.buttons.mapped.moveDown.endedDown != 0) {
                    ddP.y = -1.0;
                }
                if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                    ddP.x = -1.0;
                }
                if (controller.buttons.mapped.moveRight.endedDown != 0) {
                    ddP.x = 1.0;
                }
            }

            if (controller.buttons.mapped.actionDown.endedDown != 0) {
                controllingEntity.high.dZ = 3.0;
            }

            MovePlayer(gameState, controllingEntity, gameInput.dtForFrame, ddP);
        } else {
            if (controller.buttons.mapped.start.endedDown != 0) {
                const entityIndex = AddEntity(gameState);
                InitializaPlayer(gameState, entityIndex);
                gameState.playerIndexForController[controllerIndex] = entityIndex;
            }
        }
    }

    var entityOffsetForFrame = game.v2{};
    const cameraFollowingEntity = GetEntity(gameState, .High, gameState.cameraFollowingEntityIndex);
    if (cameraFollowingEntity.residence != .Nonexistent) {
        const oldCameraP = gameState.cameraP;

        gameState.cameraP.absTileZ = cameraFollowingEntity.dormant.p.absTileZ;

        if (cameraFollowingEntity.high.p.x > (9 * tileMap.tileSideInMeters)) {
            gameState.cameraP.absTileX += 17;
        }
        if (cameraFollowingEntity.high.p.x < -(9 * tileMap.tileSideInMeters)) {
            gameState.cameraP.absTileX -= 17;
        }
        if (cameraFollowingEntity.high.p.y > (5 * tileMap.tileSideInMeters)) {
            gameState.cameraP.absTileY += 9;
        }
        if (cameraFollowingEntity.high.p.y < -(5 * tileMap.tileSideInMeters)) {
            gameState.cameraP.absTileY -= 9;
        }

        const dCameraP = game.Substract(tileMap, &gameState.cameraP, &oldCameraP);
        entityOffsetForFrame = game.scale(dCameraP.dXY, -1);
    }

    DrawBitmap(buffer, &gameState.backdrop, 0, 0, 0, 0, 1);

    const screenCenterX = 0.5 * @intToFloat(f32, buffer.width);
    const screenCenterY = 0.5 * @intToFloat(f32, buffer.height);

    var relRow: i32 = -10;
    while (relRow < 10) : (relRow += 1) {
        var relCol: i32 = -20;
        while (relCol < 20) : (relCol += 1) {
            const col = @bitCast(u32, @intCast(i32, gameState.cameraP.absTileX) + relCol);
            const row = @bitCast(u32, @intCast(i32, gameState.cameraP.absTileY) + relRow);
            const tileID = game.GetTileValueFromAbs(tileMap, col, row, gameState.cameraP.absTileZ);

            if (tileID > 1) {
                var grey: f32 = 0.5;

                if (tileID == 2) {
                    grey = 1;
                }

                if (tileID > 2) {
                    grey = 0.25;
                }

                if ((col == gameState.cameraP.absTileX) and (row == gameState.cameraP.absTileY)) {
                    grey = 0.0;
                }

                const tileSide = .{ .x = @as(f32, 0.5) * tileSideInPixels, .y = @as(f32, 0.5) * tileSideInPixels };
                const cen = .{
                    .x = screenCenterX - metersToPixels * gameState.cameraP.offset_.x + @intToFloat(f32, relCol * tileSideInPixels),
                    .y = screenCenterY + metersToPixels * gameState.cameraP.offset_.y - @intToFloat(f32, relRow * tileSideInPixels),
                };

                // NOTE (Manav): min = cen - 0.9 * tileSide
                const min = game.sub(cen, game.scale(tileSide, 0.9));
                // NOTE (Manav): max = cen + 0.9 * tileSide
                const max = game.add(cen, game.scale(tileSide, 0.9));

                DrawRectangle(buffer, min, max, grey, grey, grey);
            }
        }
    }

    var entityIndex = @as(u32, 0);
    while (entityIndex < gameState.entityCount) : (entityIndex += 1) {
        if (gameState.entityResidence[entityIndex] == .High) {
            var highEntity = &gameState.highEntities[entityIndex];
            // var lowEntity = &gameState.lowEntities[entityIndex];
            var dormantEntity = &gameState.dormantEntities[entityIndex];

            _ = highEntity.p.add(entityOffsetForFrame);

            const dt = gameInput.dtForFrame;
            const ddZ = -9.8;
            highEntity.z += 0.5 * ddZ * game.square(dt) + highEntity.dZ * dt;
            highEntity.dZ += ddZ * dt;

            if (highEntity.z < 0) {
                highEntity.z = 0;
            }

            const cAlphaCal = 1 - 0.5 * highEntity.z;
            const cAlpha = if (cAlphaCal > 0) cAlphaCal else 0;

            const playerR = 1.0;
            const playerG = 1.0;
            const playerB = 0.0;

            const playerGroundPointX = screenCenterX + metersToPixels * highEntity.p.x;
            const playerGroundPointY = screenCenterY - metersToPixels * highEntity.p.y;
            const z = -metersToPixels * highEntity.z;
            const playerLeftTop = .{
                .x = playerGroundPointX - 0.5 * metersToPixels * dormantEntity.width,
                .y = playerGroundPointY - 0.5 * metersToPixels * dormantEntity.height,
            };
            const entityWidthHeight = .{ .x = dormantEntity.width, .y = dormantEntity.height };

            if (!NOT_IGNORE) {
                DrawRectangle(
                    buffer,
                    playerLeftTop,
                    game.add(playerLeftTop, game.scale(entityWidthHeight, metersToPixels)),
                    playerR,
                    playerG,
                    playerB,
                );
            }

            const heroBitmaps = gameState.heroBitmaps[highEntity.facingDirection];

            DrawBitmap(buffer, &gameState.shadow, playerGroundPointX, playerGroundPointY, heroBitmaps.alignX, heroBitmaps.alignY, cAlpha);
            DrawBitmap(buffer, &heroBitmaps.torso, playerGroundPointX, playerGroundPointY + z, heroBitmaps.alignX, heroBitmaps.alignY, 1.0);
            DrawBitmap(buffer, &heroBitmaps.cape, playerGroundPointX, playerGroundPointY + z, heroBitmaps.alignX, heroBitmaps.alignY, 1.0);
            DrawBitmap(buffer, &heroBitmaps.head, playerGroundPointX, playerGroundPointY + z, heroBitmaps.alignX, heroBitmaps.alignY, 1.0);
        }
    }
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

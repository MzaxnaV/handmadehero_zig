const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_internals.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_world.zig");
    usingnamespace @import("handmade_random.zig");
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
    var maxX = minX + bitmap.width;
    var maxY = minY + bitmap.height;

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

inline fn GetLowEntity(gameState: *game.state, index: u32) *game.low_entity {
    var result: *game.low_entity = undefined;

    if ((index > 0) and (index < gameState.lowEntityCount)) {
        result = &gameState.lowEntities[index];
    }

    return result;
}

inline fn MakeEntityHighFrequency(gameState: *game.state, lowIndex: u32) ?*game.high_entity {
    var entityHigh: ?*game.high_entity = null;

    const entityLow = &gameState.lowEntities[lowIndex];
    if (entityLow.highEntityIndex != 0) {
        entityHigh = &gameState.highEntities[entityLow.highEntityIndex];
    } else {
        if (gameState.highEntityCount < gameState.highEntities.len) {
            const highIndex = gameState.highEntityCount;
            gameState.highEntityCount += 1;
            entityHigh = &gameState.highEntities[highIndex];

            const diff = game.Substract(gameState.world, &entityLow.p, &gameState.cameraP);

            entityHigh.?.p = diff.dXY;
            entityHigh.?.dP = .{};
            entityHigh.?.chunkZ = @intCast(u32, entityLow.p.chunkZ);
            entityHigh.?.facingDirection = 0;
            entityHigh.?.lowEntityIndex = lowIndex;

            entityLow.highEntityIndex = highIndex;
        } else {
            unreachable;
        }
    }

    return entityHigh;
}

inline fn GetHighEntity(gameState: *game.state, lowIndex: u32) game.entity {
    var result = game.entity{
        .low = undefined,
    };

    if ((lowIndex > 0) and (lowIndex < gameState.lowEntityCount)) {
        result.lowIndex = lowIndex;
        result.low = &gameState.lowEntities[lowIndex];
        result.high = MakeEntityHighFrequency(gameState, lowIndex);
    }

    return result;
}

inline fn MakeEntityLowFrequency(gameState: *game.state, lowIndex: u32) void {
    const entityLow = &gameState.lowEntities[lowIndex];
    const highIndex = entityLow.highEntityIndex;

    if (highIndex != 0) {
        const lastHighIndex = gameState.highEntityCount - 1;
        if (highIndex != lastHighIndex) {
            const lastEntity = &gameState.highEntities[lastHighIndex];
            const delEntity = &gameState.highEntities[highIndex];

            delEntity.* = lastEntity.*;
            gameState.lowEntities[lastEntity.lowEntityIndex].highEntityIndex = highIndex;
        }
        gameState.highEntityCount -= 1;
        entityLow.highEntityIndex = 0;
    }
}

inline fn OffsetAndCheckFrequencyByArea(gameState: *game.state, offset: game.v2, highFrequencyBounds: game.rect2) void {
    var entityIndex = @as(u32, 1);
    while (entityIndex < gameState.highEntityCount) {
        var high = &gameState.highEntities[entityIndex];

        _ = high.p.Add(offset);
        if (game.IsInRectangle(highFrequencyBounds, high.p)) {
            entityIndex += 1;
        } else {
            MakeEntityLowFrequency(gameState, high.lowEntityIndex);
        }
    }
}

fn AddLowEntity(gameState: *game.state, entityType: game.entity_type) u32 {
    std.debug.assert(gameState.lowEntityCount < gameState.lowEntities.len);
    const entityIndex = gameState.lowEntityCount;
    gameState.lowEntityCount += 1;

    gameState.lowEntities[entityIndex] = .{
        .entityType = entityType,
    };

    return entityIndex;
}

fn AddWall(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) u32 {
    const entityIndex = AddLowEntity(gameState, .Wall);
    const entityLow = GetLowEntity(gameState, entityIndex);

    entityLow.p = game.ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ));
    entityLow.height = gameState.world.tileSideInMeters;
    entityLow.width = entityLow.height;
    entityLow.collides = true;

    return entityIndex;
}

fn AddPlayer(gameState: *game.state) u32 {
    const entityIndex = AddLowEntity(gameState, .Hero);
    const entityLow = GetLowEntity(gameState, entityIndex);

    entityLow.p = .{
        .chunkX = gameState.cameraP.chunkX,
        .chunkY = gameState.cameraP.chunkY,
        .offset_ = .{ .x = 0, .y = 0 },
    };
    entityLow.height = 0.5;
    entityLow.width = 1.0;
    entityLow.collides = true;

    if (gameState.cameraFollowingEntityIndex == 0) {
        gameState.cameraFollowingEntityIndex = entityIndex;
    }

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
    var ddP = accelaration;
    // const world = gameState.world;

    const ddPLength = game.LengthSq(ddP);
    if (ddPLength > 1.0) {
        _ = ddP.Scale(1.0 / game.SquareRoot(ddPLength));
    }

    const playerSpeed = @as(f32, 50.0);
    _ = ddP.Scale(playerSpeed);

    _ = ddP.Add(game.Scale(entity.high.?.dP, -8.0)); // NOTE (Manav): ddP += -8.0 * entity.high.dP;

    // const oldPlayerP = entity.high.p;
    // NOTE (Manav): playerDelta = (0.5 * ddP * square(dt)) + entity.dP * dt;
    var playerDelta = game.Add(game.Scale(ddP, 0.5 * game.Square(dt)), game.Scale(entity.high.?.dP, dt));
    _ = entity.high.?.dP.Add(game.Scale(ddP, dt)); // NOTE (Manav): entity.dP += ddP * dt;
    // const newPlayerP = game.Add(oldPlayerP, playerDelta);

    // !NOT_IGNORE
    // var minTileX = @minimum(oldPlayerP.absTileX, newPlayerP.absTileX);
    // var minTileY = @minimum(oldPlayerP.absTileY, newPlayerP.absTileY);
    // var maxTileX = @maximum(oldPlayerP.absTileX, newPlayerP.absTileX);
    // var maxTileY = @maximum(oldPlayerP.absTileY, newPlayerP.absTileY);

    // const entityTileWidth = game.CeilF32ToI32(entity.dormant.width / world.tileSideInMeters);
    // const entityTileHeight = game.CeilF32ToI32(entity.dormant.height / world.tileSideInMeters);

    // minTileX -= @intCast(u32, entityTileWidth);
    // minTileY -= @intCast(u32, entityTileHeight);
    // maxTileX += @intCast(u32, entityTileWidth);
    // maxTileY += @intCast(u32, entityTileHeight);

    // const absTileZ = entity.high.p.absTileZ;

    var iteration = @as(u32, 0);
    while (iteration < 4) : (iteration += 1) {
        var tMin = @as(f32, 1.0);
        var wallNormal = game.v2{};
        var hitHighEntityIndex = @as(u32, 0);

        // NOTE (Manav): desiredPosition = entity.high.p + playerDelta;
        const desiredPosition = game.Add(entity.high.?.p, playerDelta);

        var testHighEntityIndex = @as(u32, 1);
        while (testHighEntityIndex < gameState.highEntityCount) : (testHighEntityIndex += 1) {
            if (testHighEntityIndex != entity.low.highEntityIndex) {
                var testEntity = game.entity{
                    .low = undefined,
                    .high = undefined,
                };
                testEntity.high = &gameState.highEntities[testHighEntityIndex];
                testEntity.lowIndex = testEntity.high.?.lowEntityIndex;
                testEntity.low = &gameState.lowEntities[testEntity.lowIndex];
                if (testEntity.low.collides) {
                    const diameterW = testEntity.low.width + entity.low.width;
                    const diameterH = testEntity.low.height + entity.low.height;

                    const minCorner = game.v2{ .x = -0.5 * diameterW, .y = -0.5 * diameterH };
                    const maxCorner = game.v2{ .x = 0.5 * diameterW, .y = 0.5 * diameterH };

                    const rel = game.Sub(entity.high.?.p, testEntity.high.?.p); // NOTE: (Manav): entity.high.p - testEntity.high.p

                    if (TestWall(minCorner.x, rel.x, rel.y, playerDelta.x, playerDelta.y, &tMin, minCorner.y, maxCorner.y)) {
                        wallNormal = .{ .x = -1, .y = 0 };
                        hitHighEntityIndex = testHighEntityIndex;
                    }
                    if (TestWall(maxCorner.x, rel.x, rel.y, playerDelta.x, playerDelta.y, &tMin, minCorner.y, maxCorner.y)) {
                        wallNormal = .{ .x = 1, .y = 0 };
                        hitHighEntityIndex = testHighEntityIndex;
                    }
                    if (TestWall(minCorner.y, rel.y, rel.x, playerDelta.y, playerDelta.x, &tMin, minCorner.x, maxCorner.x)) {
                        wallNormal = .{ .x = 0, .y = -1 };
                        hitHighEntityIndex = testHighEntityIndex;
                    }
                    if (TestWall(maxCorner.y, rel.y, rel.x, playerDelta.y, playerDelta.x, &tMin, minCorner.x, maxCorner.x)) {
                        wallNormal = .{ .x = 0, .y = 1 };
                        hitHighEntityIndex = testHighEntityIndex;
                    }
                }
            }
        }

        // NOTE: (Manav): entity.high.p += tMin * playerDelta
        _ = entity.high.?.p.Add(game.Scale(playerDelta, tMin));
        if (hitHighEntityIndex != 0) {
            // NOTE (Manav): entity.high.dP -= (1 * Inner(entity.high.dP, wallNormal))*wallNormal;
            _ = entity.high.?.dP.Sub(game.Scale(wallNormal, 1 * game.Inner(entity.high.?.dP, wallNormal)));
            // NOTE (Manav): playerDelta = desiredPositon - entity.high.p;
            playerDelta = game.Sub(desiredPosition, entity.high.?.p);
            // NOTE (Manav): playerDelta -= (1 * Inner(playerDelta, wallNormal))*wallNormal;
            _ = playerDelta.Sub(game.Scale(wallNormal, 1 * game.Inner(playerDelta, wallNormal)));

            // const hitHigh = &gameState.highEntities[hitHighEntityIndex];
            // const hitLow = &gameState.lowEntities[hitHigh.lowEntityIndex];
            // entity.high.?.absTileZ = game.AddI32ToU32(entity.high.?.absTileZ, hitLow.dAbsTileZ);
        } else {
            break;
        }
    }

    if ((entity.high.?.dP.x == 0) and (entity.high.?.dP.y == 0)) {
        // NOTE(casey): Leave FacingDirection whatever it was
    } else if (game.AbsoluteValue(entity.high.?.dP.x) > game.AbsoluteValue(entity.high.?.dP.y)) {
        if (entity.high.?.dP.x > 0) {
            entity.high.?.facingDirection = 0;
        } else {
            entity.high.?.facingDirection = 2;
        }
    } else {
        if (entity.high.?.dP.y > 0) {
            entity.high.?.facingDirection = 1;
        } else {
            entity.high.?.facingDirection = 3;
        }
    }

    entity.low.p = game.MapIntoChunkSpace(gameState.world, gameState.cameraP, entity.high.?.p);
}

fn SetCamera(gameState: *game.state, newCameraP: game.world_position) void {
    const world = gameState.world;

    const dCameraP = game.Substract(world, &newCameraP, &gameState.cameraP);
    gameState.cameraP = newCameraP;

    const tileSpanX = 17 * 3;
    const tileSpanY = 9 * 3;

    const cameraBounds = game.rect2.InitCenterDim(.{}, game.Scale(
        .{
            .x = @intToFloat(f32, tileSpanX),
            .y = @intToFloat(f32, tileSpanY),
        },
        world.tileSideInMeters,
    ));

    const entityOffsetForFrame = game.Scale(dCameraP.dXY, -1);

    OffsetAndCheckFrequencyByArea(gameState, entityOffsetForFrame, cameraBounds);

    // !NOT_IGNORE
    // const minTileX = newCameraP.absTileX -% tileSpanX / 2;
    // const maxTileX = newCameraP.absTileX +% tileSpanX / 2;
    // const minTileY = newCameraP.absTileY -% tileSpanY / 2;
    // const maxTileY = newCameraP.absTileY +% tileSpanY / 2;

    // var entityIndex = @as(u32, 1);
    // while (entityIndex < gameState.lowEntityCount) : (entityIndex += 1) {
    //     const low = &gameState.lowEntities[entityIndex];
    //     if (low.highEntityIndex == 0) {
    //         if ((low.p.absTileZ == newCameraP.absTileZ) and
    //             (low.p.absTileX >= minTileX) and
    //             (low.p.absTileX <= maxTileX) and
    //             (low.p.absTileY >= minTileY) and
    //             (low.p.absTileY <= maxTileY))
    //         {
    //             _ = MakeEntityHighFrequency(gameState, entityIndex);
    //         }
    //     }
    // }
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
        _ = AddLowEntity(gameState, .Null);
        gameState.highEntityCount = 1;

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

        gameState.worldArena.Initialize(gameMemory.permanentStorageSize - @sizeOf(game.state), gameMemory.permanentStorage + @sizeOf(game.state));
        gameState.world = gameState.worldArena.PushStruct(game.world);

        const world = gameState.world;
        game.InitializeWorld(world, 1.4);

        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

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
            var randomChoice: u32 = 0;

            if (!NOT_IGNORE) {
                // if (doorUp or doorDown) {
                //     randomChoice = game.RandInt(u32) % 2;
                // } else {
                //     randomChoice = game.RandInt(u32) % 3;
                // }
            }
            randomChoice = game.RandInt(u32) % 2;

            var createdZDoor = false;
            if (randomChoice == 2) {
                createdZDoor = true;
                if (absTileZ == screenBaseZ) {
                    doorUp = true;
                } else {
                    doorDown = true;
                }
            } else if (randomChoice == 1) {
                doorRight = true;
            } else {
                doorTop = true;
            }

            var tileY = @as(u32, 0);
            while (tileY < tilesPerHeight) : (tileY += 1) {
                var tileX = @as(u32, 0);
                while (tileX < tilesPerWidth) : (tileX += 1) {
                    const absTileX = screenX * tilesPerWidth + tileX;
                    const absTileY = screenY * tilesPerHeight + tileY;

                    var tileValue = @as(u32, 1);
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

                    if (tileValue == 2) {
                        _ = AddWall(gameState, absTileX, absTileY, absTileZ);
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

            if (randomChoice == 2) {
                if (absTileZ == screenBaseZ) {
                    absTileZ = screenBaseZ + 1;
                } else {
                    absTileZ = screenBaseZ;
                }
            } else if (randomChoice == 1) {
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

        const newCameraP = game.ChunkPosFromTilePos(
            gameState.world,
            screenBaseX * tilesPerWidth + 17 / 2,
            screenBaseY * tilesPerHeight + 9 / 2,
            screenBaseZ,
        );
        SetCamera(gameState, newCameraP);

        gameMemory.isInitialized = true;
    }

    const world = gameState.world;

    const tileSideInPixels = 60;
    const metersToPixels = @intToFloat(f32, tileSideInPixels) / world.tileSideInMeters;

    // const lowerLeftX = -@intToFloat(f32, tileSideInPixels) / 2;
    // const lowerLeftY = @intToFloat(f32, buffer.height);

    for (gameInput.controllers) |controller, controllerIndex| {
        const lowIndex = gameState.playerIndexForController[controllerIndex];
        if (lowIndex == 0) {
            if (controller.buttons.mapped.start.endedDown != 0) {
                const entityIndex = AddPlayer(gameState);
                gameState.playerIndexForController[controllerIndex] = entityIndex;
            }
        } else {
            const controllingEntity = GetHighEntity(gameState, lowIndex);
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
                controllingEntity.high.?.dZ = 3.0;
            }

            MovePlayer(gameState, controllingEntity, gameInput.dtForFrame, ddP);
        }
    }

    var entityOffsetForFrame = game.v2{};
    const cameraFollowingEntity = GetHighEntity(gameState, gameState.cameraFollowingEntityIndex);
    if (cameraFollowingEntity.high) |_| {
        var newCameraP = gameState.cameraP;
        newCameraP.chunkZ = cameraFollowingEntity.low.p.chunkZ;

        if (!NOT_IGNORE) {
            if (cameraFollowingEntity.high.?.p.x > (9 * world.tileSideInMeters)) {
                newCameraP.absTileX += 17;
            }
            if (cameraFollowingEntity.high.?.p.x < -(9 * world.tileSideInMeters)) {
                newCameraP.absTileX -%= 17;
            }
            if (cameraFollowingEntity.high.?.p.y > (5 * world.tileSideInMeters)) {
                newCameraP.absTileY += 9;
            }
            if (cameraFollowingEntity.high.?.p.y < -(5 * world.tileSideInMeters)) {
                newCameraP.absTileY -%= 9;
            }
        } else {
            newCameraP = cameraFollowingEntity.low.p;
        }

        SetCamera(gameState, newCameraP);
    }

    DrawBitmap(buffer, &gameState.backdrop, 0, 0, 0, 0, 1);

    const screenCenterX = 0.5 * @intToFloat(f32, buffer.width);
    const screenCenterY = 0.5 * @intToFloat(f32, buffer.height);

    if (!NOT_IGNORE) {
        var relRow: i32 = -10;
        while (relRow < 10) : (relRow += 1) {
            var relCol: i32 = -20;
            while (relCol < 20) : (relCol += 1) {
                const col = @bitCast(u32, @intCast(i32, gameState.cameraP.absTileX) + relCol);
                const row = @bitCast(u32, @intCast(i32, gameState.cameraP.absTileY) + relRow);
                const tileID = game.GetTileValueFromAbs(world, col, row, gameState.cameraP.absTileZ);

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
                    const min = game.Sub(cen, game.Scale(tileSide, 0.9));
                    // NOTE (Manav): max = cen + 0.9 * tileSide
                    const max = game.Add(cen, game.Scale(tileSide, 0.9));

                    DrawRectangle(buffer, min, max, grey, grey, grey);
                }
            }
        }
    }

    var highEntityIndex = @as(u32, 1);
    while (highEntityIndex < gameState.highEntityCount) : (highEntityIndex += 1) {
        const highEntity = &gameState.highEntities[highEntityIndex];
        const lowEntity = &gameState.lowEntities[highEntity.lowEntityIndex];

        _ = highEntity.p.Add(entityOffsetForFrame);

        const dt = gameInput.dtForFrame;
        const ddZ = -9.8;
        highEntity.z += 0.5 * ddZ * game.Square(dt) + highEntity.dZ * dt;
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
            .x = playerGroundPointX - 0.5 * metersToPixels * lowEntity.width,
            .y = playerGroundPointY - 0.5 * metersToPixels * lowEntity.height,
        };
        const entityWidthHeight = .{ .x = lowEntity.width, .y = lowEntity.height };

        if (lowEntity.entityType == .Hero) {
            const heroBitmaps = gameState.heroBitmaps[highEntity.facingDirection];

            DrawBitmap(buffer, &gameState.shadow, playerGroundPointX, playerGroundPointY, heroBitmaps.alignX, heroBitmaps.alignY, cAlpha);
            DrawBitmap(buffer, &heroBitmaps.torso, playerGroundPointX, playerGroundPointY + z, heroBitmaps.alignX, heroBitmaps.alignY, 1.0);
            DrawBitmap(buffer, &heroBitmaps.cape, playerGroundPointX, playerGroundPointY + z, heroBitmaps.alignX, heroBitmaps.alignY, 1.0);
            DrawBitmap(buffer, &heroBitmaps.head, playerGroundPointX, playerGroundPointY + z, heroBitmaps.alignX, heroBitmaps.alignY, 1.0);
        } else {
            DrawRectangle(
                buffer,
                playerLeftTop,
                game.Add(playerLeftTop, game.Scale(entityWidthHeight, metersToPixels)),
                playerR,
                playerG,
                playerB,
            );
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

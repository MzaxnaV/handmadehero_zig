const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_internals.zig");
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

fn DrawRectangle(buffer: *platform.offscreen_buffer, fMinX: f32, fMinY: f32, fMaxX: f32, fMaxY: f32, r: f32, g: f32, b: f32) void {
    var minX = game.RoundF32ToInt(i32, fMinX);
    var minY = game.RoundF32ToInt(i32, fMinY);
    var maxX = game.RoundF32ToInt(i32, fMaxX);
    var maxY = game.RoundF32ToInt(i32, fMaxY);

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

fn DrawBitmap(buffer: *platform.offscreen_buffer, bitmap: *const game.loaded_bitmap, realX: f32, realY: f32, alignX: i32, alignY: i32) void {
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

            const a = @intToFloat(f32, ((sourceRow[index] >> 24) & 0xff)) / 255.0;
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

        const redShift = @truncate(u5, game.FindLeastSignificantSetBit(redMask));
        const greenShift = @truncate(u5, game.FindLeastSignificantSetBit(greenMask));
        const blueShift = @truncate(u5, game.FindLeastSignificantSetBit(blueMask));
        const alphaShift = @truncate(u5, game.FindLeastSignificantSetBit(alphaMask));

        const sourceDest = result.pixels.access;

        var index = @as(u32, 0);
        while (index < @intCast(u32, header.height * header.width)) : (index += 1) {
            const c = sourceDest[index];
            sourceDest[index] = ((c >> alphaShift) & 0xff) << 24 | ((c >> redShift) & 0xff) << 16 | ((c >> greenShift) & 0xff) << 8 | ((c >> blueShift) & 0xff) << 0;
        }
    }

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(thread: *platform.thread_context, gameMemory: *platform.memory, gameInput: *platform.input, buffer: *platform.offscreen_buffer) void {
    comptime {
        // This is hacky atm. Need to check as we're using win32.LoadLibrary()
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

    const playerHeight = 1.4;
    const playerWidth = 0.75 * playerHeight;

    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        gameState.backdrop = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_background.bmp");

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

        gameState.cameraP.absTileX = @divTrunc(17, 2);
        gameState.cameraP.absTileY = @divTrunc(9, 2);

        gameState.playerP.absTileX = 1;
        gameState.playerP.absTileY = 3;
        gameState.playerP.offsetX = 5.0;
        gameState.playerP.offsetY = 5.0;

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

    for (gameInput.controllers) |controller| {
        if (controller.isAnalog) {
            // Use analog movement tuning
        } else {
            // Use digital movement tuning

            var dPlayerX: f32 = 0; // pixels/second
            var dPlayerY: f32 = 0; // pixels/second

            if (controller.buttons.mapped.moveUp.endedDown != 0) {
                gameState.heroFacingDirection = 1;
                dPlayerY = 1.0;
            }
            if (controller.buttons.mapped.moveDown.endedDown != 0) {
                gameState.heroFacingDirection = 3;
                dPlayerY = -1.0;
            }
            if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                gameState.heroFacingDirection = 2;
                dPlayerX = -1.0;
            }
            if (controller.buttons.mapped.moveRight.endedDown != 0) {
                gameState.heroFacingDirection = 0;
                dPlayerX = 1.0;
            }

            var playerSpeed: f32 = 2.0;
            if (controller.buttons.mapped.actionUp.endedDown != 0) {
                playerSpeed = 10.0;
            }

            dPlayerX *= playerSpeed;
            dPlayerY *= playerSpeed;

            var newPlayerP = gameState.playerP;
            newPlayerP.offsetX += gameInput.dtForFrame * dPlayerX;
            newPlayerP.offsetY += gameInput.dtForFrame * dPlayerY;
            newPlayerP = game.RecanonicalizePosition(tileMap, newPlayerP);

            var playerLeft = newPlayerP;
            playerLeft.offsetX -= 0.5 * playerWidth;
            playerLeft = game.RecanonicalizePosition(tileMap, playerLeft);

            var playerRight = newPlayerP;
            playerRight.offsetX += 0.5 * playerWidth;
            playerRight = game.RecanonicalizePosition(tileMap, playerRight);

            if (game.IsTileMapPointEmpty(tileMap, newPlayerP) and
                game.IsTileMapPointEmpty(tileMap, playerLeft) and
                game.IsTileMapPointEmpty(tileMap, playerRight))
            {
                if (game.AreOnSameTile(&gameState.playerP, &newPlayerP)) {
                    const newTileValue = game.GetTileValueFromPos(tileMap, newPlayerP);

                    if (newTileValue == 3) {
                        newPlayerP.absTileZ +%= 1;
                    } else if (newTileValue == 4) {
                        newPlayerP.absTileZ -%= 1;
                    }
                }
                gameState.playerP = newPlayerP;
            }

            gameState.cameraP.absTileZ = gameState.playerP.absTileZ;

            const diff = game.Substract(tileMap, &gameState.playerP, &gameState.cameraP);
            if (diff.dX > (9 * tileMap.tileSideInMeters)) {
                gameState.cameraP.absTileX += 17;
            }
            if (diff.dX < -(9 * tileMap.tileSideInMeters)) {
                gameState.cameraP.absTileX -= 17;
            }
            if (diff.dY > (5 * tileMap.tileSideInMeters)) {
                gameState.cameraP.absTileY += 9;
            }
            if (diff.dY < -(5 * tileMap.tileSideInMeters)) {
                gameState.cameraP.absTileY -= 9;
            }
        }
    }

    DrawBitmap(buffer, &gameState.backdrop, 0, 0, 0, 0);

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

                const cenX = screenCenterX - metersToPixels * gameState.cameraP.offsetX + @intToFloat(f32, relCol * tileSideInPixels);
                const cenY = screenCenterY + metersToPixels * gameState.cameraP.offsetY - @intToFloat(f32, relRow * tileSideInPixels);
                const minX = cenX - 0.5 * @intToFloat(f32, tileSideInPixels);
                const minY = cenY - 0.5 * @intToFloat(f32, tileSideInPixels);
                const maxX = cenX + 0.5 * @intToFloat(f32, tileSideInPixels);
                const maxY = cenY + 0.5 * @intToFloat(f32, tileSideInPixels);

                DrawRectangle(buffer, minX, minY, maxX, maxY, grey, grey, grey);
            }
        }
    }

    const diff = game.Substract(tileMap, &gameState.playerP, &gameState.cameraP);

    const playerR = 1.0;
    const playerG = 1.0;
    const playerB = 0.0;

    const playerGroundPointX = screenCenterX + metersToPixels * diff.dX;
    const playerGroundPointY = screenCenterY - metersToPixels * diff.dY;
    const playerLeft = playerGroundPointX - 0.5 * metersToPixels * playerWidth;
    const playerTop = playerGroundPointY - metersToPixels * playerHeight;

    DrawRectangle(
        buffer,
        playerLeft,
        playerTop,
        playerLeft + metersToPixels * playerWidth,
        playerTop + metersToPixels * playerHeight,
        playerR,
        playerG,
        playerB,
    );

    const heroBitmaps = gameState.heroBitmaps[gameState.heroFacingDirection];

    DrawBitmap(buffer, &heroBitmaps.torso, playerGroundPointX, playerGroundPointY, heroBitmaps.alignX, heroBitmaps.alignY);
    DrawBitmap(buffer, &heroBitmaps.cape, playerGroundPointX, playerGroundPointY, heroBitmaps.alignX, heroBitmaps.alignY);
    DrawBitmap(buffer, &heroBitmaps.head, playerGroundPointX, playerGroundPointY, heroBitmaps.alignX, heroBitmaps.alignY);
}

// NOTEAt the moment, this has to be a very fast function, it cannot be
// more than a millisecond or so.
// TODO Reduce the pressure on this function's performance by measuring it
// or asking about it, etc.
pub export fn GetSoundSamples(_: *platform.thread_context, gameMemory: *platform.memory, soundBuffer: *platform.sound_output_buffer) void {
    comptime {
        // This is hacky atm. Need to check as we're using win32.LoadLibrary()
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

// fn RenderWeirdGradient(buffer: *platform.offscreen_buffer, xOffset: i32, yOffset: i32) void {
//     var row = @ptrCast([*]u8, buffer.memory);

//     var y: u32 = 0;
//     while (y < buffer.height) : (y += 1) {
//         var x: u32 = 0;
//         var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
//         while (x < buffer.width) : (x += 1) {
//             // Pixel in memory: BB GG RR xx
//             // Little endian arch: 0x xxRRGGBB

//             var blue: u8 = @truncate(u8, x +% @bitCast(u32, xOffset));
//             var green: u8 = @truncate(u8, y +% @bitCast(u32, yOffset));

//             pixel.* = (@as(u32, green) << 16) | @as(u32, blue);
//             pixel += 1;
//         }
//         row += buffer.pitch;
//     }
// }

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

    var y = @bitCast(u32, minY);
    while (y < maxY) : (y += 1) {
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        var x = @bitCast(u32, minX);
        while (x < maxX) : (x += 1) {
            pixel.* = colour;
            pixel += 1;
        }
        row += buffer.pitch;
    }
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(_: *platform.thread_context, gameMemory: *platform.memory, gameInput: *platform.input, buffer: *platform.offscreen_buffer) void {
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

    const playerHeight: f32 = 1.4;
    const playerWidth = 0.75 * playerHeight;

    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        gameState.playerP.absTileX = 1;
        gameState.playerP.absTileY = 3;
        gameState.playerP.tileRelX = 5.0;
        gameState.playerP.tileRelY = 5.0;

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

            if (randomChoice == 2) {
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

                    if ((tileX == (tilesPerWidth - 1)) and (!doorRight or (tileX != (tilesPerWidth / 2)))) {
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

            if (doorUp) {
                doorDown = true;
                doorUp = false;
            } else if (doorDown) {
                doorDown = false;
                doorUp = true;
            } else {
                doorDown = false;
                doorUp = false;
            }

            doorRight = false;
            doorLeft = false;

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
                dPlayerY = 1.0;
            }
            if (controller.buttons.mapped.moveDown.endedDown != 0) {
                dPlayerY = -1.0;
            }
            if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                dPlayerX = -1.0;
            }
            if (controller.buttons.mapped.moveRight.endedDown != 0) {
                dPlayerX = 1.0;
            }

            var playerSpeed: f32 = 2.0;
            if (controller.buttons.mapped.actionUp.endedDown != 0) {
                playerSpeed = 10.0;
            }

            dPlayerX *= playerSpeed;
            dPlayerY *= playerSpeed;

            var newPlayerP = gameState.playerP;
            newPlayerP.tileRelX += gameInput.dtForFrame * dPlayerX;
            newPlayerP.tileRelY += gameInput.dtForFrame * dPlayerY;
            newPlayerP = game.RecanonicalizePosition(tileMap, newPlayerP);

            var playerLeft = newPlayerP;
            playerLeft.tileRelX -= 0.5 * playerWidth;
            playerLeft = game.RecanonicalizePosition(tileMap, playerLeft);

            var playerRight = newPlayerP;
            playerRight.tileRelX += 0.5 * playerWidth;
            playerRight = game.RecanonicalizePosition(tileMap, playerRight);

            if (game.IsTileMapPointEmpty(tileMap, newPlayerP) and
                game.IsTileMapPointEmpty(tileMap, playerLeft) and
                game.IsTileMapPointEmpty(tileMap, playerRight))
            {
                gameState.playerP = newPlayerP;
            }
        }
    }

    DrawRectangle(buffer, 0, 0, @intToFloat(f32, buffer.width), @intToFloat(f32, buffer.height), 1, 0, 0);

    const screenCenterX = 0.5 * @intToFloat(f32, buffer.width);
    const screenCenterY = 0.5 * @intToFloat(f32, buffer.height);

    var relRow: i32 = -10;
    while (relRow < 10) : (relRow += 1) {
        var relCol: i32 = -20;
        while (relCol < 20) : (relCol += 1) {
            const col = @bitCast(u32, @intCast(i32, gameState.playerP.absTileX) + relCol);
            const row = @bitCast(u32, @intCast(i32, gameState.playerP.absTileY) + relRow);
            const tileID = game.GetTileValueFromAbs(tileMap, col, row, gameState.playerP.absTileZ);

            if (tileID > 0) {
                var grey: f32 = 0.5;

                if (tileID == 2) {
                    grey = 1;
                }

                if (tileID > 2) {
                    grey = 0.25;
                }

                if ((col == gameState.playerP.absTileX) and (row == gameState.playerP.absTileY)) {
                    grey = 0.0;
                }

                const cenX = screenCenterX - metersToPixels * gameState.playerP.tileRelX + @intToFloat(f32, relCol * tileSideInPixels);
                const cenY = screenCenterY + metersToPixels * gameState.playerP.tileRelY - @intToFloat(f32, relRow * tileSideInPixels);
                const minX = cenX - 0.5 * @intToFloat(f32, tileSideInPixels);
                const minY = cenY - 0.5 * @intToFloat(f32, tileSideInPixels);
                const maxX = cenX + 0.5 * @intToFloat(f32, tileSideInPixels);
                const maxY = cenY + 0.5 * @intToFloat(f32, tileSideInPixels);

                DrawRectangle(buffer, minX, minY, maxX, maxY, grey, grey, grey);
            }
        }
    }

    const playerR = 1.0;
    const playerG = 1.0;
    const playerB = 0.0;

    const playerLeft = screenCenterX - 0.5 * metersToPixels * playerWidth;
    const playerTop = screenCenterY - metersToPixels * playerHeight;

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

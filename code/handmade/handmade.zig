const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_tile.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;

// local functions ------------------------------------------------------------------------------------------------------------------------

fn SetTileValue(_: *game.memory_arena, tileMap: *game.tile_map, absTileX: u32, absTileY: u32, tileValue: u32) void
{
    const chunkPos = game.GetChunkPositionFor(tileMap, absTileX, absTileY);
    const tileChunk = game.GetTileChunk(tileMap, @intCast(i32, chunkPos.tileChunkX), @intCast(i32, chunkPos.tileChunkY));

    std.debug.assert(tileChunk != null);

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

fn InitializeArena(arena: *game.memory_arena, size: platform.memory_index, base: [*]u8) void {
    arena.size = size;
    arena.base = base;
    arena.used = 0;
}

fn PushSize(arena: *game.memory_arena, size: platform.memory_index) [*]u8 {
    std.debug.assert((arena.used + size) <= arena.size);
    const result = arena.base + arena.used;
    arena.used += size;

    return result;
}

inline fn PushStruct(comptime T: type, arena: *game.memory_arena) *T {
    return @ptrCast(*T, @alignCast(@alignOf(T), PushSize(arena, @sizeOf(T))));
}

inline fn PushArray(comptime T: type, comptime count: platform.memory_index, arena: *game.memory_arena, ) *[count]T {
    return @ptrCast(*[count]T, @alignCast(@alignOf(T), PushSize(arena, count * @sizeOf(T))));
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
        gameState.playerP.absTileX = 1  ;
        gameState.playerP.absTileY = 3;
        gameState.playerP.tileRelX = 5.0;
        gameState.playerP.tileRelY = 5.0;

        InitializeArena(&gameState.worldArena, gameMemory.permanentStorageSize - @sizeOf(game.state), gameMemory.permanentStorage + @sizeOf(game.state));

        gameState.world = PushStruct(game.world, &gameState.worldArena);

        const world = gameState.world;
        world.tileMap = PushStruct(game.tile_map, &gameState.worldArena);

        const tileChunkCountX = 128;
        const tileChunkCountY = 128;

        const chunkShift = 4;
        const chunkDim = @as(u32, 1) <<  @intCast(u5, chunkShift);

        var tileMap = world.tileMap;
        tileMap.chunkShift = chunkShift;
        tileMap.chunkMask = (@as(u32, 1) << @intCast(u5, chunkShift)) - 1;
        tileMap.chunkDim = chunkDim;

        tileMap.tileChunkCountX = tileChunkCountX;
        tileMap.tileChunkCountY = tileChunkCountY;
        tileMap.tileChunks = PushArray(game.tile_chunk, tileChunkCountX * tileChunkCountY, &gameState.worldArena);

        var y: u32 = 0;
        while(y < tileMap.tileChunkCountY) : (y += 1) {
            var x: u32 = 0;
            while(x < tileMap.tileChunkCountX) : (x += 1) {
                tileMap.tileChunks[y * @intCast(u32, tileMap.tileChunkCountX) + x].tiles = PushArray(u32, chunkDim * chunkDim, &gameState.worldArena);
            }
        }

        tileMap.tileSideInMeters = 1.4;
        tileMap.tileSideInPixels = 60;
        tileMap.metersToPixels = @intToFloat(f32, tileMap.tileSideInPixels) / tileMap.tileSideInMeters;

        // const lowerLeftX = - @intToFloat(f32, tileMap.tileSideInPixels) / 2;
        // const lowerLeftY = @intToFloat(f32, buffer.height);

        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

        var screenY:u32 = 0;
        while(screenY < 32) : (screenY += 1) {
            var screenX:u32 = 0;
            while(screenX < 32) : (screenX += 1) {
                var tileY:u32 = 0;
                while(tileY < tilesPerHeight) : (tileY += 1) {
                    var tileX:u32 = 0;
                    while(tileX < tilesPerWidth) : (tileX += 1) {
                        const absTileX = screenX * tilesPerWidth + tileX;
                        const absTileY = screenY * tilesPerHeight + tileY;

                        SetTileValue(&gameState.worldArena, world.tileMap, absTileX, absTileY, if ((tileX == tileY) and (tileY % 2 == 0)) 1 else 0);
                    }
                }
            }
        }

        gameMemory.isInitialized = true;
    }

    const world = gameState.world;
    const tileMap = world.tileMap;

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

            var playerSpeed:f32 = 2.0; 
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
            const tileID = game.GetTileValueFromAbs(tileMap, col, row);
            var grey: f32 = 0.5;
            switch (tileID) {
                1 => grey = 1,
                else => {},
            }

            if ((col == gameState.playerP.absTileX) and (row == gameState.playerP.absTileY)) {
                grey = 0.0;
            }

            const cenX = screenCenterX - tileMap.metersToPixels * gameState.playerP.tileRelX + @intToFloat(f32, relCol * tileMap.tileSideInPixels);
            const cenY = screenCenterY + tileMap.metersToPixels * gameState.playerP.tileRelY - @intToFloat(f32, relRow * tileMap.tileSideInPixels);
            const minX = cenX - 0.5 * @intToFloat(f32, tileMap.tileSideInPixels);
            const minY = cenY - 0.5 * @intToFloat(f32, tileMap.tileSideInPixels);
            const maxX = cenX + 0.5 * @intToFloat(f32, tileMap.tileSideInPixels);
            const maxY = cenY + 0.5 * @intToFloat(f32, tileMap.tileSideInPixels);

            DrawRectangle(buffer, minX, minY, maxX, maxY, grey, grey, grey);
        }
    }

    const playerR = 1.0;
    const playerG = 1.0;
    const playerB = 0.0;

    const playerLeft = screenCenterX - 0.5 * tileMap.metersToPixels * playerWidth;
    const playerTop = screenCenterY - tileMap.metersToPixels * playerHeight;

    DrawRectangle(
        buffer,
        playerLeft,
        playerTop,
        playerLeft + tileMap.metersToPixels * playerWidth,
        playerTop + tileMap.metersToPixels * playerHeight,
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

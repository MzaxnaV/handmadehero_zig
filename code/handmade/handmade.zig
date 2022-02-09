const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_data.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;

// inline functions -----------------------------------------------------------------------------------------------------------------------

inline fn GetTileChunk(world: *const game.world, tileChunkX: i32, tileChunkY: i32) ?*game.tile_chunk {
    var tileChunk: ?*game.tile_chunk = null;

    if ((tileChunkX >= 0 and tileChunkX < world.tileChunkCountX) and (tileChunkY >= 0 and tileChunkY < world.tileChunkCountY)) {
        tileChunk = &world.tileChunks[@intCast(u32, tileChunkY * world.tileChunkCountX) + @intCast(u32, tileChunkX)];
    }

    return tileChunk;
}

inline fn GetTileValueUnchecked(world: *const game.world, tileChunk: *const game.tile_chunk, tileX: u32, tileY: u32) u32 {
    std.debug.assert(tileX < world.chunkDim);
    std.debug.assert(tileY < world.chunkDim);

    const tileMapValue = tileChunk.tiles[tileY * world.chunkDim + tileX];
    return tileMapValue;
}

inline fn GetTileValue(world: *const game.world, tileChunk: ?*const game.tile_chunk, testTileX: u32, testTileY: u32) u32 {
    const tileChunkValue = if (tileChunk) |tc| GetTileValueUnchecked(world, tc, testTileX, testTileY) else 0;

    return tileChunkValue;
}

inline fn RecanonicalizeCoord(world: *const game.world, tile: *u32, tileRel: *f32) void {
    const offSet = game.FloorF32ToI32(tileRel.* / world.tileSideInMeters);
    tile.* +%= @bitCast(u32, offSet);
    tileRel.* -= @intToFloat(f32, offSet) * world.tileSideInMeters;

    std.debug.assert(tileRel.* >= 0);
    std.debug.assert(tileRel.* <= world.tileSideInMeters);
}

inline fn RecanonicalizePosition(world: *const game.world, pos: game.world_position) game.world_position {
    var result = pos;

    RecanonicalizeCoord(world, &result.absTileX, &result.tileRelX);
    RecanonicalizeCoord(world, &result.absTileY, &result.tileRelY);

    return result;
}

inline fn GetChunkPositionFor(world: *const game.world, absTileX: u32, absTileY: u32) game.tile_chunk_position {
    const result = game.tile_chunk_position{
        .tileChunkX = absTileX >> @intCast(u5, world.chunkShift),
        .tileChunkY = absTileY >> @intCast(u5, world.chunkShift),
        .relTileX = absTileX & world.chunkMask,
        .relTileY = absTileY & world.chunkMask,
    };

    return result;
}

// local functions ------------------------------------------------------------------------------------------------------------------------

fn GetTileValueFromAbs(world: *const game.world, absTileX: u32, absTileY: u32) u32 {
    const chunkPos = GetChunkPositionFor(world, absTileX, absTileY);
    const tileMap = GetTileChunk(world, @intCast(i32, chunkPos.tileChunkX), @intCast(i32, chunkPos.tileChunkY));
    const tileChunkValue = GetTileValue(world, tileMap, chunkPos.relTileX, chunkPos.relTileY);

    return tileChunkValue;
}

fn IsWorldPointEmpty(world: *const game.world, canPos: game.world_position) bool {
    const tileChunkValue = GetTileValueFromAbs(world, canPos.absTileX, canPos.absTileY);
    const empty = (tileChunkValue == 0);

    return empty;
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

    _ = thread;

    std.debug.assert(@sizeOf(game.state) <= gameMemory.permanentStorageSize);

    const TILE_MAP_COUNT_X = 256;
    const TILE_MAP_COUNT_Y = 256;

    const tempTiles = [_][TILE_MAP_COUNT_X]u32{
        [_]u32{1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 0, 0,  0, 1, 0, 0,  0, 0, 0, 0,  0, 1, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 1, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 1, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 0, 0,  0, 1, 0, 0,  1, 0, 0, 0,  0, 1, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 1, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 1, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 1, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 1, 1,  1, 1, 1, 1,  0, 1, 1, 1,  1, 1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  0, 1, 1, 1,  1, 1, 1, 1, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 1, 1,  1, 1, 1, 1,  0, 1, 1, 1,  1, 1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  0, 1, 1, 1,  1, 1, 1, 1, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
        [_]u32{1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1, 1} ++ [1]u32{ 0 } ** (TILE_MAP_COUNT_X - 34),
    } ++ [1][TILE_MAP_COUNT_X]u32 {[1]u32{ 0 } ** TILE_MAP_COUNT_X} ** (TILE_MAP_COUNT_Y - 18);

    std.debug.assert(tempTiles[0].len == TILE_MAP_COUNT_X and tempTiles.len == TILE_MAP_COUNT_Y);

    var tileChunk = game.tile_chunk{};
    tileChunk.tiles = @ptrCast([*]const u32, &tempTiles);

    var world = game.world{
        .chunkShift = 8,
        .chunkDim = 256,

        .tileSideInMeters = 1.4,
        .tileSideInPixels = 60,

        .tileChunkCountX = 1,
        .tileChunkCountY = 1,

        .tileChunks = @ptrCast([*]game.tile_chunk, &tileChunk),
    };

    world.chunkMask = (@as(u32, 1) << @intCast(u5, world.chunkShift)) - 1;
    world.metersToPixels = @intToFloat(f32, world.tileSideInPixels) / world.tileSideInMeters;

    const playerHeight: f32 = 1.4;
    const playerWidth = 0.75 * playerHeight;

    // const lowerLeftX = -@intToFloat(f32, world.tileSideInMeters) / 2;
    // const lowerLeftY = @intToFloat(f32, buffer.height);

    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        gameState.playerP.absTileX = 3;
        gameState.playerP.absTileY = 3;
        gameState.playerP.tileRelX = 5.0;
        gameState.playerP.tileRelY = 5.0;

        gameMemory.isInitialized = true;
    }

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

            dPlayerX *= 2;
            dPlayerY *= 2;

            var newPlayerP = gameState.playerP;
            newPlayerP.tileRelX += gameInput.dtForFrame * dPlayerX;
            newPlayerP.tileRelY += gameInput.dtForFrame * dPlayerY;
            newPlayerP = RecanonicalizePosition(&world, newPlayerP);

            var playerLeft = newPlayerP;
            playerLeft.tileRelX -= 0.5 * playerWidth;
            playerLeft = RecanonicalizePosition(&world, playerLeft);

            var playerRight = newPlayerP;
            playerRight.tileRelX += 0.5 * playerWidth;
            playerRight = RecanonicalizePosition(&world, playerRight);

            if (IsWorldPointEmpty(&world, newPlayerP) and
                IsWorldPointEmpty(&world, playerLeft) and
                IsWorldPointEmpty(&world, playerRight))
            {
                gameState.playerP = newPlayerP;
            }
        }
    }

    DrawRectangle(buffer, 0, 0, @intToFloat(f32, buffer.width), @intToFloat(f32, buffer.height), 1, 0, 0);

    const centerX = 0.5 * @intToFloat(f32, buffer.width);
    const centerY = 0.5 * @intToFloat(f32, buffer.height);

    var relRow: i32 = -10;
    while (relRow < 10) : (relRow += 1) {
        var relCol: i32 = -20;
        while (relCol < 20) : (relCol += 1) {
            const col = @bitCast(u32, @intCast(i32, gameState.playerP.absTileX) + relCol);
            const row = @bitCast(u32, @intCast(i32, gameState.playerP.absTileY) + relRow);
            const tileID = GetTileValueFromAbs(&world, col, row);
            var grey: f32 = 0.5;
            switch (tileID) {
                1 => grey = 1,
                else => {},
            }

            if ((col == gameState.playerP.absTileX) and (row == gameState.playerP.absTileY)) {
                grey = 0.0;
            }

            const minX = centerX + @intToFloat(f32, relCol * world.tileSideInPixels);
            const minY = centerY - @intToFloat(f32, relRow * world.tileSideInPixels);
            const maxX = minX + @intToFloat(f32, world.tileSideInPixels);
            const maxY = minY - @intToFloat(f32, world.tileSideInPixels);

            DrawRectangle(buffer, minX, maxY, maxX, minY, grey, grey, grey);
        }
    }

    const playerR = 1.0;
    const playerG = 1.0;
    const playerB = 0.0;

    const playerLeft = centerX + world.metersToPixels * gameState.playerP.tileRelX - 0.5 * world.metersToPixels * playerWidth;
    const playerTop = centerY - world.metersToPixels * gameState.playerP.tileRelY - world.metersToPixels * playerHeight;

    DrawRectangle(
        buffer,
        playerLeft,
        playerTop,
        playerLeft + world.metersToPixels * playerWidth,
        playerTop + world.metersToPixels * playerHeight,
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

const std = @import("std");
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_data.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

// inline functions -----------------------------------------------------------------------------------------------------------------------

inline fn GetTileMap(world: *const game.world, tileMapX: i32, tileMapY: i32) ?*game.tile_map {
    var tileMap: ?*game.tile_map = null;
    if ((tileMapX >= 0 and tileMapX < world.tileMapCountX) and (tileMapY >= 0 and tileMapY < world.tileMapCountY)) {
        tileMap = &world.tileMaps[@intCast(u32, tileMapY) * world.tileMapCountX + @intCast(u32, tileMapX)];
    }

    return tileMap;
}

inline fn GetTileValueUnchecked(world: *const game.world, tileMap: *game.tile_map, tileX: i32, tileY: i32) u32 {
    std.debug.assert((tileX >= 0 and tileX < world.countX) and (tileY >= 0 and tileY < world.countY));

    const tileMapValue = tileMap.tiles[@intCast(u32, tileY * world.countX) + @intCast(u32, tileX)];
    return tileMapValue;
}

inline fn IsTileMapPointEmpty(world: *const game.world, tileMap: ?*game.tile_map, testTileX: i32, testTileY: i32) bool {
    var empty = false;

    if (tileMap) |map| {
        if ((testTileX >= 0 and testTileX < world.countX) and (testTileY >= 0 and testTileY < world.countY)) {
            const tileMapValue = GetTileValueUnchecked(world, map, testTileX, testTileY);
            empty = (tileMapValue == 0);
        }
    }

    return empty;
}

inline fn GetCanonicalPosition(world: *const game.world, pos: game.raw_position) game.canonical_position {
    var result = game.canonical_position{};

    result.tileMapX = pos.tileMapX;
    result.tileMapY = pos.tileMapY;

    const x = pos.x - world.upperLeftX;
    const y = pos.y - world.upperLeftY;

    result.tileX = game.FloorF32ToI32(x / @intToFloat(f32, world.tileSideInPixels));
    result.tileY = game.FloorF32ToI32(y / @intToFloat(f32, world.tileSideInPixels));

    result.tileRelX = x - @intToFloat(f32, result.tileX * world.tileSideInPixels);
    result.tileRelY = y - @intToFloat(f32, result.tileY * world.tileSideInPixels);

    std.debug.assert(result.tileRelX >= 0);
    std.debug.assert(result.tileRelY >= 0);
    std.debug.assert(result.tileRelX < @intToFloat(f32, world.tileSideInPixels));
    std.debug.assert(result.tileRelY < @intToFloat(f32, world.tileSideInPixels));

    if (result.tileX < 0) {
        result.tileX += world.countX;
        result.tileMapX -= 1;
    }

    if (result.tileY < 0) {
        result.tileY += world.countY;
        result.tileMapY -= 1;
    }

    if (result.tileX >= world.countX) {
        result.tileX -= world.countX;
        result.tileMapX += 1;
    }

    if (result.tileY >= world.countY) {
        result.tileY -= world.countY;
        result.tileMapY += 1;
    }

    return result;
}

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

fn IsWorldPointEmpty(world: *const game.world, testPos: game.raw_position) bool {
    const canPos = GetCanonicalPosition(world, testPos);
    const tileMap = GetTileMap(world, canPos.tileMapX, canPos.tileMapY);
    const empty = IsTileMapPointEmpty(world, tileMap, canPos.tileX, canPos.tileY);

    return empty;
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

    const TILE_MAP_COUNT_X = 17;
    const TILE_MAP_COUNT_Y = 9;

    const tiles00 = [TILE_MAP_COUNT_Y][TILE_MAP_COUNT_X]u32{
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u32{ 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
        [_]u32{ 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u32{ 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
    };

    const tiles01 = [TILE_MAP_COUNT_Y][TILE_MAP_COUNT_X]u32{
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    };

    const tiles10 = [TILE_MAP_COUNT_Y][TILE_MAP_COUNT_X]u32{
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
    };

    const tiles11 = [TILE_MAP_COUNT_Y][TILE_MAP_COUNT_X]u32{
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    };

    var tileMaps = [2][2]game.tile_map{ [1]game.tile_map{game.tile_map{}} ** 2, [1]game.tile_map{game.tile_map{}} ** 2 };

    tileMaps[0][0].tiles = @ptrCast([*]const u32, &tiles00);
    tileMaps[0][1].tiles = @ptrCast([*]const u32, &tiles10);
    tileMaps[1][0].tiles = @ptrCast([*]const u32, &tiles01);
    tileMaps[1][1].tiles = @ptrCast([*]const u32, &tiles11);

    var world = game.world{
        .tileSideInMeters = 1.4,
        .tileSideInPixels = 60,

        .countX = TILE_MAP_COUNT_X,
        .countY = TILE_MAP_COUNT_Y,

        .tileMapCountX = 2,
        .tileMapCountY = 2,

        .tileMaps = @ptrCast([*]game.tile_map, &tileMaps),
    };

    world.upperLeftX = -@intToFloat(f32, world.tileSideInPixels) / 2;
    world.upperLeftY = 0;

    const playerWidth = 0.75 * @intToFloat(f32, world.tileSideInPixels);
    const playerHeight = @intToFloat(f32, world.tileSideInPixels);

    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        gameState.playerX = 175;
        gameState.playerY = 150;

        gameMemory.isInitialized = true;
    }

    if (GetTileMap(&world, gameState.playerTileMapX, gameState.playerTileMapY)) |tileMap| {
        for (gameInput.controllers) |controller| {
            if (controller.isAnalog) {
                // Use analog movement tuning
            } else {
                // Use digital movement tuning

                var dPlayerX: f32 = 0; // pixels/second
                var dPlayerY: f32 = 0; // pixels/second

                if (controller.buttons.mapped.moveUp.endedDown != 0) {
                    dPlayerY = -1.0;
                }
                if (controller.buttons.mapped.moveDown.endedDown != 0) {
                    dPlayerY = 1.0;
                }
                if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                    dPlayerX = -1.0;
                }
                if (controller.buttons.mapped.moveRight.endedDown != 0) {
                    dPlayerX = 1.0;
                }

                dPlayerX *= 64;
                dPlayerY *= 64;

                const newPlayerX = gameState.playerX + gameInput.dtForFrame * dPlayerX;
                const newPlayerY = gameState.playerY + gameInput.dtForFrame * dPlayerY;

                const playerPos = game.raw_position{
                    .tileMapX = gameState.playerTileMapX,
                    .tileMapY = gameState.playerTileMapY,
                    .x = newPlayerX,
                    .y = newPlayerY,
                };
                var playerLeft = playerPos;
                playerLeft.x -= 0.5 * playerWidth;
                var playerRight = playerPos;
                playerRight.x += 0.5 * playerWidth;

                if (IsWorldPointEmpty(&world, playerPos) and
                    IsWorldPointEmpty(&world, playerLeft) and
                    IsWorldPointEmpty(&world, playerRight))
                {
                    const canPos = GetCanonicalPosition(&world, playerPos);

                    gameState.playerTileMapX = canPos.tileMapX;
                    gameState.playerTileMapY = canPos.tileMapY;
                    gameState.playerX = world.upperLeftX + @intToFloat(f32, world.tileSideInPixels) * @intToFloat(f32, canPos.tileX) + canPos.tileRelX;
                    gameState.playerY = world.upperLeftY + @intToFloat(f32, world.tileSideInPixels) * @intToFloat(f32, canPos.tileY) + canPos.tileRelY;
                }
            }
        }

        DrawRectangle(buffer, 0, 0, @intToFloat(f32, buffer.width), @intToFloat(f32, buffer.height), 1, 0, 0);

        var row: i32 = 0;
        while (row < TILE_MAP_COUNT_Y) : (row += 1) {
            var col: i32 = 0;
            while (col < TILE_MAP_COUNT_X) : (col += 1) {
                const tileID = GetTileValueUnchecked(&world, tileMap, col, row);
                var grey: f32 = 0.5;
                switch (tileID) {
                    1 => grey = 1,
                    else => {},
                }

                const minX = world.upperLeftX + @intToFloat(f32, col * world.tileSideInPixels);
                const minY = world.upperLeftY + @intToFloat(f32, row * world.tileSideInPixels);
                const maxX = minX + @intToFloat(f32, world.tileSideInPixels);
                const maxY = minY + @intToFloat(f32, world.tileSideInPixels);

                DrawRectangle(buffer, minX, minY, maxX, maxY, grey, grey, grey);
            }
        }

        const playerR = 1.0;
        const playerG = 1.0;
        const playerB = 0.0;

        const playerLeft = gameState.playerX - 0.5 * playerWidth;
        const playerTop = gameState.playerY - playerHeight;

        DrawRectangle(buffer, playerLeft, playerTop, playerLeft + playerWidth, playerTop + playerHeight, playerR, playerG, playerB);
    }
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

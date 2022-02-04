const std = @import("std");
const platform = @import("handmade_platform");
const NOT_IGNORE = @import("build_consts").NOT_IGNORE;

// constants ------------------------------------------------------------------------------------------------------------------------------

const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

// inline functions -----------------------------------------------------------------------------------------------------------------------

inline fn RoundF32ToInt(comptime T: type, float32: f32) T {
    const result = @floatToInt(T, float32 + 0.5);
    return result;
}

// inline fn RoundF32ToU32(float32: f32) u32 {
//     const result = @floatToInt(u32, float32 + 0.5);
//     return result;
// }

inline fn TruncateF32ToI32(float32: f32) i32 {
    const result = @floatToInt(i32, float32);
    return result;
}

inline fn FloorF32ToI32(float32: f32) i32 {
    const result = @floatToInt(i32, @floor(float32));
    return result;
}

inline fn GetTileMap(world: *const platform.world, tileMapX: i32, tileMapY: i32) ?*platform.tile_map {
    var tileMap: ?*platform.tile_map = null;
    if ((tileMapX >= 0 and tileMapX < world.tileMapCountX) and (tileMapY >= 0 and tileMapY < world.tileMapCountY)) {
        tileMap = &world.tileMaps[@intCast(u32, tileMapY) * world.tileMapCountX + @intCast(u32, tileMapX)];
    }

    return tileMap;
}

inline fn GetTileValueUnchecked(world: *const platform.world, tileMap: *platform.tile_map, tileX: i32, tileY: i32) u32 {
    std.debug.assert((tileX >= 0 and tileX < world.countX) and (tileY >= 0 and tileY < world.countY));

    const tileMapValue = tileMap.tiles[@intCast(u32, tileY * world.countX) + @intCast(u32, tileX)];
    return tileMapValue;
}

inline fn IsTileMapPointEmpty(world: *const platform.world, tileMap: ?*platform.tile_map, testTileX: i32, testTileY: i32) bool {
    var empty = false;

    if (tileMap) |map| {
        if ((testTileX >= 0 and testTileX < world.countX) and (testTileY >= 0 and testTileY < world.countY)) {
            const tileMapValue = GetTileValueUnchecked(world, map, testTileX, testTileY);
            empty = (tileMapValue == 0);
        }
    }

    return empty;
}

inline fn GetCanonicalPosition(world: *const platform.world, pos: platform.raw_position) platform.canonical_position {
    var result = platform.canonical_position{};

    result.tileMapX = pos.tileMapX;
    result.tileMapY = pos.tileMapY;

    const x = pos.x - world.upperLeftX;
    const y = pos.y - world.upperLeftY;

    result.tileX = FloorF32ToI32(x / world.tileWidth);
    result.tileY = FloorF32ToI32(y / world.tileHeight);

    result.tileRelX = x - @intToFloat(f32, result.tileX) * world.tileWidth;
    result.tileRelY = y - @intToFloat(f32, result.tileY) * world.tileHeight;

    std.debug.assert(result.tileRelX >= 0);
    std.debug.assert(result.tileRelY >= 0);
    std.debug.assert(result.tileRelX < world.tileWidth);
    std.debug.assert(result.tileRelY < world.tileHeight);

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

fn OutputSound(_: *platform.state, soundBuffer: *platform.sound_output_buffer, toneHz: u32) void {
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
    var minX = RoundF32ToInt(i32, fMinX);
    var minY = RoundF32ToInt(i32, fMinY);
    var maxX = RoundF32ToInt(i32, fMaxX);
    var maxY = RoundF32ToInt(i32, fMaxY);

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

    const colour: u32 = (RoundF32ToInt(u32, r * 255.0) << 16) | (RoundF32ToInt(u32, g * 255.0) << 8) | (RoundF32ToInt(u32, b * 255) << 0);

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

fn IsWorldPointEmpty(world: *const platform.world, testPos: platform.raw_position) bool {
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

    std.debug.assert(@sizeOf(platform.state) <= gameMemory.permanentStorageSize);

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

    var tileMaps = [2][2]platform.tile_map{ [1]platform.tile_map{platform.tile_map{}} ** 2, [1]platform.tile_map{platform.tile_map{}} ** 2 };

    tileMaps[0][0].tiles = @ptrCast([*]const u32, &tiles00);
    tileMaps[0][1].tiles = @ptrCast([*]const u32, &tiles10);
    tileMaps[1][0].tiles = @ptrCast([*]const u32, &tiles01);
    tileMaps[1][1].tiles = @ptrCast([*]const u32, &tiles11);

    const world = platform.world{
        .countX = TILE_MAP_COUNT_X,
        .countY = TILE_MAP_COUNT_Y,

        .upperLeftX = -30,
        .upperLeftY = 0,

        .tileWidth = 60,
        .tileHeight = 60,

        .tileMapCountX = 2,
        .tileMapCountY = 2,

        .tileMaps = @ptrCast([*]platform.tile_map, &tileMaps),
    };

    const playerWidth = 0.75 * world.tileWidth;
    const playerHeight = world.tileHeight;

    const gameState = @ptrCast(*platform.state, @alignCast(@alignOf(platform.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        gameState.playerX = 150;
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

                const playerPos = platform.raw_position{
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
                    gameState.playerX = world.upperLeftX + world.tileWidth * @intToFloat(f32, canPos.tileX) + canPos.tileRelX;
                    gameState.playerY = world.upperLeftY + world.tileHeight * @intToFloat(f32, canPos.tileY) + canPos.tileRelY;
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

                const minX = world.upperLeftX + @intToFloat(f32, col) * world.tileWidth;
                const minY = world.upperLeftY + @intToFloat(f32, row) * world.tileHeight;
                const maxX = minX + world.tileWidth;
                const maxY = minY + world.tileHeight;

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

    const gameState = @ptrCast(*platform.state, @alignCast(@alignOf(platform.state), gameMemory.permanentStorage));
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

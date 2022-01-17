const std = @import("std");
const common = @import("handmade_common");
const NOT_IGNORE = @import("build_consts").NOT_IGNORE;

// constants ------------------------------------------------------------------------------------------------------------------------------
const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

// local functions ------------------------------------------------------------------------------------------------------------------------

fn OutputSound(_: *common.state, soundBuffer: *common.sound_output_buffer, toneHz: u32) void {
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
        // gameState.tSine += 2.0 * common.PI32 * 1.0 / @intToFloat(f32, wavePeriod);
        // if (gameState.tSine > 2.0 * common.PI32) {
        //     gameState.tSine -= 2.0 * common.PI32;
        // }
    }
}

fn RoundF32ToI32(float32: f32) i32 {
    const result = @floatToInt(i32, float32 + 0.5);
    return result;
}

fn RoundF32ToU32(float32: f32) u32 {
    const result = @floatToInt(u32, float32 + 0.5);
    return result;
}

fn DrawRectangle(buffer: *common.offscreen_buffer, fMinX: f32, fMinY: f32, fMaxX: f32, fMaxY: f32, r: f32, g: f32, b: f32) void {
    var minX = @intCast(i32, RoundF32ToI32(fMinX));
    var minY = @intCast(i32, RoundF32ToI32(fMinY));
    var maxX = @intCast(i32, RoundF32ToI32(fMaxX));
    var maxY = @intCast(i32, RoundF32ToI32(fMaxY));

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

    const colour: u32 = (RoundF32ToU32(r * 255.0) << 16) | (RoundF32ToU32(g * 255.0) << 8) | (RoundF32ToU32(b * 255) << 0);

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

pub export fn UpdateAndRender(thread: *common.thread_context, gameMemory: *common.memory, gameInput: *common.input, buffer: *common.offscreen_buffer) void {
    comptime {
        // This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args.len != @typeInfo(common.UpdateAndRenderType).Fn.args.len or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[0].arg_type.? != @typeInfo(common.UpdateAndRenderType).Fn.args[0].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[1].arg_type.? != @typeInfo(common.UpdateAndRenderType).Fn.args[1].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[2].arg_type.? != @typeInfo(common.UpdateAndRenderType).Fn.args[2].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[3].arg_type.? != @typeInfo(common.UpdateAndRenderType).Fn.args[3].arg_type.?) or
            @typeInfo(@TypeOf(UpdateAndRender)).Fn.return_type.? != @typeInfo(common.UpdateAndRenderType).Fn.return_type.?)
        {
            @compileError("Function signature mismatch!");
        }
    }

    _ = thread;

    std.debug.assert(@sizeOf(common.state) <= gameMemory.permanentStorageSize);

    const gameState = @ptrCast(*common.state, @alignCast(@alignOf(common.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
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

            gameState.playerX += gameInput.dtForFrame * dPlayerX;
            gameState.playerX += gameInput.dtForFrame * dPlayerX;
        }
    }

    const tileMap = [9][17]u32{
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
        [_]u32{ 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
        [_]u32{ 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1 },
        [_]u32{ 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
        [_]u32{ 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1 },
        [_]u32{ 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
        [_]u32{ 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
    };

    const upperLeftX = -30.0;
    const upperLeftY = 0.0;
    const tileWidth = 60.0;
    const tileHeight = 60.0;

    DrawRectangle(buffer, 0, 0, @intToFloat(f32, buffer.width), @intToFloat(f32, buffer.height), 1, 0, 0);

    var row: u32 = 0;
    while (row < tileMap.len) : (row += 1) {
        var col: u32 = 0;
        while (col < tileMap[0].len) : (col += 1) {
            const tileID = tileMap[row][col];
            var grey: f32 = 0.5;
            switch (tileID) {
                1 => grey = 1,
                else => {},
            }

            const minX = upperLeftX + @intToFloat(f32, col) * tileWidth;
            const minY = upperLeftY + @intToFloat(f32, row) * tileHeight;
            const maxX = minX + tileWidth;
            const maxY = minY + tileHeight;

            DrawRectangle(buffer, minX, minY, maxX, maxY, grey, grey, grey);
        }
    }

    const playerR = 1.0;
    const playerG = 1.0;
    const playerB = 0.0;

    const playerWidth = 0.7 * tileWidth;
    const playerHeight = tileHeight;
    const playerLeft = gameState.playerX - 0.5 * playerWidth;
    const playerTop = gameState.playerY - playerHeight;

    DrawRectangle(buffer, playerLeft, playerTop, playerLeft + playerHeight, playerTop + playerWidth, playerR, playerG, playerB);
}

// NOTEAt the moment, this has to be a very fast function, it cannot be
// more than a millisecond or so.
// TODO Reduce the pressure on this function's performance by measuring it
// or asking about it, etc.
pub export fn GetSoundSamples(_: *common.thread_context, gameMemory: *common.memory, soundBuffer: *common.sound_output_buffer) void {
    comptime {
        // This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args.len != @typeInfo(common.GetSoundSamplesType).Fn.args.len or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[0].arg_type.? != @typeInfo(common.GetSoundSamplesType).Fn.args[0].arg_type.?) or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[1].arg_type.? != @typeInfo(common.GetSoundSamplesType).Fn.args[1].arg_type.?) or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[2].arg_type.? != @typeInfo(common.GetSoundSamplesType).Fn.args[2].arg_type.?) or
            @typeInfo(@TypeOf(GetSoundSamples)).Fn.return_type.? != @typeInfo(common.GetSoundSamplesType).Fn.return_type.?)
        {
            @compileError("Function signature mismatch!");
        }
    }

    const gameState = @ptrCast(*common.state, @alignCast(@alignOf(common.state), gameMemory.permanentStorage));
    OutputSound(gameState, soundBuffer, 400);
}

// fn RenderWeirdGradient(buffer: *common.offscreen_buffer, xOffset: i32, yOffset: i32) void {
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

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

fn DrawRectangle(buffer: *common.offscreen_buffer, fMinX: f32, fMinY: f32, fMaxX: f32, fMaxY: f32, colour: u32) void {
    var minX = @bitCast(u32, RoundF32ToI32(fMinX));
    var minY = @bitCast(u32, RoundF32ToI32(fMinY));
    var maxX = @bitCast(u32, RoundF32ToI32(fMaxX));
    var maxY = @bitCast(u32, RoundF32ToI32(fMaxY));

    if (fMinX < 0) {
        minX = 0;
    }

    if (fMinY < 0) {
        minY = 0;
    }

    if (fMaxX > @intToFloat(f32, buffer.width)) {
        maxX = buffer.width;
    }

    if (fMaxY > @intToFloat(f32, buffer.height)) {
        maxY = buffer.width;
    }

    var row = @ptrCast([*]u8, buffer.memory) + minX * buffer.bytesPerPixel + minY * buffer.pitch;

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

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(_: *common.thread_context, gameMemory: *common.memory, gameInput: *common.input, buffer: *common.offscreen_buffer) void {
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

    std.debug.assert(@sizeOf(common.state) <= gameMemory.permanentStorageSize);

    // const gameState = @ptrCast(*common.state, @alignCast(@alignOf(common.state), gameMemory.permanentStorage));
    const gameState = @ptrCast(*common.state, gameMemory.permanentStorage);
    _ = gameState;

    if (!gameMemory.isInitialized) {
        gameMemory.isInitialized = true;
    }

    for (gameInput.controllers) |controller| {
        if (controller.isAnalog) {} else {}
    }

    DrawRectangle(buffer, 0, 0, @intToFloat(f32, buffer.width), @intToFloat(f32, buffer.height), 0x00ff00ff);
    DrawRectangle(buffer, 10, 10, 40, 40, 0x0000ffff);
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

    // const gameState = @ptrCast(*common.state, @alignCast(@alignOf(common.state), gameMemory.permanentStorage));
    const gameState = @ptrCast(*common.state, gameMemory.permanentStorage);
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

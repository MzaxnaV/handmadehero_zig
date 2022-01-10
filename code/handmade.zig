const std = @import("std");
const common = @import("handmade_common");

// constants ------------------------------------------------------------------------------------------------------------------------------
const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

// local functions ------------------------------------------------------------------------------------------------------------------------

fn OutputSound(gameState: *common.state, soundBuffer: *common.sound_output_buffer, toneHz: u32) void {
    const toneVolume = 3000;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);

    var sampleOut = soundBuffer.samples;
    var sampleIndex: u32 = 0;
    while (sampleIndex < soundBuffer.sampleCount) : (sampleIndex += 1) {
        const sineValue = @sin(gameState.tSine);
        const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, toneVolume));
        sampleOut.* = sampleValue;
        sampleOut += 1;
        sampleOut.* = sampleValue;
        sampleOut += 1;

        gameState.tSine += 2.0 * common.PI32 * 1.0 / @intToFloat(f32, wavePeriod);
        if (gameState.tSine > 2.0 * common.PI32) {
            gameState.tSine -= 2.0 * common.PI32;
        }
    }
}

fn RenderWeirdGradient(buffer: *common.offscreen_buffer, xOffset: i32, yOffset: i32) void {
    var row = @ptrCast([*]u8, buffer.memory);

    var y: u32 = 0;
    while (y < buffer.height) : (y += 1) {
        var x: u32 = 0;
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        while (x < buffer.width) : (x += 1) {
            // Pixel in memory: BB GG RR xx
            // Little endian arch: 0x xxRRGGBB

            var blue: u8 = @truncate(u8, x +% @bitCast(u32, xOffset));
            var green: u8 = @truncate(u8, y +% @bitCast(u32, yOffset));

            pixel.* = (@as(u32, green) << 16) | @as(u32, blue);
            pixel += 1;
        }
        row += buffer.pitch;
    }
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(gameMemory: *common.memory, gameInput: *common.input, buffer: *common.offscreen_buffer) void {
    std.debug.assert(@sizeOf(common.state) <= gameMemory.permanentStorageSize);

    const gameState: *common.state = @ptrCast(*common.state, @alignCast(@alignOf(common.state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        const fileName = "../code/handmade.zig";

        var file = gameMemory.DEBUGPlatformReadEntireFile(fileName);

        if (file.contentSize > 0) {
            _ = gameMemory.DEBUGPlatformWriteEntireFile("test.out", file.contentSize, file.contents);
            gameMemory.DEBUGPlatformFreeFileMemory(file.contents);
        }

        gameState.toneHz = 512;
        gameState.tSine = 0;

        // TODO: This may be more appropriate to do in the platform layer
        gameMemory.isInitialized = true;
    }

    for (gameInput.controllers) |controller| {
        if (controller.isAnalog) {
            // Use analog movement tuning
            gameState.blueOffset +%= @floatToInt(i32, 4.0 * controller.stickAverageX);
            gameState.toneHz = 512 + @floatToInt(u32, 120.0 * controller.stickAverageY);
        } else {
            // Use digital movement tuning
            if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                gameState.blueOffset -%= 1;
            }
            if (controller.buttons.mapped.moveRight.endedDown != 0) {
                gameState.blueOffset +%= 1;
            }
        }

        // Input.AButtonEndedDown;
        // Input.NumberOfTransitions;
        if (controller.buttons.mapped.actionDown.endedDown != 0) {
            gameState.greenOffset +%= 1;
        }
    }

    RenderWeirdGradient(buffer, gameState.blueOffset, gameState.greenOffset);
}

// NOTEAt the moment, this has to be a very fast function, it cannot be
// more than a millisecond or so.
// TODO Reduce the pressure on this function's performance by measuring it
// or asking about it, etc.
pub export fn GetSoundSamples(gameMemory: *common.memory, soundBuffer: *common.sound_output_buffer) void {
    const gameState: *common.state = @ptrCast(*common.state, @alignCast(@alignOf(common.state), gameMemory.permanentStorage));
    OutputSound(gameState, soundBuffer, gameState.toneHz);
}

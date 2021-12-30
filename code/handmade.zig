const std = @import("std");

// constants ----------------------------------------------------------------------------------------------------------

pub const PI32 = 3.14159265359;

// data structure -----------------------------------------------------------------------------------------------------

pub const offscreen_buffer = struct {
    memory: ?*anyopaque,
    width: i32,
    height: i32,
    pitch: usize,
};

pub const sound_output_buffer = struct {
    samplesPerSecond: u32,
    sampleCount: u32,
    samples: [*]i16,
};

pub const button_state = packed struct {
    haltTransitionCount: u32 = 0,
    // boolean
    endedDown: u32 = 0,
};

pub const controller_input = struct {
    isAnalog: bool = false,

    startX: f32 = 0,
    startY: f32 = 0,

    minX: f32 = 0,
    minY: f32 = 0,

    maxX: f32 = 0,
    maxY: f32 = 0,

    endX: f32 = 0,
    endY: f32 = 0,

    buttons: packed struct {
        up: button_state,
        down: button_state,
        left: button_state,
        right: button_state,
        leftShoulder: button_state,
        rightShoulder: button_state,
    },
};

pub const input = struct {
    controllers: [4]controller_input,
};

pub const memory = struct {
    isInitialized: bool = false,
    permanentStorageSize: u64,
    permanentStorage: [*]u8,
    transientStorageSize: u64,
    transientStorage: [*]u8,
};

pub const state = struct {
    blueOffset: i32,
    greenOffset: i32,
    toneHz: u32,
};

// local functions ----------------------------------------------------------------------------------------------------------

fn OutputSound(soundBuffer: *sound_output_buffer, toneHz: u32) void {
    const s = struct {
        var tSine: f32 = 0;
    };

    const toneVolume = 3000;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);

    var sampleOut = soundBuffer.samples;
    var sampleIndex: u32 = 0;
    while (sampleIndex < soundBuffer.sampleCount) : (sampleIndex += 1) {
        const sineValue = std.math.sin(s.tSine);
        const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, toneVolume));
        sampleOut.* = sampleValue;
        sampleOut += 1;
        sampleOut.* = sampleValue;
        sampleOut += 1;

        s.tSine += 2.0 * PI32 * 1.0 / @intToFloat(f32, wavePeriod);
    }
}

fn RenderWeirdGradient(buffer: *offscreen_buffer, xOffset: i32, yOffset: i32) void {
    var row = @ptrCast([*]u8, buffer.memory);

    var y: u32 = 0;
    while (y < buffer.height) : (y += 1) {
        var x: u32 = 0;
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        while (x < buffer.width) : (x += 1) {
            // Pixel in memory: BB GG RR xx
            // Little endian arch: 0x xxRRGGBB
            var blue = x + @intCast(u32, xOffset);
            var green = y + @intCast(u32, yOffset);

            pixel.* = (green << 8) | blue;
            pixel += 1;
        }
        row += buffer.pitch;
    }
}

// public functions ---------------------------------------------------------------------------------------------------

pub inline fn KiloBytes(value: u64) u64 {
    return 1000 * value;
}
pub inline fn MegaBytes(value: u64) u64 {
    return 1000 * KiloBytes(value);
}
pub inline fn GigaBytes(value: u64) u64 {
    return 1000 * MegaBytes(value);
}
pub inline fn TeraBytes(value: u64) u64 {
    return 1000 * GigaBytes(value);
}

pub fn UpdateAndRender(gameMemory: *memory, gameInput: *input, buffer: *offscreen_buffer, soundBuffer: *sound_output_buffer) void {
    std.debug.assert(@sizeOf(state) <= gameMemory.permanentStorageSize);

    const gameState: *state = @ptrCast(*state, @alignCast(@alignOf(state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        gameState.toneHz = 256;

        // TODO: This may be more appropriate to do in the platform layer
        gameMemory.isInitialized = true;
    }

    const input0 = gameInput.controllers[0];

    if (input0.isAnalog) {
        gameState.blueOffset += @floatToInt(i32, 4.0 * input0.endX);
        gameState.toneHz += 256 + @floatToInt(u32, 120.0 * input0.endY);
    } else {
        // Use digital movement tuning
    }

    // Input.AButtonEndedDown;
    // Input.NumberOfTransitions;
    if (input0.buttons.down.endedDown != 0) {
        gameState.greenOffset += 1;
    }

    // TODO:  Allow sample offsets here for more robust platform options
    OutputSound(soundBuffer, gameState.toneHz);
    RenderWeirdGradient(buffer, gameState.blueOffset, gameState.greenOffset);
}

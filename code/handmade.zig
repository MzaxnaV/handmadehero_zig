const std = @import("std");

pub const PI32 = 3.14159265359;

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

fn OutputSound(soundBuffer: *sound_output_buffer, toneHz: u32) void {
    const state = struct {
        var tSine: f32 = 0;
    };

    const toneVolume = 3000;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);

    var sampleOut = soundBuffer.samples;
    var sampleIndex: u32 = 0;
    while (sampleIndex < soundBuffer.sampleCount) : (sampleIndex += 1) {
        const sineValue = std.math.sin(state.tSine);
        const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, toneVolume));
        sampleOut.* = sampleValue;
        sampleOut += 1;
        sampleOut.* = sampleValue;
        sampleOut += 1;

        state.tSine += 2.0 * PI32 * 1.0 / @intToFloat(f32, wavePeriod);
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

pub fn UpdateAndRender(i: *input, buffer: *offscreen_buffer, soundBuffer: *sound_output_buffer) void {

    const state = struct {
        var blueOffset:i32 = 0;
        var greenOffset:i32 = 0;
        var toneHz:u32 = 256;
    };

    const input0 = i.controllers[0];

    if (input0.isAnalog)
    {
        state.blueOffset += @floatToInt(i32, 4.0 * input0.endX);
        state.toneHz += 256 + @floatToInt(u32, 120.0 * input0.endY);
    } else {
        // Use digital movement tuning
    }

    // Input.AButtonEndedDown;
    // Input.NumberOfTransitions;
    if (input0.buttons.down.endedDown != 0)
    {
        state.greenOffset += 1;
    }

    // TODO:  Allow sample offsets here for more robust platform options
    OutputSound(soundBuffer, state.toneHz);
    RenderWeirdGradient(buffer, state.blueOffset, state.greenOffset);
}

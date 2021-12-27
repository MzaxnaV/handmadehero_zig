const std = @import("std");

pub const PI32 = 3.14159265359;

pub const offscreen_buffer = struct {
    memory: ?*anyopaque, 
    width: i32, 
    height: i32, 
    pitch: usize 
};

pub const sound_output_buffer = struct {
    samplesPerSecond : u32,
    sampleCount: u32,
    samples: [*]i16
};

fn OutputSound(soundBuffer: *sound_output_buffer, toneHz: u32) void
{
    const state = struct {
        var tSine: f32 = 0;
    };

    const toneVolume = 3000;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond , toneHz);

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

pub fn UpdateAndRender(buffer: *offscreen_buffer, blueOffset: i32, greenOffset: i32, soundBuffer: *sound_output_buffer, toneHz: u32) void {
    // TODO:  Allow sample offsets here for more robust platform options
    OutputSound(soundBuffer, toneHz);
    RenderWeirdGradient(buffer, blueOffset, greenOffset);
}
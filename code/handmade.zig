const std = @import("std");

// constants ------------------------------------------------------------------------------------------------------------------------------

pub const PI32 = 3.14159265359;
const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

// data structure -------------------------------------------------------------------------------------------------------------------------

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

const input_buttons = struct {
    moveUp: button_state = button_state{},
    moveDown: button_state = button_state{},
    moveLeft: button_state = button_state{},
    moveRight: button_state = button_state{},

    actionUp: button_state = button_state{},
    actionDown: button_state = button_state{},
    actionLeft: button_state = button_state{},
    actionRight: button_state = button_state{},

    leftShoulder: button_state = button_state{},
    rightShoulder: button_state = button_state{},

    back: button_state = button_state{},
    start: button_state = button_state{},

    pub fn Get(self: *input_buttons, index: u8) *button_state {
        return switch (index) {
            0 => &self.moveUp,
            1 => &self.moveDown,
            2 => &self.moveLeft,
            3 => &self.moveRight,
            4 => &self.actionUp,
            5 => &self.actionDown,
            6 => &self.actionLeft,
            7 => &self.actionRight,
            8 => &self.leftShoulder,
            9 => &self.rightShoulder,
            10 => &self.back,
            11 => &self.start,
            else => unreachable,
        };
    }
};

pub const controller_input = struct {
    isAnalog: bool = false,
    isConnected: bool = false,
    stickAverageX: f32 = 0,
    stickAverageY: f32 = 0,

    buttons: input_buttons = input_buttons{},
};

pub const input = struct {
    controllers: [5]controller_input,
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

// local functions ------------------------------------------------------------------------------------------------------------------------

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

            var blue: u8 = @truncate(u8, x +% @bitCast(u32, xOffset));
            var green: u8 = @truncate(u8, y +% @bitCast(u32, yOffset));

            pixel.* = (@as(u32, green) << 8) | @as(u32, blue);
            pixel += 1;
        }
        row += buffer.pitch;
    }
}

// public functions -----------------------------------------------------------------------------------------------------------------------

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

pub const platform = struct {
    DEBUGPlatformFreeFileMemory: fn (*anyopaque) void = undefined,
    DEBUGPlatformReadEntireFile: fn ([*:0]const u8) debug_read_file_result = undefined,
    DEBUGPlatformWriteEntireFile: fn ([*:0]const u8, u32, *anyopaque) bool = undefined,
};

// IMPORTANT: These are NOT for doing anything in the shipping game - they are blocking and the write doesn't protect against lost data
pub const debug_read_file_result = struct {
    contentSize: u32 = 0,
    contents: *anyopaque = undefined,
};

pub fn UpdateAndRender(callbacks: *const platform, gameMemory: *memory, gameInput: *input, buffer: *offscreen_buffer, soundBuffer: *sound_output_buffer) void {
    std.debug.assert(@sizeOf(state) <= gameMemory.permanentStorageSize);

    const gameState: *state = @ptrCast(*state, @alignCast(@alignOf(state), gameMemory.permanentStorage));

    if (!gameMemory.isInitialized) {
        const fileName = "../code/handmade.zig";

        var file = callbacks.DEBUGPlatformReadEntireFile(fileName);

        if (file.contentSize > 0) {
            _ = callbacks.DEBUGPlatformWriteEntireFile("test.out", file.contentSize, file.contents);
            callbacks.DEBUGPlatformFreeFileMemory(file.contents);
        }

        gameState.toneHz = 256;

        // TODO: This may be more appropriate to do in the platform layer
        gameMemory.isInitialized = true;
    }

    for (gameInput.controllers) |controller| {
        if (controller.isAnalog) {
            // Use analog movement tuning
            gameState.blueOffset +%= @floatToInt(i32, 4.0 * controller.stickAverageX);
            gameState.toneHz = 256 + @floatToInt(u32, 120.0 * controller.stickAverageY);
        } else {
            // Use digital movement tuning
            if (controller.buttons.moveLeft.endedDown != 0) {
                gameState.blueOffset -%= 1;
            }
            if (controller.buttons.moveRight.endedDown != 0) {
                gameState.blueOffset +%= 1;
            }
        }

        // Input.AButtonEndedDown;
        // Input.NumberOfTransitions;
        if (controller.buttons.actionDown.endedDown != 0) {
            gameState.greenOffset +%= 1;
        }
    }

    // TODO:  Allow sample offsets here for more robust platform options
    OutputSound(soundBuffer, gameState.toneHz);
    RenderWeirdGradient(buffer, gameState.blueOffset, gameState.greenOffset);
}

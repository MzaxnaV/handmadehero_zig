// globals --------------------------------------------------------------------------------------------------------------------------------

pub const PI32 = 3.14159265359;

// platform data types -----------------------------------------------------------------------------------------------------------------------------

pub const memory_index = usize;

pub const thread_context = struct {
    placeHolder: u32 = 0,
};

pub const offscreen_buffer = struct {
    memory: ?*anyopaque,
    width: u32,
    height: u32,
    pitch: usize,
    bytesPerPixel: u32,
};

pub const sound_output_buffer = struct {
    samplesPerSecond: u32,
    sampleCount: u32,
    samples: [*]i16,
};

pub const button_state = packed struct {
    haltTransitionCount: u32 = 0,
    // NOTE: (Manav) endedDown is a boolean
    endedDown: u32 = 0,
};

const input_buttons = extern union {
    mapped: struct {
        moveUp: button_state,
        moveDown: button_state,
        moveLeft: button_state,
        moveRight: button_state,

        actionUp: button_state,
        actionDown: button_state,
        actionLeft: button_state,
        actionRight: button_state,

        leftShoulder: button_state,
        rightShoulder: button_state,

        back: button_state,
        start: button_state,
    },
    states: [12]button_state,
};

pub const controller_input = struct {
    isAnalog: bool = false,
    isConnected: bool = false,
    stickAverageX: f32 = 0,
    stickAverageY: f32 = 0,

    buttons: input_buttons = input_buttons{
        .states = [1]button_state{button_state{}} ** 12,
    },
};

pub const input = struct {
    mouseButtons: [5]button_state = [1]button_state{button_state{}} ** 5,
    mouseX: i32 = 0,
    mouseY: i32 = 0,
    mouseZ: i32 = 0,
    dtForFrame: f32 = 0,
    controllers: [5]controller_input = [1]controller_input{controller_input{}} ** 5,
};

pub const debug_platform_read_entire_file = fn (*thread_context, [*:0]const u8) debug_read_file_result;

pub const memory = struct {
    isInitialized: bool = false,
    permanentStorageSize: u64,
    permanentStorage: [*]u8,
    transientStorageSize: u64,
    transientStorage: [*]u8,

    DEBUGPlatformFreeFileMemory: fn (*thread_context, *anyopaque) void = undefined,
    DEBUGPlatformReadEntireFile: debug_platform_read_entire_file = undefined,
    DEBUGPlatformWriteEntireFile: fn (*thread_context, [*:0]const u8, u32, *anyopaque) bool = undefined,
};

// IMPORTANT: These are NOT for doing anything in the shipping game - they are blocking and the write doesn't protect against lost data
pub const debug_read_file_result = struct {
    contentSize: u32 = 0,
    contents: *anyopaque = undefined,
};

// functions ------------------------------------------------------------------------------------------------------------------------------

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

// exported functions ---------------------------------------------------------------------------------------------------------------------

pub const GetSoundSamplesType = fn (*thread_context, *memory, *sound_output_buffer) void;
pub const UpdateAndRenderType = fn (*thread_context, *memory, *input, *offscreen_buffer) void;

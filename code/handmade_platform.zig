const f32_max = @import("std").math.f32_max;

/// `False` - slow code not allowed, `True` - slow code welcome.
const HANDMADE_SLOW = @import("build_consts").HANDMADE_SLOW;
/// `False` - Build for public release, `True` - Build for developer only
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;

// globals --------------------------------------------------------------------------------------------------------------------------------

pub const PI32 = 3.14159265359;
pub const CONTROLLERS = 5;
pub const BITMAP_BYTES_PER_PIXEL = 4;

pub const F32MAXIMUM = f32_max;

// ----------------------------------------------------------------------------------------------------------------------------------------

pub const handmade_slow = if (HANDMADE_SLOW) struct {
    pub fn Assert(expression: bool) void {
        if (!expression) unreachable;
    }
} else {};

pub const handmade_internal = if (HANDMADE_INTERNAL) struct {
    pub const debug_read_file_result = struct {
        contentSize: u32 = 0,
        contents: [*]u8 = undefined,
    };

    pub const debug_platform_free_file_memory = fn (*thread_context, *anyopaque) void;
    pub const debug_platform_read_entire_file = fn (*thread_context, [*:0]const u8) debug_read_file_result;
    pub const debug_platform_write_entire_file = fn (*thread_context, [*:0]const u8, u32, *anyopaque) bool;

    // move this to someplace proper
    inline fn __rdtsc() u64 {
        var low: u64 = undefined;
        var high: u64 = undefined;

        asm volatile ("rdtsc"
            : [low] "={eax}" (low),
              [high] "={edx}" (high),
        );

        return (high << 32) | low;
    }

    pub const debug_cycle_counter_type = enum(u32) {
        UpdateAndRender = 0,
        RenderGroupToOutput,
        DrawRectangleQuickly,
        DrawRectangleSlowly,
        ProcessPixel,
    };

    pub const debug_cycle_counter = struct {
        t: debug_cycle_counter_type = undefined,
        startCyleCount: u64 = 0,

        cycleCount: u64 = 0,
        hitCount: u32 = 0,
    };

    pub var debugGlobalMemory: ?*memory = null;

    inline fn BeginTimedBlock(comptime id: debug_cycle_counter_type) void {
        if (debugGlobalMemory) |m| {
            m.counters[@enumToInt(id)].t = id;
            m.counters[@enumToInt(id)].startCyleCount = __rdtsc();
        }
    }

    inline fn EndTimedBlock(comptime id: debug_cycle_counter_type) void {
        if (debugGlobalMemory) |m| {
            m.counters[@enumToInt(id)].cycleCount += __rdtsc() - m.counters[@enumToInt(id)].startCyleCount;
            m.counters[@enumToInt(id)].hitCount += 1;
        }
    }

    inline fn EndTimedBlockCounted(comptime id: debug_cycle_counter_type, count: u32) void {
        if (debugGlobalMemory) |m| {
            m.counters[@enumToInt(id)].cycleCount += __rdtsc() - m.counters[@enumToInt(id)].startCyleCount;
            m.counters[@enumToInt(id)].hitCount += count;
        }
    }
} else {};

// platform data types --------------------------------------------------------------------------------------------------------------------

pub const memory_index = usize;

pub const thread_context = struct {
    placeHolder: u32 = 0,
};

pub const offscreen_buffer = struct {
    memory: ?*anyopaque,
    width: u32,
    height: u32,
    pitch: usize,
};

pub const sound_output_buffer = struct {
    samplesPerSecond: u32,
    sampleCount: u32,
    samples: [*]i16,
};

pub const button_state = packed struct {
    haltTransitionCount: u32 = 0,
    // endedDown is a boolean
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
    mouseButtons: [CONTROLLERS]button_state = [1]button_state{button_state{}} ** CONTROLLERS,
    mouseX: i32 = 0,
    mouseY: i32 = 0,
    mouseZ: i32 = 0,

    executableReloaded: bool = false,
    dtForFrame: f32 = 0,
    controllers: [CONTROLLERS]controller_input = [1]controller_input{controller_input{}} ** CONTROLLERS,
};

const len = if (HANDMADE_INTERNAL) @typeInfo(handmade_internal.debug_cycle_counter_type).Enum.fields.len else 0;

pub const memory = struct {
    isInitialized: bool = false,
    permanentStorageSize: u64,
    permanentStorage: [*]u8,
    transientStorageSize: u64,
    transientStorage: [*]u8,

    DEBUGPlatformFreeFileMemory: handmade_internal.debug_platform_free_file_memory = undefined,
    DEBUGPlatformReadEntireFile: handmade_internal.debug_platform_read_entire_file = undefined,
    DEBUGPlatformWriteEntireFile: handmade_internal.debug_platform_write_entire_file = undefined,

    // TODO (Manav): make declaration dependent on HANDMADE_INTERNAL
    counters: [len]handmade_internal.debug_cycle_counter = [1]handmade_internal.debug_cycle_counter{.{}} ** len,
};

// functions ------------------------------------------------------------------------------------------------------------------------------

pub inline fn KiloBytes(comptime value: comptime_int) comptime_int {
    return 1024 * value;
}
pub inline fn MegaBytes(comptime value: comptime_int) comptime_int {
    return 1024 * KiloBytes(value);
}
pub inline fn GigaBytes(comptime value: comptime_int) comptime_int {
    return 1024 * MegaBytes(value);
}
pub inline fn TeraBytes(comptime value: comptime_int) comptime_int {
    return 1024 * GigaBytes(value);
}

pub const BEGIN_TIMED_BLOCK = handmade_internal.BeginTimedBlock; // TODO (Manav): make it portable
pub const END_TIMED_BLOCK = handmade_internal.EndTimedBlock; // TODO (Manav): make it portable
pub const END_TIMED_BLOCK_COUNTED = handmade_internal.EndTimedBlockCounted;

// exported functions ---------------------------------------------------------------------------------------------------------------------

pub const GetSoundSamplesType = fn (*thread_context, *memory, *sound_output_buffer) void;
pub const UpdateAndRenderType = fn (*thread_context, *memory, *input, *offscreen_buffer) void;

/// Debug
pub const NOT_IGNORE = true;
/// Debug: `False` - slow code not allowed, `True` - slow code welcome.
pub const HANDMADE_SLOW = true;
/// Debug: `False` - Build for public release, `True` - Build for developer only
pub const HANDMADE_INTERNAL = true;

pub const native_endian = @import("builtin").target.cpu.arch.endian();

// globals --------------------------------------------------------------------------------------------------------------------------------

pub const Pi32 = 3.14159265359; // TODO: these should be in handmade_math
pub const Tau32 = 6.28318530718;

pub const CONTROLLERS = 5;
pub const BITMAP_BYTES_PER_PIXEL = 4;

pub const F32MAXIMUM = @import("std").math.floatMax(f32);
pub const MAXINT32 = @import("std").math.maxInt(i32);

// ----------------------------------------------------------------------------------------------------------------------------------------

pub const handmade_internal = if (HANDMADE_INTERNAL) struct {
    pub const debug_read_file_result = struct {
        contentSize: u32 = 0,
        contents: [*]u8 = undefined,
    };

    pub const debug_platform_free_file_memory = *const fn (*anyopaque) void;
    pub const debug_platform_read_entire_file = *const fn ([*:0]const u8) debug_read_file_result;
    pub const debug_platform_write_entire_file = *const fn ([*:0]const u8, u32, *anyopaque) bool;

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
            m.counters[@intFromEnum(id)].t = id;
            m.counters[@intFromEnum(id)].startCyleCount = __rdtsc();
        }
    }

    inline fn EndTimedBlock(comptime id: debug_cycle_counter_type) void {
        if (debugGlobalMemory) |m| {
            var startCycleCount = m.counters[@intFromEnum(id)].startCyleCount;
            // TODO things are busted.
            m.counters[@intFromEnum(id)].cycleCount +%= __rdtsc() -% startCycleCount;
            m.counters[@intFromEnum(id)].hitCount +%= 1;
        }
    }

    inline fn EndTimedBlockCounted(comptime id: debug_cycle_counter_type, count: u32) void {
        if (debugGlobalMemory) |m| {
            // TODO things are busted.
            m.counters[@intFromEnum(id)].cycleCount +%= __rdtsc() -% m.counters[@intFromEnum(id)].startCyleCount;
            m.counters[@intFromEnum(id)].hitCount +%= count;
        }
    }
} else {};

// platform data types --------------------------------------------------------------------------------------------------------------------

pub const s8 = i8;
pub const s16 = i16;
pub const s32 = i32;
pub const s64 = i64;

pub const memory_index = usize;

pub const offscreen_buffer = struct {
    memory: ?*anyopaque,
    width: u32,
    height: u32,
    pitch: usize,
};

pub const sound_output_buffer = struct {
    const i32x4: type = @Vector(4, i32);

    samplesPerSecond: u32,
    sampleCount: u32,
    samples: [*]align(@alignOf(i32x4)) i16, // NOTE (Manav): samples should be padded to a multiple of 4 samples
};

pub const button_state = extern struct {
    haltTransitionCount: u32 = 0,
    // endedDown is a boolean
    endedDown: u32 = 0,
};

const input_buttons = extern union {
    mapped: extern struct {
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

// TODO (Manav): replace this with an "interface" using a vtable???, https://youtu.be/AHc4x1uXBQE?t=783
pub const work_queue = opaque {};

pub const work_queue_callback = *const fn (queue: ?*work_queue, data: *anyopaque) void;
pub const add_entry = *const fn (queue: *work_queue, callback: work_queue_callback, data: *anyopaque) void;
pub const complete_all_work = *const fn (queue: *work_queue) void;

pub const memory = struct {
    permanentStorageSize: u64,
    permanentStorage: [*]u8,

    transientStorageSize: u64,
    transientStorage: [*]u8,

    d: *debug,

    highPriorityQueue: *work_queue,
    lowPriorityQueue: *work_queue,

    PlatformAddEntry: add_entry,
    PlatformCompleteAllWork: complete_all_work,

    DEBUGPlatformFreeFileMemory: handmade_internal.debug_platform_free_file_memory = undefined,
    DEBUGPlatformReadEntireFile: handmade_internal.debug_platform_read_entire_file = undefined,
    DEBUGPlatformWriteEntireFile: handmade_internal.debug_platform_write_entire_file = undefined,

    // TODO (Manav): make declaration dependent on HANDMADE_INTERNAL
    counters: [len]handmade_internal.debug_cycle_counter = [1]handmade_internal.debug_cycle_counter{.{}} ** len,
};

pub const debug = struct {
    flag: bool = false,
    someState: u32 = 0,
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

pub inline fn Align(addr: usize, alignment: usize) usize {
    // return @import("std").mem.alignForward(usize, addr, alignment);
    return addr + (alignment - 1) & ~(alignment - 1);
}

pub inline fn Assert(expression: bool) void {
    if (HANDMADE_SLOW and !expression) unreachable;
}

pub inline fn InvalidCodePath(comptime _: []const u8) noreturn {
    unreachable;
}

pub const BEGIN_TIMED_BLOCK = handmade_internal.BeginTimedBlock; // TODO (Manav): make it portable
pub const END_TIMED_BLOCK = handmade_internal.EndTimedBlock; // TODO (Manav): make it portable
pub const END_TIMED_BLOCK_COUNTED = handmade_internal.EndTimedBlockCounted;

// exported functions ---------------------------------------------------------------------------------------------------------------------

pub const GetSoundSamplesFnPtrType = *const fn (*memory, *sound_output_buffer) callconv(.C) void;
pub const UpdateAndRenderFnPtrType = *const fn (*memory, *input, *offscreen_buffer) callconv(.C) void;

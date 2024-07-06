const config = @import("config");
/// Debug
pub const ignore = config.ignore;
/// Debug: `False` - slow code not allowed, `True` - slow code welcome.
pub const HANDMADE_SLOW = config.HANDMADE_SLOW;
/// Debug: `False` - Build for public release, `True` - Build for developer only
pub const HANDMADE_INTERNAL = config.HANDMADE_INTERNAL;

pub const native_endian = @import("builtin").target.cpu.arch.endian();

// globals --------------------------------------------------------------------------------------------------------------------------------

pub const Pi32 = 3.14159265359;
pub const Tau32 = 6.28318530718;

pub const CONTROLLERS = 5;
pub const BITMAP_BYTES_PER_PIXEL = 4;

pub const F32MAXIMUM = @import("std").math.floatMax(f32);
pub const MAXINT32 = @import("std").math.maxInt(i32);
pub const MAXUINT32 = @import("std").math.maxInt(u32);

// ----------------------------------------------------------------------------------------------------------------------------------------

pub const handmade_internal = if (HANDMADE_INTERNAL) struct {
    pub const debug_read_file_result = struct {
        contentSize: u32 = 0,
        contents: [*]u8 = undefined,
    };

    pub const debug_free_file_memory = *const fn (*anyopaque) void;
    pub const debug_read_entire_file = *const fn ([*:0]const u8) debug_read_file_result;
    pub const debug_write_entire_file = *const fn ([*:0]const u8, u32, *anyopaque) bool;

    pub fn __rdtsc() u64 {
        var low: u32 = 0;
        var high: u32 = 0;

        asm volatile ("rdtsc"
            : [low] "={eax}" (low),
              [high] "={edx}" (high),
        );

        return (@as(u64, high) << 32) | @as(u64, low);
    }

    // inline fn BeginTimedBlock(comptime id: debug_cycle_counter_type) void {
    //     if (debugGlobalMemory) |m| {
    //         m.counters[@intFromEnum(id)].t = id;
    //         m.counters[@intFromEnum(id)].startCyleCount = __rdtsc();
    //     }
    // }
    // inline fn EndTimedBlock(comptime id: debug_cycle_counter_type) void {
    //     if (debugGlobalMemory) |m| {
    //         const startCycleCount = m.counters[@intFromEnum(id)].startCyleCount;
    //         // TODO things are busted.
    //         m.counters[@intFromEnum(id)].cycleCount +%= __rdtsc() -% startCycleCount;
    //         m.counters[@intFromEnum(id)].hitCount +%= 1;
    //     }
    // }
    // inline fn EndTimedBlockCounted(comptime id: debug_cycle_counter_type, count: u32) void {
    //     if (debugGlobalMemory) |m| {
    //         // TODO things are busted.
    //         m.counters[@intFromEnum(id)].cycleCount +%= __rdtsc() -% m.counters[@intFromEnum(id)].startCyleCount;
    //         m.counters[@intFromEnum(id)].hitCount +%= count;
    //     }
    // }
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

pub const file_handle = extern struct {
    noErrors: bool,
    platform: ?*anyopaque,
};

pub const file_group = extern struct {
    fileCount: u32,
    platform: ?*anyopaque,
};

pub const file_type = enum(u32) {
    PlatformFileType_AssetFile,
    PlatformFileType_SavedGameFile,

    pub fn count() comptime_int {
        comptime {
            return @typeInfo(@This()).Enum.fields.len;
        }
    }
};

pub const get_all_files_of_type_begin = *const fn (fileType: file_type) file_group;
pub const get_all_files_of_type_end = *const fn (fileGroup: *file_group) void;
pub const open_next_file = *const fn (fileGroup: *file_group) file_handle;
pub const read_data_from_file = *const fn (source: *file_handle, offset: u64, size: u64, dest: *anyopaque) void;
pub const file_error = *const fn (source: *file_handle, message: [:0]const u8) void;

pub const platform_allocate_memory = *const fn (size: memory_index) ?*anyopaque;
pub const platform_deallocate_memory = *const fn (memory: ?*anyopaque) void;

pub inline fn NoFileErrors(handle: *file_handle) bool {
    const result = handle.noErrors;
    return result;
}

pub const api = struct {
    AddEntry: add_entry,
    CompleteAllWork: complete_all_work,

    GetAllFilesOfTypeBegin: get_all_files_of_type_begin,
    GetAllFilesOfTypeEnd: get_all_files_of_type_end,
    OpenNextFile: open_next_file,
    ReadDataFromFile: read_data_from_file,
    FileError: file_error,

    AllocateMemory: platform_allocate_memory,
    DeallocateMemory: platform_deallocate_memory,

    DEBUGFreeFileMemory: handmade_internal.debug_free_file_memory = undefined,
    DEBUGReadEntireFile: handmade_internal.debug_read_entire_file = undefined,
    DEBUGWriteEntireFile: handmade_internal.debug_write_entire_file = undefined,
};

pub const memory = struct {
    permanentStorageSize: u64,
    permanentStorage: [*]u8,

    transientStorageSize: u64,
    transientStorage: [*]u8,

    highPriorityQueue: *work_queue,
    lowPriorityQueue: *work_queue,

    platformAPI: api,
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

pub inline fn GetAlignForwardOffset(resultPointer: memory_index, comptime alignment: u5) memory_index {
    const alignmentMask = alignment - 1;
    const alignmentOffset = if ((resultPointer & alignmentMask) != 0) alignment - (resultPointer & alignmentMask) else 0;
    return alignmentOffset;
}

pub inline fn Assert(expression: bool) void {
    if (HANDMADE_SLOW and !expression) unreachable;
}

pub fn InvalidCodePath(comptime _: []const u8) noreturn {
    unreachable;
}

// exported functions ---------------------------------------------------------------------------------------------------------------------

pub const GetSoundSamplesFnPtrType = *const fn (*memory, *sound_output_buffer) callconv(.C) void;
pub const UpdateAndRenderFnPtrType = *const fn (*memory, *input, *offscreen_buffer) callconv(.C) void;

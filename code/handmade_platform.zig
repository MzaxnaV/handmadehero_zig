const std = @import("std");
const builtin = @import("builtin");
const options = @import("options");

const SourceLocation = std.builtin.SourceLocation;

pub const config = @import("handmade_config.zig");

/// Debug: build constant to dynamically ignore code sections
pub const ignore = !options.ignore;
/// Debug: `False` - slow code not allowed, `True` - slow code welcome.
pub const HANDMADE_SLOW = options.HANDMADE_SLOW;
/// Debug: `False` - Build for public release, `True` - Build for developer only
pub const HANDMADE_INTERNAL = options.HANDMADE_INTERNAL;

pub const TRANSLATION_UNIT_INDEX = options.TRANSLATION_UNIT_INDEX;

pub const native_endian = builtin.target.cpu.arch.endian();

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

    pub const debug_executing_process = struct {
        osHandle: u64 = 0,
    };

    pub const debug_executing_state = struct {
        startedSuccessfully: bool = false,
        isRunning: bool = false,
        returnCode: i32 = 0,
    };

    pub const debug_free_file_memory = *const fn (*anyopaque) void;
    pub const debug_read_entire_file = *const fn ([*:0]const u8) debug_read_file_result;
    pub const debug_write_entire_file = *const fn (fileName: [*:0]const u8, memorySize: u32, memory: *anyopaque) bool;
    pub const debug_execute_system_command = *const fn (path: [*:0]const u8, command: [*:0]const u8, commandline: [*:0]const u8) debug_executing_process;
    pub const debug_get_process_state = *const fn (process: debug_executing_process) debug_executing_state;
} else {};

pub fn __rdtsc() u64 {
    var low: u32 = 0;
    var high: u32 = 0;

    asm volatile ("rdtsc"
        : [low] "={eax}" (low),
          [high] "={edx}" (high),
    );

    return (@as(u64, high) << 32) | @as(u64, low);
}

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
    halfTransitionCount: u32 = 0,
    /// endedDown is a boolean
    endedDown: u32 = 0,
};

pub inline fn WasPressed(state: *const button_state) bool {
    const result = (state.halfTransitionCount > 1) or ((state.halfTransitionCount == 1) and (state.endedDown != 0));

    return result;
}

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

pub const input_mouse_button = enum {
    PlatformMouseButton_Left,
    PlatformMouseButton_Middle,
    PlatformMouseButton_Right,
    PlatformMouseButton_Extended0,
    PlatformMouseButton_Extended1,

    pub fn len() comptime_int {
        comptime {
            return @typeInfo(@This()).Enum.fields.len;
        }
    }
};

pub const input = struct {
    mouseButtons: [input_mouse_button.len()]button_state = [1]button_state{button_state{}} ** input_mouse_button.len(),
    mouseX: f32 = 0,
    mouseY: f32 = 0,
    mouseZ: f32 = 0,

    dtForFrame: f32 = 0,
    controllers: [CONTROLLERS]controller_input = [1]controller_input{controller_input{}} ** CONTROLLERS,
};

const len = if (HANDMADE_INTERNAL) @typeInfo(handmade_internal.debug_cycle_counter_type).Enum.fields.len else 0;

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

    DEBUGFreeFileMemory: handmade_internal.debug_free_file_memory,
    DEBUGReadEntireFile: handmade_internal.debug_read_entire_file,
    DEBUGWriteEntireFile: handmade_internal.debug_write_entire_file,
    DEBUGExecuteSystemCommand: handmade_internal.debug_execute_system_command,
    DEBUGGetProcessState: handmade_internal.debug_get_process_state,
};

pub const memory = struct {
    permanentStorageSize: u64,
    permanentStorage: [*]u8,

    transientStorageSize: u64,
    transientStorage: [*]u8,

    debugStorageSize: u64,
    debugStorage: ?[*]u8,

    highPriorityQueue: *work_queue,
    lowPriorityQueue: *work_queue,

    executableReloaded: bool = false,
    platformAPI: api,
};

pub const MAX_DEBUG_THREAD_COUNT = 256;
/// NOTE (Manav): should be 2 for win32 and handmadelib, but for now it's 1
pub const MAX_DEBUG_TRANSLATION_UNITS = 1;
/// NOTE (Manav): investigate the issue that why stack size can never exceed a certain limit
/// and gives permission-denied errors when greater than 64
pub const MAX_DEBUG_EVENT_ARRAY_COUNT = 8;
pub const MAX_DEBUG_EVENT_COUNT = 65536 * 16;
pub const MAX_DEBUG_EVENT_RECORD_COUNT = 65536;

pub const debug_record = extern struct {
    fileName: ?[*:0]const u8 = null,
    blockName: ?[*:0]const u8 = null,

    lineNumber: u32 = 0,
};

const debug_event_type = enum(u8) {
    DebugEvent_FrameMarker,
    DebugEvent_BeginBlock,
    DebugEvent_EndBlock,
};

const threadid_coreIndex = packed struct(u32) {
    threadID: u16 = 0,
    coreIndex: u16 = 0,
};

pub const debug_event = extern struct {
    clock: u64 = 0,
    data: extern union {
        tc: threadid_coreIndex,
        secondsElapsed: f32,
    } = .{ .tc = .{} },
    debugRecordIndex: u16 = 0,
    translationUnit: u8 = 0,
    eventType: debug_event_type = undefined,
};

pub const debug_table = extern struct {
    pub const packed_indices = packed struct(u64) {
        eventIndex: u32 = 0,
        /// NOTE (Manav): should always be 0 since we only have one array
        eventArrayIndex: u32 = 0,
    };

    currentEventArrayIndex: u32 = 0,
    indices: packed_indices = .{},
    eventCount: [MAX_DEBUG_EVENT_ARRAY_COUNT]u32 = .{0} ** MAX_DEBUG_EVENT_ARRAY_COUNT,
    events: [MAX_DEBUG_EVENT_ARRAY_COUNT][MAX_DEBUG_EVENT_COUNT]debug_event = .{[1]debug_event{.{}} ** MAX_DEBUG_EVENT_COUNT} ** MAX_DEBUG_EVENT_ARRAY_COUNT,

    recordCount: [MAX_DEBUG_TRANSLATION_UNITS]u32 = .{0},
    records: [MAX_DEBUG_TRANSLATION_UNITS][MAX_DEBUG_EVENT_RECORD_COUNT]debug_record = .{[1]debug_record{.{}} ** MAX_DEBUG_EVENT_RECORD_COUNT},
};

var globalDebugTable_ = debug_table{};
pub export var globalDebugTable: *debug_table = &globalDebugTable_;

fn RecordDebugEvent(comptime recordIndex: comptime_int, comptime eventType: debug_event_type, secondsElapsed: f32) void {
    const arrayIndex_eventIndex = AtomicAdd(u64, @ptrCast(&globalDebugTable.indices), 1);
    const indices: debug_table.packed_indices = @bitCast(arrayIndex_eventIndex);
    var event: *debug_event = &globalDebugTable.events[indices.eventArrayIndex][indices.eventIndex];
    event.clock = __rdtsc();
    event.debugRecordIndex = recordIndex;
    event.translationUnit = TRANSLATION_UNIT_INDEX;
    event.eventType = eventType;

    switch (eventType) {
        .DebugEvent_FrameMarker => {
            event.data = .{ .secondsElapsed = secondsElapsed };
        },
        else => {
            event.data = .{
                .tc = .{
                    .coreIndex = 0,
                    .threadID = @intCast(GetThreadID()), // NOTE (Manav): this seems to be the bug.
                },
            };
        },
    }
}

/// The function at call site  will be replaced, using a preprocesing tool, with
/// ```
/// debug.TIMED_BLOCK("...", ...);
/// // AUTOGENERATED ----------------------------------------------------------
/// var __t_blk__#counter = debug.TIMED_BLOCK__impl(#counter, @src()).Init("...", ...);
/// defer __t_blk__#counter.End()
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// - #counter will be generated based on `TIMED_BLOCK` call sites.
/// - debug is assumed to be imported at the very top.
pub inline fn TIMED_BLOCK(comptime _: [:0]const u8, _: struct { hitCount: u32 = 1 }) void {}

pub fn TIMED_BLOCK__impl(comptime __counter__: comptime_int, comptime source: SourceLocation) type {
    const timed_block = struct {
        const Self = @This();

        counter: u32, // NOTE (Manav): don't need this atm.

        pub inline fn Init(comptime name: [:0]const u8, _: struct { hitCount: u32 = 1 }) Self {
            const self = Self{
                .counter = __counter__,
            };

            BEGIN_BLOCK_(__counter__, source, name);

            return self;
        }

        pub inline fn End(_: *Self) void {
            END_BLOCK_(__counter__);
        }
    };

    return timed_block;
}

/// The function at call site  will be replaced, using a preprocesing tool, with
/// ```
/// debug.TIMED_FUNCTION(...);
/// // AUTOGENERATED ----------------------------------------------------------
/// var __t_blk__#counter = debug.TIMED_FUNCTION__impl(#counter, @src()).Init(...);
/// defer __t_blk__#counter.End()
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// - #counter will be generated based on `TIMED_FUNCTION` call sites.
/// - debug is assumed to be imported at the very top.
pub inline fn TIMED_FUNCTION(_: struct {}) void {}

pub fn TIMED_FUNCTION__impl(comptime __counter__: comptime_int, comptime source: SourceLocation) type {
    const timed_fn = struct {
        const Self = @This();

        counter: u32, // NOTE (Manav): don't need this atm.

        pub inline fn Init(_: struct { hitCount: u32 = 1 }) Self {
            const self = Self{
                .counter = __counter__,
            };

            BEGIN_BLOCK_(__counter__, source, source.fn_name);

            return self;
        }

        pub inline fn End(_: *Self) void {
            END_BLOCK_(__counter__);
        }
    };

    return timed_fn;
}

inline fn BEGIN_BLOCK_(comptime __counter__: comptime_int, comptime source: SourceLocation, comptime block_name: [:0]const u8) void {
    const record: *debug_record = &globalDebugTable.records[TRANSLATION_UNIT_INDEX][__counter__];

    record.fileName = source.file;
    record.lineNumber = source.line;
    record.blockName = block_name.ptr;

    RecordDebugEvent(__counter__, .DebugEvent_BeginBlock, 0);
}

/// The function at call site  will be replaced, using a preprocesing tool, with
/// ```
/// debug.BEGIN_BLOCK("...");
/// // AUTOGENERATED ----------------------------------------------------------
/// platform.BEGIN_BLOCK__impl(#counter, @src(), "...");
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// - #counter will be generated based on `BEGIN_BLOCK` call sites.
pub inline fn BEGIN_BLOCK(comptime _: []const u8) void {}

pub inline fn BEGIN_BLOCK__impl(comptime __counter__: comptime_int, comptime source: SourceLocation, comptime name: [:0]const u8) void {
    BEGIN_BLOCK_(__counter__, source, name);
}

pub inline fn END_BLOCK__impl(comptime __counter__: comptime_int, comptime _: []const u8) void {
    END_BLOCK_(__counter__);
}

/// The function at call site  will be replaced, using a preprocesing tool, with
/// ```
/// debug.END_BLOCK("...");
/// // AUTOGENERATED ----------------------------------------------------------
/// platform.END_BLOCK__impl(#counter, "...");
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// - #counter will be generated based on `END_BLOCK` call sites.
pub inline fn END_BLOCK(comptime _: []const u8) void {}

inline fn END_BLOCK_(comptime __counter__: comptime_int) void {
    RecordDebugEvent(__counter__, .DebugEvent_EndBlock, 0);
}

/// The function at call site  will be replaced, using a preprocesing tool, with
/// ```
/// debug.FRAME_MARKER(...);
/// // AUTOGENERATED ----------------------------------------------------------
/// platform.FRAME_MARKER__impl(#counter, @src(), ...);
/// // AUTOGENERATED ----------------------------------------------------------
/// ```
/// - #counter will be generated based on `FRAME_MARKER` call sites.
pub inline fn FRAME_MARKER(_: f32) void {}

pub inline fn FRAME_MARKER__impl(comptime __counter__: comptime_int, comptime source: SourceLocation, secondsElapsed: f32) void {
    const record: *debug_record = &globalDebugTable.records[TRANSLATION_UNIT_INDEX][__counter__];

    const block_name = "Frame marker";

    record.fileName = source.file;
    record.lineNumber = source.line;
    record.blockName = block_name.ptr;

    RecordDebugEvent(__counter__, .DebugEvent_FrameMarker, secondsElapsed);
}

// functions ------------------------------------------------------------------------------------------------------------------------------

/// Performs a strong atomic compare exchange operation. It's the equivalent of this code, except atomic:
///
/// ```
/// fn CompareExchange(comptime T: type, ptr: *T, new_value: T, expected_value: T) ?T {
///     const old_value = ptr.*;
///     if (old_value == expected_value) {
///         ptr.* = new_value;
///         return null;        // successful exchange
///     } else {
///         return old_value;   // otherwise
///     }
/// }
/// ```
pub inline fn AtomicCompareExchange(comptime T: type, ptr: *T, new_value: T, expected_value: T) ?T {
    return @cmpxchgStrong(T, ptr, expected_value, new_value, .seq_cst, .seq_cst);
}

/// Performs an atomic add and returns the previous value
pub inline fn AtomicAdd(comptime T: type, ptr: *T, addend: T) T {
    return @atomicRmw(T, ptr, .Add, addend, .seq_cst);
}

pub inline fn AtomicExchange(comptime T: type, ptr: *T, new_value: T) T {
    return @atomicRmw(T, ptr, .Xchg, new_value, .seq_cst);
}

inline fn __readgsqword() *anyopaque {
    return asm ("movq %%gs:0x30, %[res]" // TODO (Manav): investigate this further
        : [res] "=r" (-> *anyopaque),
    );
}

pub inline fn GetThreadID() u32 {
    if (builtin.target.os.tag == .windows and builtin.target.cpu.arch == .x86_64) {
        var threadID: u32 = 0;
        asm volatile ("movl %%gs:0x48, %[res]"
            : [res] "=r" (threadID),
        );

        return threadID;
    } else {
        InvalidCodePath("Unsupported platform");
    }
}

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

pub fn StringLength(string: [*]const u8) u32 {
    var result: u32 = 0;
    while (string[result] != 0) {
        result += 1;
    }

    return result;
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

// globals --------------------------------------------------------------------------------------------------------------------------------

pub var debugGlobalMemory: ?*memory = null;

// exported functions ---------------------------------------------------------------------------------------------------------------------

pub const DEBUGFrameEndsFnPtrType = *const fn (*memory) callconv(.C) *debug_table;

pub const GetSoundSamplesFnPtrType = *const fn (*memory, *sound_output_buffer) callconv(.C) void;
pub const UpdateAndRenderFnPtrType = *const fn (*memory, *input, *offscreen_buffer) callconv(.C) void;

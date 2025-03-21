//! Provides debug functionality
//!
//! __Requirements when importing:__
//! - `const debug = @import("handmade_debug.zig");` must be within the top two lines of the file.

const std = @import("std");
const platform = struct {
    usingnamespace @import("handmade_platform");
    usingnamespace @import("handmade_platform").handmade_internal;
};

const h = struct {
    usingnamespace @import("intrinsics");

    usingnamespace @import("handmade_asset.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_debug_variables.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_render_group.zig");

    usingnamespace @import("handmade_file_formats.zig");
};

const ignore = platform.ignore;

pub const perf_analyzer = struct {
    const method = enum {
        llvm_mca,
    };

    pub fn Start(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .llvm_mca => asm volatile ("# LLVM-MCA-BEGIN " ++ region ::: "memory"),
        }
    }

    pub fn End(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .llvm_mca => asm volatile ("# LLVM-MCA-END " ++ region ::: "memory"),
        }
    }
};

pub const debug_variable_to_text_flag = packed struct {
    Prefix: bool = false,
    Name: bool = false,
    Colon: bool = false,
    TypeSuffix: bool = false,
    LineFeedEnd: bool = false,
    NullTerminate: bool = false,
};

pub const debug_variable_type = enum {
    bool,
    i32,
    u32,
    f32,
    v2,
    v3,
    v4,

    counterThreadList,

    group,

    pub inline fn toT(comptime t: debug_variable_type) type {
        comptime return switch (t) {
            .bool => bool,
            .i32 => i32,
            .u32 => u32,
            .f32 => f32,
            .v2 => h.v2,
            .v3 => h.v3,
            .v4 => h.v4,
            .group => debug_variable_group,
            .counterThreadList => debug_profile_settings,
        };
    }
};

pub fn ShouldBeWritten(t: debug_variable_type) bool {
    const result = (t != .counterThreadList);
    return result;
}

pub const debug_variable_reference = struct {
    variable: *debug_variable,
    next: ?*debug_variable_reference,
    parent: ?*debug_variable_reference,
};

pub const debug_variable_group = struct {
    expanded: bool,
    firstChild: ?*debug_variable_reference,
    lastChild: ?*debug_variable_reference,
};

const debug_variable_hierarchy = struct {
    uiP: h.v2,
    group: *debug_variable_reference,

    next: *debug_variable_hierarchy,
    prev: *debug_variable_hierarchy,
};

const debug_profile_settings = struct {
    dimension: h.v2,
};

pub const debug_variable = struct {
    type: debug_variable_type,
    name: [:0]const u8,

    value: union { // NOTE (Manav): consider tagged union once everything is finalised
        bool: bool,
        i32: i32,
        u32: u32,
        f32: f32,
        v2: h.v2,
        v3: h.v3,
        v4: h.v4,
        group: debug_variable_group,
        profile: debug_profile_settings,
    },
};

const debug_text_op = enum {
    DEBUGTextOp_DrawText,
    DEBUGTextOp_SizeText,
};

const debug_counter_snapshot = struct {
    hitCount: u32 = 0,
    cycleCount: u64 = 0,
};

const debug_counter_state = struct {
    fileName: ?[*:0]const u8,
    blockName: ?[*:0]const u8,

    lineNumber: u32,
};

const debug_frame_region = struct {
    record: *platform.debug_record,
    cycleCount: u64,
    laneIndex: u16,
    colourIndex: u16,
    maxT: f32,
    minT: f32,
};

const MAX_REGIONS_PER_FRAME = 4096 * 2; // NOTE (Manav): we need a bigger number
const debug_frame = struct {
    beginClock: u64,
    endClock: u64,
    wallSecondsElapsed: f32,

    regionCount: u32,
    regions: []debug_frame_region,
};

const open_debug_block = struct {
    startingFrameIndex: u32,
    openingEvent: *platform.debug_event,
    source: *platform.debug_record,
    parent: ?*open_debug_block,

    nextFree: ?*open_debug_block,
};

const debug_thread = struct {
    id: u32,
    laneIndex: u32,
    firstOpenBlock: ?*open_debug_block,
    next: ?*debug_thread,
};

const debug_interaction = enum {
    None,

    NOP,

    ToggleValue,
    DragValue,
    TearValue,

    ResizeProfile,
    MoveHierarchy,
};

pub const debug_state = struct {
    initialized: bool,

    highPriorityQueue: *platform.work_queue,

    debugArena: h.memory_arena,

    renderGroup: *h.render_group,
    debugFont: ?*h.loaded_font,
    debugFontInfo: *h.hha_font,

    compiling: bool,
    compiler: platform.debug_executing_process,

    menuP: h.v2,
    menuActive: bool,

    rootGroup: *debug_variable_reference,
    hierarchySentinel: debug_variable_hierarchy,

    interaction: debug_interaction,
    lastMouseP: h.v2,
    hotInteraction: debug_interaction,
    hot: ?*debug_variable,
    interactingWith: ?*debug_variable,
    nextHotInteraction: debug_interaction,
    nextHot: ?*debug_variable,
    nextHotHierarchy: ?*debug_variable_hierarchy,

    draggingHierarchy: ?*debug_variable_hierarchy,

    leftEdge: f32,
    rightEdge: f32,
    atY: f32,
    fontScale: f32,
    fontID: h.font_id,
    globalWidth: f32,
    globalHeight: f32,

    scopeToRecord: ?*platform.debug_record,

    collateArena: h.memory_arena,
    collateTemp: h.temporary_memory,

    collationArrayIndex: u32,
    collationFrame: ?*debug_frame,
    frameBarLaneCount: u32,
    frameCount: u32,
    frameBarScale: f32,
    paused: bool,

    frames: []debug_frame,
    firstThread: ?*debug_thread,
    firstFreeBlock: ?*open_debug_block,
};

/// sum of all counters (timed  + named)
pub const debugRecordsCount = __COUNTER__() + 2; // TOOD (Manav), one on Start and another on End

pub const TIMED_FUNCTION = platform.TIMED_FUNCTION;
pub const TIMED_FUNCTION__impl = platform.TIMED_FUNCTION__impl;

pub const TIMED_BLOCK = platform.TIMED_BLOCK;
pub const TIMED_BLOCK__impl = platform.TIMED_BLOCK__impl;

/// The function definition is replaced with
/// ```
/// {
///     return #counter;
/// }
/// ```
/// where #counter is the total no. of <...>_impl callsites.
pub inline fn __COUNTER__() comptime_int
// AUTOGENERATED ----------------------------------------------------------
{
    return 45;
}
// AUTOGENERATED ----------------------------------------------------------

fn UpdateDebugRecords(debugState: *debug_state, counters: []platform.debug_record) void {
    for (0..counters.len) |counterIndex| {
        const source: *platform.debug_record = &counters[counterIndex];
        const dest: *debug_counter_state = &debugState.counterStates[debugState.counterCount];
        debugState.counterCount += 1;

        const hitCount_CycleCount: u64 = h.AtomicExchange(u64, @ptrCast(&source.counts), 0);
        const counts: platform.debug_record.packed_counts = @bitCast(hitCount_CycleCount);

        dest.fileName = source.fileName;
        dest.functionName = source.functionName;
        dest.lineNumber = source.lineNumber;
        dest.snapshots[debugState.snapshotIndex].hitCount = counts.hit;
        dest.snapshots[debugState.snapshotIndex].cycleCount = counts.cycle;
    }
}

// 5c0f - 小
// 8033 - 耳
// 6728 - 木
// 514e - 兎

inline fn DEBUGGetStateMem(memory: ?*platform.memory) ?*debug_state {
    if (memory) |_| {
        const debugState: *debug_state = @alignCast(@ptrCast(memory.?.debugStorage));
        platform.Assert(debugState.initialized);

        return debugState;
    } else {
        return null;
    }
}

inline fn DEBUGGetState() ?*debug_state {
    const result = DEBUGGetStateMem(platform.debugGlobalMemory);

    return result;
}

pub fn Start(assets: *h.game_assets, width: u32, height: u32) void {
    var block = TIMED_FUNCTION__impl(__COUNTER__(), @src()).Init(.{});
    defer block.End();

    if (@as(?*debug_state, @alignCast(@ptrCast(platform.debugGlobalMemory.?.debugStorage)))) |debugState| {
        if (!debugState.initialized) {
            debugState.hierarchySentinel.next = &debugState.hierarchySentinel;
            debugState.hierarchySentinel.prev = &debugState.hierarchySentinel;
            debugState.hierarchySentinel.group = undefined;

            debugState.highPriorityQueue = platform.debugGlobalMemory.?.highPriorityQueue;

            debugState.debugArena.Initialize(
                platform.debugGlobalMemory.?.debugStorageSize - @sizeOf(debug_state),
                @ptrCast(@as([*]debug_state, @ptrCast(debugState)) + 1),
            );

            var context = h.debug_variable_definition_context{
                .state = debugState,
                .arena = &debugState.debugArena,
                .group = null,
            };

            context.group = h.DEBUGBeginVariableGroup(&context, "Root");
            _ = h.DEBUGBeginVariableGroup(&context, "Debugging");

            h.DEBUGCreateVariables(&context);
            _ = h.DEBUGBeginVariableGroup(&context, "Profile");
            _ = h.DEBUGBeginVariableGroup(&context, "By Thread");
            const threadList = h.DEBUGAddVariable(&context, "", .counterThreadList, .{ .dimension = h.v2{ 1024, 100 } });
            _ = threadList;
            h.DEBUGEndVariableGroup(&context);
            _ = h.DEBUGBeginVariableGroup(&context, "By Function");
            const functionList = h.DEBUGAddVariable(&context, "", .counterThreadList, .{ .dimension = h.v2{ 1024, 200 } });
            _ = functionList;
            h.DEBUGEndVariableGroup(&context);
            h.DEBUGEndVariableGroup(&context);

            h.DEBUGEndVariableGroup(&context);

            debugState.rootGroup = context.group.?;

            debugState.renderGroup = h.render_group.Allocate(assets, &debugState.debugArena, platform.MegaBytes(16), false);

            debugState.paused = false;
            debugState.scopeToRecord = null;

            debugState.initialized = true;

            debugState.collateArena.SubArena(&debugState.debugArena, 4, platform.MegaBytes(32));
            debugState.collateTemp = h.BeginTemporaryMemory(&debugState.collateArena);

            RestartCollation(debugState, 0);

            _ = AddHierarchy(debugState, debugState.rootGroup, .{ -0.5 * @as(f32, @floatFromInt(width)), 0.5 * @as(f32, @floatFromInt(height)) });
        }

        h.BeginRender(debugState.renderGroup);
        debugState.debugFont = debugState.renderGroup.PushFont(debugState.fontID);
        debugState.debugFontInfo = debugState.renderGroup.assets.GetFontInfo(debugState.fontID);

        debugState.globalWidth = @floatFromInt(width);
        debugState.globalHeight = @floatFromInt(height);

        var matchVectorFont = h.asset_vector{};
        var weightVectorFont = h.asset_vector{};

        matchVectorFont.e[@intFromEnum(h.asset_tag_id.Tag_FontType)] = @floatFromInt(@as(i32, @intFromEnum(h.asset_font_type.FontType_Debug)));
        weightVectorFont.e[@intFromEnum(h.asset_tag_id.Tag_FontType)] = 1.0;

        debugState.fontID = h.GetBestMatchFontFrom(
            assets,
            .Asset_Font,
            &matchVectorFont,
            &weightVectorFont,
        );

        debugState.fontScale = 1;
        debugState.renderGroup.Orthographic(width, height, 1);
        debugState.leftEdge = -0.5 * @as(f32, @floatFromInt(width));
        debugState.rightEdge = 0.5 * @as(f32, @floatFromInt(width));

        debugState.atY = 0.5 * @as(f32, @floatFromInt(height));
    }
}

fn AddHierarchy(debugState: *debug_state, group: *debug_variable_reference, atP: h.v2) *debug_variable_hierarchy {
    var hierarchy: *debug_variable_hierarchy = debugState.debugArena.PushStruct(debug_variable_hierarchy);
    hierarchy.uiP = atP;
    hierarchy.group = group;
    hierarchy.next = debugState.hierarchySentinel.next;
    hierarchy.prev = &debugState.hierarchySentinel;

    hierarchy.next.prev = hierarchy;
    hierarchy.prev.next = hierarchy;

    return hierarchy;
}

inline fn IsHex(char: u8) bool {
    const result = (((char >= '0') and (char <= '9')) or ((char >= 'A') and (char <= 'F')));

    return result;
}

inline fn GetHex(char: u8) u32 {
    var result: u32 = 0;

    if ((char >= '0') and (char <= '9')) {
        result = char - '0';
    } else if ((char >= 'A') and (char <= 'F')) {
        result = 0xA + (char - 'A');
    }

    return result;
}

/// `colour = .{ 1, 1, 1, 1 }` by default
fn DEBUGTextOp(debugState: ?*debug_state, op: debug_text_op, p: h.v2, string: []const u8, colour_: h.v4) h.rect2 {
    var result: h.rect2 = h.rect2.InvertedInfinity();

    var colour = colour_;

    if (debugState) |_| {
        if (debugState.?.debugFont) |font| {
            const renderGroup: *h.render_group = debugState.?.renderGroup;
            const info: *h.hha_font = debugState.?.debugFontInfo;

            var prevCodePoint: u32 = 0;
            var charScale = debugState.?.fontScale;
            const atY: f32 = h.Y(p);
            var atX: f32 = h.X(p);

            var at: [*]const u8 = string.ptr;
            while (at[0] != 0) {
                if (at[0] == '\\' and at[1] == '#' and at[2] != 0 and at[3] != 0 and at[4] != 0) {
                    const cScale = 1.0 / 9.0;
                    colour = h.ClampV401(h.v4{
                        h.Clampf01(cScale * @as(f32, @floatFromInt(at[2] - '0'))),
                        h.Clampf01(cScale * @as(f32, @floatFromInt(at[3] - '0'))),
                        h.Clampf01(cScale * @as(f32, @floatFromInt(at[4] - '0'))),
                        1,
                    });
                    at += 5;
                } else if (at[0] == '\\' and at[1] == '^' and at[2] != 0) {
                    const cScale = 1.0 / 9.0;
                    charScale = debugState.?.fontScale * h.Clampf01(cScale * @as(f32, @floatFromInt(at[2] - '0')));
                    at += 3;
                } else {
                    var codePoint: u32 = at[0];

                    if ((at[0] == '\\') and
                        (IsHex(at[1])) and
                        (IsHex(at[2])) and
                        (IsHex(at[3])) and
                        (IsHex(at[4])))
                    {
                        codePoint = ((GetHex(at[1]) << 12) |
                            (GetHex(at[2]) << 8) |
                            (GetHex(at[3]) << 4) |
                            (GetHex(at[4]) << 0));

                        at += 4;
                    }

                    const advanceX: f32 = charScale * h.GetHorizontalAdvanceForPair(info, font, prevCodePoint, codePoint);
                    atX += advanceX;

                    // NOTE (Manav): this can have issues with handling newlines or other special characters.
                    if (codePoint != ' ') {
                        const bitmapID = h.GetBitmapForGlyph(renderGroup.assets, info, font, codePoint);
                        const info_ = renderGroup.assets.GetBitmapInfo(bitmapID);

                        const bitmapScale = charScale * @as(f32, @floatFromInt(info_.dim[1]));
                        const bitmapOffset: h.v3 = .{ atX, atY, 0 };

                        switch (op) {
                            .DEBUGTextOp_DrawText => renderGroup.PushBitmap2(bitmapID, bitmapScale, bitmapOffset, colour),
                            .DEBUGTextOp_SizeText => {
                                if (renderGroup.assets.GetBitmap(bitmapID, renderGroup.generationID)) |bitmap| {
                                    const dim = h.GetBitmapDim(renderGroup, bitmap, bitmapScale, bitmapOffset);
                                    const glyphDim = h.rect2.InitMinDim(h.XY(dim.p), dim.size);

                                    result = h.rect2.Union(result, glyphDim);
                                }
                            },
                        }
                    }

                    prevCodePoint = @intCast(codePoint);

                    at += 1;
                }
            }
        }
    }

    return result;
}

/// `colour = .{ 1, 1, 1, 1 }` by default
fn DEBUGTextOutAt(p: h.v2, string: []const u8, colour: h.v4) void {
    if (DEBUGGetState()) |debugState| {
        const renderGroup: *h.render_group = debugState.renderGroup;
        _ = renderGroup;

        _ = DEBUGTextOp(debugState, .DEBUGTextOp_DrawText, p, string, colour);
    }
}

fn DEBUGGetTextSize(debugState: *debug_state, string: []const u8) h.rect2 {
    const result: h.rect2 = DEBUGTextOp(debugState, .DEBUGTextOp_SizeText, .{ 0, 0 }, string, .{ 1, 1, 1, 1 });

    return result;
}

fn DEBUGTextLine(string: []const u8) void {
    if (DEBUGGetState()) |debugState| {
        const renderGroup: *h.render_group = debugState.renderGroup;
        if (renderGroup.PushFont(debugState.fontID)) |_| {
            const info = renderGroup.assets.GetFontInfo(debugState.fontID);

            DEBUGTextOutAt(.{
                debugState.leftEdge,
                debugState.atY - debugState.fontScale * h.GetStartingBaselineY(debugState.debugFontInfo),
            }, string, .{ 1, 1, 1, 1 });

            debugState.atY -= h.GetLineAdvanceFor(info) * debugState.fontScale;
        }
    }
}

const debug_statistic = struct {
    min: f64,
    max: f64,
    avg: f64,
    count: u32,

    const Self = @This();

    fn BeginDebugStatistic(stat: *Self) void {
        stat.min = platform.F32MAXIMUM;
        stat.max = -platform.F32MAXIMUM;
        stat.avg = 0;
        stat.count = 0;
    }

    fn EndDebugStatistic(stat: *Self) void {
        if (stat.count != 0) {
            stat.avg /= @floatFromInt(stat.count);
        } else {
            stat.min = 0;
            stat.max = 0;
        }
    }

    fn AccumDebugStatistic(stat: *Self, value: f64) void {
        stat.count += 1;
        if (stat.min > value) {
            stat.min = value;
        }

        if (stat.max < value) {
            stat.max = value;
        }

        stat.avg += value;
    }
};

// pub const DEBUGUI_UseDebugCamera = true;
// pub const DEBUGUI_GroundChunkOutlines = true;
// pub const DEBUGUI_ParticleTest = true;
// pub const DEBUGUI_ParticleGrid = true;
// pub const DEBUGUI_UseSpaceOutlines = true;
// pub const DEBUGUI_GroundChunkCheckerboards = true;
// pub const DEBUGUI_RecomputeGroundChunksOnExeChange = true;
// pub const DEBUGUI_TestWeirdDrawBufferSize = true;
// pub const DEBUGUI_FamiliarFollowsHero = true;
// pub const DEBUGUI_ShowLightingSamples = true;
// pub const DEBUGUI_UseRoomBasedCamera = true;

fn VariableToText(buffer: []u8, variable: *debug_variable, flags: debug_variable_to_text_flag) u32 {
    var written: u32 = 0;

    if (flags.Prefix) {
        written += @intCast((std.fmt.bufPrint(buffer[written..], "pub const DEBUGUI_", .{}) catch |err| {
            std.debug.print("{}\n", .{err});
            return 0;
        }).len);
    }

    if (flags.Name) {
        written += @intCast((std.fmt.bufPrint(buffer[written..], "{s}", .{
            variable.name,
        }) catch |err| {
            std.debug.print("{}\n", .{err});
            return 0;
        }).len);
    }

    if (flags.Colon) {
        written += @intCast((std.fmt.bufPrint(buffer[written..], ": ", .{}) catch |err| {
            std.debug.print("{}\n", .{err});
            return 0;
        }).len);
    }

    if (flags.TypeSuffix) {
        written += @intCast((std.fmt.bufPrint(buffer[written..], "{s} = ", .{
            @tagName(variable.type),
        }) catch |err| {
            std.debug.print("{}\n", .{err});
            return 0;
        }).len);
    }

    switch (variable.type) {
        .bool => {
            const memory = std.fmt.bufPrint(buffer[written..], "{}", .{
                variable.value.bool,
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .i32 => {
            const memory = std.fmt.bufPrint(buffer[written..], "{}", .{
                variable.value.i32,
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .u32 => {
            const memory = std.fmt.bufPrint(buffer[written..], "{}", .{
                variable.value.u32,
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .f32 => {
            const memory = std.fmt.bufPrint(buffer[written..], "{d}", .{
                variable.value.f32,
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .v2 => {
            const memory = std.fmt.bufPrint(buffer[written..], "v2{{ {d}, {d} }}", .{
                h.X(variable.value.v2),
                h.Y(variable.value.v2),
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .v3 => {
            const memory = std.fmt.bufPrint(buffer[written..], "v3{{ {d}, {d}, {d} }}", .{
                h.X(variable.value.v3),
                h.Y(variable.value.v3),
                h.Z(variable.value.v3),
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .v4 => {
            const memory = std.fmt.bufPrint(buffer[written..], "v4{{ {d}, {d}, {d}, {d} }}", .{
                h.X(variable.value.v4),
                h.Y(variable.value.v4),
                h.Z(variable.value.v4),
                h.W(variable.value.v4),
            }) catch |err| {
                std.debug.print("{}\n", .{err});
                return 0;
            };

            written += @intCast(memory.len);
        },
        .group => {},
        else => platform.InvalidCodePath("Unaccounted type."),
    }

    if (flags.LineFeedEnd) {
        written += @intCast((std.fmt.bufPrint(buffer[written..], ";\n", .{}) catch |err| {
            std.debug.print("{}\n", .{err});
            return 0;
        }).len);
    }

    if (flags.NullTerminate) {
        buffer[written] = 0;
        written += 1;
    }

    return written;
}

fn WriteHandmadeConfig(debugState: *debug_state) void {
    var temp = [1]u8{0} ** 4096;
    var written: u32 = 0;

    var depth: i32 = 0;
    var ref: ?*debug_variable_reference = debugState.rootGroup.variable.value.group.firstChild;

    const include = "const math = @import(\"handmade_math.zig\");\nconst v2 = math.v2;\nconst v3 = math.v3;\nconst v4 = math.v4;\n\n";

    written += @intCast((std.fmt.bufPrint(temp[written..], "{s}", .{include}) catch |err| {
        std.debug.print("{}\n", .{err});
        return;
    }).len);

    while (ref) |_| {
        const variable = ref.?.variable;
        if (ShouldBeWritten(variable.type)) {
            var index: i32 = 0;
            while (index < depth) : (index += 1) {
                temp[written] = '\t';
                written += 1;
            }

            if (variable.type == .group) {
                written += @intCast((std.fmt.bufPrint(temp[written..], "// ", .{}) catch |err| {
                    std.debug.print("{}\n", .{err});
                    return;
                }).len);
            }

            written += VariableToText(temp[written..], variable, .{
                .Prefix = true,
                .Name = true,
                .Colon = true,
                .TypeSuffix = true,
                .LineFeedEnd = true,
            });
        }

        if (variable.type == .group) {
            ref = variable.value.group.firstChild;
            depth += 1;
        } else {
            while (ref) |_| {
                if (ref.?.next) |_| {
                    ref = ref.?.next;
                    break;
                } else {
                    ref = ref.?.parent;
                    depth -= 1;
                }
            }
        }
    }

    {
        // TODO (Manav): remove duplicate declarations.
    }

    _ = h.platformAPI.DEBUGWriteEntireFile("../code/handmade/handmade_config.zig", written, temp[0..written].ptr);

    if (!debugState.compiling) {
        // NOTE (Manav): compilation is incredibly slow, wait for incremental compilation support (use -fincremental) in 0.14
        const commandline = "/C zig build lib -p build -Dself_compilation=true -Doptimize=" ++ switch (@import("builtin").mode) {
            .Debug => "Debug",
            .ReleaseFast => "ReleaseFast",
            .ReleaseSafe => "ReleaseSafe",
            .ReleaseSmall => "ReleaseSmall",
        };

        debugState.compiling = true;
        debugState.compiler = h.platformAPI.DEBUGExecuteSystemCommand("..\\", "c:\\windows\\system32\\cmd.exe", commandline);
    }
}

fn DrawProfileIn(debugState: *debug_state, profileRect: h.rect2, mouseP: h.v2) void {
    debugState.renderGroup.PushRect2(profileRect, 0, .{ 0, 0, 0, 0.25 });

    var laneHeight: f32 = 20.0;
    const laneCount: f32 = @floatFromInt(debugState.frameBarLaneCount);

    const barSpacing = 4.0;
    var maxFrame = debugState.frameCount;
    if (maxFrame > 10) {
        maxFrame = 10;
    }

    if (laneCount > 0 and maxFrame > 0) {
        const pixelsPerFramePlusSpacing = h.Y(profileRect.GetDim()) / @as(f32, @floatFromInt(maxFrame));
        const pixelsPerFrame = pixelsPerFramePlusSpacing - barSpacing;
        laneHeight = pixelsPerFrame / laneCount;
    }

    const barHeight = laneHeight * laneCount;
    const barPlusSpacing = barHeight + barSpacing;
    const chartLeft = h.X(profileRect.min);
    const chartHeight = barPlusSpacing * @as(f32, @floatFromInt(maxFrame));
    _ = chartHeight;
    const chartWidth = h.X(profileRect.GetDim());
    const chartTop = h.Y(profileRect.max);
    const scale = chartWidth * debugState.frameBarScale;

    const colours = [_]h.v3{
        .{ 1, 0, 0 },
        .{ 0, 1, 0 },
        .{ 0, 0, 1 },
        .{ 1, 1, 0 },
        .{ 0, 1, 1 },
        .{ 1, 0, 1 },
        .{ 1, 0.5, 0 },
        .{ 1, 0, 0.5 },
        .{ 0.5, 1, 0 },
        .{ 0, 1, 0.5 },
        .{ 0.5, 0, 1 },
        .{ 0, 0.5, 1 },
    };

    for (0..maxFrame) |frameIndex| {
        const frame: *debug_frame = &debugState.frames[debugState.frameCount - (frameIndex + 1)];

        const stackX: f32 = chartLeft;
        const stackY: f32 = chartTop - @as(f32, @floatFromInt(frameIndex)) * barPlusSpacing;

        for (0..frame.regionCount) |regionIndex| {
            const region: *debug_frame_region = &frame.regions[regionIndex];

            // const colour = colours[regionIndex % colours.len];
            const colour = colours[region.colourIndex % colours.len];
            const thisMinX = stackX + scale * region.minT;
            const thisMaxX = stackX + scale * region.maxT;
            const regionRect = h.rect2.InitMinMax(
                .{ thisMinX, stackY - laneHeight * @as(f32, @floatFromInt(region.laneIndex + 1)) },
                .{ thisMaxX, stackY - laneHeight * @as(f32, @floatFromInt(region.laneIndex)) },
            );
            debugState.renderGroup.PushRect2(regionRect, 0, h.ToV4(colour, 1));

            if (regionRect.IsInRect(mouseP)) {
                const record: *platform.debug_record = region.record;

                var textBuffer = [1]u8{0} ** 256;
                const buffer = std.fmt.bufPrint(textBuffer[0..], "{s}: {:10}cy [{s}({d})]\n", .{
                    record.blockName.?,
                    region.cycleCount,
                    record.fileName.?,
                    record.lineNumber,
                }) catch |err| {
                    std.debug.print("{}\n", .{err});
                    return;
                };

                DEBUGTextOutAt(h.Add(mouseP, .{ 0, 10 }), buffer, .{ 1, 1, 1, 1 });

                // hotRecord = record;
            }
        }
    }

    // renderGroup.PushRect(
    //     .{ chartLeft + 0.5 * chartWidth, chartMinY + chartHeight, 0 },
    //     .{ chartWidth, 1 },
    //     .{ 1, 1, 1, 1 },
    // );

}

fn DEBUGDrawMainMenu(debugState: *debug_state, _: *h.render_group, mouseP: h.v2) void {
    var hierarchy = debugState.hierarchySentinel.next;
    while (hierarchy != &debugState.hierarchySentinel) : (hierarchy = hierarchy.next) {
        const atX: f32 = h.X(hierarchy.uiP);
        var atY: f32 = h.Y(hierarchy.uiP);
        const lineAdvance: f32 = debugState.fontScale * h.GetLineAdvanceFor(debugState.debugFontInfo);

        const spacingY = 4.0;
        var depth: i32 = 0;
        var ref: ?*debug_variable_reference = hierarchy.group.variable.value.group.firstChild;
        while (ref) |_| {
            const variable = ref.?.variable;
            const isHot = debugState.hot == variable;
            const itemColour: h.v4 = if (isHot and debugState.hotInteraction == .None) .{ 1, 1, 0, 1 } else .{ 1, 1, 1, 1 };

            var bounds = h.rect2{};
            switch (variable.type) {
                .counterThreadList => {
                    const minCorner = h.v2{ atX + @as(f32, @floatFromInt(depth)) * 2 * lineAdvance, atY - h.Y(variable.value.profile.dimension) };
                    const maxCorner = h.v2{ h.X(minCorner) + h.X(variable.value.profile.dimension), atY };
                    const sizeP = h.v2{ h.X(maxCorner), h.Y(minCorner) };
                    bounds = h.rect2.InitMinMax(minCorner, maxCorner);
                    DrawProfileIn(debugState, bounds, mouseP);

                    const sizeBox = h.rect2.InitCenterHalfDim(sizeP, .{ 4, 4 });
                    debugState.renderGroup.PushRect2(
                        sizeBox,
                        0,
                        if (isHot and debugState.hotInteraction == .ResizeProfile) .{ 1, 1, 0, 1 } else .{ 1, 1, 1, 1 },
                    );

                    if (sizeBox.IsInRect(mouseP)) {
                        debugState.nextHotInteraction = .ResizeProfile;
                        debugState.nextHot = variable;
                    } else if (bounds.IsInRect(mouseP)) {
                        debugState.nextHotInteraction = .None;
                        debugState.nextHot = variable;
                    }

                    // bounds.min.y -= spaceingY;
                    h.SetY(&bounds.min, h.Y(bounds.min) - spacingY);
                },
                else => {
                    var text = [1]u8{0} ** 256;

                    _ = VariableToText(text[0..], variable, .{
                        .Name = true,
                        .Colon = true,
                    });

                    const leftPx = atX + @as(f32, @floatFromInt(depth)) * 2 * lineAdvance;
                    const topPy = atY;

                    const textBounds: h.rect2 = DEBUGGetTextSize(debugState, text[0..]);

                    bounds = h.rect2.InitMinMax(.{ leftPx + h.X(textBounds.min), topPy - lineAdvance }, .{ leftPx + h.X(textBounds.max), topPy });

                    DEBUGTextOutAt(.{ leftPx, topPy - debugState.fontScale * h.GetStartingBaselineY(debugState.debugFontInfo) }, text[0..], itemColour);

                    if (bounds.IsInRect(mouseP)) {
                        debugState.nextHotInteraction = .None;
                        debugState.nextHot = variable;
                    }
                },
            }

            atY = h.Y(bounds.GetMinCorner());

            if (variable.type == .group and variable.value.group.expanded) {
                ref = variable.value.group.firstChild;
                depth += 1;
            } else {
                while (ref) |_| {
                    if (ref.?.next) |_| {
                        ref = ref.?.next;
                        break;
                    } else {
                        ref = ref.?.parent;
                        depth -= 1;
                    }
                }
            }
        }

        debugState.atY = atY;

        if (true) {
            const moveBox = h.rect2.InitCenterHalfDim(h.Sub(hierarchy.uiP, .{ 4, -4 }), .{ 4, 4 });
            debugState.renderGroup.PushRect2(moveBox, 0, .{ 1, 1, 1, 1 });

            if (moveBox.IsInRect(mouseP)) {
                debugState.nextHotInteraction = .MoveHierarchy;
                debugState.nextHotHierarchy = hierarchy;
            }
        }
    }

    if (ignore) {
        var newHotMenuIndex: u32 = h.debugVariableList.len;
        var bestDistanceSq: f32 = platform.F32MAXIMUM;

        const menuRadius = 400.0;
        const angleStep: f32 = platform.Tau32 / @as(f32, @floatFromInt(h.debugVariableList.len));
        for (0..h.debugVariableList.len) |menuItemIndex| {
            const debugVar = h.debugVariableList[menuItemIndex];
            const text = debugVar.name;

            var itemColour: h.v4 = if (debugVar.value) .{ 1, 1, 1, 1 } else .{ 0.5, 0.5, 0.5, 1 };
            if (menuItemIndex == debugState.hotMenuIndex) {
                itemColour = .{ 1, 1, 0, 1 };
            }
            const angle = @as(f32, @floatFromInt(menuItemIndex)) * angleStep;

            // const textP: h.v2 = debugState.menuP + menuRadius * h.Arm2(angle);
            const textP: h.v2 = h.Add(debugState.menuP, h.Scale(h.Arm2(angle), menuRadius));

            const thisDistanceSq = h.LengthSq(h.Sub(textP, mouseP));
            if (bestDistanceSq > thisDistanceSq) {
                newHotMenuIndex = @intCast(menuItemIndex);
                bestDistanceSq = thisDistanceSq;
            }

            const textBounds: h.rect2 = DEBUGGetTextSize(debugState, text);
            DEBUGTextOutAt(h.Sub(textP, h.Scale(textBounds.GetDim(), 0.5)), text, itemColour);
        }

        if (h.LengthSq(h.Sub(mouseP, debugState.menuP)) > h.Square(menuRadius)) {
            debugState.hotMenuIndex = newHotMenuIndex;
        } else {
            debugState.hotMenuIndex = h.debugVariableList.len;
        }
    }
}

fn BeginInteract(debugState: *debug_state, _: *platform.input, _: h.v2, altUI: bool) void {
    if (debugState.hotInteraction != .None) {
        debugState.interaction = debugState.hotInteraction;
    } else {
        if (debugState.hot) |hotVariable| {
            if (altUI) {
                debugState.interaction = .TearValue;
            } else {
                switch (hotVariable.type) {
                    .bool => {
                        debugState.interaction = .ToggleValue;
                    },
                    .f32 => {
                        debugState.interaction = .DragValue;
                    },
                    .group => {
                        debugState.interaction = .ToggleValue;
                    },
                    else => {},
                }
            }

            if (debugState.interaction != .None) {
                debugState.interactingWith = debugState.hot;
            }
        } else {
            debugState.interaction = .NOP;
        }
    }
}

fn EndInteract(debugState: *debug_state, _: *platform.input, _: h.v2) void {
    if (debugState.interaction != .NOP) {
        // NOTE (Manav): debugState.interactingWith can be null .NOP
        switch (debugState.interaction) {
            .ToggleValue => {
                var variable = debugState.interactingWith.?;
                switch (variable.type) {
                    .bool => {
                        variable.value.bool = !variable.value.bool;
                    },
                    .group => {
                        variable.value.group.expanded = !variable.value.group.expanded;
                    },
                    else => {},
                }
            },

            else => {},
        }

        WriteHandmadeConfig(debugState);
    }

    debugState.interaction = .None;
    debugState.interactingWith = null;
    debugState.draggingHierarchy = null;
}

fn Interact(debugState: *debug_state, input: *platform.input, mouseP: h.v2) void {
    const dMouseP: h.v2 = h.Sub(mouseP, debugState.lastMouseP);

    // if (input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Right)].endedDown > 0) {
    //     if (input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Right)].halfTransitionCount > 0) {
    //         debugState.menuP = mouseP;
    //     }
    //     DrawDebugMainMenu(debugState, renderGroup, mouseP);
    // } else if (input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Right)].halfTransitionCount > 0)

    if (debugState.interaction != .None) {
        // Mouse move interaction
        var variable: ?*debug_variable = debugState.interactingWith; // NOTE (Manav): variable can be null with .NOP

        switch (debugState.interaction) {
            .DragValue => {
                switch (variable.?.type) {
                    .f32 => {
                        variable.?.value.f32 += 0.1 * h.Y(dMouseP);
                    },

                    else => {},
                }
            },
            .ResizeProfile => {
                if (variable != null) { // NOTE (Manav): variable can be null with .ResizeProfile when it's in a hierarchy
                    // variable.value.profile.dimension += .{ dMouseP.x, -dMouseP.y };
                    h.AddTo(&variable.?.value.profile.dimension, .{ h.X(dMouseP), -h.Y(dMouseP) });
                    // variable.value.profile.dimension.x = @max(variable.value.profile.dimension.x, 10.0);
                    h.SetX(&variable.?.value.profile.dimension, @max(h.X(variable.?.value.profile.dimension), 10.0));
                    // variable.value.profile.dimension.y = @max(variable.value.profile.dimension.y, 10.0);
                    h.SetY(&variable.?.value.profile.dimension, @max(h.Y(variable.?.value.profile.dimension), 10.0));
                }
            },
            .MoveHierarchy => {
                // debugState.draggingHierarchy.uiP += .{ dMouseP.x, dMouseP.y };
                h.AddTo(&debugState.draggingHierarchy.?.uiP, .{ h.X(dMouseP), h.Y(dMouseP) });
            },
            .TearValue => {
                if (debugState.draggingHierarchy == null) {
                    const rootGroup: *debug_variable_reference = h.DEBUGAddRootGroup(debugState, "NewUserGroup");
                    _ = h.DEBUGAddVariableReference__(debugState, rootGroup, debugState.interactingWith.?);
                    debugState.draggingHierarchy = AddHierarchy(debugState, rootGroup, .{ 0, 0 });
                }

                debugState.draggingHierarchy.?.uiP = mouseP;
            },
            else => {},
        }

        const altUI = input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Right)].endedDown != 0;

        // Mouse click interaction
        var transitionIndex = input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Left)].halfTransitionCount;
        while (transitionIndex > 1) : (transitionIndex -= 1) {
            EndInteract(debugState, input, mouseP);
            BeginInteract(debugState, input, mouseP, altUI);
        }

        if (input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Left)].endedDown == 0) {
            EndInteract(debugState, input, mouseP);
        }
    } else {
        debugState.hot = debugState.nextHot;
        debugState.hotInteraction = debugState.nextHotInteraction;
        debugState.draggingHierarchy = debugState.nextHotHierarchy;

        const altUI = input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Right)].endedDown != 0;

        var transitionIndex = input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Left)].halfTransitionCount;
        while (transitionIndex > 1) : (transitionIndex -= 1) {
            BeginInteract(debugState, input, mouseP, altUI);
            EndInteract(debugState, input, mouseP);
        }

        if (input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Left)].endedDown != 0) {
            BeginInteract(debugState, input, mouseP, altUI);
        }
    }

    if (platform.ignore) {
        if (platform.WasPressed(&input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Left)])) {
            if (debugState.hotVariable) |hotVariable| {
                switch (hotVariable.type) {
                    .bool => {
                        debugState.hotVariable.?.value.bool = !debugState.hotVariable.?.value.bool;
                    },
                    .group => {
                        debugState.hotVariable.?.value.group.expanded = !debugState.hotVariable.?.value.group.expanded;
                    },
                    else => {},
                }
            }

            WriteHandmadeConfig(debugState);
        }
    }

    debugState.lastMouseP = mouseP;
}

pub fn End(input: *platform.input, drawBuffer: *h.loaded_bitmap) void {
    TIMED_FUNCTION(.{});
    var block = TIMED_FUNCTION__impl(__COUNTER__() + 1, @src()).Init(.{});
    defer block.End();

    if (DEBUGGetState()) |debugState| {
        const renderGroup: *h.render_group = debugState.renderGroup;

        debugState.nextHot = null;
        debugState.nextHotHierarchy = null;
        debugState.nextHotInteraction = .None;
        const hotRecord: ?*platform.debug_record = null;

        const mouseP: h.v2 = h.V2(input.mouseX, input.mouseY);

        DEBUGDrawMainMenu(debugState, renderGroup, mouseP);
        Interact(debugState, input, mouseP);

        if (debugState.compiling) {
            const state = h.platformAPI.DEBUGGetProcessState(debugState.compiler);
            if (state.isRunning) {
                DEBUGTextLine("Compiling...");
            } else {
                debugState.compiling = false;
            }
        }

        const info = debugState.debugFontInfo;
        if (debugState.debugFont) |_| {
            if (platform.ignore) {
                for (0..debugState.counterCount) |counterIndex| {
                    const counter = &debugState.counterStates[counterIndex];

                    var hitCount: debug_statistic = undefined;
                    var cycleCount: debug_statistic = undefined;
                    var cycleOverHit: debug_statistic = undefined;

                    hitCount.BeginDebugStatistic();
                    cycleCount.BeginDebugStatistic();
                    cycleOverHit.BeginDebugStatistic();

                    for (counter.snapshots) |snapshot| {
                        const cycles: u32 = @truncate(snapshot.cycleCount);
                        hitCount.AccumDebugStatistic(@floatFromInt(snapshot.hitCount));
                        cycleCount.AccumDebugStatistic(@floatFromInt(cycles));

                        var coh: f64 = 0;
                        if (snapshot.hitCount != 0) {
                            coh = @as(f64, @floatFromInt(snapshot.cycleCount)) / @as(f64, @floatFromInt(snapshot.hitCount));
                        }
                        cycleOverHit.AccumDebugStatistic(coh);
                    }

                    hitCount.EndDebugStatistic();
                    cycleCount.EndDebugStatistic();
                    cycleOverHit.EndDebugStatistic();

                    if (counter.blockName) |blockName| {
                        if (cycleCount.max > 0) {
                            const barWidth = 4;
                            const chartLeft = 0;
                            const chartMinY = debugState.atY;
                            const chartHeight = info.ascenderHeight * debugState.fontScale;

                            const scale: f32 = @floatCast(1 / cycleCount.max);
                            for (0..counter.snapshots.len) |snapshotIndex| {
                                const thisProportion = scale * @as(f32, @floatFromInt(counter.snapshots[snapshotIndex].cycleCount));
                                const thisHeight = chartHeight * thisProportion;
                                renderGroup.PushRect(
                                    .{ chartLeft + @as(f32, @floatFromInt(snapshotIndex)) * barWidth + 0.5 * barWidth, chartMinY + 0.5 * thisHeight, 0 },
                                    .{ barWidth, thisHeight },
                                    .{ thisProportion, 1, 0, 1 },
                                );
                            }
                        }

                        if (!platform.ignore) {
                            var textBuffer = [1]u8{0} ** 256;
                            const buffer = std.fmt.bufPrint(textBuffer[0..], "{s:32}({:4}) - {:10}cy {:8}h {:10}cy/h\n", .{
                                blockName,
                                counter.lineNumber,
                                @as(u32, @intFromFloat(cycleCount.avg)),
                                @as(u32, @intFromFloat(hitCount.avg)),
                                @as(u32, @intFromFloat(cycleOverHit.avg)),
                            }) catch |err| {
                                std.debug.print("{}\n", .{err});
                                return;
                            };

                            DEBUGTextLine(buffer);
                        }
                    }
                }
            }

            if (debugState.frameCount != 0) {
                var textBuffer = [1]u8{0} ** 256;
                const buffer = std.fmt.bufPrint(textBuffer[0..], "Last Frame Time: {d:5.2}ms\n", .{
                    debugState.frames[debugState.frameCount - 1].wallSecondsElapsed * 1000,
                }) catch |err| {
                    std.debug.print("{}\n", .{err});
                    return;
                };

                DEBUGTextLine(buffer);
            }
        }
        if (platform.WasPressed(&input.mouseButtons[@intFromEnum(platform.input_mouse_button.PlatformMouseButton_Left)])) {
            if (hotRecord) |_| {
                debugState.scopeToRecord = hotRecord;
            } else {
                debugState.scopeToRecord = null;
            }
            RefreshCollation(debugState);
        }

        renderGroup.TiledRenderGroupToOutput(debugState.highPriorityQueue, drawBuffer);
        h.EndRender(renderGroup);
    }
}

inline fn GetLaneFromThreadIndex(debugState: *debug_state, threadIndex: u32) u32 {
    const result: u32 = 0;

    _ = debugState;
    _ = threadIndex;

    return result;
}

fn GetDebugThread(debugState: *debug_state, threadID: u32) *debug_thread {
    var result: ?*debug_thread = null;
    var thread = debugState.firstThread;
    while (thread != null) : (thread = thread.?.next) {
        if (thread.?.id == threadID) {
            result = thread;
            break;
        }
    }

    if (result == null) {
        result = debugState.collateArena.PushStruct(debug_thread);
        result.?.id = threadID;
        result.?.laneIndex = debugState.frameBarLaneCount;
        debugState.frameBarLaneCount += 1;
        result.?.firstOpenBlock = null;
        result.?.next = debugState.firstThread;
        debugState.firstThread = result;
    }

    return result.?;
}

fn AddRegion(_: *debug_state, currentFrame: *debug_frame) *debug_frame_region {
    platform.Assert(currentFrame.regionCount < MAX_REGIONS_PER_FRAME);
    const result: *debug_frame_region = &currentFrame.regions[currentFrame.regionCount];
    currentFrame.regionCount += 1;

    return result;
}

fn StringsAreEqual(strA: [*:0]const u8, strB: [*:0]const u8) bool {
    var a = strA;
    var b = strB;

    while ((a[0] != 0 and b[0] != 0) and (a[0] == b[0])) {
        a += 1;
        b += 1;
    }

    const result = a[0] == 0 and b[0] == 0;

    return result;
}

fn RestartCollation(debugState: *debug_state, invalidArrayIndex: u32) void {
    h.EndTemporaryMemory(debugState.collateTemp);
    debugState.collateTemp = h.BeginTemporaryMemory(&debugState.collateArena);

    debugState.firstThread = null;
    debugState.firstFreeBlock = null;

    debugState.frames = debugState.collateArena.PushSlice(debug_frame, platform.MAX_DEBUG_EVENT_ARRAY_COUNT * 4);
    debugState.frameBarLaneCount = 0;
    debugState.frameCount = 0;
    debugState.frameBarScale = 1.0 / 60000000.0;

    debugState.collationArrayIndex = invalidArrayIndex + 1;
    debugState.collationFrame = null;
}

inline fn GetRecordFrom(block: ?*open_debug_block) ?*platform.debug_record {
    const result = if (block) |_| block.?.source else null;

    return result;
}

fn CollateDebugRecords(debugState: *debug_state, invalidArrayIndex: u32) void {
    while (true) : (debugState.collationArrayIndex += 1) {
        if (debugState.collationArrayIndex == platform.MAX_DEBUG_EVENT_ARRAY_COUNT) {
            debugState.collationArrayIndex = 0;
        }
        const eventArrayIndex = debugState.collationArrayIndex;

        if (eventArrayIndex == invalidArrayIndex) {
            break;
        }

        for (0..platform.globalDebugTable.eventCount[eventArrayIndex]) |eventIndex| {
            const event: *platform.debug_event = &platform.globalDebugTable.events[eventArrayIndex][eventIndex];
            const source: *platform.debug_record = &platform.globalDebugTable.records[event.translationUnit][event.debugRecordIndex];

            if (event.eventType == .DebugEvent_FrameMarker) {
                if (debugState.collationFrame) |_| {
                    debugState.collationFrame.?.endClock = event.clock;
                    debugState.collationFrame.?.wallSecondsElapsed = event.data.secondsElapsed;
                    debugState.frameCount += 1; // NOTE (Manav): this can increase beyond the debugState.frames.len

                    // const clockRange: f32 = @floatFromInt(debugState.collationFrame.?.endClock - debugState.collationFrame.?.beginClock);

                    // if (clockRange > 0) {
                    //     const frameBarScale = 1 / clockRange;
                    //     if (debugState.frameBarScale > frameBarScale) {
                    //         debugState.frameBarScale = frameBarScale;
                    //     }
                    // }
                }

                debugState.collationFrame = &debugState.frames[debugState.frameCount];
                debugState.collationFrame.?.beginClock = event.clock;
                debugState.collationFrame.?.endClock = 0;
                debugState.collationFrame.?.regionCount = 0;
                debugState.collationFrame.?.regions = debugState.collateArena.PushSlice(debug_frame_region, MAX_REGIONS_PER_FRAME);
                debugState.collationFrame.?.wallSecondsElapsed = 0;
            } else if (debugState.collationFrame) |_| {
                const frameIndex: u32 = debugState.frameCount -% 1; // TODO (Manav): ignore this for now.
                const thread: *debug_thread = GetDebugThread(debugState, event.data.tc.threadID);
                const relativeClock = event.clock -% debugState.collationFrame.?.beginClock;
                _ = relativeClock;

                if (StringsAreEqual("DrawRectangle", source.blockName.?)) {
                    // @breakpoint();
                }

                if (event.eventType == .DebugEvent_BeginBlock) {
                    var debugBlock = debugState.firstFreeBlock;
                    if (debugBlock) |_| {
                        debugState.firstFreeBlock = debugBlock.?.nextFree;
                    } else {
                        debugBlock = debugState.collateArena.PushStruct(open_debug_block);
                    }

                    debugBlock.?.startingFrameIndex = frameIndex;
                    debugBlock.?.openingEvent = event;
                    debugBlock.?.parent = thread.firstOpenBlock;
                    debugBlock.?.source = source;
                    thread.firstOpenBlock = debugBlock;
                    debugBlock.?.nextFree = null;
                } else if (event.eventType == .DebugEvent_EndBlock) {
                    if (thread.firstOpenBlock) |_| {
                        const matchingBlock: *open_debug_block = thread.firstOpenBlock.?;
                        const openingEvent: *platform.debug_event = matchingBlock.openingEvent;
                        if (openingEvent.data.tc.threadID == event.data.tc.threadID and
                            openingEvent.debugRecordIndex == event.debugRecordIndex and
                            openingEvent.translationUnit == event.translationUnit)
                        {
                            if (matchingBlock.startingFrameIndex == frameIndex) {
                                if (GetRecordFrom(matchingBlock.parent) == debugState.scopeToRecord) {
                                    const minT: f32 = @floatFromInt(openingEvent.clock -% debugState.collationFrame.?.beginClock);
                                    const maxT: f32 = @floatFromInt(event.clock -% debugState.collationFrame.?.beginClock);
                                    const thresholdT = 0.01;

                                    if ((maxT - minT) > thresholdT) {
                                        const region: *debug_frame_region = AddRegion(debugState, debugState.collationFrame.?);
                                        region.record = source;
                                        region.cycleCount = event.clock - openingEvent.clock;
                                        region.laneIndex = @intCast(thread.laneIndex);
                                        region.minT = minT;
                                        region.maxT = maxT;
                                        region.colourIndex = openingEvent.debugRecordIndex;
                                    }
                                }
                            } else {
                                // record all frames in between and begin/end spans
                            }

                            thread.firstOpenBlock.?.nextFree = debugState.firstFreeBlock;
                            debugState.firstFreeBlock = thread.firstOpenBlock;
                            thread.firstOpenBlock = matchingBlock.parent;
                        } else {
                            // record span that goes to the beginning of the frames series?
                        }
                    }
                } else {
                    platform.InvalidCodePath("Invalid event type");
                }
            }
        }
    }
}

fn RefreshCollation(debugState: *debug_state) void {
    RestartCollation(debugState, platform.globalDebugTable.currentEventArrayIndex);
    CollateDebugRecords(debugState, platform.globalDebugTable.currentEventArrayIndex);
}

pub export fn DEBUGFrameEnd(memory: *platform.memory) *platform.debug_table {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(platform.DEBUGFrameEndsFnPtrType).pointer.child != @TypeOf(DEBUGFrameEnd)) {
            @compileError("Function signature mismatch!");
        }
    }

    platform.globalDebugTable.recordCount[0] = debugRecordsCount;

    platform.globalDebugTable.currentEventArrayIndex += 1;
    if (platform.globalDebugTable.currentEventArrayIndex >= platform.globalDebugTable.events.len) {
        platform.globalDebugTable.currentEventArrayIndex = 0;
    }

    const arrayIndex_eventIndex = h.AtomicExchange(
        u64,
        @ptrCast(&platform.globalDebugTable.indices),
        @as(u64, platform.globalDebugTable.currentEventArrayIndex) << 32,
    );

    const indices: platform.debug_table.packed_indices = @bitCast(arrayIndex_eventIndex);

    const eventArrayIndex = indices.eventArrayIndex;
    const eventCount = indices.eventIndex;
    platform.globalDebugTable.eventCount[eventArrayIndex] = eventCount;

    if (DEBUGGetStateMem(memory)) |debugState| {
        if (memory.executableReloaded) {
            // NOTE (Manav): we don't really need to do this
            RestartCollation(debugState, platform.globalDebugTable.currentEventArrayIndex);
        }
        if (!debugState.paused) {
            if (debugState.frameCount >= platform.MAX_DEBUG_EVENT_ARRAY_COUNT * 4 - 1) { // NOTE (Manav): check note in CollateDebugRecords
                RestartCollation(debugState, platform.globalDebugTable.currentEventArrayIndex);
            }
            CollateDebugRecords(debugState, platform.globalDebugTable.currentEventArrayIndex);
        }
    }

    return platform.globalDebugTable;
}

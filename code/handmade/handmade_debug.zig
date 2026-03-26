//! Provides debug functionality
//!
//! __Requirements when importing:__
//! - `const debug = @import("handmade_debug.zig");` must be within the top two lines of the file.

const std = @import("std");
const h = @import("handmade_all.zig");

const Platform = @import("platform");

pub const perf_analyzer = struct {
    const method = enum {
        llvm_mca,
    };

    pub fn Start(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .llvm_mca => asm volatile ("# LLVM-MCA-BEGIN " ++ region ::: .{ .memory = true }),
        }
    }

    pub fn End(comptime m: method, comptime region: []const u8) void {
        switch (m) {
            .llvm_mca => asm volatile ("# LLVM-MCA-END " ++ region ::: .{ .memory = true }),
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
    bitmapDisplay,

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
            .bitmapDisplay => h.FileFormats.bitmap_id,
        };
    }
};

pub fn ShouldBeWritten(t: debug_variable_type) bool {
    const result = ((t != .counterThreadList) and (t != .bitmapDisplay));
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

const debug_bitmap_display = struct {
    id: h.FileFormats.bitmap_id,
    dim: h.v2,
    alpha: bool,
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
        bitmapDisplay: debug_bitmap_display,
    },
};

const debug_text_op = enum {
    DrawText,
    SizeText,
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
    record: *Platform.debug_record,
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
    openingEvent: *Platform.debug_event,
    source: *Platform.debug_record,
    parent: ?*open_debug_block,

    nextFree: ?*open_debug_block,
};

const debug_thread = struct {
    id: u32,
    laneIndex: u32,
    firstOpenBlock: ?*open_debug_block,
    next: ?*debug_thread,
};

const debug_interaction_type = enum {
    None,

    NOP,

    AutoModifyVariable,

    ToggleValue,
    DragValue,
    TearValue,

    Resize,
    Move,
};

const debug_interaction = struct {
    type: debug_interaction_type,
    data: extern union { // NOTE (Manav): consider tagged union
        generic: ?*anyopaque,
        variable: ?*debug_variable,
        hierarchy: ?*debug_variable_hierarchy,
        p: ?*h.v2,
    },
};

pub const debug_state = struct {
    initialized: bool,

    highPriorityQueue: *Platform.work_queue,

    debugArena: h.Data.memory_arena,

    renderGroup: *h.RenderGroup.render_group,
    debugFont: ?*h.Asset.loaded_font,
    debugFontInfo: *h.FileFormats.hha_font,

    compiling: bool,
    compiler: Platform.debug_executing_process,

    menuP: h.v2,
    menuActive: bool,

    rootGroup: *debug_variable_reference,
    hierarchySentinel: debug_variable_hierarchy,

    lastMouseP: h.v2,
    interaction: debug_interaction,
    hotInteraction: debug_interaction,
    nextHotInteraction: debug_interaction,

    leftEdge: f32,
    rightEdge: f32,
    atY: f32,
    fontScale: f32,
    fontID: h.FileFormats.font_id,
    globalWidth: f32,
    globalHeight: f32,

    scopeToRecord: ?*Platform.debug_record,

    collateArena: h.Data.memory_arena,
    collateTemp: h.Data.temporary_memory,

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
pub const debugRecordsCount = __COUNTER__();

pub const TIMED_FUNCTION = Platform.TIMED_FUNCTION;
pub const TIMED_FUNCTION__impl = Platform.TIMED_FUNCTION__impl;

pub const TIMED_BLOCK = Platform.TIMED_BLOCK;
pub const TIMED_BLOCK__impl = Platform.TIMED_BLOCK__impl;

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
    return 47;
}
// AUTOGENERATED ----------------------------------------------------------

fn UpdateDebugRecords(debugState: *debug_state, counters: []Platform.debug_record) void {
    for (0..counters.len) |counterIndex| {
        const source: *Platform.debug_record = &counters[counterIndex];
        const dest: *debug_counter_state = &debugState.counterStates[debugState.counterCount];
        debugState.counterCount += 1;

        const hitCount_CycleCount: u64 = h.AtomicExchange(u64, @ptrCast(&source.counts), 0);
        const counts: Platform.debug_record.packed_counts = @bitCast(hitCount_CycleCount);

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

inline fn DEBUGGetStateMem(memory: ?*Platform.memory) ?*debug_state {
    if (memory) |_| {
        const debugState: *debug_state = @ptrCast(@alignCast(memory.?.debugStorage));
        Platform.Assert(debugState.initialized);

        return debugState;
    } else {
        return null;
    }
}

inline fn DEBUGGetState() ?*debug_state {
    const result = DEBUGGetStateMem(Platform.debugGlobalMemory);

    return result;
}

pub fn Start(assets: *h.Asset.game_assets, width: u32, height: u32) void {
    TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__45 = TIMED_FUNCTION__impl(45, @src()).Init(.{});
    defer __t_blk__45.End();
    // AUTOGENERATED ----------------------------------------------------------

    if (@as(?*debug_state, @ptrCast(@alignCast(Platform.debugGlobalMemory.?.debugStorage)))) |debugState| {
        if (!debugState.initialized) {
            debugState.hierarchySentinel.next = &debugState.hierarchySentinel;
            debugState.hierarchySentinel.prev = &debugState.hierarchySentinel;
            debugState.hierarchySentinel.group = undefined;

            debugState.highPriorityQueue = Platform.debugGlobalMemory.?.highPriorityQueue;

            debugState.debugArena.Initialize(
                Platform.debugGlobalMemory.?.debugStorageSize - @sizeOf(debug_state),
                @ptrCast(@as([*]debug_state, @ptrCast(debugState)) + 1),
            );

            var context = h.DebugVars.debug_variable_definition_context{
                .state = debugState,
                .arena = &debugState.debugArena,
                .group = null,
            };

            const DEBUGBeginVariableGroup = h.DebugVars.DEBUGBeginVariableGroup;
            const DEBUGEndVariableGroup = h.DebugVars.DEBUGEndVariableGroup;
            const DEBUGCreateVariables = h.DebugVars.DEBUGCreateVariables;
            const DEBUGAddVariable = h.DebugVars.DEBUGAddVariable;

            context.group = DEBUGBeginVariableGroup(&context, "Root");
            _ = DEBUGBeginVariableGroup(&context, "Debugging");

            DEBUGCreateVariables(&context);
            _ = DEBUGBeginVariableGroup(&context, "Profile");
            _ = DEBUGBeginVariableGroup(&context, "By Thread");
            const threadList = DEBUGAddVariable(&context, "", .counterThreadList, .{ .dimension = h.v2{ 1024, 100 } });
            _ = threadList;
            DEBUGEndVariableGroup(&context);
            _ = DEBUGBeginVariableGroup(&context, "By Function");
            const functionList = DEBUGAddVariable(&context, "", .counterThreadList, .{ .dimension = h.v2{ 1024, 200 } });
            _ = functionList;
            DEBUGEndVariableGroup(&context);
            DEBUGEndVariableGroup(&context);

            var matchVector = h.Asset.asset_vector{};
            matchVector.e[@intFromEnum(h.FileFormats.asset_tag_id.FacingDirection)] = 0.0;

            var weightVector = h.Asset.asset_vector{};
            weightVector.e[@intFromEnum(h.FileFormats.asset_tag_id.FacingDirection)] = 1.0;

            const id = h.Asset.GetBestMatchBitmapFrom(assets, .Head, &matchVector, &weightVector);

            _ = DEBUGAddVariable(&context, "Test Bitmap", .bitmapDisplay, id);

            DEBUGEndVariableGroup(&context);

            debugState.rootGroup = context.group.?;

            debugState.renderGroup = h.RenderGroup.render_group.Allocate(assets, &debugState.debugArena, Platform.MegaBytes(16), false);

            debugState.paused = false;
            debugState.scopeToRecord = null;

            debugState.initialized = true;

            debugState.collateArena.SubArena(&debugState.debugArena, 4, Platform.MegaBytes(32));
            debugState.collateTemp = h.Data.BeginTemporaryMemory(&debugState.collateArena);

            RestartCollation(debugState, 0);

            _ = AddHierarchy(debugState, debugState.rootGroup, .{ -0.5 * @as(f32, @floatFromInt(width)), 0.5 * @as(f32, @floatFromInt(height)) });
        }

        h.RenderGroup.BeginRender(debugState.renderGroup);
        debugState.debugFont = debugState.renderGroup.PushFont(debugState.fontID);
        debugState.debugFontInfo = debugState.renderGroup.assets.GetFontInfo(debugState.fontID);

        debugState.globalWidth = @floatFromInt(width);
        debugState.globalHeight = @floatFromInt(height);

        var matchVectorFont = h.Asset.asset_vector{};
        var weightVectorFont = h.Asset.asset_vector{};

        matchVectorFont.e[@intFromEnum(h.FileFormats.asset_tag_id.FontType)] = @floatFromInt(@as(i32, @intFromEnum(h.FileFormats.asset_font_type.Debug)));
        weightVectorFont.e[@intFromEnum(h.FileFormats.asset_tag_id.FontType)] = 1.0;

        debugState.fontID = h.Asset.GetBestMatchFontFrom(
            assets,
            .Font,
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
            const renderGroup: *h.RenderGroup.render_group = debugState.?.renderGroup;
            const info: *h.FileFormats.hha_font = debugState.?.debugFontInfo;

            var prevCodePoint: u32 = 0;
            var charScale = debugState.?.fontScale;
            const atY: f32 = h.Y(p);
            var atX: f32 = h.X(p);

            var at: [*]const u8 = string.ptr;
            while (at[0] != 0) {
                if (at[0] == '\\' and at[1] == '#' and at[2] != 0 and at[3] != 0 and at[4] != 0) {
                    const cScale = 1.0 / 9.0;
                    colour = h.Math.ClampV401(h.v4{
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

                    const advanceX: f32 = charScale * h.Asset.GetHorizontalAdvanceForPair(info, font, prevCodePoint, codePoint);
                    atX += advanceX;

                    // NOTE (Manav): this can have issues with handling newlines or other special characters.
                    if (codePoint != ' ') {
                        const bitmapID = h.Asset.GetBitmapForGlyph(renderGroup.assets, info, font, codePoint);
                        const info_ = renderGroup.assets.GetBitmapInfo(bitmapID);

                        const bitmapScale = charScale * @as(f32, @floatFromInt(info_.dim[1]));
                        const bitmapOffset: h.v3 = .{ atX, atY, 0 };

                        switch (op) {
                            .DrawText => renderGroup.PushBitmap2(bitmapID, bitmapScale, bitmapOffset, .{ .colour = colour, .cAlign = 1.0 }),
                            .SizeText => {
                                if (renderGroup.assets.GetBitmap(bitmapID, renderGroup.generationID)) |bitmap| {
                                    const dim = h.RenderGroup.GetBitmapDim(renderGroup, bitmap, bitmapScale, bitmapOffset, 1.0);
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
        const renderGroup: *h.RenderGroup.render_group = debugState.renderGroup;
        _ = renderGroup;

        _ = DEBUGTextOp(debugState, .DrawText, p, string, colour);
    }
}

fn DEBUGGetTextSize(debugState: *debug_state, string: []const u8) h.rect2 {
    const result: h.rect2 = DEBUGTextOp(debugState, .SizeText, .{ 0, 0 }, string, .{ 1, 1, 1, 1 });

    return result;
}

fn DEBUGTextLine(string: []const u8) void {
    if (DEBUGGetState()) |debugState| {
        const renderGroup: *h.RenderGroup.render_group = debugState.renderGroup;
        if (renderGroup.PushFont(debugState.fontID)) |_| {
            const info = renderGroup.assets.GetFontInfo(debugState.fontID);

            DEBUGTextOutAt(.{
                debugState.leftEdge,
                debugState.atY - debugState.fontScale * h.Asset.GetStartingBaselineY(debugState.debugFontInfo),
            }, string, .{ 1, 1, 1, 1 });

            debugState.atY -= h.Asset.GetLineAdvanceFor(info) * debugState.fontScale;
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
        stat.min = Platform.F32MAXIMUM;
        stat.max = -Platform.F32MAXIMUM;
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
        else => Platform.InvalidCodePath("Unaccounted type."),
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

    const include = "const Math = @import(\"handmade_math.zig\");\nconst v2 = Math.v2;\nconst v3 = Math.v3;\nconst v4 = Math.v4;\n\n";

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

    _ = h.Data.platformAPI.DEBUGWriteEntireFile("../code/handmade/handmade_config.zig", written, temp[0..written].ptr);

    if (!debugState.compiling) {
        // NOTE (Manav): compilation is incredibly slow, wait for incremental compilation support (use -fincremental) in 0.14
        const commandline = "/C zig build lib -p build -Dself_compilation=true -Doptimize=" ++ switch (@import("builtin").mode) {
            .Debug => "Debug",
            .ReleaseFast => "ReleaseFast",
            .ReleaseSafe => "ReleaseSafe",
            .ReleaseSmall => "ReleaseSmall",
        };

        debugState.compiling = true;
        debugState.compiler = h.Data.platformAPI.DEBUGExecuteSystemCommand("..\\", "c:\\windows\\system32\\cmd.exe", commandline);
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
                const record: *Platform.debug_record = region.record;

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

fn InteractionsAreEqual(a: debug_interaction, b: debug_interaction) bool {
    const result: bool = (a.type == b.type) and (a.data.generic == b.data.generic);

    return result;
}

fn InteractionsIsHot(debugState: *debug_state, b: debug_interaction) bool {
    const result = InteractionsAreEqual(debugState.hotInteraction, b);

    return result;
}

const debug_layout = struct {
    debugState: *debug_state,
    mouseP: h.v2,
    at: h.v2,
    depth: i32,
    lineAdvance: f32,
    spacingY: f32,
};

fn PlaceRectangle(layout: *debug_layout, dim: h.v2) h.rect2 {
    _ = layout;
    _ = dim;
}

const layout_element = struct {
    // NOTE (Manav): Storage:
    _layout: *debug_layout,
    dim: *h.v2,
    size: ?*h.v2,
    interaction: debug_interaction,

    // NOTE (Manav): Out:
    bounds: h.rect2,
};

fn BeginElementRectangle(_layout: *debug_layout, dim: *h.v2) layout_element {
    const element: layout_element = .{
        ._layout = _layout,
        .dim = dim,
        .size = null,
        .interaction = .{ .type = .None, .data = .{ .generic = null } },
        .bounds = h.rect2{ .min = .{ 0, 0 }, .max = .{ 0, 0 } },
    };

    return element;
}

fn MakeElementSizable(element: *layout_element) void {
    element.size = element.dim;
}

fn DefaultInteraction(element: *layout_element, interaction: debug_interaction) void {
    element.interaction = interaction;
}

fn EndElement(element: *layout_element) void {
    const _layout = element._layout;
    const debugState = _layout.debugState;

    const sizeHandlePixels = 4.0;

    var frame: h.v2 = .{ 0, 0 };
    if (element.size) |_| {
        frame = .{ sizeHandlePixels, sizeHandlePixels };
    }

    const totalDim = h.Add(element.dim.*, h.Scale(frame, 2));

    const totalMinCorner = h.v2{
        h.X(_layout.at) + @as(f32, @floatFromInt(_layout.depth)) * 2 * _layout.lineAdvance,
        h.Y(_layout.at) - h.Y(totalDim),
    };
    const totalMaxCorner = h.Add(totalMinCorner, totalDim);

    const interiorMinCorner = h.Add(totalMinCorner, frame);
    const interiorMaxCorner = h.Add(interiorMinCorner, element.dim.*);

    const totalBounds = h.rect2.InitMinMax(totalMinCorner, totalMaxCorner);
    element.bounds = h.rect2.InitMinMax(interiorMinCorner, interiorMaxCorner);

    if (element.interaction.type != .None and element.bounds.IsInRect(_layout.mouseP)) {
        debugState.nextHotInteraction = element.interaction;
    }

    if (element.size) |_| {
        debugState.renderGroup.PushRect2(h.rect2.InitMinMax(
            h.v2{ h.X(totalMinCorner), h.Y(interiorMinCorner) },
            h.v2{ h.X(interiorMinCorner), h.Y(interiorMaxCorner) },
        ), 0, .{ 0, 0, 0, 1 });
        debugState.renderGroup.PushRect2(h.rect2.InitMinMax(
            h.v2{ h.X(interiorMaxCorner), h.Y(interiorMinCorner) },
            h.v2{ h.X(totalMaxCorner), h.Y(interiorMaxCorner) },
        ), 0, .{ 0, 0, 0, 1 });
        debugState.renderGroup.PushRect2(h.rect2.InitMinMax(
            h.v2{ h.X(interiorMinCorner), h.Y(totalMinCorner) },
            h.v2{ h.X(interiorMaxCorner), h.Y(interiorMinCorner) },
        ), 0, .{ 0, 0, 0, 1 });
        debugState.renderGroup.PushRect2(h.rect2.InitMinMax(
            h.v2{ h.X(interiorMinCorner), h.Y(totalMaxCorner) },
            h.v2{ h.X(interiorMaxCorner), h.Y(totalMaxCorner) },
        ), 0, .{ 0, 0, 0, 1 });

        const sizeInteraction: debug_interaction = .{
            .type = .Resize,
            .data = .{
                .p = element.size,
            },
        };

        const sizeBox = h.rect2.InitMinMax(
            h.v2{ h.X(interiorMaxCorner), h.Y(totalMinCorner) },
            h.v2{ h.X(totalMaxCorner), h.Y(interiorMinCorner) },
        );
        debugState.renderGroup.PushRect2(
            sizeBox,
            0,
            if (InteractionsIsHot(debugState, sizeInteraction)) .{ 1, 1, 0, 1 } else .{ 1, 1, 1, 1 },
        );

        if (sizeBox.IsInRect(_layout.mouseP)) {
            debugState.nextHotInteraction = sizeInteraction;
        }
    }

    const spacingY = _layout.spacingY;
    if (false) {
        spacingY = 0;
    }
    // _layout.at.Y = bounds.GetMinCorner() - spaceingY;
    h.SetY(&_layout.at, h.Y(totalBounds.GetMinCorner()) - spacingY);
}

fn DEBUGDrawMainMenu(debugState: *debug_state, _: *h.RenderGroup.render_group, mouseP: h.v2) void {
    var hierarchy = debugState.hierarchySentinel.next;
    while (hierarchy != &debugState.hierarchySentinel) : (hierarchy = hierarchy.next) {
        var layout = debug_layout{
            .debugState = debugState,
            .mouseP = mouseP,
            .at = hierarchy.uiP,
            .lineAdvance = debugState.fontScale * h.Asset.GetLineAdvanceFor(debugState.debugFontInfo),
            .depth = 0,
            .spacingY = 4.0,
        };

        var ref: ?*debug_variable_reference = hierarchy.group.variable.value.group.firstChild;
        while (ref) |_| {
            const variable = ref.?.variable;

            const itemInteraction: debug_interaction = .{
                .type = .AutoModifyVariable,
                .data = .{
                    .variable = variable,
                },
            };

            const isHot = InteractionsIsHot(debugState, itemInteraction);
            const itemColour: h.v4 = if (isHot) .{ 1, 1, 0, 1 } else .{ 1, 1, 1, 1 };

            switch (variable.type) {
                .counterThreadList => {
                    var element: layout_element = BeginElementRectangle(&layout, &variable.value.profile.dimension);
                    MakeElementSizable(&element);
                    DefaultInteraction(&element, itemInteraction);
                    EndElement(&element);

                    DrawProfileIn(debugState, element.bounds, mouseP);
                },

                .bitmapDisplay => {
                    const bitmapScale = h.Y(variable.value.bitmapDisplay.dim);
                    if (debugState.renderGroup.assets.GetBitmap(
                        variable.value.bitmapDisplay.id,
                        debugState.renderGroup.generationID,
                    )) |bitmap| {
                        const dim = h.RenderGroup.GetBitmapDim(debugState.renderGroup, bitmap, bitmapScale, .{ 0, 0, 0 }, 1.0);
                        // variable.value.bitmapDisplay.dim.x = dim.size.x;
                        h.SetX(&variable.value.bitmapDisplay.dim, h.X(dim.size));
                    }

                    const tearInteraction: debug_interaction = .{
                        .type = .TearValue,
                        .data = .{
                            .variable = variable,
                        },
                    };

                    var element: layout_element = BeginElementRectangle(&layout, &variable.value.bitmapDisplay.dim);
                    MakeElementSizable(&element);
                    DefaultInteraction(&element, tearInteraction);
                    EndElement(&element);

                    debugState.renderGroup.PushRect2(element.bounds, 0, .{ 0, 0, 0, 1 });
                    debugState.renderGroup.PushBitmap2(
                        variable.value.bitmapDisplay.id,
                        bitmapScale,
                        h.ToV3(element.bounds.GetMinCorner(), 0),
                        .{ .colour = .{ 1, 1, 1, 1 }, .cAlign = 0.0 },
                    );
                },

                else => {
                    var text = [1]u8{0} ** 256;

                    _ = VariableToText(text[0..], variable, .{
                        .Name = true,
                        .Colon = true,
                    });

                    const textBounds: h.rect2 = DEBUGGetTextSize(debugState, text[0..]);
                    var dim: h.v2 = .{ h.X(textBounds.GetDim()), layout.lineAdvance };

                    var element: layout_element = BeginElementRectangle(&layout, &dim);
                    DefaultInteraction(&element, itemInteraction);
                    EndElement(&element);

                    DEBUGTextOutAt(.{
                        h.X(element.bounds.GetMinCorner()),
                        h.Y(element.bounds.GetMaxCorner()) - debugState.fontScale * h.Asset.GetStartingBaselineY(debugState.debugFontInfo),
                    }, text[0..], itemColour);
                },
            }

            if (variable.type == .group and variable.value.group.expanded) {
                ref = variable.value.group.firstChild;
                layout.depth += 1;
            } else {
                while (ref) |_| {
                    if (ref.?.next) |_| {
                        ref = ref.?.next;
                        break;
                    } else {
                        ref = ref.?.parent;
                        layout.depth -= 1;
                    }
                }
            }
        }

        debugState.atY = h.Y(layout.at);

        if (true) {
            const moveInteraction: debug_interaction = .{
                .type = .Move,
                .data = .{
                    .p = &hierarchy.uiP,
                },
            };

            const moveBox = h.rect2.InitCenterHalfDim(h.Sub(hierarchy.uiP, .{ 4, 4 }), .{ 4, 4 });
            debugState.renderGroup.PushRect2(
                moveBox,
                0,
                if (InteractionsIsHot(debugState, moveInteraction)) .{ 1, 1, 0, 1 } else .{ 1, 1, 1, 1 },
            );

            if (moveBox.IsInRect(mouseP)) {
                debugState.nextHotInteraction = moveInteraction;
            }
        }
    }

    if (Platform.IGNORE) {
        var newHotMenuIndex: u32 = h.debugVariableList.len;
        var bestDistanceSq: f32 = Platform.F32MAXIMUM;

        const menuRadius = 400.0;
        const angleStep: f32 = Platform.Tau32 / @as(f32, @floatFromInt(h.debugVariableList.len));
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

        if (h.Math.LengthSq(h.Sub(mouseP, debugState.menuP)) > h.Square(menuRadius)) {
            debugState.hotMenuIndex = newHotMenuIndex;
        } else {
            debugState.hotMenuIndex = h.debugVariableList.len;
        }
    }
}

fn BeginInteract(debugState: *debug_state, _: *Platform.input, _: h.v2, altUI: bool) void {
    if (debugState.hotInteraction.type != .None) {
        if (debugState.hotInteraction.type == .AutoModifyVariable) {
            switch (debugState.hotInteraction.data.variable.?.type) {
                .bool => {
                    debugState.hotInteraction.type = .ToggleValue;
                },
                .f32 => {
                    debugState.hotInteraction.type = .DragValue;
                },
                .group => {
                    debugState.hotInteraction.type = .ToggleValue;
                },
                else => {},
            }

            if (altUI) {
                debugState.hotInteraction.type = .TearValue;
            }
        }

        switch (debugState.hotInteraction.type) {
            .TearValue => {
                const rootGroup: *debug_variable_reference = h.DebugVars.DEBUGAddRootGroup(debugState, "NewUserGroup");
                _ = h.DebugVars.DEBUGAddVariableReference__(debugState, rootGroup, debugState.hotInteraction.data.variable.?);
                var hierarchy = AddHierarchy(debugState, rootGroup, .{ 0, 0 });
                hierarchy.uiP = debugState.lastMouseP;
                debugState.hotInteraction.type = .Move;
                debugState.hotInteraction.data.p = &hierarchy.uiP;
            },
            else => {},
        }

        debugState.interaction = debugState.hotInteraction;
    } else {
        debugState.interaction.type = .NOP;
    }
}

fn EndInteract(debugState: *debug_state, _: *Platform.input, _: h.v2) void {
    switch (debugState.interaction.type) {
        .ToggleValue => {
            var variable = debugState.interaction.data.variable.?;
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

    debugState.interaction = .{
        .type = .None,
        .data = .{
            .generic = null,
        },
    };
}

fn Interact(debugState: *debug_state, input: *Platform.input, mouseP: h.v2) void {
    const dMouseP: h.v2 = h.Sub(mouseP, debugState.lastMouseP);

    // if (input.mouseButtons[@intFromEnum(input_mouse_button.PlatformMouseButton_Right)].endedDown > 0) {
    //     if (input.mouseButtons[@intFromEnum(input_mouse_button.PlatformMouseButton_Right)].halfTransitionCount > 0) {
    //         debugState.menuP = mouseP;
    //     }
    //     DrawDebugMainMenu(debugState, renderGroup, mouseP);
    // } else if (input.mouseButtons[@intFromEnum(input_mouse_button.PlatformMouseButton_Right)].halfTransitionCount > 0)

    if (debugState.interaction.type != .None) {
        // Mouse move interaction
        var variable: ?*debug_variable = debugState.interaction.data.variable;
        // var hierarchy: ?*debug_variable_hierarchy = debugState.interaction.data.hierarchy;
        const p: ?*h.v2 = debugState.interaction.data.p;

        switch (debugState.interaction.type) {
            .DragValue => {
                switch (variable.?.type) {
                    .f32 => {
                        variable.?.value.f32 += 0.1 * h.Y(dMouseP);
                    },

                    else => {},
                }
            },
            .Resize => {
                if (variable != null) { // NOTE (Manav): variable can be null with .Resize when it's in a hierarchy

                    // p += .{ dMouseP.x, -dMouseP.y };
                    h.AddTo(p.?, .{ h.X(dMouseP), -h.Y(dMouseP) });
                    // p.x = @max(p.x, 10.0);
                    h.SetX(p.?, @max(h.X(p.?.*), 10.0));
                    // p.y = @max(p.y, 10.0);
                    h.SetY(p.?, @max(h.Y(p.?.*), 10.0));
                }
            },
            .Move => {
                // p += .{ dMouseP.x, dMouseP.y };
                h.AddTo(p.?, .{ h.X(dMouseP), h.Y(dMouseP) });
            },
            else => {},
        }

        const altUI = input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Right)].endedDown != 0;

        // Mouse click interaction
        var transitionIndex = input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Left)].halfTransitionCount;
        while (transitionIndex > 1) : (transitionIndex -= 1) {
            EndInteract(debugState, input, mouseP);
            BeginInteract(debugState, input, mouseP, altUI);
        }

        if (input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Left)].endedDown == 0) {
            EndInteract(debugState, input, mouseP);
        }
    } else {
        debugState.hotInteraction = debugState.nextHotInteraction;

        const altUI = input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Right)].endedDown != 0;

        var transitionIndex = input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Left)].halfTransitionCount;
        while (transitionIndex > 1) : (transitionIndex -= 1) {
            BeginInteract(debugState, input, mouseP, altUI);
            EndInteract(debugState, input, mouseP);
        }

        if (input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Left)].endedDown != 0) {
            BeginInteract(debugState, input, mouseP, altUI);
        }
    }

    if (Platform.IGNORE) {
        if (Platform.WasPressed(&input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Left)])) {
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

pub fn End(input: *Platform.input, drawBuffer: *h.RenderGroup.loaded_bitmap) void {
    TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__46 = TIMED_FUNCTION__impl(46, @src()).Init(.{});
    defer __t_blk__46.End();
    // AUTOGENERATED ----------------------------------------------------------

    if (DEBUGGetState()) |debugState| {
        const renderGroup: *h.RenderGroup.render_group = debugState.renderGroup;

        h.Data.ZeroStruct(debug_interaction, &debugState.nextHotInteraction);

        const hotRecord: ?*Platform.debug_record = null;

        const mouseP: h.v2 = h.V2(input.mouseX, input.mouseY);

        DEBUGDrawMainMenu(debugState, renderGroup, mouseP);
        Interact(debugState, input, mouseP);

        if (debugState.compiling) {
            const state = h.Data.platformAPI.DEBUGGetProcessState(debugState.compiler);
            if (state.isRunning) {
                DEBUGTextLine("Compiling...");
            } else {
                debugState.compiling = false;
            }
        }

        const info = debugState.debugFontInfo;
        if (debugState.debugFont) |_| {
            if (Platform.IGNORE) {
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

                        if (!Platform.IGNORE) {
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
        if (Platform.WasPressed(&input.mouseButtons[@intFromEnum(Platform.input_mouse_button.PlatformMouseButton_Left)])) {
            if (hotRecord) |_| {
                debugState.scopeToRecord = hotRecord;
            } else {
                debugState.scopeToRecord = null;
            }
            RefreshCollation(debugState);
        }

        renderGroup.TiledRenderGroupToOutput(debugState.highPriorityQueue, drawBuffer);
        h.RenderGroup.EndRender(renderGroup);
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
    Platform.Assert(currentFrame.regionCount < MAX_REGIONS_PER_FRAME);
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
    h.Data.EndTemporaryMemory(debugState.collateTemp);
    debugState.collateTemp = h.Data.BeginTemporaryMemory(&debugState.collateArena);

    debugState.firstThread = null;
    debugState.firstFreeBlock = null;

    debugState.frames = debugState.collateArena.PushSlice(debug_frame, Platform.MAX_DEBUG_EVENT_ARRAY_COUNT * 4);
    debugState.frameBarLaneCount = 0;
    debugState.frameCount = 0;
    debugState.frameBarScale = 1.0 / 60000000.0;

    debugState.collationArrayIndex = invalidArrayIndex + 1;
    debugState.collationFrame = null;
}

inline fn GetRecordFrom(block: ?*open_debug_block) ?*Platform.debug_record {
    const result = if (block) |_| block.?.source else null;

    return result;
}

fn CollateDebugRecords(debugState: *debug_state, invalidArrayIndex: u32) void {
    while (true) : (debugState.collationArrayIndex += 1) {
        if (debugState.collationArrayIndex == Platform.MAX_DEBUG_EVENT_ARRAY_COUNT) {
            debugState.collationArrayIndex = 0;
        }
        const eventArrayIndex = debugState.collationArrayIndex;

        if (eventArrayIndex == invalidArrayIndex) {
            break;
        }

        for (0..Platform.globalDebugTable.eventCount[eventArrayIndex]) |eventIndex| {
            const event: *Platform.debug_event = &Platform.globalDebugTable.events[eventArrayIndex][eventIndex];
            const source: *Platform.debug_record = &Platform.globalDebugTable.records[event.translationUnit][event.debugRecordIndex];

            if (event.eventType == .FrameMarker) {
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

                if (event.eventType == .BeginBlock) {
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
                } else if (event.eventType == .EndBlock) {
                    if (thread.firstOpenBlock) |_| {
                        const matchingBlock: *open_debug_block = thread.firstOpenBlock.?;
                        const openingEvent: *Platform.debug_event = matchingBlock.openingEvent;
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
                    Platform.InvalidCodePath("Invalid event type");
                }
            }
        }
    }
}

fn RefreshCollation(debugState: *debug_state) void {
    RestartCollation(debugState, Platform.globalDebugTable.currentEventArrayIndex);
    CollateDebugRecords(debugState, Platform.globalDebugTable.currentEventArrayIndex);
}

pub export fn DEBUGFrameEnd(memory: *Platform.memory) *Platform.debug_table {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(Platform.DEBUGFrameEndsFnPtrType).pointer.child != @TypeOf(DEBUGFrameEnd)) {
            @compileError("Function signature mismatch!");
        }
    }

    Platform.globalDebugTable.recordCount[0] = debugRecordsCount;

    Platform.globalDebugTable.currentEventArrayIndex += 1;
    if (Platform.globalDebugTable.currentEventArrayIndex >= Platform.globalDebugTable.events.len) {
        Platform.globalDebugTable.currentEventArrayIndex = 0;
    }

    const arrayIndex_eventIndex = h.Intrinsics.AtomicExchange(
        u64,
        @ptrCast(&Platform.globalDebugTable.indices),
        @as(u64, Platform.globalDebugTable.currentEventArrayIndex) << 32,
    );

    const indices: Platform.debug_table.packed_indices = @bitCast(arrayIndex_eventIndex);

    const eventArrayIndex = indices.eventArrayIndex;
    const eventCount = indices.eventIndex;
    Platform.globalDebugTable.eventCount[eventArrayIndex] = eventCount;

    if (DEBUGGetStateMem(memory)) |debugState| {
        if (memory.executableReloaded) {
            // NOTE (Manav): we don't really need to do this
            RestartCollation(debugState, Platform.globalDebugTable.currentEventArrayIndex);
        }
        if (!debugState.paused) {
            if (debugState.frameCount >= Platform.MAX_DEBUG_EVENT_ARRAY_COUNT * 4 - 1) { // NOTE (Manav): check note in CollateDebugRecords
                RestartCollation(debugState, Platform.globalDebugTable.currentEventArrayIndex);
            }
            CollateDebugRecords(debugState, Platform.globalDebugTable.currentEventArrayIndex);
        }
    }

    return Platform.globalDebugTable;
}

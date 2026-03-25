const Debug = @import("handmade_debug.zig");
const Config = @import("handmade_config.zig");
const h = @import("handmade_all.zig");

const platform = @import("platform");

const debug_state = Debug.debug_state;
const debug_variable = Debug.debug_variable;
const debug_variable_type = Debug.debug_variable_type;
const debug_variable_group = Debug.debug_variable_group;
const debug_variable_reference = Debug.debug_variable_reference;

pub const debug_variable_definition_context = struct {
    state: *debug_state,
    arena: *h.Data.memory_arena,

    group: ?*debug_variable_reference,
};

fn AddUnreferencedVariable(
    state: *debug_state,
    comptime t: Debug.debug_variable_type,
    comptime name: [:0]const u8,
) *debug_variable {
    var debugVar: *debug_variable = state.debugArena.PushStruct(debug_variable);
    debugVar.type = t;
    debugVar.name = state.debugArena.PushCopy(name.len, name)[0..name.len :0];

    return debugVar;
}

pub fn DEBUGAddVariableReference__(state: *debug_state, groupRef: ?*debug_variable_reference, debugVar: *debug_variable) *debug_variable_reference {
    var ref: *debug_variable_reference = state.debugArena.PushStruct(debug_variable_reference);
    ref.variable = debugVar;
    ref.next = null;

    ref.parent = groupRef;
    var group: ?*debug_variable = if (ref.parent) |parent| parent.variable else null;

    if (group) |_| {
        if (group.?.value.group.firstChild) |_| {
            group.?.value.group.lastChild.?.next = ref;
            group.?.value.group.lastChild = group.?.value.group.lastChild.?.next;
        } else {
            group.?.value.group.firstChild = ref;
            group.?.value.group.lastChild = group.?.value.group.firstChild;
        }
    }

    return ref;
}

pub fn DEBUGAddVariableReference(context: *debug_variable_definition_context, debugVar: *debug_variable) *debug_variable_reference {
    const ref: *debug_variable_reference = DEBUGAddVariableReference__(context.state, context.group, debugVar);

    return ref;
}

fn AddVariable__(context: *debug_variable_definition_context, comptime t: debug_variable_type, comptime name: [:0]const u8) *debug_variable_reference {
    const debugVar: *debug_variable = AddUnreferencedVariable(context.state, t, name);
    const ref: *debug_variable_reference = DEBUGAddVariableReference(context, debugVar);

    return ref;
}

fn DEBUGAddRootGroupInternal(debugState: *debug_state, comptime name: [:0]const u8) *debug_variable {
    var group: *debug_variable = AddUnreferencedVariable(debugState, .group, name);

    group.value = .{
        .group = debug_variable_group{
            .expanded = true,
            .firstChild = null,
            .lastChild = null,
        },
    };

    return group;
}

pub fn DEBUGAddRootGroup(debugState: *debug_state, comptime name: [:0]const u8) *debug_variable_reference {
    const groupRef: *debug_variable_reference = DEBUGAddVariableReference__(
        debugState,
        null,
        DEBUGAddRootGroupInternal(debugState, name),
    );

    return groupRef;
}

pub fn DEBUGBeginVariableGroup(context: *debug_variable_definition_context, comptime name: [:0]const u8) *debug_variable_reference {
    var group: *debug_variable_reference = DEBUGAddVariableReference(
        context,
        DEBUGAddRootGroupInternal(context.state, name),
    );

    group.variable.value.group.expanded = false;

    context.group = group;

    return group;
}

pub fn DEBUGAddVariable(
    context: *debug_variable_definition_context,
    comptime name: [:0]const u8,
    comptime t: debug_variable_type,
    value: debug_variable_type.toT(t),
) *debug_variable_reference {
    var ref: *debug_variable_reference = AddVariable__(context, t, name);

    ref.variable.value = switch (t) {
        .u32 => .{ .u32 = value },
        .i32 => .{ .i32 = value },
        .f32 => .{ .f32 = value },
        .bool => .{ .bool = value },
        .v2 => .{ .v2 = value },
        .v3 => .{ .v3 = value },
        .v4 => .{ .v4 = value },
        .counterThreadList => .{ .profile = value },
        .bitmapDisplay => .{
            .bitmapDisplay = .{
                .id = value,
                .dim = .{ 25, 25 },
                .alpha = true,
            },
        },
        else => platform.InvalidCodePath("Unsupported debug variable type"),
    };

    return ref;
}

pub fn DEBUGEndVariableGroup(context: *debug_variable_definition_context) void {
    platform.Assert(context.group != null);

    context.group = context.group.?.parent;
}

inline fn VariableListing(context: *debug_variable_definition_context, comptime name: [:0]const u8) *debug_variable_reference {
    const debug_name = "DEBUGUI_" ++ name;
    const config_variable = @field(Config, debug_name);

    const t: debug_variable_type = comptime switch (@TypeOf(config_variable)) {
        bool => .bool,
        u32 => .u32,
        i32 => .i32,
        f32 => .f32,
        h.v2 => .v2,
        h.v3 => .v3,
        h.v4 => .v4,
        h.FileFormats.bitmap_id => .bitmapDisplay,
        else => platform.InvalidCodePath("Unsupported debug variable type"),
    };

    return DEBUGAddVariable(context, name, t, config_variable);
}

pub fn DEBUGCreateVariables(context: *debug_variable_definition_context) void {
    var useDebugCamRef: *debug_variable_reference = undefined;

    _ = DEBUGBeginVariableGroup(context, "Ground Chunks");
    _ = VariableListing(context, "GroundChunkOutlines");
    _ = VariableListing(context, "GroundChunkCheckerboards");
    _ = VariableListing(context, "RecomputeGroundChunksOnExeChange");
    DEBUGEndVariableGroup(context);

    _ = DEBUGBeginVariableGroup(context, "Particles");
    _ = VariableListing(context, "ParticleTest");
    _ = VariableListing(context, "ParticleGrid");
    DEBUGEndVariableGroup(context);

    _ = DEBUGBeginVariableGroup(context, "Renderer");
    {
        _ = VariableListing(context, "TestWeirdDrawBufferSize");
        _ = VariableListing(context, "ShowLightingSamples");
        _ = DEBUGBeginVariableGroup(context, "Camera");
        {
            useDebugCamRef = VariableListing(context, "UseDebugCamera");
            _ = VariableListing(context, "DebugCameraDistance");
            _ = VariableListing(context, "UseRoomBasedCamera");
            DEBUGEndVariableGroup(context);
        }
        DEBUGEndVariableGroup(context);
    }

    _ = VariableListing(context, "UseSpaceOutlines");
    _ = VariableListing(context, "FamiliarFollowsHero");
    _ = VariableListing(context, "FauxV4");
}

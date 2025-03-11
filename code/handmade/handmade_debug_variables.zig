const platform = @import("handmade_platform");
const config = @import("handmade_config.zig");

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_debug.zig");
    usingnamespace @import("handmade_math.zig");
};

pub const debug_variable_definition_context = struct {
    state: *h.debug_state,
    arena: *h.memory_arena,

    group: ?*h.debug_variable_reference,
};

fn AddUnreferencedVariable(
    context: *debug_variable_definition_context,
    comptime t: h.debug_variable_type,
    comptime name: [:0]const u8,
) *h.debug_variable {
    var debugVar: *h.debug_variable = context.arena.PushStruct(h.debug_variable);
    debugVar.type = t;
    debugVar.name = context.arena.PushCopy(name.len, name)[0..name.len :0];

    return debugVar;
}

fn AddVariableReference(context: *debug_variable_definition_context, debugVar: *h.debug_variable) *h.debug_variable_reference {
    var ref: *h.debug_variable_reference = context.arena.PushStruct(h.debug_variable_reference);
    ref.variable = debugVar;
    ref.next = null;

    ref.parent = context.group;
    var group: ?*h.debug_variable = if (ref.parent) |parent| parent.variable else null;

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

fn AddVariable__(context: *debug_variable_definition_context, comptime t: h.debug_variable_type, comptime name: [:0]const u8) *h.debug_variable_reference {
    const debugVar: *h.debug_variable = AddUnreferencedVariable(context, t, name);
    const ref: *h.debug_variable_reference = AddVariableReference(context, debugVar);

    return ref;
}

pub fn DEBUGBeginVariableGroup(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable_reference {
    var group: *h.debug_variable_reference = AddVariable__(context, .group, name);

    group.variable.value = .{
        .group = h.debug_variable_group{
            .expanded = false,
            .firstChild = null,
            .lastChild = null,
        },
    };

    context.group = group;

    return group;
}

pub fn DEBUGAddVariable(
    context: *debug_variable_definition_context,
    comptime name: [:0]const u8,
    comptime t: h.debug_variable_type,
    value: h.debug_variable_type.toT(t),
) *h.debug_variable_reference {
    var ref: *h.debug_variable_reference = AddVariable__(context, t, name);

    ref.variable.value = switch (t) {
        .u32 => .{ .u32 = value },
        .i32 => .{ .i32 = value },
        .f32 => .{ .f32 = value },
        .bool => .{ .bool = value },
        .v2 => .{ .v2 = value },
        .v3 => .{ .v3 = value },
        .v4 => .{ .v4 = value },
        .counterThreadList => .{ .profile = value },
        else => platform.InvalidCodePath("Unsupported debug variable type"),
    };

    return ref;
}

pub fn DEBUGEndVariableGroup(context: *debug_variable_definition_context) void {
    platform.Assert(context.group != null);

    context.group = context.group.?.parent;
}

inline fn VariableListing(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable_reference {
    const debug_name = "DEBUGUI_" ++ name;
    const config_variable = @field(config, debug_name);

    const t: h.debug_variable_type = comptime switch (@TypeOf(config_variable)) {
        bool => .bool,
        u32 => .u32,
        i32 => .i32,
        f32 => .f32,
        h.v2 => .v2,
        h.v3 => .v3,
        h.v4 => .v4,
        else => platform.InvalidCodePath("Unsupported debug variable type"),
    };

    return DEBUGAddVariable(context, name, t, config_variable);
}

pub fn DEBUGCreateVariables(context: *debug_variable_definition_context) void {
    var useDebugCamRef: *h.debug_variable_reference = undefined;

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

    // NOTE (Manav): Comment out this until we can make sure there's only one declaration of the variable
    // _ = AddVariableReference(context, useDebugCamRef.variable);
}

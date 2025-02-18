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

    group: ?*h.debug_variable,
};

fn AddVariable__(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable {
    var debugVar: *h.debug_variable = context.arena.PushStruct(h.debug_variable);

    debugVar.name = context.arena.PushCopy(name.len, name)[0..name.len :0];
    debugVar.next = null;

    var group = context.group;

    debugVar.parent = group;

    if (group) |_| {
        if (group.?.value.group.firstChild) |_| {
            group.?.value.group.lastChild.?.next = debugVar;
            group.?.value.group.lastChild = debugVar;
        } else {
            group.?.value.group.firstChild = debugVar;
            group.?.value.group.lastChild = group.?.value.group.firstChild;
        }
    }

    return debugVar;
}

pub fn DEBUGBeginVariableGroup(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable {
    var group: *h.debug_variable = AddVariable__(context, name);

    group.type = .group;

    group.value = .{
        .group = h.debug_variable_group{
            .expanded = false,
            .firstChild = null,
            .lastChild = null,
        },
    };

    context.group = group;

    return group;
}

pub fn DEBUGAddVariable(context: *debug_variable_definition_context, comptime name: [:0]const u8, comptime t: h.debug_variable_type, value: h.debug_variable_type.toT(t)) *h.debug_variable {
    var debugVar: *h.debug_variable = AddVariable__(context, name);

    debugVar.type = t;

    switch (t) {
        .u32 => {
            debugVar.value = .{ .u32 = value };
        },
        .i32 => {
            debugVar.value = .{ .i32 = value };
        },
        .f32 => {
            debugVar.value = .{ .f32 = value };
        },
        .bool => {
            debugVar.value = .{ .bool = value };
        },
        .v2 => {
            debugVar.value = .{ .v2 = value };
        },
        .v3 => {
            debugVar.value = .{ .v3 = value };
        },
        .v4 => {
            debugVar.value = .{ .v4 = value };
        },
        .counterThreadList => {
            debugVar.value = .{ .profile = value };
        },
        else => platform.InvalidCodePath("Unsupported debug variable type"),
    }

    return debugVar;
}

pub fn DEBUGEndVariableGroup(context: *debug_variable_definition_context) void {
    platform.Assert(context.group != null);

    context.group = context.group.?.parent;
}

inline fn VariableListing(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable {
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
            _ = VariableListing(context, "UseDebugCamera");
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

const platform = @import("handmade_platform");
const config = @import("handmade_config.zig");

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_debug.zig");
    usingnamespace @import("handmade_math.zig");
};

const debug_variable_definition_context = struct {
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

fn BeginVariableGroup(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable {
    var group: *h.debug_variable = AddVariable__(context, name);

    // group.type = .group;

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

fn AddVariable(context: *debug_variable_definition_context, comptime name: [:0]const u8, comptime T: type, value: T) *h.debug_variable {
    var debugVar: *h.debug_variable = AddVariable__(context, name);

    switch (T) {
        u32 => {
            // debugVar.type = .u32;
            debugVar.value = .{ .u32 = value };
        },
        i32 => {
            // debugVar.type = .i32;
            debugVar.value = .{ .i32 = value };
        },
        f32 => {
            // debugVar.type = .f32;
            debugVar.value = .{ .f32 = value };
        },
        bool => {
            // debugVar.type = .bool;
            debugVar.value = .{ .bool = value };
        },
        h.v2 => {
            // debugVar.type = .v2;
            debugVar.value = .{ .v2 = value };
        },
        h.v3 => {
            // debugVar.type = .v3;
            debugVar.value = .{ .v3 = value };
        },
        h.v4 => {
            // debugVar.type = .v4;
            debugVar.value = .{ .v4 = value };
        },
        else => platform.InvalidCodePath("Unsupported debug variable type"),
    }

    return debugVar;
}

fn EndVariableGroup(context: *debug_variable_definition_context) void {
    platform.Assert(context.group != null);

    context.group = context.group.?.parent;
}

inline fn VariableListing(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable {
    const debug_name = "DEBUGUI_" ++ name;
    const config_variable = @field(config, debug_name);
    return AddVariable(context, name, @TypeOf(config_variable), config_variable);
}

pub fn DEBUGCreateVariables(state: *h.debug_state) void {
    var context = debug_variable_definition_context{
        .state = state,
        .arena = &state.debugArena,
        .group = null,
    };

    context.group = BeginVariableGroup(&context, "Root");

    _ = BeginVariableGroup(&context, "Ground Chunks");
    _ = VariableListing(&context, "GroundChunkOutlines");
    _ = VariableListing(&context, "GroundChunkCheckerboards");
    _ = VariableListing(&context, "RecomputeGroundChunksOnExeChange");
    EndVariableGroup(&context);

    _ = BeginVariableGroup(&context, "Particles");
    _ = VariableListing(&context, "ParticleTest");
    _ = VariableListing(&context, "ParticleGrid");
    EndVariableGroup(&context);

    _ = BeginVariableGroup(&context, "Renderer");
    {
        _ = VariableListing(&context, "TestWeirdDrawBufferSize");
        _ = VariableListing(&context, "ShowLightingSamples");
        _ = BeginVariableGroup(&context, "Camera");
        {
            _ = VariableListing(&context, "UseDebugCamera");
            _ = VariableListing(&context, "DebugCameraDistance");
            _ = VariableListing(&context, "UseRoomBasedCamera");
            EndVariableGroup(&context);
        }
        EndVariableGroup(&context);
    }

    _ = VariableListing(&context, "UseSpaceOutlines");
    _ = VariableListing(&context, "FamiliarFollowsHero");
    _ = VariableListing(&context, "FauxV4");

    state.rootGroup = context.group.?;
}

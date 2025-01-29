const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_debug.zig");
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

fn AddVariable(context: *debug_variable_definition_context, comptime name: [:0]const u8, value: bool) *h.debug_variable {
    var debugVar: *h.debug_variable = AddVariable__(context, name);
    debugVar.value = .{ .bool = value };

    return debugVar;
}

fn EndVariableGroup(context: *debug_variable_definition_context) void {
    platform.Assert(context.group != null);

    context.group = context.group.?.parent;
}

inline fn VariableListing(context: *debug_variable_definition_context, comptime name: [:0]const u8) *h.debug_variable {
    return AddVariable(context, name, @field(platform.config, name));
}

pub fn DEBUGCreateVariables(state: *h.debug_state) void {
    var context = debug_variable_definition_context{
        .state = state,
        .arena = &state.debugArena,
        .group = null,
    };

    context.group = BeginVariableGroup(&context, "Root");

    _ = BeginVariableGroup(&context, "Ground Chunks");
    _ = VariableListing(&context, "DEBUGUI_GroundChunkOutlines");
    _ = VariableListing(&context, "DEBUGUI_GroundChunkCheckerboards");
    _ = VariableListing(&context, "DEBUGUI_RecomputeGroundChunksOnExeChange");
    EndVariableGroup(&context);

    _ = BeginVariableGroup(&context, "Particles");
    _ = VariableListing(&context, "DEBUGUI_ParticleTest");
    _ = VariableListing(&context, "DEBUGUI_ParticleGrid");
    EndVariableGroup(&context);

    _ = BeginVariableGroup(&context, "Renderer");
    {
        _ = VariableListing(&context, "DEBUGUI_TestWeirdDrawBufferSize");
        _ = VariableListing(&context, "DEBUGUI_ShowLightingSamples");
        _ = BeginVariableGroup(&context, "Camera");
        {
            _ = VariableListing(&context, "DEBUGUI_UseDebugCamera");
            _ = VariableListing(&context, "DEBUGUI_UseRoomBasedCamera");
            EndVariableGroup(&context);
        }
        EndVariableGroup(&context);
    }

    _ = VariableListing(&context, "DEBUGUI_UseSpaceOutlines");
    _ = VariableListing(&context, "DEBUGUI_FamiliarFollowsHero");

    state.rootGroup = context.group.?;
}

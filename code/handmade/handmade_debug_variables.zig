const platform = @import("handmade_platform");

const debug = @import("handmade_debug.zig");

pub var debugVariableList = [_]debug.debug_variable{
    DebugVariableListing("DEBUGUI_UseDebugCamera"),
    DebugVariableListing("DEBUGUI_GroundChunkOutlines"),
    DebugVariableListing("DEBUGUI_ParticleTest"),
    DebugVariableListing("DEBUGUI_ParticleGrid"),
    DebugVariableListing("DEBUGUI_UseSpaceOutlines"),
    DebugVariableListing("DEBUGUI_GroundChunkCheckerboards"),
    DebugVariableListing("DEBUGUI_RecomputeGroundChunksOnExeChange"),
    DebugVariableListing("DEBUGUI_TestWeirdDrawBufferSize"),
    DebugVariableListing("DEBUGUI_FamiliarFollowsHero"),
    DebugVariableListing("DEBUGUI_ShowLightingSamples"),
    DebugVariableListing("DEBUGUI_UseRoomBasedCamera"),
};

fn DebugVariableListing(comptime name: [:0]const u8) debug.debug_variable {
    return debug.debug_variable{
        .type = .DebugVariableType_Boolean,
        .name = name,
        .value = @field(platform.config, name),
    };
}

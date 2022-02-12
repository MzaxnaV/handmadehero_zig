const std = @import("std");

const memory_index = @import("handmade_platform").memory_index;
const tile_map = @import("handmade_tile.zig").tile_map;
const tile_map_position = @import("handmade_tile.zig").tile_map_position;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const memory_arena = struct {
    size: memory_index,
    base: [*]u8,
    used: memory_index,
};

pub const world = struct {
    tileMap: *tile_map,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *world,

    playerP: tile_map_position = tile_map_position{},
    pixelPointer: [*]u32,
};

// functions ------------------------------------------------------------------------------------------------------------------------------

fn PushSize(arena: *memory_arena, size: memory_index) [*]u8 {
    std.debug.assert((arena.used + size) <= arena.size);
    const result = arena.base + arena.used;
    arena.used += size;

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn InitializeArena(arena: *memory_arena, size: memory_index, base: [*]u8) void {
    arena.size = size;
    arena.base = base;
    arena.used = 0;
}

pub inline fn PushStruct(comptime T: type, arena: *memory_arena) *T {
    return @ptrCast(*T, @alignCast(@alignOf(T), PushSize(arena, @sizeOf(T))));
}

pub inline fn PushArraySlice(comptime T: type, comptime count: memory_index, arena: *memory_arena) *[count]T {
    return @ptrCast(*[count]T, @alignCast(@alignOf(T), PushSize(arena, count * @sizeOf(T))));
}

pub inline fn PushArrayPtr(comptime T: type, count: memory_index, arena: *memory_arena) [*]T {
    return @ptrCast([*]T, @alignCast(@alignOf(T), PushSize(arena, count * @sizeOf(T))));
}

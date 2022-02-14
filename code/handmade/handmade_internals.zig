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

pub const loaded_bitmap = struct {
    width: i32 = 0,
    height: i32 = 0,
    pixels: extern union {
        // access individual colours
        colour: [*]u8,
        // access the whole pixel
        access: [*]u32,
    } = undefined,
};

pub const hero_bitmaps = struct {
    alignX: i32,
    alignY: i32,
    head: loaded_bitmap,
    cape: loaded_bitmap,
    torso: loaded_bitmap,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *world,

    cameraP: tile_map_position = tile_map_position{},
    playerP: tile_map_position = tile_map_position{},

    backdrop: loaded_bitmap,

    heroFacingDirection: u32,
    heroBitmaps: [4]hero_bitmaps,
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

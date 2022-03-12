const std = @import("std");

const CONTROLLERS = @import("handmade_platform").CONTROLLERS;
const memory_index = @import("handmade_platform").memory_index;
const tile_map = @import("handmade_tile.zig").tile_map;
const tile_map_position = @import("handmade_tile.zig").tile_map_position;
const v2 = @import("handmade_math.zig").v2;

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
        // NOTE (Manav):, access colours
        colour: [*]u8,
        // NOTE (Manav):, access pixel array
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

pub const high_entity = struct {
    p: v2 = .{},
    dP: v2 = .{},
    absTileZ: u32 = 0,
    facingDirection: u32 = 0,

    z: f32 = 0,
    dZ: f32 = 0,
};

pub const low_entity = struct {};

pub const entity_type = enum {
    Null,

    Hero,
    Wall,
};

pub const dormant_entity = struct {
    entityType: entity_type = .Null,
    p: tile_map_position = .{},
    width: f32 = 0,
    height: f32 = 0,

    collides: bool = false,
    dAbsTileZ: i32 = 0,
};

pub const entity_residence = enum(u2) {
    Nonexistent,
    Dormant,
    Low,
    High,
};

pub const entity = struct {
    residence: entity_residence = .Nonexistent,
    low: *low_entity,
    dormant: *dormant_entity,
    high: *high_entity,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *world,

    cameraFollowingEntityIndex: u32,
    cameraP: tile_map_position = tile_map_position{},

    playerIndexForController: [CONTROLLERS]u32,
    entityCount: u32,

    entityResidence: [256]entity_residence,
    highEntities: [256]high_entity,
    lowEntities: [256]low_entity,
    dormantEntities: [256]dormant_entity,

    backdrop: loaded_bitmap,
    shadow: loaded_bitmap,
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

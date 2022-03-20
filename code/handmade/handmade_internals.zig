const std = @import("std");

const CONTROLLERS = @import("handmade_platform").CONTROLLERS;
const memory_index = @import("handmade_platform").memory_index;
const sim_entity = @import("handmade_sim_region.zig").sim_entity;
const world_position = @import("handmade_world.zig").world_position;
const world = @import("handmade_world.zig").world;
const v2 = @import("handmade_math.zig").v2;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const memory_arena = struct {
    size: memory_index,
    base: [*]u8,
    used: memory_index,

    pub fn Initialize(self: *memory_arena, size: memory_index, base: [*]u8) void {
        self.size = size;
        self.base = base;
        self.used = 0;
    }

    inline fn PushSize(self: *memory_arena, size: memory_index) [*]u8 {
        std.debug.assert((self.used + size) <= self.size);
        const result = self.base + self.used;
        self.used += size;

        return result;
    }

    pub inline fn PushStruct(self: *memory_arena, comptime T: type) *T {
        return @ptrCast(*T, @alignCast(@alignOf(T), self.PushSize(@sizeOf(T))));
    }

    pub inline fn PushArraySlice(self: *memory_arena, comptime T: type, comptime count: memory_index) *[count]T {
        return @ptrCast(*[count]T, @alignCast(@alignOf(T), self.PushSize(count * @sizeOf(T))));
    }

    pub inline fn PushArrayPtr(self: *memory_arena, comptime T: type, count: memory_index) [*]T {
        return @ptrCast([*]T, @alignCast(@alignOf(T), self.PushSize(count * @sizeOf(T))));
    }
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
    alignment: v2,
    head: loaded_bitmap,
    cape: loaded_bitmap,
    torso: loaded_bitmap,
};

pub const low_entity = struct {
    p: world_position,
    sim: sim_entity,
};

pub const entity_visible_piece = struct {
    bitmap: ?*loaded_bitmap,
    offset: v2 = .{},
    offsetZ: f32 = 0,
    entityZC: f32 = 0,

    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,
    a: f32 = 0,

    dim: v2 = .{},
};

pub const entity_visible_piece_group = struct {
    gameState: *state,
    pieceCount: u32,
    pieces: [8]entity_visible_piece,
};

pub const controlled_hero = struct {
    entityIndex: u32 = 0,

    ddP: v2 = .{},
    dSword: v2 = .{},
    dZ: f32 = 0,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *world,

    cameraFollowingEntityIndex: u32,
    cameraP: world_position = .{},

    controlledHeroes: [CONTROLLERS]controlled_hero,

    lowEntityCount: u32,
    lowEntities: [100000]low_entity,

    backdrop: loaded_bitmap,
    shadow: loaded_bitmap,
    heroBitmaps: [4]hero_bitmaps,

    tree: loaded_bitmap,
    sword: loaded_bitmap,
    metersToPixels: f32,
};

// inline pub functions -------------------------------------------------------------------------------------------------------------------

inline fn ZeroSize(size: memory_index, ptr: [*]u8) void {
    var byte = ptr;
    var s = size;
    while (s > 0) : (s -= 1) {
        byte.* = 0;
        byte += 1;
    }
}

// NOTE (Manav): works for slices too.
pub inline fn ZeroStruct(comptime T: type, ptr: *T) void {
    ZeroSize(@sizeOf(T), @ptrCast([*]u8, ptr));
}

pub inline fn GetLowEntity(gameState: *state, index: u32) ?*low_entity {
    var result: ?*low_entity = null;

    if ((index > 0) and (index < gameState.lowEntityCount)) {
        result = &gameState.lowEntities[index];
    }

    return result;
}

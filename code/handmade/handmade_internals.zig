const std = @import("std");

const CONTROLLERS = @import("handmade_platform").CONTROLLERS;
const memory_index = @import("handmade_platform").memory_index;
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

    fn PushSize(self: *memory_arena, size: memory_index) [*]u8 {
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
    alignX: i32,
    alignY: i32,
    head: loaded_bitmap,
    cape: loaded_bitmap,
    torso: loaded_bitmap,
};

pub const high_entity = struct {
    p: v2 = .{},
    dP: v2 = .{},
    chunkZ: u32 = 0,
    facingDirection: u32 = 0,

    z: f32 = 0,
    dZ: f32 = 0,

    lowEntityIndex: u32 = 0,
};

pub const entity_type = enum {
    Null,

    Hero,
    Wall,
};

pub const low_entity = struct {
    entityType: entity_type = .Null,
    p: world_position = .{},
    width: f32 = 0,
    height: f32 = 0,

    collides: bool = false,
    dAbsTileZ: i32 = 0,

    highEntityIndex: u32 = 0,
};

pub const entity = struct {
    lowIndex: u32 = 0,
    low: *low_entity,
    high: ?*high_entity = null,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *world,

    cameraFollowingEntityIndex: u32,
    cameraP: world_position = .{},

    playerIndexForController: [CONTROLLERS]u32,

    lowEntityCount: u32,
    lowEntities: [100000]low_entity,

    highEntityCount: u32,
    highEntities: [256]high_entity,

    backdrop: loaded_bitmap,
    shadow: loaded_bitmap,
    heroBitmaps: [4]hero_bitmaps,

    tree: loaded_bitmap,
};

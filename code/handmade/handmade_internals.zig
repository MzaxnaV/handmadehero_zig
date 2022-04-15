const std = @import("std");

const CONTROLLERS = @import("handmade_platform").CONTROLLERS;
const memory_index = @import("handmade_platform").memory_index;
const sim_entity = @import("handmade_sim_region.zig").sim_entity;
const sim_entity_collision_volume_group = @import("handmade_sim_region.zig").sim_entity_collision_volume_group;
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

    pub inline fn PushSize(self: *memory_arena, size: memory_index) [*]u8 {
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
    pitch: i32 = 0,
    memory: [*]u8 = undefined,
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
    offset: v2 = v2{ 0, 0 },
    offsetZ: f32 = 0,
    entityZC: f32 = 0,

    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,
    a: f32 = 0,

    dim: v2 = v2{ 0, 0 },
};

pub const entity_visible_piece_group = struct {
    gameState: *state,
    pieceCount: u32,
    pieces: [32]entity_visible_piece,
};

pub const controlled_hero = struct {
    entityIndex: u32 = 0,

    ddP: v2 = v2{ 0, 0 },
    dSword: v2 = v2{ 0, 0 },
    dZ: f32 = 0,
};

pub const pairwise_collision_rule = struct {
    canCollide: bool,
    storageIndexA: u32,
    storageIndexB: u32,

    nextInHash: ?*pairwise_collision_rule,
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

    grass: [2]loaded_bitmap,
    stones: [4]loaded_bitmap,
    tufts: [3]loaded_bitmap,

    tree: loaded_bitmap,
    sword: loaded_bitmap,
    stairwell: loaded_bitmap,
    metersToPixels: f32,

    collisionRuleHash: [256]?*pairwise_collision_rule,
    firstFreeCollisionRule: ?*pairwise_collision_rule,

    nullCollision: *sim_entity_collision_volume_group,
    swordCollision: *sim_entity_collision_volume_group,
    stairCollision: *sim_entity_collision_volume_group,
    playerCollision: *sim_entity_collision_volume_group,
    monstarCollision: *sim_entity_collision_volume_group,
    familiarCollision: *sim_entity_collision_volume_group,
    wallCollision: *sim_entity_collision_volume_group,
    standardRoomCollision: *sim_entity_collision_volume_group,

    groundBuggerP: world_position,
    groundBuffer: loaded_bitmap,
};

// inline pub functions -------------------------------------------------------------------------------------------------------------------

pub inline fn ZeroSize(size: memory_index, ptr: [*]u8) void {
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

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn ClearCollisionRulesFor(gameState: *state, storageIndex: u32) void {
    var hashBucket = @as(u32, 0);
    while (hashBucket < gameState.collisionRuleHash.len) : (hashBucket += 1) {
        var collisionRule = &gameState.collisionRuleHash[hashBucket];
        while (collisionRule.*) |rule| {
            if ((rule.storageIndexA == storageIndex) or
                (rule.storageIndexB == storageIndex))
            {
                const removedRule = rule;
                collisionRule.* = rule.nextInHash;

                removedRule.nextInHash = gameState.firstFreeCollisionRule;
                gameState.firstFreeCollisionRule = removedRule;
            } else {
                collisionRule = &rule.nextInHash;
            }
        }
    }
}

pub fn AddCollisionRule(gameState: *state, unsortedStorageIndexA: u32, unsortedStorageIndexB: u32, canCollide: bool) void {
    var storageIndexA = unsortedStorageIndexA;
    var storageIndexB = unsortedStorageIndexB;
    if (storageIndexA > storageIndexB) {
        storageIndexA = unsortedStorageIndexB;
        storageIndexB = unsortedStorageIndexA;
    }

    var found: ?*pairwise_collision_rule = null;
    const hashBucket = storageIndexA & (gameState.collisionRuleHash.len - 1);
    var collisionRule: ?*pairwise_collision_rule = gameState.collisionRuleHash[hashBucket];
    while (collisionRule) |rule| : (collisionRule = rule.nextInHash) {
        if ((rule.storageIndexA == storageIndexA) and
            (rule.storageIndexB == storageIndexB))
        {
            found = rule;
            break;
        }
    }

    if (found) |_| {} else {
        found = gameState.firstFreeCollisionRule;
        if (found) |_| {
            gameState.firstFreeCollisionRule = found.?.nextInHash;
        } else {
            found = gameState.worldArena.PushStruct(pairwise_collision_rule);
        }
        found.?.nextInHash = gameState.collisionRuleHash[hashBucket];
        gameState.collisionRuleHash[hashBucket] = found;
    }

    if (found) |rule| {
        rule.canCollide = canCollide;
        rule.storageIndexA = storageIndexA;
        rule.storageIndexB = storageIndexB;
    }
}

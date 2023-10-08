const std = @import("std");

const platform = @import("handmade_platform");
const hsr = @import("handmade_sim_region.zig");
const hw = @import("handmade_world.zig");
const hm = @import("handmade_math.zig");
const hrg = @import("handmade_render_group.zig");

// game data types ------------------------------------------------------------------------------------------------------------------------

// NOTE: (Manav), make it extern temporarily so loaded_bitmap.memory in groundBuffers is aligned 
pub const memory_arena = extern struct {
    size: platform.memory_index,
    base_addr: platform.memory_index,
    used: platform.memory_index,
    tempCount: u32,

    pub inline fn Initialize(self: *memory_arena, size: platform.memory_index, base: [*]u8) void {
        self.size = size;
        self.base_addr = @intFromPtr(base);
        self.used = 0;
        self.tempCount = 0;
    }

    pub inline fn PushSize(self: *memory_arena, comptime alignment: u5, size: platform.memory_index) [*]align(alignment) u8 {
        const adjusted_addr = std.mem.alignForward(usize, self.base_addr + self.used, alignment);
        const padding = adjusted_addr - (self.base_addr + self.used);

        std.debug.assert((self.used + size + padding) <= self.size);
        const result = @as([*]align(alignment) u8, @ptrFromInt(adjusted_addr));
        self.used += size + padding;

        return result;
    }

    pub inline fn PushStruct(self: *memory_arena, comptime T: type) *T {
        return @as(*T, @ptrCast(self.PushSize(@alignOf(T), @sizeOf(T))));
    }

    pub inline fn PushSlice(self: *memory_arena, comptime T: type, comptime count: platform.memory_index) *[count]T {
        return @as(*[count]T, @ptrCast(self.PushSize(@alignOf(T), count * @sizeOf(*[]T))));
    }

    pub inline fn PushArray(self: *memory_arena, comptime T: type, count: platform.memory_index) [*]T {
        return @as([*]T, @ptrCast(self.PushSize(@alignOf(T), count * @sizeOf(T))));
    }

    pub inline fn CheckArena(self: *memory_arena) void {
        std.debug.assert(self.tempCount == 0);
    }
};

pub const temporary_memory = struct {
    arena: *memory_arena,
    used: platform.memory_index,
};

pub const hero_bitmaps = struct {
    head: hrg.loaded_bitmap,
    cape: hrg.loaded_bitmap,
    torso: hrg.loaded_bitmap,
};

pub const low_entity = struct {
    p: hw.world_position,
    sim: hsr.sim_entity,
};

pub const controlled_hero = struct {
    entityIndex: u32 = 0,

    ddP: hm.v2 = hm.v2{ 0, 0 },
    dSword: hm.v2 = hm.v2{ 0, 0 },
    dZ: f32 = 0,
};

pub const pairwise_collision_rule = struct {
    canCollide: bool,
    storageIndexA: u32,
    storageIndexB: u32,

    nextInHash: ?*pairwise_collision_rule,
};

// NOTE: (Manav), make it extern temporarily so loaded_bitmap.memory in groundBuffers is aligned 
pub const ground_buffer = extern struct {
    p: hw.world_position,
    bitmap: hrg.loaded_bitmap,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *hw.world,

    typicalFloorHeight: f32,

    cameraFollowingEntityIndex: u32,
    cameraP: hw.world_position = .{},

    controlledHeroes: [platform.CONTROLLERS]controlled_hero,

    lowEntityCount: u32,
    lowEntities: [100000]low_entity,

    backdrop: hrg.loaded_bitmap,
    shadow: hrg.loaded_bitmap,
    heroBitmaps: [4]hero_bitmaps,

    grass: [2]hrg.loaded_bitmap,
    stones: [4]hrg.loaded_bitmap,
    tufts: [3]hrg.loaded_bitmap,

    tree: hrg.loaded_bitmap,
    sword: hrg.loaded_bitmap,
    stairwell: hrg.loaded_bitmap,

    collisionRuleHash: [256]?*pairwise_collision_rule,
    firstFreeCollisionRule: ?*pairwise_collision_rule,

    nullCollision: *hsr.sim_entity_collision_volume_group,
    swordCollision: *hsr.sim_entity_collision_volume_group,
    stairCollision: *hsr.sim_entity_collision_volume_group,
    playerCollision: *hsr.sim_entity_collision_volume_group,
    monstarCollision: *hsr.sim_entity_collision_volume_group,
    familiarCollision: *hsr.sim_entity_collision_volume_group,
    wallCollision: *hsr.sim_entity_collision_volume_group,
    standardRoomCollision: *hsr.sim_entity_collision_volume_group,

    time: f32,

    testDiffuse: hrg.loaded_bitmap,
    testNormal: hrg.loaded_bitmap,
};

// NOTE: (Manav), make it extern temporarily so loaded_bitmap.memory in groundBuffers is aligned 
pub const transient_state = extern struct {
    initialized: bool,
    tranArena: memory_arena,
    groundBufferCount: u32,
    groundBuffers: [*]ground_buffer,

    renderQueue: *platform.work_queue,

    envMapWidth: u32,
    envMapHeight: u32,
    envMaps: [3]hrg.environment_map,
};

// inline pub functions -------------------------------------------------------------------------------------------------------------------

pub inline fn ZeroSize(size: platform.memory_index, ptr: [*]u8) void {
    @memset(ptr[0..size], 0);

    //@memset(ptr, 0, size);

    // NOTE (Manav): this is slow :/, use memset
    // var byte = ptr;
    // var s = size;
    // while (s > 0) : (s -= 1) {
    //     byte.* = 0;
    //     byte += 1;
    // }
}

pub inline fn BeginTemporaryMemory(arena: *memory_arena) temporary_memory {
    var result = temporary_memory{
        .arena = arena,
        .used = arena.used,
    };

    result.arena.tempCount += 1;

    return result;
}

pub inline fn EndTemporaryMemory(tempMem: temporary_memory) void {
    var arena = tempMem.arena;
    std.debug.assert(arena.used >= tempMem.used);
    arena.used = tempMem.used;
    std.debug.assert(tempMem.arena.tempCount > 0);
    arena.tempCount -= 1;
}

// NOTE (Manav): works for slices too.
pub inline fn ZeroStruct(comptime T: type, ptr: *T) void {
    ZeroSize(@sizeOf(T), @as([*]u8, @ptrCast(ptr)));
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

// TODO (Manav): this is weird, we already have a function pointer in gameMemory
pub var PlatformAddEntry: platform.add_entry = undefined;
pub var PlatformCompleteAllWork: platform.complete_all_work = undefined;

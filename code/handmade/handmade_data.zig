const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_sim_region.zig");
    usingnamespace @import("handmade_world.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade_asset.zig");
};

const hi = platform.handmade_internal;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const memory_arena = struct {
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

    pub inline fn PushSize(self: *memory_arena, size: platform.memory_index) [*]align(@alignOf(u32)) u8 {
        return self.PushSizeAlign(@alignOf(u32), size);
    }

    pub inline fn PushSizeAlign(self: *memory_arena, comptime alignment: u5, sizeInit: platform.memory_index) [*]align(alignment) u8 {
        const alignmentOffset = self.GetAlignmentOffset(alignment);

        const size = sizeInit + alignmentOffset;
        platform.Assert((self.used + size) <= self.size);

        const result: [*]align(alignment) u8 = @ptrFromInt(self.base_addr + self.used + alignmentOffset);
        self.used += size;

        platform.Assert(size >= sizeInit);

        return result;
    }

    pub inline fn GetAlignmentOffset(self: *memory_arena, comptime alignment: u5) platform.memory_index {
        const resultPointer = self.base_addr + self.used;
        const alignmentMask = alignment - 1;

        const alignmentOffset = if ((resultPointer & alignmentMask) != 0) alignment - (resultPointer & alignmentMask) else 0;

        return alignmentOffset;
    }

    pub inline fn GetSizeRemaining(self: *memory_arena, comptime alignment: u5) platform.memory_index {
        const result = self.size - (self.used + self.GetAlignmentOffset(alignment));

        return result;
    }

    pub inline fn PushStruct(self: *memory_arena, comptime T: type) *T {
        return @as(*T, @ptrCast(self.PushSizeAlign(@alignOf(T), @sizeOf(T))));
    }

    pub inline fn PushSlice(self: *memory_arena, comptime T: type, count: platform.memory_index) []T {
        return self.PushArray(T, count)[0..count];
    }

    pub inline fn PushArray(self: *memory_arena, comptime T: type, count: platform.memory_index) [*]T {
        return @as([*]T, @ptrCast(self.PushSizeAlign(@alignOf(T), count * @sizeOf(T))));
    }

    pub inline fn CheckArena(self: *memory_arena) void {
        platform.Assert(self.tempCount == 0);
    }

    /// Initialize arena of given `size` from `parentArena`.
    ///
    /// Defaults: `alignment = 16`
    pub inline fn SubArena(self: *memory_arena, parentArena: *memory_arena, alignment: u5, size: platform.memory_index) void {
        self.size = size;
        self.base_addr = @intFromPtr(parentArena.PushSizeAlign(alignment, size));
        self.used = 0;
        self.tempCount = 0;
    }
};

pub const temporary_memory = struct {
    arena: *memory_arena,
    used: platform.memory_index,
};

pub const low_entity = struct {
    p: h.world_position,
    sim: h.sim_entity,
};

pub const controlled_hero = struct {
    entityIndex: u32 = 0,

    ddP: h.v2 = h.v2{ 0, 0 },
    dSword: h.v2 = h.v2{ 0, 0 },
    dZ: f32 = 0,
};

pub const pairwise_collision_rule = struct {
    canCollide: bool,
    storageIndexA: u32,
    storageIndexB: u32,

    nextInHash: ?*pairwise_collision_rule,
};

pub const ground_buffer = struct {
    p: h.world_position,
    bitmap: h.loaded_bitmap,
};

pub const hero_bitmap_ids = struct {
    head: h.bitmap_id,
    cape: h.bitmap_id,
    torso: h.bitmap_id,
};

pub const playing_sound = struct {
    volume: [2]f32,
    ID: h.sound_id,
    samplesPlayed: i32,
    next: ?*playing_sound,
};

pub const game_state = struct {
    isInitialized: bool = false,

    metaArena: memory_arena,
    worldArena: memory_arena,
    world: *h.world,

    typicalFloorHeight: f32,

    cameraFollowingEntityIndex: u32,
    cameraP: h.world_position = .{},

    controlledHeroes: [platform.CONTROLLERS]controlled_hero,

    lowEntityCount: u32,
    lowEntities: [100000]low_entity,

    collisionRuleHash: [256]?*pairwise_collision_rule,
    firstFreeCollisionRule: ?*pairwise_collision_rule,

    nullCollision: *h.sim_entity_collision_volume_group,
    swordCollision: *h.sim_entity_collision_volume_group,
    stairCollision: *h.sim_entity_collision_volume_group,
    playerCollision: *h.sim_entity_collision_volume_group,
    monstarCollision: *h.sim_entity_collision_volume_group,
    familiarCollision: *h.sim_entity_collision_volume_group,
    wallCollision: *h.sim_entity_collision_volume_group,
    standardRoomCollision: *h.sim_entity_collision_volume_group,

    time: f32,

    testDiffuse: h.loaded_bitmap,
    testNormal: h.loaded_bitmap,

    generalEntropy: h.random_series,
    tSine: f32,

    firstPlayingSound: ?*playing_sound,
    firstFreePlayingSound: ?*playing_sound,
};

pub const task_with_memory = struct {
    beingUsed: bool,
    arena: memory_arena,
    memoryFlush: temporary_memory,
};

pub const transient_state = struct {
    initialized: bool,
    tranArena: memory_arena,

    tasks: [4]task_with_memory,

    assets: *h.game_assets,

    groundBufferCount: u32,
    groundBuffers: [*]ground_buffer,

    highPriorityQueue: *platform.work_queue,
    lowPriorityQueue: *platform.work_queue,

    envMapWidth: u32,
    envMapHeight: u32,
    envMaps: [3]h.environment_map,
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
    platform.Assert(arena.used >= tempMem.used);
    arena.used = tempMem.used;
    platform.Assert(tempMem.arena.tempCount > 0);
    arena.tempCount -= 1;
}

// NOTE (Manav): works for slices too.
pub inline fn ZeroStruct(comptime T: type, ptr: *T) void {
    ZeroSize(@sizeOf(T), @as([*]u8, @ptrCast(ptr)));
}

pub inline fn GetLowEntity(gameState: *game_state, index: u32) ?*low_entity {
    var result: ?*low_entity = null;

    if ((index > 0) and (index < gameState.lowEntityCount)) {
        result = &gameState.lowEntities[index];
    }

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn ClearCollisionRulesFor(gameState: *game_state, storageIndex: u32) void {
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

pub fn AddCollisionRule(gameState: *game_state, unsortedStorageIndexA: u32, unsortedStorageIndexB: u32, canCollide: bool) void {
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

pub var DEBUGPlatformReadEntireFile: ?hi.debug_platform_read_entire_file = null;

// NOTE (Manav): the below two pointers are weird, we already have a function pointer in gameMemory
pub var PlatformAddEntry: platform.add_entry = undefined;
pub var PlatformCompleteAllWork: platform.complete_all_work = undefined;

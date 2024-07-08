const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_math.zig");

    usingnamespace @import("handmade_audio.zig");
    usingnamespace @import("handmade_asset.zig");
    usingnamespace @import("handmade_file_formats.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade_sim_region.zig");
    usingnamespace @import("handmade_world.zig");
};

const hi = platform.handmade_internal;

// global variables -----------------------------------------------------------------------------------------------------------------------

pub var platformAPI: platform.api = undefined;

// data types -----------------------------------------------------------------------------------------------------------------------------

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

    pub fn PushSizeAlign(self: *memory_arena, comptime alignment: u5, sizeInit: platform.memory_index) [*]align(alignment) u8 {
        const alignmentOffset = self.GetAlignmentOffset(alignment);

        const size = sizeInit + alignmentOffset;
        platform.Assert((self.used + size) <= self.size);

        const result: [*]align(alignment) u8 = @ptrFromInt(self.base_addr + self.used + alignmentOffset);
        self.used += size;

        platform.Assert(size >= sizeInit);

        return result;
    }

    pub inline fn GetAlignmentOffset(self: *memory_arena, comptime alignment: u5) platform.memory_index {
        return platform.GetAlignForwardOffset(self.base_addr + self.used, alignment);
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

    pub fn CheckArena(self: *memory_arena) void {
        platform.Assert(self.tempCount == 0);
    }

    pub fn PushString(self: *memory_arena, source: [*:0]const u8) [*:0]const u8 {
        var size: platform.memory_index = 0;

        while (source[size] != 0) : (size += 1) {}

        var dest: [*]u8 = self.PushSize(size + 1);

        for (0..size) |index| {
            dest[index] = source[index];
        }

        dest[size] = 0;

        return @ptrCast(dest);
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

pub const particle_cel = struct {
    density: f32,
    velocityTimesDensity: h.v3,
};

pub const PARTICLE_CEL_DIM = 32;

pub const particle = struct {
    p: h.v3,
    dP: h.v3,
    ddP: h.v3,
    colour: h.v4,
    dColour: h.v4,
    bitmapID: h.bitmap_id,
};

pub const game_state = struct {
    isInitialized: bool = false,

    metaArena: memory_arena,
    worldArena: memory_arena,
    world: *h.world,

    typicalFloorHeight: f32,

    cameraFollowingEntityIndex: u32,
    cameraP: h.world_position = .{},
    lastCameraP: h.world_position,

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

    effectsEntropy: h.random_series,
    tSine: f32,

    audioState: h.audio_state,
    music: ?*h.playing_sound,

    nextParticle: u32,
    particles: [256]particle,
    particleCels: [PARTICLE_CEL_DIM][PARTICLE_CEL_DIM]particle_cel,
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

    groundBuffers: []ground_buffer,

    highPriorityQueue: *platform.work_queue,
    lowPriorityQueue: *platform.work_queue,

    envMapWidth: u32,
    envMapHeight: u32,
    envMaps: [3]h.environment_map,
};

// inline pub functions -------------------------------------------------------------------------------------------------------------------

pub inline fn ZeroSize(size: platform.memory_index, ptr: [*]u8) void {
    @memset(ptr[0..size], 0);
}

pub inline fn ZeroSlice(comptime T: type, slice: []T) void {
    const ptr: [*]u8 = @ptrCast(slice.ptr);
    @memset(ptr[0 .. slice.len * @sizeOf(T)], 0);
}

pub inline fn ZeroStruct(comptime T: type, ptr: *T) void {
    ZeroSize(@sizeOf(T), @as([*]u8, @ptrCast(ptr)));
}

pub inline fn Copy(size: usize, source: *const anyopaque, dest: *anyopaque) void {
    const d: [*]u8 = @ptrCast(dest);
    const s: [*]const u8 = @ptrCast(source);

    @memcpy(d[0..size], s[0..size]);

    // // NOTE (Manav): loop below is incredibly slow.
    // for (@as([*]const u8, @ptrCast(source))[0..size], 0..) |byte, index| {
    //     @as([*]u8, @ptrCast(dest))[index] = byte;
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

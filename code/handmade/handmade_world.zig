const platform = @import("handmade_platform");
const debug = @import("debug");
const assert = platform.Assert;

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_entity.zig");
    usingnamespace @import("handmade_sim_region.zig");
    usingnamespace @import("handmade_intrinsics.zig");
};

// constants ------------------------------------------------------------------------------------------------------------------------------

const TILE_CHUNK_SAFE_MARGIN = platform.MAXINT32 / 64;
const TILE_CHUNK_UNINITIALIZED = platform.MAXINT32;

const TILES_PER_CHUNK = 8;

// tile data types ------------------------------------------------------------------------------------------------------------------------

pub const world_position = struct {
    chunkX: i32 = 0,
    chunkY: i32 = 0,
    chunkZ: i32 = 0,

    offset_: h.v3 = h.v3{ 0, 0, 0 },
};

pub const world_entity_block = struct {
    entityCount: u32,
    lowEntityIndex: [16]u32,
    next: ?*world_entity_block,
};

pub const world_chunk = struct {
    chunkX: i32,
    chunkY: i32,
    chunkZ: i32,

    firstBlock: world_entity_block,

    nextInHash: ?*world_chunk = null,
};

pub const world = struct {
    chunkDimInMeters: h.v3,

    firstFree: ?*world_entity_block,

    chunkHash: [4096]world_chunk,
};

// public inline functions ----------------------------------------------------------------------------------------------------------------

pub inline fn NullPosition() world_position {
    const result: world_position = .{
        .chunkX = TILE_CHUNK_UNINITIALIZED,
    };
    return result;
}

pub inline fn IsValid(p: world_position) bool {
    const result = p.chunkX != TILE_CHUNK_UNINITIALIZED;
    return result;
}

inline fn IsCanonicalCoord(chunkDim: f32, tileRel: f32) bool {
    const epsilon = 0.01;
    const result = (tileRel >= -(0.5 * chunkDim + epsilon)) and (tileRel <= (0.5 * chunkDim + epsilon));
    return result;
}

pub inline fn IsCanonical(w: *const world, offset: h.v3) bool {
    const chunkDimInMeters = w.chunkDimInMeters;
    const result = (IsCanonicalCoord(h.X(chunkDimInMeters), h.X(offset)) and
        IsCanonicalCoord(h.Y(chunkDimInMeters), h.Y(offset)) and
        IsCanonicalCoord(h.Z(chunkDimInMeters), h.Z(offset)));
    return result;
}

pub inline fn AreInSameChunk(w: *const world, a: *const world_position, b: *const world_position) bool {
    assert(IsCanonical(w, a.offset_));
    assert(IsCanonical(w, b.offset_));

    const result = (a.chunkX == b.chunkX) and (a.chunkY == b.chunkY) and (a.chunkZ == b.chunkZ);
    return result;
}

pub fn GetWorldChunk(memoryArena: ?*h.memory_arena, w: *world, chunkX: i32, chunkY: i32, chunkZ: i32) ?*world_chunk {
    debug.TIMED_BLOCK(.{});
    // AUTOGENERATED ----------------------------------------------------------
    const __t_blk__25 = debug.TIMED_BLOCK__impl(25, @src()).Init(.{});
    defer __t_blk__25.End();
    // AUTOGENERATED ----------------------------------------------------------

    assert(chunkX > -TILE_CHUNK_SAFE_MARGIN);
    assert(chunkY > -TILE_CHUNK_SAFE_MARGIN);
    assert(chunkZ > -TILE_CHUNK_SAFE_MARGIN);
    assert(chunkX < TILE_CHUNK_SAFE_MARGIN);
    assert(chunkY < TILE_CHUNK_SAFE_MARGIN);
    assert(chunkZ < TILE_CHUNK_SAFE_MARGIN);

    const hashValue = @as(u32, @bitCast(19 * chunkX + 7 * chunkY + 3 * chunkZ));
    const hashSlot = hashValue & (w.chunkHash.len - 1);
    assert(hashSlot < w.chunkHash.len);

    var worldChunk: ?*world_chunk = &w.chunkHash[hashSlot];

    while (worldChunk) |*chunk| {
        if ((chunkX == chunk.*.chunkX) and (chunkY == chunk.*.chunkY) and (chunkZ == chunk.*.chunkZ)) {
            break;
        }

        if (memoryArena) |arena| {
            if ((chunk.*.chunkX != TILE_CHUNK_UNINITIALIZED) and (chunk.*.nextInHash == null)) {
                chunk.*.nextInHash = arena.PushStruct(world_chunk);
                worldChunk = chunk.*.nextInHash;
                chunk.*.chunkX = TILE_CHUNK_UNINITIALIZED;
            }

            if (chunk.*.chunkX == TILE_CHUNK_UNINITIALIZED) {
                chunk.*.chunkX = chunkX;
                chunk.*.chunkY = chunkY;
                chunk.*.chunkZ = chunkZ;

                chunk.*.nextInHash = null;
                break;
            }
        }

        worldChunk = chunk.*.nextInHash;
    }

    return worldChunk;
}

inline fn RecanonicalizeCoord(chunkDim: f32, tile: *i32, tileRel: *f32) void {
    const offSet = h.RoundF32ToInt(i32, tileRel.* / chunkDim);
    tile.* +%= offSet;
    tileRel.* -= @as(f32, @floatFromInt(offSet)) * chunkDim;

    assert(IsCanonicalCoord(chunkDim, tileRel.*));
}

pub inline fn MapIntoChunkSpace(w: *const world, basePos: world_position, offset: h.v3) world_position {
    var result = basePos;

    h.AddTo(&result.offset_, offset); // NOTE (Manav): result.offset_ += offset

    RecanonicalizeCoord(w.chunkDimInMeters[0], &result.chunkX, &result.offset_[0]);
    RecanonicalizeCoord(w.chunkDimInMeters[1], &result.chunkY, &result.offset_[1]);
    RecanonicalizeCoord(w.chunkDimInMeters[2], &result.chunkZ, &result.offset_[2]);

    return result;
}

pub inline fn Substract(w: *const world, a: *const world_position, b: *const world_position) h.v3 {
    const dTile = h.v3{
        @as(f32, @floatFromInt(a.chunkX)) - @as(f32, @floatFromInt(b.chunkX)),
        @as(f32, @floatFromInt(a.chunkY)) - @as(f32, @floatFromInt(b.chunkY)),
        @as(f32, @floatFromInt(a.chunkZ)) - @as(f32, @floatFromInt(b.chunkZ)),
    };

    const result = h.Add(h.Hammard(w.chunkDimInMeters, dTile), h.Sub(a.offset_, b.offset_));

    return result;
}

pub inline fn CenteredChunkPoint(chunkX: i32, chunkY: i32, chunkZ: i32) world_position {
    const result = world_position{
        .chunkX = chunkX,
        .chunkY = chunkY,
        .chunkZ = chunkZ,
    };

    return result;
}

// pub inline fn CenteredChunkPoint(chunk: *world_chunk) world_position {
//     const result = world_position {
//         .chunkX = chunk.chunkX,
//         .chunkY = chunk.chunkY,
//         .chunkZ = chunk.chunkZ,
//     };

//     return result;
// }

pub fn ChangeEntityLocationRaw(arena: *h.memory_arena, w: *world, lowEntityIndex: u32, oldP: ?*const world_position, newP: ?*const world_position) void {
    debug.TIMED_BLOCK(.{});
    // AUTOGENERATED ----------------------------------------------------------
    const __t_blk__26 = debug.TIMED_BLOCK__impl(26, @src()).Init(.{});
    defer __t_blk__26.End();
    // AUTOGENERATED ----------------------------------------------------------
    assert((oldP == null) or IsValid(oldP.?.*));
    assert((newP == null) or IsValid(newP.?.*));

    if ((oldP != null) and (newP != null) and AreInSameChunk(w, oldP.?, newP.?)) {} else {
        if (oldP) |p| {
            if (GetWorldChunk(null, w, p.chunkX, p.chunkY, p.chunkZ)) |chunk| {
                var notFound = true;
                var firstBlock = &chunk.firstBlock;
                var entityBlock: ?*world_entity_block = firstBlock;
                while (entityBlock) |block| : (entityBlock = block.next) {
                    if (!notFound) {
                        break;
                    }
                    var index = @as(u32, 0);
                    while ((index < block.entityCount) and notFound) : (index += 1) {
                        if ((block.lowEntityIndex[index] == lowEntityIndex)) {
                            assert(firstBlock.entityCount > 0);
                            firstBlock.entityCount -= 1;
                            block.lowEntityIndex[index] = firstBlock.lowEntityIndex[firstBlock.entityCount];
                            if (firstBlock.entityCount == 0) {
                                if (firstBlock.next) |_| {
                                    const nextBlock = firstBlock.next;
                                    firstBlock.* = nextBlock.?.*;

                                    nextBlock.?.next = w.firstFree;
                                    w.firstFree = nextBlock;
                                }
                            }

                            notFound = false;
                        }
                    }
                }
            } else {
                platform.InvalidCodePath("");
            }
        }

        if (newP) |p| {
            if (GetWorldChunk(arena, w, p.chunkX, p.chunkY, p.chunkZ)) |chunk| {
                var block = &chunk.firstBlock;
                if (block.entityCount == block.lowEntityIndex.len) {
                    var oldBlock = w.firstFree;
                    if (oldBlock) |b| {
                        w.firstFree = b.next;
                    } else {
                        oldBlock = arena.PushStruct(world_entity_block);
                    }

                    oldBlock.?.* = block.*;
                    block.next = oldBlock;
                    block.entityCount = 0;
                }

                assert(block.entityCount < block.lowEntityIndex.len);
                block.lowEntityIndex[block.entityCount] = lowEntityIndex;
                block.entityCount += 1;
            } else {
                platform.InvalidCodePath("");
            }
        }
    }
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn ChangeEntityLocation(arena: *h.memory_arena, w: *world, lowEntityIndex: u32, lowEntity: *h.low_entity, newPInit: world_position) void {
    debug.TIMED_BLOCK(.{});
    // AUTOGENERATED ----------------------------------------------------------
    const __t_blk__27 = debug.TIMED_BLOCK__impl(27, @src()).Init(.{});
    defer __t_blk__27.End();
    // AUTOGENERATED ----------------------------------------------------------

    var oldP: ?*const world_position = null;
    var newP: ?*const world_position = null;

    if (!h.IsSet(&lowEntity.sim, @intFromEnum(h.sim_entity_flags.NonSpatial)) and IsValid(lowEntity.p)) {
        oldP = &lowEntity.p;
    }

    if (IsValid(newPInit)) {
        newP = &newPInit;
    }

    ChangeEntityLocationRaw(arena, w, lowEntityIndex, oldP, newP);

    if (newP) |p| {
        lowEntity.p = p.*;
        h.ClearFlags(&lowEntity.sim, @intFromEnum(h.sim_entity_flags.NonSpatial));
    } else {
        lowEntity.p = NullPosition();
        h.AddFlags(&lowEntity.sim, @intFromEnum(h.sim_entity_flags.NonSpatial));
    }
}

pub fn InitializeWorld(w: *world, chunkDimInMeters: h.v3) void {
    w.chunkDimInMeters = chunkDimInMeters;
    w.firstFree = null;

    for (&w.chunkHash) |*chunk| {
        chunk.chunkX = TILE_CHUNK_UNINITIALIZED;
        chunk.firstBlock.entityCount = 0;
    }
}

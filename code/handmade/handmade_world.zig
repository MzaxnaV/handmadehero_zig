const std = @import("std");
const assert = std.debug.assert;

const math = @import("handmade_math.zig");
const memory_arena = @import("handmade_internals.zig").memory_arena;
const RoundF32ToInt = @import("handmade_intrinsics.zig").RoundF32ToInt;

// constants ------------------------------------------------------------------------------------------------------------------------------

const TILE_CHUNK_SAFE_MARGIN = std.math.maxInt(i32) / 64;
const TILE_CHUNK_UNINITIALIZED = std.math.maxInt(i32);

const TILES_PER_CHUNK = 16;

// tile data types ------------------------------------------------------------------------------------------------------------------------

pub const world_difference = struct {
    dXY: math.v2 = .{},
    dZ: f32 = 0,
};

pub const world_position = struct {
    chunkX: i32 = 0,
    chunkY: i32 = 0,
    chunkZ: i32 = 0,

    offset_: math.v2 = .{},
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
    tileSideInMeters: f32,
    chunkSideInMeters: f32,

    firstFree: ?*world_entity_block,
    chunkHash: [4096]world_chunk,
};

// public inline functions ----------------------------------------------------------------------------------------------------------------

inline fn IsCanonicalCoord(w: *const world, tileRel: f32) bool {
    const result = (tileRel >= -0.5 * w.chunkSideInMeters) and (tileRel <= 0.5 * w.chunkSideInMeters);
    return result;
}

inline fn IsCanonical(w: *const world, offset: math.v2) bool {
    const result = IsCanonicalCoord(w, offset.x) and IsCanonicalCoord(w, offset.y);
    return result;
}

inline fn AreInSameChunk(w: *const world, a: *const world_position, b: *const world_position) bool {
    assert(IsCanonical(w, a.offset_));
    assert(IsCanonical(w, b.offset_));

    const result = (a.chunkX == b.chunkX) and (a.chunkY == b.chunkY) and (a.chunkZ == b.chunkZ);
    return result;
}

pub fn GetWorldChunk(memoryArena: ?*memory_arena, w: *world, chunkX: i32, chunkY: i32, chunkZ: i32) ?*world_chunk {
    assert(chunkX > -TILE_CHUNK_SAFE_MARGIN);
    assert(chunkY > -TILE_CHUNK_SAFE_MARGIN);
    assert(chunkZ > -TILE_CHUNK_SAFE_MARGIN);
    assert(chunkX < TILE_CHUNK_SAFE_MARGIN);
    assert(chunkY < TILE_CHUNK_SAFE_MARGIN);
    assert(chunkZ < TILE_CHUNK_SAFE_MARGIN);

    const hashValue = @bitCast(u32, 19 * chunkX + 7 * chunkY + 3 * chunkZ);
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

inline fn RecanonicalizeCoord(w: *const world, tile: *i32, tileRel: *f32) void {
    var offSet = RoundF32ToInt(i32, tileRel.* / w.chunkSideInMeters);
    tile.* +%= offSet;
    tileRel.* -= @intToFloat(f32, offSet) * w.chunkSideInMeters;

    assert(IsCanonicalCoord(w, tileRel.*));
}

pub inline fn MapIntoChunkSpace(w: *const world, basePos: world_position, offset: math.v2) world_position {
    var result = basePos;

    _ = result.offset_.Add(offset); // NOTE (Manav): result.offset_ += offset

    RecanonicalizeCoord(w, &result.chunkX, &result.offset_.x);
    RecanonicalizeCoord(w, &result.chunkY, &result.offset_.y);

    return result;
}

pub inline fn ChunkPosFromTilePos(w: *world, absTileX: i32, absTileY: i32, absTileZ: i32) world_position {
    const result = world_position{
        .chunkX = @divTrunc(absTileX, TILES_PER_CHUNK),
        .chunkY = @divTrunc(absTileY, TILES_PER_CHUNK),
        .chunkZ = @divTrunc(absTileZ, TILES_PER_CHUNK),

        .offset_ = .{
            // check against mod use
            .x = @intToFloat(f32, @rem(absTileX, TILES_PER_CHUNK)) * w.tileSideInMeters,
            .y = @intToFloat(f32, @rem(absTileY, TILES_PER_CHUNK)) * w.tileSideInMeters,
        },
    };
    return result;
}

pub inline fn Substract(w: *const world, a: *const world_position, b: *const world_position) world_difference {
    const dTileXY = .{
        .x = @intToFloat(f32, a.chunkX) - @intToFloat(f32, b.chunkX),
        .y = @intToFloat(f32, a.chunkY) - @intToFloat(f32, b.chunkY),
    };
    const dTileZ = @intToFloat(f32, a.chunkZ) - @intToFloat(f32, b.chunkZ);

    const result = world_difference{
        // NOTE (Manav): .dxy = w.chunkSideInMeters * dTileXY  + (a.offset_ - b.offset_)
        .dXY = math.Add(math.Scale(dTileXY, w.chunkSideInMeters), math.Sub(a.offset_, b.offset_)),
        .dZ = w.chunkSideInMeters * dTileZ,
    };

    return result;
}

inline fn CenteredChunkPoint(chunkX: u32, chunkY: u32, chunkZ: u32) world_position {
    const result = world_position{
        .chunkX = @intCast(i32, chunkX),
        .chunkY = @intCast(i32, chunkY),
        .chunkZ = @intCast(i32, chunkZ),
    };

    return result;
}

pub fn ChangeEntityLocation(arena: *memory_arena, w: *world, lowEntityIndex: u32, oldP: ?*const world_position, newP: *const world_position) void {
    if ((oldP != null) and AreInSameChunk(w, &(oldP.?.*), newP)) {} else {
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
                unreachable;
            }
        }

        if (GetWorldChunk(arena, w, newP.chunkX, newP.chunkY, newP.chunkZ)) |chunk| {
            var block = &chunk.firstBlock;
            if (block.entityCount == block.lowEntityIndex.len) {
                var oldBlock = w.firstFree;
                if (oldBlock) |_| {
                    w.firstFree = oldBlock.?.next;
                } else {
                    oldBlock = arena.PushStruct(world_entity_block);
                }

                oldBlock.?.* = block.*;
                block.next = oldBlock;
                block.entityCount = 0;
            }

            block.lowEntityIndex[block.entityCount] = lowEntityIndex;
            block.entityCount += 1;
        } else {
            unreachable;
        }
    }
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn InitializeWorld(w: *world, tileSideInMeters: f32) void {
    w.tileSideInMeters = tileSideInMeters;
    w.chunkSideInMeters = TILES_PER_CHUNK * tileSideInMeters;
    w.firstFree = null;

    for (w.chunkHash) |*chunk| {
        chunk.chunkX = TILE_CHUNK_UNINITIALIZED;
        chunk.firstBlock.entityCount = 0;
    }
}

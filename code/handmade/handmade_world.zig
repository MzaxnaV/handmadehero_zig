const std = @import("std");
const assert = std.debug.assert;

const math = @import("handmade_math.zig");
const memory_arena = @import("handmade_internals.zig").memory_arena;
const PushStruct = @import("handmade_internals.zig").PushStruct;
const RoundF32ToInt = @import("handmade_intrinsics.zig").RoundF32ToInt;

// constants ------------------------------------------------------------------------------------------------------------------------------

const TILE_CHUNK_SAFE_MARGIN = std.math.maxInt(i32) / 64;
const TILE_CHUNK_UNINITIALIZED = std.math.maxInt(i32);

// tile data types ------------------------------------------------------------------------------------------------------------------------

pub const world_difference = struct {
    dXY: math.v2 = .{},
    dZ: f32 = 0,
};

pub const world_position = struct {
    absTileX: i32 = 0,
    absTileY: i32 = 0,
    absTileZ: i32 = 0,

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

    chunkShift: i32, // NOTE (Manav): should this be u5?
    chunkMask: i32,
    chunkDim: i32,

    chunkHash: [4096]world_chunk,
};

// public inline functions ----------------------------------------------------------------------------------------------------------------

fn GetWorldChunk(memoryArena: ?*memory_arena, w: *world, chunkX: i32, chunkY: i32, chunkZ: i32) ?*world_chunk {
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
            if ((chunk.*.chunkX != TILE_CHUNK_UNINITIALIZED) and (chunk.*.nextInHash != null)) {
                chunk.*.nextInHash = PushStruct(world_chunk, arena);
                worldChunk = chunk.*.nextInHash;
                chunk.*.chunkX = TILE_CHUNK_UNINITIALIZED;
            }

            if (chunk.*.chunkX == TILE_CHUNK_UNINITIALIZED) {
                // const tileCount = @intCast(u32, world.chunkDim * world.chunkDim);

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

// !NOT_IGNORE
// inline fn GetChunkPositionFor(tileMap: *const tile_map, absTileX: u32, absTileY: u32, absTileZ: u32) tile_chunk_position {
//     const result = tile_chunk_position{
//         .tileChunkX = @intCast(i32, absTileX) >> @intCast(u5, tileMap.chunkShift),
//         .tileChunkY = @intCast(i32, absTileY) >> @intCast(u5, tileMap.chunkShift),
//         .tileChunkZ = @intCast(i32, absTileZ),
//         .relTileX = @intCast(i32, absTileX) & tileMap.chunkMask,
//         .relTileY = @intCast(i32, absTileY) & tileMap.chunkMask,
//     };

//     return result;
// }

inline fn RecanonicalizeCoord(w: *const world, tile: *i32, tileRel: *f32) void {
    const offSet = RoundF32ToInt(i32, tileRel.* / w.tileSideInMeters);
    tile.* +%= offSet;
    tileRel.* -= @intToFloat(f32, offSet) * w.tileSideInMeters;

    assert(tileRel.* > -0.5 * w.tileSideInMeters);
    assert(tileRel.* < 0.5 * w.tileSideInMeters);
}

pub inline fn MapIntoTileSpace(w: *const world, basePos: world_position, offset: math.v2) world_position {
    var result = basePos;

    _ = result.offset_.add(offset); // NOTE (Manav): result.offset_ += offset

    RecanonicalizeCoord(w, &result.absTileX, &result.offset_.x);
    RecanonicalizeCoord(w, &result.absTileY, &result.offset_.y);

    return result;
}

inline fn AreOnSameTile(a: *const world_position, b: *const world_position) bool {
    const result = ((a.absTileX == b.absTileX) and (a.absTileY == b.absTileY) and (a.absTileZ == b.absTileZ));
    return result;
}

pub inline fn Substract(w: *const world, a: *const world_position, b: *const world_position) world_difference {
    const dTileXY = .{
        .x = @intToFloat(f32, a.absTileX) - @intToFloat(f32, b.absTileX),
        .y = @intToFloat(f32, a.absTileY) - @intToFloat(f32, b.absTileY),
    };
    const dTileZ = @intToFloat(f32, a.absTileZ) - @intToFloat(f32, b.absTileZ);

    const result = world_difference{
        // NOTE (Manav): .dxy = tileMap.tileSideInMeters * dTileXY  + (a.offset_ - b.offset_)
        .dXY = math.add(math.scale(dTileXY, w.tileSideInMeters), math.sub(a.offset_, b.offset_)),
        .dZ = w.tileSideInMeters * dTileZ,
    };

    return result;
}

inline fn CenteredTilePoint(absTileX: u32, absTileY: u32, absTileZ: u32) world_position {
    const result = world_position{
        .absTileX = @intCast(i32, absTileX),
        .absTileY = @intCast(i32, absTileY),
        .absTileZ = @intCast(i32, absTileZ),
    };

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn InitializeWorld(w: *world, tileSideInMeters: f32) void {
    const chunkShift = 4;
    const chunkMask = @as(u32, 1) << @intCast(u5, chunkShift) - 1;
    const chunkDim = @as(u32, 1) << @intCast(u5, chunkShift);

    w.chunkShift = chunkShift;
    w.chunkMask = chunkMask;
    w.chunkDim = chunkDim;
    w.tileSideInMeters = tileSideInMeters;

    for (w.chunkHash) |*chunk| {
        chunk.chunkX = TILE_CHUNK_UNINITIALIZED;
    }
}

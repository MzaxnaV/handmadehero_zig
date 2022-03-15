const std = @import("std");
const assert = std.debug.assert;

const math = @import("handmade_math.zig");
const memory_arena = @import("handmade_internals.zig").memory_arena;
const PushStruct = @import("handmade_internals.zig").PushStruct;
const PushArrayPtr = @import("handmade_internals.zig").PushArrayPtr;
const RoundF32ToInt = @import("handmade_intrinsics.zig").RoundF32ToInt;

// constants ------------------------------------------------------------------------------------------------------------------------------

const TILE_CHUNK_SAFE_MARGIN = std.math.maxInt(i32) / 64;
const TILE_CHUNK_UNINITIALIZED = std.math.maxInt(i32);

// tile data types ------------------------------------------------------------------------------------------------------------------------

pub const tile_map_difference = struct {
    dXY: math.v2 = .{},
    dZ: f32 = 0,
};

pub const tile_map_position = struct {
    absTileX: i32 = 0,
    absTileY: i32 = 0,
    absTileZ: i32 = 0,

    offset_: math.v2 = .{},
};

pub const tile_chunk_position = struct {
    tileChunkX: i32 = 0,
    tileChunkY: i32 = 0,
    tileChunkZ: i32 = 0,

    relTileX: i32 = 0,
    relTileY: i32 = 0,
};

pub const tile_chunk = struct {
    tileChunkX: i32,
    tileChunkY: i32,
    tileChunkZ: i32,

    tiles: ?[*]u32 = null,

    nextInHash: ?*tile_chunk = null,
};

pub const tile_map = struct {
    chunkShift: i32, // NOTE (Manav): should this be u5?
    chunkMask: i32 = undefined,
    chunkDim: i32,

    tileSideInMeters: f32,
    tileChunkHash: [4096]tile_chunk,
};

// public inline functions ----------------------------------------------------------------------------------------------------------------

fn GetTileChunk(memoryArena: ?*memory_arena, tileMap: *tile_map, tileChunkX: i32, tileChunkY: i32, tileChunkZ: i32) ?*tile_chunk {
    assert(tileChunkX > -TILE_CHUNK_SAFE_MARGIN);
    assert(tileChunkY > -TILE_CHUNK_SAFE_MARGIN);
    assert(tileChunkZ > -TILE_CHUNK_SAFE_MARGIN);
    assert(tileChunkX < TILE_CHUNK_SAFE_MARGIN);
    assert(tileChunkY < TILE_CHUNK_SAFE_MARGIN);
    assert(tileChunkZ < TILE_CHUNK_SAFE_MARGIN);

    const hashValue = @bitCast(u32, 19 * tileChunkX + 7 * tileChunkY + 3 * tileChunkZ);
    const hashSlot = hashValue & (tileMap.tileChunkHash.len - 1);
    assert(hashSlot < tileMap.tileChunkHash.len);

    var tileChunk: ?*tile_chunk = &tileMap.tileChunkHash[hashSlot];

    while (tileChunk) |*chunk| {
        if ((tileChunkX == chunk.*.tileChunkX) and (tileChunkY == chunk.*.tileChunkY) and (tileChunkZ == chunk.*.tileChunkZ)) {
            break;
        }

        if (memoryArena) |arena| {
            if ((chunk.*.tileChunkX != TILE_CHUNK_UNINITIALIZED) and (chunk.*.nextInHash != null)) {
                chunk.*.nextInHash = PushStruct(tile_chunk, arena);
                tileChunk = chunk.*.nextInHash;
                chunk.*.tileChunkX = TILE_CHUNK_UNINITIALIZED;
            }

            if (chunk.*.tileChunkX == TILE_CHUNK_UNINITIALIZED) {
                const tileCount = @intCast(u32, tileMap.chunkDim * tileMap.chunkDim);

                chunk.*.tileChunkX = tileChunkX;
                chunk.*.tileChunkY = tileChunkY;
                chunk.*.tileChunkZ = tileChunkZ;

                chunk.*.tiles = PushArrayPtr(u32, tileCount, arena);

                var tileIndex = @as(u32, 0);
                while (tileIndex < tileCount) : (tileIndex += 1) {
                    chunk.*.tiles.?[tileIndex] = 1;
                }

                chunk.*.nextInHash = null;
                break;
            }
        }

        tileChunk = chunk.*.nextInHash;
    }

    return tileChunk;
}

inline fn GetTileValueUnchecked(tileMap: *const tile_map, tileChunk: *const tile_chunk, tileX: i32, tileY: i32) u32 {
    assert(tileX < tileMap.chunkDim);
    assert(tileY < tileMap.chunkDim);

    const tileChunkValue = tileChunk.tiles.?[@intCast(u32, tileY * tileMap.chunkDim + tileX)];
    return tileChunkValue;
}

inline fn SetTileValueUnchecked(tileMap: *const tile_map, tileChunk: *const tile_chunk, tileX: i32, tileY: i32, tileValue: u32) void {
    assert(tileX < tileMap.chunkDim);
    assert(tileY < tileMap.chunkDim);

    tileChunk.tiles.?[@intCast(u32, tileY * tileMap.chunkDim + tileX)] = tileValue;
}

inline fn GetTileValue(tileMap: *const tile_map, tileChunk: ?*const tile_chunk, testTileX: u32, testTileY: u32) u32 {
    var tileChunkValue: u32 = 0;
    if (tileChunk) |tc| {
        if (tc.tiles) |_| {
            tileChunkValue = GetTileValueUnchecked(tileMap, tc, testTileX, testTileY);
        }
    }

    return tileChunkValue;
}

inline fn GetTileValueFromAbs(tileMap: *const tile_map, absTileX: u32, absTileY: u32, absTileZ: u32) u32 {
    const chunkPos = GetChunkPositionFor(tileMap, absTileX, absTileY, absTileZ);
    const tileChunk = GetTileChunk(null, tileMap, chunkPos.tileChunkX, chunkPos.tileChunkY, chunkPos.tileChunkZ);
    const tileChunkValue = GetTileValue(tileMap, tileChunk, @intCast(u32, chunkPos.relTileX), @intCast(u32, chunkPos.relTileY));

    return tileChunkValue;
}

inline fn GetTileValueFromPos(tileMap: *const tile_map, pos: tile_map_position) u32 {
    const tileChunkValue = GetTileValueFromAbs(tileMap, pos.absTileX, pos.absTileY, pos.absTileZ);
    return tileChunkValue;
}

inline fn SetTileValue(tileMap: *const tile_map, tileChunk: ?*const tile_chunk, testTileX: u32, testTileY: u32, tileValue: u32) void {
    if (tileChunk) |tc| {
        if (tc.tiles) |_| {
            SetTileValueUnchecked(tileMap, tc, @intCast(i32, testTileX), @intCast(i32, testTileY), tileValue);
        }
    }
}

inline fn GetChunkPositionFor(tileMap: *const tile_map, absTileX: u32, absTileY: u32, absTileZ: u32) tile_chunk_position {
    const result = tile_chunk_position{
        .tileChunkX = @intCast(i32, absTileX) >> @intCast(u5, tileMap.chunkShift),
        .tileChunkY = @intCast(i32, absTileY) >> @intCast(u5, tileMap.chunkShift),
        .tileChunkZ = @intCast(i32, absTileZ),
        .relTileX = @intCast(i32, absTileX) & tileMap.chunkMask,
        .relTileY = @intCast(i32, absTileY) & tileMap.chunkMask,
    };

    return result;
}

inline fn RecanonicalizeCoord(tileMap: *const tile_map, tile: *i32, tileRel: *f32) void {
    const offSet = RoundF32ToInt(i32, tileRel.* / tileMap.tileSideInMeters);
    tile.* +%= offSet;
    tileRel.* -= @intToFloat(f32, offSet) * tileMap.tileSideInMeters;

    assert(tileRel.* > -0.5 * tileMap.tileSideInMeters);
    assert(tileRel.* < 0.5 * tileMap.tileSideInMeters);
}

pub inline fn MapIntoTileSpace(tileMap: *const tile_map, basePos: tile_map_position, offset: math.v2) tile_map_position {
    var result = basePos;

    _ = result.offset_.add(offset); // NOTE (Manav): result.offset_ += offset

    RecanonicalizeCoord(tileMap, &result.absTileX, &result.offset_.x);
    RecanonicalizeCoord(tileMap, &result.absTileY, &result.offset_.y);

    return result;
}

inline fn AreOnSameTile(a: *const tile_map_position, b: *const tile_map_position) bool {
    const result = ((a.absTileX == b.absTileX) and (a.absTileY == b.absTileY) and (a.absTileZ == b.absTileZ));
    return result;
}

pub inline fn Substract(tileMap: *const tile_map, a: *const tile_map_position, b: *const tile_map_position) tile_map_difference {
    const dTileXY = .{
        .x = @intToFloat(f32, a.absTileX) - @intToFloat(f32, b.absTileX),
        .y = @intToFloat(f32, a.absTileY) - @intToFloat(f32, b.absTileY),
    };
    const dTileZ = @intToFloat(f32, a.absTileZ) - @intToFloat(f32, b.absTileZ);

    const result = tile_map_difference{
        // NOTE (Manav): .dxy = tileMap.tileSideInMeters * dTileXY  + (a.offset_ - b.offset_)
        .dXY = math.add(math.scale(dTileXY, tileMap.tileSideInMeters), math.sub(a.offset_, b.offset_)),
        .dZ = tileMap.tileSideInMeters * dTileZ,
    };

    return result;
}

inline fn CenteredTilePoint(absTileX: u32, absTileY: u32, absTileZ: u32) tile_map_position {
    const result = tile_map_position{
        .absTileX = @intCast(i32, absTileX),
        .absTileY = @intCast(i32, absTileY),
        .absTileZ = @intCast(i32, absTileZ),
    };

    return result;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub fn IsTileValueEmpty(tileValue: u32) bool {
    const empty = (tileValue == 1) or (tileValue == 3) or (tileValue == 4);
    return empty;
}

pub fn IsTileMapPointEmpty(tileMap: *const tile_map, pos: tile_map_position) bool {
    const tileChunkValue = GetTileValueFromPos(tileMap, pos);
    const empty = IsTileValueEmpty(tileChunkValue);
    return empty;
}

pub fn SetTileValueFromAbs(arena: *memory_arena, tileMap: *tile_map, absTileX: u32, absTileY: u32, absTileZ: u32, tileValue: u32) void {
    const chunkPos = GetChunkPositionFor(tileMap, absTileX, absTileY, absTileZ);
    const tileChunk = GetTileChunk(arena, tileMap, chunkPos.tileChunkX, chunkPos.tileChunkY, chunkPos.tileChunkZ);
    SetTileValue(tileMap, tileChunk, @intCast(u32, chunkPos.relTileX), @intCast(u32, chunkPos.relTileY), tileValue);
}

pub fn InitializeTileMap(tileMap: *tile_map, tileSideInMeters: f32) void {
    const chunkShift = 4;
    const chunkMask = @as(u32, 1) << @intCast(u5, chunkShift) - 1;
    const chunkDim = @as(u32, 1) << @intCast(u5, chunkShift);

    tileMap.chunkShift = chunkShift;
    tileMap.chunkMask = chunkMask;
    tileMap.chunkDim = chunkDim;
    tileMap.tileSideInMeters = tileSideInMeters;

    for (tileMap.tileChunkHash) |*chunk| {
        chunk.tileChunkX = TILE_CHUNK_UNINITIALIZED;
    }
}

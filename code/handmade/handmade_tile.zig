const assert = @import("std").debug.assert;
const math = @import("handmade_math.zig");
const RoundF32ToInt = @import("handmade_intrinsics.zig").RoundF32ToInt;

// tile data types ------------------------------------------------------------------------------------------------------------------------

pub const tile_map_difference = struct {
    dXY: math.v2 = .{},
    dZ: f32 = 0,
};

pub const tile_map_position = struct {
    absTileX: u32 = 0,
    absTileY: u32 = 0,
    absTileZ: u32 = 0,

    offset: math.v2 = .{},
};

pub const tile_chunk_position = struct {
    tileChunkX: u32 = 0,
    tileChunkY: u32 = 0,
    tileChunkZ: u32 = 0,

    relTileX: u32 = 0,
    relTileY: u32 = 0,
};

pub const tile_chunk = struct {
    tiles: ?[*]u32 = null,
};

pub const tile_map = struct {
    chunkShift: u32, // NOTE (Manav): should this be u5?
    chunkMask: u32 = undefined,
    chunkDim: u32,

    tileSideInMeters: f32,

    tileChunkCountX: u32,
    tileChunkCountY: u32,
    tileChunkCountZ: u32,

    tileChunks: [*]tile_chunk,
};

// public inline functions ----------------------------------------------------------------------------------------------------------------

pub inline fn RecanonicalizeCoord(tileMap: *const tile_map, tile: *u32, tileRel: *f32) void {
    const offSet = RoundF32ToInt(i32, tileRel.* / tileMap.tileSideInMeters);
    tile.* +%= @bitCast(u32, offSet);
    tileRel.* -= @intToFloat(f32, offSet) * tileMap.tileSideInMeters;

    assert(tileRel.* > -0.5001 * tileMap.tileSideInMeters);
    assert(tileRel.* < 0.5001 * tileMap.tileSideInMeters);
}

pub inline fn RecanonicalizePosition(tileMap: *const tile_map, pos: tile_map_position) tile_map_position {
    var result = pos;

    RecanonicalizeCoord(tileMap, &result.absTileX, &result.offset.x);
    RecanonicalizeCoord(tileMap, &result.absTileY, &result.offset.y);

    return result;
}

pub inline fn AreOnSameTile(a: *const tile_map_position, b: *const tile_map_position) bool {
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
        // NOTE (Manav): .dxy = dTileXY * tileMap.tileSideInMeters + (a.offset - b.offset)
        .dXY = math.add(math.scale(dTileXY, tileMap.tileSideInMeters), math.sub(a.offset, b.offset)),
        .dZ = tileMap.tileSideInMeters * dTileZ,
    };

    return result;
}

pub inline fn GetTileChunk(tileMap: *const tile_map, tileChunkX: u32, tileChunkY: u32, tileChunkZ: u32) ?*tile_chunk {
    var tileChunk: ?*tile_chunk = null;

    if ((tileChunkX < tileMap.tileChunkCountX) and (tileChunkY < tileMap.tileChunkCountY) and (tileChunkZ < tileMap.tileChunkCountZ)) {
        tileChunk = &tileMap.tileChunks[tileChunkZ * tileMap.tileChunkCountY * tileMap.tileChunkCountX + tileChunkY * tileMap.tileChunkCountX + tileChunkX];
    }

    return tileChunk;
}

pub inline fn GetTileValueUnchecked(tileMap: *const tile_map, tileChunk: *const tile_chunk, tileX: u32, tileY: u32) u32 {
    assert(tileX < tileMap.chunkDim);
    assert(tileY < tileMap.chunkDim);

    const tileChunkValue = tileChunk.tiles.?[tileY * tileMap.chunkDim + tileX];
    return tileChunkValue;
}

pub inline fn SetTileValueUnchecked(tileMap: *const tile_map, tileChunk: *const tile_chunk, tileX: u32, tileY: u32, tileValue: u32) void {
    assert(tileX < tileMap.chunkDim);
    assert(tileY < tileMap.chunkDim);

    tileChunk.tiles.?[tileY * tileMap.chunkDim + tileX] = tileValue;
}

pub inline fn GetTileValue(tileMap: *const tile_map, tileChunk: ?*const tile_chunk, testTileX: u32, testTileY: u32) u32 {
    var tileChunkValue: u32 = 0;
    if (tileChunk) |tc| {
        if (tc.tiles) |_| {
            tileChunkValue = GetTileValueUnchecked(tileMap, tc, testTileX, testTileY);
        }
    }

    return tileChunkValue;
}

pub inline fn GetTileValueFromAbs(tileMap: *const tile_map, absTileX: u32, absTileY: u32, absTileZ: u32) u32 {
    const chunkPos = GetChunkPositionFor(tileMap, absTileX, absTileY, absTileZ);
    const tileChunk = GetTileChunk(tileMap, chunkPos.tileChunkX, chunkPos.tileChunkY, chunkPos.tileChunkZ);
    const tileChunkValue = GetTileValue(tileMap, tileChunk, chunkPos.relTileX, chunkPos.relTileY);

    return tileChunkValue;
}

pub inline fn GetTileValueFromPos(tileMap: *const tile_map, pos: tile_map_position) u32 {
    const tileChunkValue = GetTileValueFromAbs(tileMap, pos.absTileX, pos.absTileY, pos.absTileZ);

    return tileChunkValue;
}

pub inline fn SetTileValue(tileMap: *const tile_map, tileChunk: ?*const tile_chunk, testTileX: u32, testTileY: u32, tileValue: u32) void {
    if (tileChunk) |tc| {
        if (tc.tiles) |_| {
            SetTileValueUnchecked(tileMap, tc, testTileX, testTileY, tileValue);
        }
    }
}

pub inline fn GetChunkPositionFor(tileMap: *const tile_map, absTileX: u32, absTileY: u32, absTileZ: u32) tile_chunk_position {
    const result = tile_chunk_position{
        .tileChunkX = absTileX >> @intCast(u5, tileMap.chunkShift),
        .tileChunkY = absTileY >> @intCast(u5, tileMap.chunkShift),
        .tileChunkZ = absTileZ,
        .relTileX = absTileX & tileMap.chunkMask,
        .relTileY = absTileY & tileMap.chunkMask,
    };

    return result;
}

pub inline fn CenteredTilePoint(absTileX: u32, absTileY: u32, absTileZ: u32) tile_map_position {
    const result = tile_map_position{
        .absTileX = absTileX,
        .absTileY = absTileY,
        .absTileZ = absTileZ,
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

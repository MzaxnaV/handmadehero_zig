// game data types ------------------------------------------------------------------------------------------------------------------------

pub const tile_chunk_position = struct {
    tileChunkX: u32 = 0,
    tileChunkY: u32 = 0,

    relTileX: u32 = 0,
    relTileY: u32 = 0,
};

pub const world_position = struct {
    absTileX: u32 = 0,
    absTileY: u32 = 0,

    tileRelX: f32 = 0,
    tileRelY: f32 = 0,
};

pub const tile_chunk = struct {
    tiles: [*]const u32 = undefined,
};

pub const world = struct {

    chunkShift: u32,
    chunkMask: u32 = undefined,
    chunkDim: u32,

    tileSideInMeters: f32,
    tileSideInPixels: i32,
    metersToPixels: f32 = undefined,

    tileChunkCountX: i32,
    tileChunkCountY: i32,

    tileChunks: [*]tile_chunk,
};

pub const state = struct {
    playerP: world_position = world_position{}
};

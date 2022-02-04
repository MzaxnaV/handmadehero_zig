// game data types ------------------------------------------------------------------------------------------------------------------------

pub const canonical_position = struct {
    tileMapX: i32 = 0,
    tileMapY: i32 = 0,

    tileX: i32 = 0,
    tileY: i32 = 0,

    tileRelX: f32 = 0,
    tileRelY: f32 = 0,
};

pub const raw_position = struct {
    tileMapX: i32,
    tileMapY: i32,

    x: f32,
    y: f32,
};

pub const tile_map = struct {
    tiles: [*]const u32 = undefined,
};

pub const world = struct {
    tileSideInMeters: f32,
    tileSideInPixels: i32,

    countX: i32 = 0,
    countY: i32 = 0,

    upperLeftX: f32 = 0,
    upperLeftY: f32 = 0,

    tileMapCountX: u32,
    tileMapCountY: u32,

    tileMaps: [*]tile_map,
};

pub const state = struct {
    playerTileMapX: i32,
    playerTileMapY: i32,

    playerX: f32,
    playerY: f32,
};

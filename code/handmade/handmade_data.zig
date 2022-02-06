const NOT_IGNORE = @import("build_consts").NOT_IGNORE;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const canonical_position = if (NOT_IGNORE) struct {
    tileMapX: i32 = 0,
    tileMapY: i32 = 0,

    tileX: i32 = 0,
    tileY: i32 = 0,

    tileRelX: f32 = 0,
    tileRelY: f32 = 0,
} else struct {
    _tileX: i32 = 0,
    _tileY: i32 = 0,

    tileRelX: f32 = 0,
    tileRelY: f32 = 0,
};

pub const tile_map = struct {
    tiles: [*]const u32 = undefined,
};

pub const world = struct {
    tileSideInMeters: f32,
    tileSideInPixels: i32,
    metersToPixels: f32 = undefined,

    countX: i32 = 0,
    countY: i32 = 0,

    upperLeftX: f32 = 0,
    upperLeftY: f32 = 0,

    tileMapCountX: u32,
    tileMapCountY: u32,

    tileMaps: [*]tile_map,
};

pub const state = struct {
    playerP: canonical_position = canonical_position{}
};

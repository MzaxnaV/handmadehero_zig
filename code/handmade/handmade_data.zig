const memory_index = @import("handmade_platform").memory_index;
const tile_map = @import("handmade_tile.zig").tile_map;
const tile_map_position = @import("handmade_tile.zig").tile_map_position;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const memory_arena = struct {
    size: memory_index,
    base: [*]u8,
    used: memory_index,
};

pub const world = struct {
    tileMap: *tile_map,
};

pub const state = struct {
    worldArena: memory_arena,
    world: *world,
    playerP: tile_map_position = tile_map_position{}
};

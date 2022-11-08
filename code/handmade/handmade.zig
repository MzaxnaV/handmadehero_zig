const std = @import("std");
const assert = std.debug.assert;
const platform = @import("handmade_platform");
const game = struct {
    usingnamespace @import("handmade_entity.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_sim_region.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade_world.zig");
};

const handmade_internal = platform.handmade_internal;

// build constants ------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;

// local functions ------------------------------------------------------------------------------------------------------------------------

fn OutputSound(_: *game.state, soundBuffer: *platform.sound_output_buffer, toneHz: u32) void {
    const toneVolume = 3000;
    _ = toneVolume;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);
    _ = wavePeriod;

    var sampleOut = soundBuffer.samples;
    var sampleIndex = @as(u32, 0);
    while (sampleIndex < soundBuffer.sampleCount) : (sampleIndex += 1) {
        // !NOT_IGNORE:
        // const sineValue = @sin(gameState.tSine);
        // const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, toneVolume);

        const sampleValue = 0;
        sampleOut.* = sampleValue;
        sampleOut += 1;
        sampleOut.* = sampleValue;
        sampleOut += 1;

        // !NOT_IGNORE:
        // gameState.tSine += 2.0 * platform.PI32 * 1.0 / @intToFloat(f32, wavePeriod);
        // if (gameState.tSine > 2.0 * platform.PI32) {
        //     gameState.tSine -= 2.0 * platform.PI32;
        // }
    }
}

/// Defaults: ```alignX =  , topDownAlignY = ```
fn DEBUGLoadBMPDefaultAligned(
    thread: *platform.thread_context,
    ReadEntireFile: handmade_internal.debug_platform_read_entire_file,
    fileName: [*:0]const u8,
) game.loaded_bitmap {
    var result = DEBUGLoadBMP(thread, ReadEntireFile, fileName, 0, 0);
    result.alignPercentage = .{ 0.5, 0.5 };

    return result;
}

fn DEBUGLoadBMP(
    thread: *platform.thread_context,
    ReadEntireFile: handmade_internal.debug_platform_read_entire_file,
    fileName: [*:0]const u8,
    alignX: i32,
    topDownAlignY: i32,
) game.loaded_bitmap {
    const bitmap_header = packed struct {
        fileType: u16,
        fileSize: u32,
        reserved1: u16,
        reserved2: u16,
        bitmapOffset: u32,
        size: u32,
        width: i32,
        height: i32,
        planes: u16,
        bitsPerPixel: u16,
        compression: u32,
        sizeOfBitmap: u32,
        horzResolution: u32,
        vertResolution: u32,
        colorsUsed: u32,
        colorsImportant: u32,

        redMask: u32,
        greenMask: u32,
        blueMask: u32,
    };

    var result = game.loaded_bitmap{};

    const readResult = ReadEntireFile(thread, fileName);
    if (readResult.contentSize != 0) {
        const header = @ptrCast(*bitmap_header, readResult.contents);
        const pixels = readResult.contents + header.bitmapOffset;
        result.width = header.width;
        result.height = header.height;
        result.memory = pixels;
        result.alignPercentage = TopDownAlign(&result, game.V2(alignX, topDownAlignY));
        result.widthOverHeight = game.SafeRatiof0(@intToFloat(f32, result.width), @intToFloat(f32, result.height));

        assert(header.height >= 0);
        assert(header.compression == 3);

        const redMask = header.redMask;
        const greenMask = header.greenMask;
        const blueMask = header.blueMask;
        const alphaMask = ~(redMask | greenMask | blueMask);

        const redScan = game.FindLeastSignificantSetBit(redMask);
        const greenScan = game.FindLeastSignificantSetBit(greenMask);
        const blueScan = game.FindLeastSignificantSetBit(blueMask);
        const alphaScan = game.FindLeastSignificantSetBit(alphaMask);

        const redShiftDown = @intCast(u5, redScan);
        const greenShiftDown = @intCast(u5, greenScan);
        const blueShiftDown = @intCast(u5, blueScan);
        const alphaShiftDown = @intCast(u5, alphaScan);

        const sourceDest = @ptrCast([*]align(1) u32, result.memory);

        var index = @as(u32, 0);
        while (index < @intCast(u32, header.height * header.width)) : (index += 1) {
            const c = sourceDest[index];

            var texel = game.v4{
                @intToFloat(f32, (c & redMask) >> redShiftDown),
                @intToFloat(f32, (c & greenMask) >> greenShiftDown),
                @intToFloat(f32, (c & blueMask) >> blueShiftDown),
                @intToFloat(f32, (c & alphaMask) >> alphaShiftDown),
            };

            texel = game.SRGB255ToLinear1(texel);

            if (NOT_IGNORE) {
                // texel.rgb *= texel.a;
                texel = game.ToV4(game.Scale(game.RGB(texel), game.A(texel)), game.A(texel));
            }

            texel = game.Linear1ToSRGB255(texel);

            sourceDest[index] =
                (@floatToInt(u32, (game.A(texel) + 0.5)) << 24 |
                @floatToInt(u32, (game.R(texel) + 0.5)) << 16 |
                @floatToInt(u32, (game.G(texel) + 0.5)) << 8 |
                @floatToInt(u32, (game.B(texel) + 0.5)) << 0);
        }
    }

    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;

    if (!NOT_IGNORE) {
        result.memory += @intCast(usize, result.pitch * (result.height - 1));
        result.pitch = -result.width;
    }

    return result;
}

const add_low_entity_result = struct {
    low: *game.low_entity,
    lowIndex: u32,
};

fn AddLowEntity(gameState: *game.state, entityType: game.entity_type, pos: game.world_position) add_low_entity_result {
    assert(gameState.lowEntityCount < gameState.lowEntities.len);
    const entityIndex = gameState.lowEntityCount;
    gameState.lowEntityCount += 1;

    const entityLow = &gameState.lowEntities[entityIndex];

    entityLow.* = .{
        .sim = .{
            .entityType = entityType,
            .collision = gameState.nullCollision,
        },
        .p = game.NullPosition(),
    };

    game.ChangeEntityLocation(&gameState.worldArena, gameState.world, entityIndex, entityLow, pos);

    const result = .{
        .low = entityLow,
        .lowIndex = entityIndex,
    };

    return result;
}

fn AddGroundedEntity(gameState: *game.state, entityType: game.entity_type, p: game.world_position, collision: *game.sim_entity_collision_volume_group) add_low_entity_result {
    const entity = AddLowEntity(gameState, entityType, p);
    entity.low.sim.collision = collision;
    return entity;
}

fn AddStandardRoom(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Space, p, gameState.standardRoomCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Traversable));

    return entity;
}

fn AddWall(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Wall, p, gameState.wallCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides));

    return entity;
}

fn AddStairs(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: i32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), absTileZ, .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Stairwell, p, gameState.stairCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides));
    entity.low.sim.walkableDim = .{ game.X(entity.low.sim.collision.totalVolume.dim), game.Y(entity.low.sim.collision.totalVolume.dim) };
    entity.low.sim.walkableHeight = gameState.typicalFloorHeight;

    return entity;
}

fn InitHitPoints(entityLow: *game.low_entity, hitPointCount: u32) void {
    assert(hitPointCount <= entityLow.sim.hitPoint.len);
    entityLow.sim.hitPointMax = hitPointCount;

    var hitPointIndex = @as(u32, 0);
    while (hitPointIndex < entityLow.sim.hitPointMax) : (hitPointIndex += 1) {
        const hitPoint = &entityLow.sim.hitPoint[hitPointIndex];
        hitPoint.flags = 0;
        hitPoint.filledAmount = game.HIT_POINT_SUB_COUNT;
    }
}

fn AddSword(gameState: *game.state) add_low_entity_result {
    var entity = AddLowEntity(gameState, .Sword, game.NullPosition());

    entity.low.sim.collision = gameState.swordCollision;

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Movable));

    return entity;
}

fn AddPlayer(gameState: *game.state) add_low_entity_result {
    const p = gameState.cameraP;
    var entity = AddGroundedEntity(gameState, .Hero, p, gameState.playerCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides) | @enumToInt(game.sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    const sword = AddSword(gameState);
    entity.low.sim.sword.index = sword.lowIndex;

    if (gameState.cameraFollowingEntityIndex == 0) {
        gameState.cameraFollowingEntityIndex = entity.lowIndex;
    }

    return entity;
}

fn AddMonstar(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Monstar, p, gameState.monstarCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides) | @enumToInt(game.sim_entity_flags.Movable));

    InitHitPoints(entity.low, 3);

    return entity;
}

fn AddFamiliar(gameState: *game.state, absTileX: u32, absTileY: u32, absTileZ: u32) add_low_entity_result {
    const p = ChunkPosFromTilePos(gameState.world, @intCast(i32, absTileX), @intCast(i32, absTileY), @intCast(i32, absTileZ), .{ 0, 0, 0 });
    var entity = AddGroundedEntity(gameState, .Familiar, p, gameState.familiarCollision);

    game.AddFlags(&entity.low.sim, @enumToInt(game.sim_entity_flags.Collides) | @enumToInt(game.sim_entity_flags.Movable));

    return entity;
}

fn DrawHitpoints(entity: *game.sim_entity, pieceGroup: *game.render_group) void {
    if (entity.hitPointMax >= 1) {
        const healthDim = game.v2{ 0.2, 0.2 };
        const spacingX = 1.5 * game.X(healthDim);
        var hitP = game.v2{
            -0.5 * @intToFloat(f32, entity.hitPointMax - 1) * spacingX,
            -0.25,
        };
        const dHitP = game.v2{ spacingX, 0 };
        var healthIndex = @as(u32, 0);
        while (healthIndex < entity.hitPointMax) : (healthIndex += 1) {
            const hitPoint = entity.hitPoint[healthIndex];
            var colour = game.v4{ 1, 0, 0, 1 };
            if (hitPoint.filledAmount == 0) {
                colour = .{ 0.2, 0.2, 0.2, 1 };
            }

            pieceGroup.PushRect(game.ToV3(hitP, 0), healthDim, colour);
            game.AddTo(&hitP, dHitP);
        }
    }
}

fn MakeSimpleGroundedCollision(gameState: *game.state, dimX: f32, dimY: f32, dimZ: f32) *game.sim_entity_collision_volume_group {
    const group: *game.sim_entity_collision_volume_group = gameState.worldArena.PushStruct(game.sim_entity_collision_volume_group);

    group.volumeCount = 1;
    group.volumes = gameState.worldArena.PushArray(game.sim_entity_collision_volume, group.volumeCount);
    group.totalVolume.offsetP = game.v3{ 0, 0, 0.5 * dimZ };
    group.totalVolume.dim = game.v3{ dimX, dimY, dimZ };
    group.volumes[0] = group.totalVolume;

    return group;
}

fn MakeNullCollision(gameState: *game.state) *game.sim_entity_collision_volume_group {
    const group: *game.sim_entity_collision_volume_group = gameState.worldArena.PushStruct(game.sim_entity_collision_volume_group);

    group.volumeCount = 0;
    group.volumes = undefined; // TODO (Manav): change type from,  [*]sim_entity_collision_volume to ?[*]sim_entity_collision_volume
    group.totalVolume.offsetP = game.v3{ 0, 0, 0 };
    group.totalVolume.dim = game.v3{ 0, 0, 0 };

    return group;
}

fn FillGroundChunk(tranState: *game.transient_state, gameState: *game.state, groundBuffer: *game.ground_buffer, chunkP: *const game.world_position) void {
    const groundMemory = game.BeginTemporaryMemory(&tranState.tranArena);
    defer game.EndTemporaryMemory(groundMemory);

    var buffer = &groundBuffer.bitmap;
    buffer.alignPercentage = game.v2{ 0.5, 0.5 };
    buffer.widthOverHeight = 1.0;

    const renderGroup = game.render_group.Allocate(&tranState.tranArena, platform.MegaBytes(4), @intCast(u32, buffer.width), @intCast(u32, buffer.height));

    renderGroup.Clear(.{ 1, 1, 0, 1 });

    groundBuffer.p = chunkP.*;

    if (!NOT_IGNORE) {
        const width = game.X(gameState.world.chunkDimInMeters);
        const height = game.Y(gameState.world.chunkDimInMeters);
        const haldDim = game.Scale(game.v2{ 0.5 * width, 0.5 * height }, 2);

        {
            var chunkOffsetY = @as(i32, -1);
            while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
                var chunkOffsetX = @as(i32, -1);
                while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
                    const chunkX = chunkP.chunkX + chunkOffsetX;
                    const chunkY = chunkP.chunkY + chunkOffsetY;
                    const chunkZ = chunkP.chunkZ;

                    var series = game.RandomSeed(@bitCast(u32, 139 * chunkX + 593 * chunkY + 329 * chunkZ));

                    const center = game.v2{ @intToFloat(f32, chunkOffsetX) * width, @intToFloat(f32, chunkOffsetY) * height };

                    var grassIndex = @as(u32, 0);
                    while (grassIndex < 50) : (grassIndex += 1) {
                        const stamp = if (series.RandomChoice(2) == 1)
                            &gameState.grass[series.RandomChoice(gameState.grass.len)]
                        else
                            &gameState.stones[series.RandomChoice(gameState.stones.len)];

                        const p = game.Add(center, game.Hammard(haldDim, .{ series.RandomBilateral(), series.RandomBilateral() }));
                        renderGroup.PushBitmap(stamp, 4, game.ToV3(p, 0), .{ 1, 1, 1, 1 });
                    }
                }
            }
        }

        {
            var chunkOffsetY = @as(i32, -1);
            while (chunkOffsetY <= 1) : (chunkOffsetY += 1) {
                var chunkOffsetX = @as(i32, -1);
                while (chunkOffsetX <= 1) : (chunkOffsetX += 1) {
                    const chunkX = chunkP.chunkX + chunkOffsetX;
                    const chunkY = chunkP.chunkY + chunkOffsetY;
                    const chunkZ = chunkP.chunkZ;

                    var series = game.RandomSeed(@bitCast(u32, 139 * chunkX + 593 * chunkY + 329 * chunkZ));

                    const center = game.v2{ @intToFloat(f32, chunkOffsetX) * width, @intToFloat(f32, chunkOffsetY) * height };

                    var grassIndex = @as(u32, 0);
                    while (grassIndex < 50) : (grassIndex += 1) {
                        const stamp = &gameState.tufts[series.RandomChoice(gameState.tufts.len)];

                        const p = game.Add(center, game.Hammard(haldDim, .{ series.RandomBilateral(), series.RandomBilateral() }));
                        renderGroup.PushBitmap(stamp, 0.4, game.ToV3(p, 0), .{ 1, 1, 1, 1 });
                    }
                }
            }
        }
    }

    renderGroup.TiledRenderGroupToOutput(buffer);
}

fn ClearBitmap(bitmap: *game.loaded_bitmap) void {
    const totalBitmapSize = @intCast(usize, bitmap.width * bitmap.height * platform.BITMAP_BYTES_PER_PIXEL);
    game.ZeroSize(totalBitmapSize, bitmap.memory);
}

fn MakeEmptyBitmap(arena: *game.memory_arena, width: i32, height: i32, clearToZero: bool) game.loaded_bitmap {
    var result = game.loaded_bitmap{};

    result.width = width;
    result.height = height;
    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;
    const totalBitmapSize = @intCast(usize, result.width * result.height * platform.BITMAP_BYTES_PER_PIXEL);
    result.memory = arena.PushSize(@alignOf(u8), totalBitmapSize);
    if (clearToZero) {
        ClearBitmap(&result);
    }

    return result;
}

/// Defaults: ```cX = 1.0, cY = 1.0```
fn MakeSphereDiffuseMap(bitmap: *const game.loaded_bitmap, cX: f32, cY: f32) void {
    const invWidth = 1.0 / (@intToFloat(f32, bitmap.width) - 1);
    const invHeight = 1.0 / (@intToFloat(f32, bitmap.height) - 1);

    var row = bitmap.memory;

    var y = @as(u32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(u32, 0);
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        while (x < bitmap.width) : (x += 1) {
            const bitmapUV = game.v2{ invWidth * @intToFloat(f32, x), invHeight * @intToFloat(f32, y) };

            const nX = cX * (2 * game.X(bitmapUV) - 1);
            const nY = cY * (2 * game.Y(bitmapUV) - 1);
            const nZ_sq = 1 - nX * nX - nY * nY;

            var alpha = @as(f32, 0);

            if (nZ_sq >= 0) {
                alpha = 1;
            }

            const baseColour: game.v3 = .{ 0, 0, 0 };
            alpha *= 255;
            const colour: game.v4 = .{
                alpha * game.X(baseColour),
                alpha * game.Y(baseColour),
                alpha * game.Z(baseColour),
                alpha,
            };

            pixel.* = (@floatToInt(u32, game.A(colour) + 0.5) << 24) |
                (@floatToInt(u32, game.R(colour) + 0.5) << 16) |
                (@floatToInt(u32, game.G(colour) + 0.5) << 8) |
                (@floatToInt(u32, game.B(colour) + 0.5) << 0);

            pixel += 1;
        }
        row += @intCast(usize, bitmap.pitch);
    }
}

/// Defaults: ```cX = 1.0, cY = 1.0```
fn MakeSphereNormalMap(bitmap: *const game.loaded_bitmap, roughness: f32, cX: f32, cY: f32) void {
    const invWidth = 1.0 / (@intToFloat(f32, bitmap.width) - 1);
    const invHeight = 1.0 / (@intToFloat(f32, bitmap.height) - 1);

    var row = bitmap.memory;

    var y = @as(u32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(u32, 0);
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        while (x < bitmap.width) : (x += 1) {
            const bitmapUV = game.v2{ invWidth * @intToFloat(f32, x), invHeight * @intToFloat(f32, y) };

            const nX = cX * (2 * game.X(bitmapUV) - 1);
            const nY = cY * (2 * game.Y(bitmapUV) - 1);
            const nZ_sq = 1 - nX * nX - nY * nY;

            var normal: game.v3 = if (nZ_sq >= 0) .{ nX, nY, game.SquareRoot(nZ_sq) } else .{ 0, 0.70710678118, 0.70710678118 };

            const colour = game.v4{
                255 * (0.5 * (game.X(normal) + 1)),
                255 * (0.5 * (game.Y(normal) + 1)),
                255 * (0.5 * (game.Z(normal) + 1)),
                255 * roughness,
            };

            pixel.* = (@floatToInt(u32, game.A(colour) + 0.5) << 24) |
                (@floatToInt(u32, game.R(colour) + 0.5) << 16) |
                (@floatToInt(u32, game.G(colour) + 0.5) << 8) |
                (@floatToInt(u32, game.B(colour) + 0.5) << 0);

            pixel += 1;
        }
        row += @intCast(usize, bitmap.pitch);
    }
}

fn MakePyramidNormalMap(bitmap: *const game.loaded_bitmap, roughness: f32) void {
    // const invWidth = 1.0 / (@intToFloat(f32, bitmap.width) - 1);
    // const invHeight = 1.0 / (@intToFloat(f32, bitmap.height) - 1);

    var row = bitmap.memory;

    var y = @as(i32, 0);
    while (y < bitmap.height) : (y += 1) {
        var x = @as(i32, 0);
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        while (x < bitmap.width) : (x += 1) {
            // const bitmapUV = game.v2{ invWidth * @intToFloat(f32, x), invHeight * @intToFloat(f32, y) };

            const invX = (bitmap.width - 1) - x;
            const seven = 0.70710678118;
            var normal: game.v3 = .{ 0, 0, seven };
            if (x < y) {
                if (invX < y) {
                    normal[0] = -seven;
                } else {
                    normal[1] = seven;
                }
            } else {
                if (invX < y) {
                    normal[1] = -seven;
                } else {
                    normal[0] = seven;
                }
            }

            const colour = game.v4{
                255 * (0.5 * (game.X(normal) + 1)),
                255 * (0.5 * (game.Y(normal) + 1)),
                255 * (0.5 * (game.Z(normal) + 1)),
                255 * roughness,
            };

            pixel.* = (@floatToInt(u32, game.A(colour) + 0.5) << 24) |
                (@floatToInt(u32, game.R(colour) + 0.5) << 16) |
                (@floatToInt(u32, game.G(colour) + 0.5) << 8) |
                (@floatToInt(u32, game.B(colour) + 0.5) << 0);

            pixel += 1;
        }
        row += @intCast(usize, bitmap.pitch);
    }
}

pub inline fn ChunkPosFromTilePos(w: *game.world, absTileX: i32, absTileY: i32, absTileZ: i32, additionalOffset: game.v3) game.world_position {
    const basePos: game.world_position = .{};

    const tileSideInMeters = 1.4;
    const tileDepthInMeters = 3.0;

    const tileDim = game.v3{ tileSideInMeters, tileSideInMeters, tileDepthInMeters };
    const offset = game.Hammard(tileDim, game.V3(absTileX, absTileY, absTileZ));

    const result: game.world_position = game.MapIntoChunkSpace(w, basePos, game.Add(offset, additionalOffset));

    assert(game.IsCanonical(w, result.offset_));

    return result;
}

inline fn TopDownAlign(bitmap: *const game.loaded_bitmap, alignment: game.v2) game.v2 {
    const fixedAlignment = game.v2{
        game.SafeRatiof0(game.X(alignment), @intToFloat(f32, bitmap.width)),
        game.SafeRatiof0(@intToFloat(f32, bitmap.height - 1) - game.Y(alignment), @intToFloat(f32, bitmap.height)),
    };
    return fixedAlignment;
}

fn SetTopDownAlignment(bitmaps: *game.hero_bitmaps, alignment: game.v2) void {
    const fixedAlignment = TopDownAlign(&bitmaps.head, alignment);

    bitmaps.head.alignPercentage = fixedAlignment;
    bitmaps.torso.alignPercentage = fixedAlignment;
    bitmaps.cape.alignPercentage = fixedAlignment;
}

// public functions -----------------------------------------------------------------------------------------------------------------------

pub export fn UpdateAndRender(
    thread: *platform.thread_context,
    gameMemory: *platform.memory,
    gameInput: *platform.input,
    buffer: *platform.offscreen_buffer,
) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args.len != @typeInfo(platform.UpdateAndRenderType).Fn.args.len or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[0].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[0].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[1].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[1].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[2].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[2].arg_type.?) or
            (@typeInfo(@TypeOf(UpdateAndRender)).Fn.args[3].arg_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.args[3].arg_type.?) or
            @typeInfo(@TypeOf(UpdateAndRender)).Fn.return_type.? != @typeInfo(platform.UpdateAndRenderType).Fn.return_type.?)
        {
            @compileError("Function signature mismatch!");
        }
    }

    if (HANDMADE_INTERNAL) {
        handmade_internal.debugGlobalMemory = gameMemory;
    }

    platform.BEGIN_TIMED_BLOCK(.UpdateAndRender);
    defer platform.END_TIMED_BLOCK(.UpdateAndRender);

    assert(@sizeOf(game.state) <= gameMemory.permanentStorageSize);
    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));

    const groundBufferWidth = 256.0;
    const groundBufferHeight = 256.0;
    const pixelsToMeters = 1.0 / 42.0;

    if (!gameMemory.isInitialized) {
        const tilesPerWidth = 17;
        const tilesPerHeight = 9;

        gameState.typicalFloorHeight = 3.0;

        const worldChunkDimInMeters = game.v3{
            pixelsToMeters * groundBufferWidth,
            pixelsToMeters * groundBufferHeight,
            gameState.typicalFloorHeight,
        };

        gameState.worldArena.Initialize(gameMemory.permanentStorageSize - @sizeOf(game.state), gameMemory.permanentStorage + @sizeOf(game.state));

        _ = AddLowEntity(gameState, .Null, game.NullPosition());

        gameState.world = gameState.worldArena.PushStruct(game.world);
        const world = gameState.world;
        game.InitializeWorld(world, worldChunkDimInMeters);

        const tileSideInMeters = 1.4;
        const tileDepthInMeters = gameState.typicalFloorHeight;

        gameState.nullCollision = MakeNullCollision(gameState);
        gameState.swordCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.1);
        gameState.stairCollision = MakeSimpleGroundedCollision(gameState, tileSideInMeters, 2 * tileSideInMeters, 1.1 * tileDepthInMeters);
        gameState.playerCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 1.2);
        gameState.monstarCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.5);
        gameState.familiarCollision = MakeSimpleGroundedCollision(gameState, 1, 0.5, 0.5);
        gameState.wallCollision = MakeSimpleGroundedCollision(gameState, tileSideInMeters, tileSideInMeters, tileDepthInMeters);

        gameState.standardRoomCollision = MakeSimpleGroundedCollision(gameState, tilesPerWidth * tileSideInMeters, tilesPerHeight * tileSideInMeters, 0.9 * tileDepthInMeters);

        gameState.grass[0] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/grass00.bmp");
        gameState.grass[1] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/grass01.bmp");

        gameState.tufts[0] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tuft00.bmp");
        gameState.tufts[1] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tuft01.bmp");
        gameState.tufts[2] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tuft00.bmp");

        gameState.stones[0] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground00.bmp");
        gameState.stones[1] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground01.bmp");
        gameState.stones[2] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground02.bmp");
        gameState.stones[3] = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/ground03.bmp");

        gameState.backdrop = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_background.bmp");
        gameState.shadow = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_shadow.bmp", 72, 182);
        gameState.tree = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/tree00.bmp", 40, 80);
        gameState.stairwell = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/rock02.bmp");
        gameState.sword = DEBUGLoadBMP(thread, gameMemory.DEBUGPlatformReadEntireFile, "test2/rock03.bmp", 29, 10);

        gameState.heroBitmaps[0].head = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_head.bmp");
        gameState.heroBitmaps[0].cape = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_cape.bmp");
        gameState.heroBitmaps[0].torso = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_right_torso.bmp");
        SetTopDownAlignment(&gameState.heroBitmaps[0], .{ 72, 182 });

        gameState.heroBitmaps[1].head = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_head.bmp");
        gameState.heroBitmaps[1].cape = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_cape.bmp");
        gameState.heroBitmaps[1].torso = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_back_torso.bmp");
        SetTopDownAlignment(&gameState.heroBitmaps[1], .{ 72, 182 });

        gameState.heroBitmaps[2].head = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_head.bmp");
        gameState.heroBitmaps[2].cape = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_cape.bmp");
        gameState.heroBitmaps[2].torso = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_left_torso.bmp");
        SetTopDownAlignment(&gameState.heroBitmaps[2], .{ 72, 182 });

        gameState.heroBitmaps[3].head = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_head.bmp");
        gameState.heroBitmaps[3].cape = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_cape.bmp");
        gameState.heroBitmaps[3].torso = DEBUGLoadBMPDefaultAligned(thread, gameMemory.DEBUGPlatformReadEntireFile, "test/test_hero_front_torso.bmp");
        SetTopDownAlignment(&gameState.heroBitmaps[3], .{ 72, 182 });

        var series = game.RandomSeed(1234);

        const screenBaseX = @as(u32, 0);
        const screenBaseY = @as(u32, 0);
        const screenBaseZ = @as(u32, 0);
        var screenX = screenBaseX;
        var screenY = screenBaseY;
        var absTileZ = @as(i32, screenBaseZ);

        var doorLeft = false;
        var doorRight = false;
        var doorTop = false;
        var doorBottom = false;
        var doorUp = false;
        var doorDown = false;

        var screenIndex: u32 = 0;
        while (screenIndex < 2000) : (screenIndex += 1) {
            var doorDirection = @as(u32, 0);
            if (NOT_IGNORE) {
                doorDirection = series.RandomChoice(if (doorUp or doorDown) 2 else 4);
            } else {
                doorDirection = series.RandomChoice(2);
            }

            // doorDirection = 3;

            var createdZDoor = false;
            if (doorDirection == 3) {
                createdZDoor = true;
                doorDown = true;
            } else if (doorDirection == 2) {
                createdZDoor = true;
                doorUp = true;
            } else if (doorDirection == 1) {
                doorRight = true;
            } else {
                doorTop = true;
            }

            _ = AddStandardRoom(gameState, screenX * tilesPerWidth + tilesPerWidth / 2, screenY * tilesPerHeight + tilesPerHeight / 2, absTileZ);

            var tileY = @as(u32, 0);
            while (tileY < tilesPerHeight) : (tileY += 1) {
                var tileX = @as(u32, 0);
                while (tileX < tilesPerWidth) : (tileX += 1) {
                    const absTileX = screenX * tilesPerWidth + tileX;
                    const absTileY = screenY * tilesPerHeight + tileY;

                    var shouldBeDoor = false;
                    if ((tileX == 0) and (!doorLeft or (tileY != (tilesPerHeight / 2)))) {
                        shouldBeDoor = true;
                    }

                    if ((tileX == (tilesPerWidth - 1)) and (!doorRight or (tileY != (tilesPerHeight / 2)))) {
                        shouldBeDoor = true;
                    }

                    if ((tileY == 0) and (!doorBottom or (tileX != (tilesPerWidth / 2)))) {
                        shouldBeDoor = true;
                    }

                    if ((tileY == (tilesPerHeight - 1)) and (!doorTop or (tileX != (tilesPerWidth / 2)))) {
                        shouldBeDoor = true;
                    }

                    if (shouldBeDoor) {
                        _ = AddWall(gameState, absTileX, absTileY, absTileZ);
                    } else if (createdZDoor) {
                        if (((@rem(absTileZ, 2) != 0) and (tileX == 10) and (tileY == 5)) or ((@rem(absTileZ, 2) == 0) and (tileX == 4) and (tileY == 5))) {
                            // TODO (Manav): absTileZ has integer overflow, tolerate it for now.
                            _ = AddStairs(gameState, absTileX, absTileY, if (doorDown) absTileZ - 1 else absTileZ);
                        }
                    }
                }
            }

            doorLeft = doorRight;
            doorBottom = doorTop;

            if (createdZDoor) {
                doorDown = !doorDown;
                doorUp = !doorUp;
            } else {
                doorDown = false;
                doorUp = false;
            }

            doorRight = false;
            doorTop = false;

            if (doorDirection == 3) {
                absTileZ -= 1;
            } else if (doorDirection == 2) {
                absTileZ += 1;
            } else if (doorDirection == 1) {
                screenX += 1;
            } else {
                screenY += 1;
            }
        }

        if (!NOT_IGNORE) {
            while (gameState.lowEntityCount < (gameState.lowEntities.len - 16)) {
                const coordinate = 1024 + gameState.lowEntityCount;
                AddWall(gameState, coordinate, coordinate, coordinate);
            }
        }

        const cameraTileX = screenBaseX * tilesPerWidth + 17 / 2;
        const cameraTileY = screenBaseY * tilesPerHeight + 9 / 2;
        const cameraTileZ = screenBaseZ;

        const newCameraP = ChunkPosFromTilePos(gameState.world, cameraTileX, cameraTileY, cameraTileZ, .{ 0, 0, 0 });

        gameState.cameraP = newCameraP;

        _ = AddMonstar(gameState, cameraTileX - 3, cameraTileY + 2, cameraTileZ);
        var familiarIndex = @as(u32, 0);
        while (familiarIndex < 1) : (familiarIndex += 1) {
            const familiarOffsetX = series.RandomBetweenI32(-7, 7);
            const familiarOffsetY = series.RandomBetweenI32(-3, -1);

            if ((familiarOffsetX != 0) or (familiarOffsetY != 0)) {
                _ = AddFamiliar(gameState, @intCast(u32, @intCast(i32, cameraTileX) + familiarOffsetX), @intCast(u32, @intCast(i32, cameraTileY) + familiarOffsetY), cameraTileZ);
            }
        }

        gameMemory.isInitialized = true;
    }

    assert(@sizeOf(game.transient_state) <= gameMemory.transientStorageSize);
    const tranState = @ptrCast(*game.transient_state, @alignCast(@alignOf(game.transient_state), gameMemory.transientStorage));
    if (!tranState.initialized) {
        tranState.tranArena.Initialize(
            gameMemory.transientStorageSize - @sizeOf(game.transient_state),
            gameMemory.transientStorage + @sizeOf(game.transient_state),
        );

        tranState.groundBufferCount = 256; // 64
        tranState.groundBuffers = tranState.tranArena.PushArray(game.ground_buffer, tranState.groundBufferCount);
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBufferCount) : (groundBufferIndex += 1) {
            var groundBuffer: *game.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.bitmap = MakeEmptyBitmap(&tranState.tranArena, groundBufferWidth, groundBufferHeight, false);
            groundBuffer.p = game.NullPosition();
        }

        gameState.testDiffuse = MakeEmptyBitmap(&tranState.tranArena, 256, 256, false);
        gameState.testNormal = MakeEmptyBitmap(&tranState.tranArena, gameState.testDiffuse.width, gameState.testDiffuse.height, false);

        MakeSphereNormalMap(&gameState.testNormal, 0, 1, 1);
        MakeSphereDiffuseMap(&gameState.testDiffuse, 1, 1);
        // MakePyramidNormalMap(&gameState.testNormal, 0);

        tranState.envMapWidth = 512;
        tranState.envMapHeight = 256;
        for (tranState.envMaps) |*map| {
            var width = tranState.envMapWidth;
            var height = tranState.envMapHeight;
            var lodIndex = @as(u32, 0);
            while (lodIndex < map.lod.len) : (lodIndex += 1) {
                map.lod[lodIndex] = MakeEmptyBitmap(&tranState.tranArena, @intCast(i32, width), @intCast(i32, height), false);
                width >>= 1;
                height >>= 1;
            }
        }

        tranState.initialized = true;
    }

    if (!NOT_IGNORE and gameInput.executableReloaded) {
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBufferCount) : (groundBufferIndex += 1) {
            var groundBuffer: *game.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            groundBuffer.p = game.NullPosition();
        }
    }

    const world = gameState.world;

    for (gameInput.controllers) |controller, controllerIndex| {
        const conHero = &gameState.controlledHeroes[controllerIndex];
        if (conHero.entityIndex == 0) {
            if (controller.buttons.mapped.start.endedDown != 0) {
                conHero.* = .{};
                conHero.entityIndex = AddPlayer(gameState).lowIndex;
            }
        } else {
            conHero.dZ = 0;
            conHero.dSword = .{ 0, 0 };
            conHero.ddP = .{ 0, 0 };

            if (controller.isAnalog) {
                conHero.ddP = .{ controller.stickAverageX, controller.stickAverageX };
            } else {
                if (controller.buttons.mapped.moveUp.endedDown != 0) {
                    conHero.ddP[1] = 1.0;
                }
                if (controller.buttons.mapped.moveDown.endedDown != 0) {
                    conHero.ddP[1] = -1.0;
                }
                if (controller.buttons.mapped.moveLeft.endedDown != 0) {
                    conHero.ddP[0] = -1.0;
                }
                if (controller.buttons.mapped.moveRight.endedDown != 0) {
                    conHero.ddP[0] = 1.0;
                }
            }

            if (controller.buttons.mapped.start.endedDown != 0) {
                conHero.dZ = 3.0;
            }

            conHero.dSword = .{ 0, 0 };

            if (controller.buttons.mapped.actionUp.endedDown != 0) {
                conHero.dSword[1] = 1.0;
            }
            if (controller.buttons.mapped.actionDown.endedDown != 0) {
                conHero.dSword[1] = -1.0;
            }
            if (controller.buttons.mapped.actionLeft.endedDown != 0) {
                conHero.dSword[0] = -1.0;
            }
            if (controller.buttons.mapped.actionRight.endedDown != 0) {
                conHero.dSword[0] = 1.0;
            }
        }
    }

    var drawBuffer_ = game.loaded_bitmap{
        .width = @intCast(i32, buffer.width),
        .height = @intCast(i32, buffer.height),
        .pitch = @intCast(i32, buffer.pitch),
        .memory = @ptrCast([*]u8, buffer.memory.?),
    };
    const drawBuffer = &drawBuffer_;

    const renderMemory = game.BeginTemporaryMemory(&tranState.tranArena);
    const renderGroup = game.render_group.Allocate(&tranState.tranArena, platform.MegaBytes(4), @intCast(u32, drawBuffer.width), @intCast(u32, drawBuffer.height));

    renderGroup.Clear(game.v4{ 0.25, 0.25, 0.25, 0 });

    const screenCenter = game.v2{
        0.5 * @intToFloat(f32, drawBuffer.width),
        0.5 * @intToFloat(f32, drawBuffer.height),
    };

    const screenBounds = game.GetCameraRectangleAtTarget(renderGroup);
    var cameraBoundsInMeters = game.rect3{ .min = game.ToV3(screenBounds.min, 0), .max = game.ToV3(screenBounds.max, 0) };
    cameraBoundsInMeters.min[2] = -3 * gameState.typicalFloorHeight;
    cameraBoundsInMeters.max[2] = 1 * gameState.typicalFloorHeight;

    if (NOT_IGNORE) {
        var groundBufferIndex = @as(u32, 0);
        while (groundBufferIndex < tranState.groundBufferCount) : (groundBufferIndex += 1) {
            var groundBuffer: *game.ground_buffer = &tranState.groundBuffers[groundBufferIndex];
            if (game.IsValid(groundBuffer.p)) {
                const bitmap = &groundBuffer.bitmap;
                const delta = game.Substract(world, &groundBuffer.p, &gameState.cameraP);

                if ((game.Z(delta) >= -1.0) and (game.Z(delta) < 1.0)) {
                    const basis = tranState.tranArena.PushStruct(game.render_basis);
                    renderGroup.defaultBasis = basis;
                    basis.p = delta;

                    const groundSideInMeters = game.X(world.chunkDimInMeters);
                    renderGroup.PushBitmap(bitmap, groundSideInMeters, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                    if (NOT_IGNORE) {
                        renderGroup.PushRectOutline(.{ 0, 0, 0 }, .{ groundSideInMeters, groundSideInMeters }, .{ 1, 1, 0, 1 });
                    }
                }
            }
        }

        {
            const minChunkP = game.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMinCorner());
            const maxChunkP = game.MapIntoChunkSpace(world, gameState.cameraP, cameraBoundsInMeters.GetMaxCorner());

            var chunkZ = minChunkP.chunkZ;
            while (chunkZ <= maxChunkP.chunkZ) : (chunkZ += 1) {
                var chunkY = minChunkP.chunkY;
                while (chunkY <= maxChunkP.chunkY) : (chunkY += 1) {
                    var chunkX = minChunkP.chunkX;
                    while (chunkX <= maxChunkP.chunkX) : (chunkX += 1) {
                        // if (game.GetWorldChunk(null, world, )) |chunk|
                        {
                            const chunkCenterP = game.CenteredChunkPoint(chunkX, chunkY, chunkZ);
                            const relP = game.Substract(world, &chunkCenterP, &gameState.cameraP);
                            _ = relP;

                            var furthestBufferLengthSq = @as(f32, 0);
                            var furthestBuffer: ?*game.ground_buffer = null;
                            var index = @as(u32, 0);
                            while (index < tranState.groundBufferCount) : (index += 1) {
                                const groundBuffer = &tranState.groundBuffers[index];
                                if (game.AreInSameChunk(world, &groundBuffer.p, &chunkCenterP)) {
                                    furthestBuffer = null;
                                    break;
                                } else if (game.IsValid(groundBuffer.p)) {
                                    const distance = game.Substract(world, &groundBuffer.p, &gameState.cameraP);
                                    const bufferLengthSq = game.LengthSq(game.XY(distance));
                                    if (furthestBufferLengthSq < bufferLengthSq) {
                                        furthestBufferLengthSq = bufferLengthSq;
                                        furthestBuffer = groundBuffer;
                                    }
                                } else {
                                    furthestBufferLengthSq = platform.F32MAXIMUM;
                                    furthestBuffer = groundBuffer;
                                }
                            }

                            if (furthestBuffer != null) {
                                FillGroundChunk(tranState, gameState, furthestBuffer.?, &chunkCenterP);
                            }
                        }
                    }
                }
            }
        }
    }

    const simBoundsExpansion = game.v3{ 15, 15, 0 };
    const simBounds = cameraBoundsInMeters.AddRadius(simBoundsExpansion);
    const simMemory = game.BeginTemporaryMemory(&tranState.tranArena);
    const simCenterP = gameState.cameraP;
    const simRegion = game.BeginSim(&tranState.tranArena, gameState, gameState.world, simCenterP, simBounds, gameInput.dtForFrame);

    const cameraP: game.v3 = game.Substract(world, &gameState.cameraP, &simCenterP);

    const b = tranState.tranArena.PushStruct(game.render_basis);
    b.p = .{ 0, 0, 0 };
    renderGroup.defaultBasis = b;

    renderGroup.PushRectOutline(.{ 0, 0, 0 }, screenBounds.GetDim(), .{ 1, 1, 0, 1 });
    // renderGroup.PushRectOutline( .{0, 0, 0}, game.XY(cameraBoundsInMeters.GetDim()), .{1, 1, 1, 1});
    renderGroup.PushRectOutline(.{ 0, 0, 0 }, game.XY(simBounds.GetDim()), .{ 0, 1, 1, 1 });
    renderGroup.PushRectOutline(.{ 0, 0, 0 }, game.XY(simRegion.bounds.GetDim()), .{ 1, 0, 1, 1 });
    // renderGroup.PushRectOutline( .{ 0, 0, 0 }, game.XY(simRegion.updatableBounds.GetDim()), .{ 1, 1, 1, 1 });

    var entityIndex = @as(u32, 0);
    while (entityIndex < simRegion.entityCount) : (entityIndex += 1) {
        const entity: *game.sim_entity = &simRegion.entities[entityIndex];

        if (entity.updatable) {
            const dt = gameInput.dtForFrame;

            const alpha = 1 - 0.5 * game.Z(entity.p);
            const shadowAlpha = game.Clampf01(alpha);

            var moveSpec = game.DefaultMoveSpec();
            var ddP = game.v3{ 0, 0, 0 };

            const basis = tranState.tranArena.PushStruct(game.render_basis);
            renderGroup.defaultBasis = basis;

            const cameraRelativeGroundP: game.v3 = game.Sub(game.GetEntityGroundPoint(entity), cameraP);
            const fadeTopEndZ = 0.75 * gameState.typicalFloorHeight;
            const fadeTopStartZ = 0.5 * gameState.typicalFloorHeight;
            const fadeBottomStartZ = -2 * gameState.typicalFloorHeight;
            const fadeBottomEndZ = -2.5 * gameState.typicalFloorHeight;
            renderGroup.globalAlpha = 1.0;
            if (game.Z(cameraRelativeGroundP) > fadeTopStartZ) {
                renderGroup.globalAlpha = game.ClampMapToRange(fadeTopEndZ, game.Z(cameraRelativeGroundP), fadeTopStartZ);
            } else if (game.Z(cameraRelativeGroundP) < fadeBottomStartZ) {
                renderGroup.globalAlpha = game.ClampMapToRange(fadeBottomEndZ, game.Z(cameraRelativeGroundP), fadeBottomStartZ);
            }

            const heroBitmaps = &gameState.heroBitmaps[entity.facingDirection];
            switch (entity.entityType) {
                .Hero => {
                    for (gameState.controlledHeroes) |conHero| {
                        if (entity.storageIndex == conHero.entityIndex) {
                            if (conHero.dZ != 0) {
                                entity.dP[2] = conHero.dZ;
                            }

                            moveSpec.unitMaxAccelVector = true;
                            moveSpec.speed = 50;
                            moveSpec.drag = 8;
                            ddP = .{ game.X(conHero.ddP), game.Y(conHero.ddP), 0 };
                            if ((game.X(conHero.dSword) != 0) or (game.Y(conHero.dSword) != 0)) {
                                switch (entity.sword) {
                                    .ptr => {
                                        const sword = entity.sword.ptr;
                                        if (game.IsSet(sword, @enumToInt(game.sim_entity_flags.NonSpatial))) {
                                            sword.distanceLimit = 5.0;
                                            const dSwordV3 = game.v3{ game.X(conHero.dSword), game.Y(conHero.dSword), 0 };
                                            game.MakeEntitySpatial(sword, entity.p, game.Add(entity.dP, (game.Scale(dSwordV3, 5))));
                                            game.AddCollisionRule(gameState, sword.storageIndex, entity.storageIndex, false);
                                        }
                                    },

                                    .index => {
                                        unreachable;
                                    },
                                }
                            }
                        }
                    }

                    const heroSizeC = 2.5;

                    renderGroup.PushBitmap(&gameState.shadow, heroSizeC * 1.0, .{ 0, 0, 0 }, .{ 1, 1, 1, shadowAlpha });
                    renderGroup.PushBitmap(&heroBitmaps.torso, heroSizeC * 1.2, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                    renderGroup.PushBitmap(&heroBitmaps.cape, heroSizeC * 1.2, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                    renderGroup.PushBitmap(&heroBitmaps.head, heroSizeC * 1.2, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });

                    DrawHitpoints(entity, renderGroup);
                },

                .Wall => {
                    renderGroup.PushBitmap(&gameState.tree, 2.5, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                },

                .Stairwell => {
                    renderGroup.PushRect(.{ 0, 0, 0 }, entity.walkableDim, .{ 1, 0.5, 0, 1 });
                    renderGroup.PushRect(.{ 0, 0, entity.walkableHeight }, entity.walkableDim, .{ 1, 1, 0, 1 });
                },

                .Sword => {
                    moveSpec.unitMaxAccelVector = false;
                    moveSpec.speed = 0;
                    moveSpec.drag = 0;

                    if (entity.distanceLimit == 0) {
                        game.ClearCollisionRulesFor(gameState, entity.storageIndex);
                        game.MakeEntityNonSpatial(entity);
                    } else {
                        // NOTE (Manav): invalid z position causes float overflow down the line when drawing bitmap because of zFudge,
                        // so not pushing bitmap when entity becomes non spatial
                    }
                    renderGroup.PushBitmap(&gameState.shadow, 0.5, .{ 0, 0, 0 }, .{ 1, 1, 1, shadowAlpha });
                    renderGroup.PushBitmap(&gameState.sword, 0.5, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });
                },

                .Familiar => {
                    var closestHero: ?*game.sim_entity = null;
                    var closestHeroDSq = game.Square(10);
                    if (!NOT_IGNORE) {
                        var testEntityIndex = @as(u32, 0);
                        while (testEntityIndex < simRegion.entityCount) : (testEntityIndex += 1) {
                            const testEntity: *game.sim_entity = &simRegion.entities[testEntityIndex];
                            if (testEntity.entityType == .Hero) {
                                var testDSq = game.LengthSq(3, testEntity.p - entity.p);

                                if (closestHeroDSq > testDSq) {
                                    closestHero = testEntity;
                                    closestHeroDSq = testDSq;
                                }
                            }
                        }
                    }

                    if (closestHero) |hero| {
                        if (closestHeroDSq > game.Square(3)) {
                            const accelaration = 0.5;
                            const oneOverLength = accelaration / game.SquareRoot(closestHeroDSq);
                            ddP = game.Scale(game.Sub(hero.p, entity.p), oneOverLength);
                        }
                    }

                    moveSpec.unitMaxAccelVector = true;
                    moveSpec.speed = 50;
                    moveSpec.drag = 8;

                    entity.tBob += dt;
                    if (entity.tBob > 2 * platform.PI32) {
                        entity.tBob -= 2 * platform.PI32;
                    }
                    const bobSin = game.Sin(2 * entity.tBob);
                    renderGroup.PushBitmap(&gameState.shadow, 2.5, .{ 0, 0, 0 }, .{ 1, 1, 1, (0.5 * shadowAlpha) + (0.2 * bobSin) });
                    renderGroup.PushBitmap(&heroBitmaps.head, 2.5, .{ 0, 0, 0.25 * bobSin }, .{ 1, 1, 1, 1 });
                },

                .Monstar => {
                    renderGroup.PushBitmap(&gameState.shadow, 4.5, .{ 0, 0, 0 }, .{ 1, 1, 1, shadowAlpha });
                    renderGroup.PushBitmap(&heroBitmaps.torso, 4.5, .{ 0, 0, 0 }, .{ 1, 1, 1, 1 });

                    DrawHitpoints(entity, renderGroup);
                },

                .Space => {
                    if (!NOT_IGNORE) {
                        var volumeIndex = @as(u32, 0);
                        while (volumeIndex < entity.collision.volumeCount) : (volumeIndex += 1) {
                            const volume = entity.collision.volumes[volumeIndex];
                            renderGroup.PushRectOutline(game.Sub(volume.offsetP, .{ 0, 0, 0.5 * game.Z(volume.dim) }), game.XY(volume.dim), .{ 0, 0.5, 1, 1 });
                        }
                    }
                },

                .Null => {
                    unreachable;
                },
            }

            if (!game.IsSet(entity, @enumToInt(game.sim_entity_flags.NonSpatial)) and
                game.IsSet(entity, @enumToInt(game.sim_entity_flags.Movable)))
            {
                game.MoveEntity(gameState, simRegion, entity, gameInput.dtForFrame, &moveSpec, ddP);
            }

            basis.p = game.GetEntityGroundPoint(entity);
        }
    }

    renderGroup.globalAlpha = 1.0;

    if (!NOT_IGNORE) {
        gameState.time += gameInput.dtForFrame;

        const mapColour = [_]game.v3{
            .{ 1, 0, 0 },
            .{ 0, 1, 0 },
            .{ 0, 0, 1 },
        };

        {
            var mapIndex = @as(u32, 0);
            while (mapIndex < tranState.envMaps.len) : (mapIndex += 1) {
                const map = &tranState.envMaps[mapIndex];
                const lod = &map.lod[0];
                var rowCheckerOn = false;
                var checkerWidth = @as(i32, 16);
                var checkerHeight = @as(i32, 16);

                var y = @as(i32, 0);
                while (y < lod.height) : (y += checkerHeight) {
                    var checkerOn = rowCheckerOn;
                    var x = @as(i32, 0);
                    while (x < lod.width) : (x += checkerWidth) {
                        const colour: game.v4 = if (checkerOn) game.ToV4(mapColour[mapIndex], 1) else game.v4{ 0, 0, 0, 1 };
                        const minP = game.V2(x, y);
                        const maxP: game.v2 = game.Add(minP, game.V2(checkerWidth, checkerHeight));
                        game.DrawRectangle(lod, minP, maxP, colour);
                        checkerOn = !checkerOn;
                    }
                    rowCheckerOn = !rowCheckerOn;
                }
            }
        }
        tranState.envMaps[0].pZ = -1.5;
        tranState.envMaps[1].pZ = 0;
        tranState.envMaps[2].pZ = 1.5;

        game.DrawBitmap(&tranState.envMaps[0].lod[0], &tranState.groundBuffers[tranState.groundBufferCount - 1].bitmap, 125, 25, 1);

        // angle = 0;

        var origin = screenCenter;

        var angle = 0.1 * gameState.time;
        const disp: game.v2 = if (NOT_IGNORE) .{ 100 * game.Cos(5 * angle), 100 * game.Sin(3 * angle) } else .{ 0, 0 };

        var xAxis: game.v2 = undefined;
        var yAxis: game.v2 = undefined;
        if (NOT_IGNORE) {
            xAxis = game.Scale(game.v2{ game.Cos(10 * angle), game.Sin(10 * angle) }, 100);
            yAxis = game.Perp(xAxis);
        } else {
            xAxis = game.v2{ 100, 0 };
            yAxis = game.v2{ 0, 100 };
        }

        const cAngle = 5 * angle;

        var colour: game.v4 = undefined;

        if (!NOT_IGNORE) {
            colour = .{
                0.5 + 0.5 * game.Sin(cAngle),
                0.5 + 0.5 * game.Sin(2.9 * cAngle),
                0.5 + 0.5 * game.Cos(9.9 * cAngle),
                0.5 + 0.5 * game.Sin(10 * cAngle),
            };
        } else {
            colour = .{ 1, 1, 1, 1 };
        }

        _ = game.CoordinateSystem(
            renderGroup,
            game.Sub(game.Add(disp, origin), game.Scale(game.Add(xAxis, yAxis), 0.5)),
            xAxis,
            yAxis,
            colour,
            &gameState.testDiffuse,
            &gameState.testNormal,
            &tranState.envMaps[2],
            &tranState.envMaps[1],
            &tranState.envMaps[0],
        );

        var mapP: game.v2 = .{ 0, 0 };
        {
            var index = @as(u32, 0);
            while (index < tranState.envMaps.len) : (index += 1) {
                const lod = &tranState.envMaps[index].lod[0];

                xAxis = game.v2{ 0.5 * @intToFloat(f32, lod.width), 0 };
                yAxis = game.v2{ 0, 0.5 * @intToFloat(f32, lod.height) };

                _ = game.CoordinateSystem(renderGroup, mapP, xAxis, yAxis, .{ 1, 1, 1, 1 }, lod, null, null, null, null);
                game.AddTo(&mapP, game.Add(yAxis, game.v2{ 0, 6 }));
            }
        }

        // game.Saturation(renderGroup, 0.5 + 0.5 * game.Sin(10 * gameState.time));
    }

    renderGroup.TiledRenderGroupToOutput(drawBuffer);

    game.EndSim(simRegion, gameState); // TODO (Manav): use defer
    game.EndTemporaryMemory(simMemory);
    game.EndTemporaryMemory(renderMemory);

    gameState.worldArena.CheckArena();
    tranState.tranArena.CheckArena();
}

pub export fn GetSoundSamples(_: *platform.thread_context, gameMemory: *platform.memory, soundBuffer: *platform.sound_output_buffer) void {
    comptime {
        // NOTE (Manav): This is hacky atm. Need to check as we're using win32.LoadLibrary()
        if (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args.len != @typeInfo(platform.GetSoundSamplesType).Fn.args.len or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[0].arg_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.args[0].arg_type.?) or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[1].arg_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.args[1].arg_type.?) or
            (@typeInfo(@TypeOf(GetSoundSamples)).Fn.args[2].arg_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.args[2].arg_type.?) or
            @typeInfo(@TypeOf(GetSoundSamples)).Fn.return_type.? != @typeInfo(platform.GetSoundSamplesType).Fn.return_type.?)
        {
            @compileError("Function signature mismatch!");
        }
    }

    const gameState = @ptrCast(*game.state, @alignCast(@alignOf(game.state), gameMemory.permanentStorage));
    OutputSound(gameState, soundBuffer, 400);
}

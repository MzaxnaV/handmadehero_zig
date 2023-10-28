const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade.zig");
};

const hi = platform.handmade_internal;
const assert = platform.Assert;

const NOT_IGNORE = platform.NOT_IGNORE;

// data types -----------------------------------------------------------------------------------------------------------------------------

pub const hero_bitmaps = struct {
    head: h.loaded_bitmap,
    cape: h.loaded_bitmap,
    torso: h.loaded_bitmap,
};

pub const asset_state = enum {
    AssetState_Unloaded,
    AssetState_Queued,
    AssetState_Loaded,
    AssetState_Locked,
};

pub const asset_slot = struct {
    state: asset_state,
    bitmap: ?*h.loaded_bitmap,
};

pub const asset_tag_id = enum {
    Tag_Smoothness,
    Tag_Flatness,

    fn len() comptime_int {
        comptime {
            return @typeInfo(asset_type_id).Enum.fields.len;
        }
    }
};

pub const asset_type_id = enum(u32) {
    Asset_Backdrop = 0,
    Asset_Shadow,
    Asset_Tree,
    Asset_Sword,
    Asset_Stairwell,
    Asset_Rock,

    fn len() comptime_int {
        comptime {
            return @typeInfo(asset_type_id).Enum.fields.len;
        }
    }
};

pub const asset_tag = struct {
    ID: u32,
    value: f32,
};

pub const asset = struct {
    firstTagIndex: u32,
    onePastLastTagIndex: u32,
    slotId: u32,
};

pub const asset_type = struct {
    count: u32,
    firstAssetIndex: u32,
    onePastLastAssetIndex: u32,
};

pub const asset_bitmap_info = struct {
    alignPercentage: h.v2 = .{ 0, 0 },
    widthOverHeight: f32 = 0,

    width: i32 = 0,
    height: i32 = 0,
};

pub const asset_group = struct {
    firstTagIndex: u32,
    onePastLastTagIndex: u32,
};

pub const game_assets = struct {
    tranState: *h.transient_state,
    assetArena: h.memory_arena,

    bitMapCount: u32,
    bitmaps: [*]asset_slot,

    soundCount: u32,
    sounds: [*]asset_slot,

    assetTypes: [asset_type_id.len()]asset_type,

    grass: [2]h.loaded_bitmap,
    stones: [4]h.loaded_bitmap,
    tufts: [3]h.loaded_bitmap,

    heroBitmaps: [4]hero_bitmaps,

    pub inline fn GetBitmap(self: *game_assets, ID: bitmap_id) ?*h.loaded_bitmap {
        var result = self.bitmaps[ID.value].bitmap;
        return result;
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.assetArena.SubArena(arena, 16, size);
        assets.tranState = tranState;

        assets.bitMapCount = asset_tag_id.len();
        assets.bitmaps = arena.PushArray(asset_slot, assets.bitMapCount);

        assets.soundCount = 1;
        assets.sounds = arena.PushArray(asset_slot, assets.soundCount);

        assets.grass[0] = DEBUGLoadBMPDefaultAligned("test2/grass00.bmp");
        assets.grass[1] = DEBUGLoadBMPDefaultAligned("test2/grass01.bmp");

        assets.tufts[0] = DEBUGLoadBMPDefaultAligned("test2/tuft00.bmp");
        assets.tufts[1] = DEBUGLoadBMPDefaultAligned("test2/tuft01.bmp");
        assets.tufts[2] = DEBUGLoadBMPDefaultAligned("test2/tuft00.bmp");

        assets.stones[0] = DEBUGLoadBMPDefaultAligned("test2/ground00.bmp");
        assets.stones[1] = DEBUGLoadBMPDefaultAligned("test2/ground01.bmp");
        assets.stones[2] = DEBUGLoadBMPDefaultAligned("test2/ground02.bmp");
        assets.stones[3] = DEBUGLoadBMPDefaultAligned("test2/ground03.bmp");

        assets.heroBitmaps[0].head = DEBUGLoadBMPDefaultAligned("test/test_hero_right_head.bmp");
        assets.heroBitmaps[0].cape = DEBUGLoadBMPDefaultAligned("test/test_hero_right_cape.bmp");
        assets.heroBitmaps[0].torso = DEBUGLoadBMPDefaultAligned("test/test_hero_right_torso.bmp");
        SetTopDownAlignment(&assets.heroBitmaps[0], .{ 72, 182 });

        assets.heroBitmaps[1].head = DEBUGLoadBMPDefaultAligned("test/test_hero_back_head.bmp");
        assets.heroBitmaps[1].cape = DEBUGLoadBMPDefaultAligned("test/test_hero_back_cape.bmp");
        assets.heroBitmaps[1].torso = DEBUGLoadBMPDefaultAligned("test/test_hero_back_torso.bmp");
        SetTopDownAlignment(&assets.heroBitmaps[1], .{ 72, 182 });

        assets.heroBitmaps[2].head = DEBUGLoadBMPDefaultAligned("test/test_hero_left_head.bmp");
        assets.heroBitmaps[2].cape = DEBUGLoadBMPDefaultAligned("test/test_hero_left_cape.bmp");
        assets.heroBitmaps[2].torso = DEBUGLoadBMPDefaultAligned("test/test_hero_left_torso.bmp");
        SetTopDownAlignment(&assets.heroBitmaps[2], .{ 72, 182 });

        assets.heroBitmaps[3].head = DEBUGLoadBMPDefaultAligned("test/test_hero_front_head.bmp");
        assets.heroBitmaps[3].cape = DEBUGLoadBMPDefaultAligned("test/test_hero_front_cape.bmp");
        assets.heroBitmaps[3].torso = DEBUGLoadBMPDefaultAligned("test/test_hero_front_torso.bmp");
        SetTopDownAlignment(&assets.heroBitmaps[3], .{ 72, 182 });

        return assets;
    }
};

pub const bitmap_id = struct { value: u32 };

pub const audio_id = struct { value: u32 };

/// Defaults: ```alignX =  , topDownAlignY = ```
inline fn DEBUGLoadBMPDefaultAligned(
    fileName: [*:0]const u8,
) h.loaded_bitmap {
    var result = DEBUGLoadBMP(fileName, 0, 0);
    result.alignPercentage = .{ 0.5, 0.5 };

    return result;
}

inline fn TopDownAlign(bitmap: *const h.loaded_bitmap, alignment: h.v2) h.v2 {
    const fixedAlignment = h.v2{
        h.SafeRatiof0(h.X(alignment), @as(f32, @floatFromInt(bitmap.width))),
        h.SafeRatiof0(@as(f32, @floatFromInt(bitmap.height - 1)) - h.Y(alignment), @as(f32, @floatFromInt(bitmap.height))),
    };
    return fixedAlignment;
}

fn SetTopDownAlignment(bitmaps: *hero_bitmaps, alignment: h.v2) void {
    const fixedAlignment = TopDownAlign(&bitmaps.head, alignment);

    bitmaps.head.alignPercentage = fixedAlignment;
    bitmaps.torso.alignPercentage = fixedAlignment;
    bitmaps.cape.alignPercentage = fixedAlignment;
}

fn DEBUGLoadBMP(
    fileName: [*:0]const u8,
    alignX: i32,
    topDownAlignY: i32,
) h.loaded_bitmap {
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

    var result = h.loaded_bitmap{};

    const readResult = h.DEBUGPlatformReadEntireFile.?(fileName);
    if (readResult.contentSize != 0) {
        const header = @as(*align(@alignOf(u8)) bitmap_header, @ptrCast(readResult.contents));
        const pixels = readResult.contents + header.bitmapOffset;
        result.width = header.width;
        result.height = header.height;
        result.memory = pixels;
        result.alignPercentage = TopDownAlign(&result, h.V2(alignX, topDownAlignY));
        result.widthOverHeight = h.SafeRatiof0(@as(f32, @floatFromInt(result.width)), @as(f32, @floatFromInt(result.height)));

        assert(header.height >= 0);
        assert(header.compression == 3);

        const redMask = header.redMask;
        const greenMask = header.greenMask;
        const blueMask = header.blueMask;
        const alphaMask = ~(redMask | greenMask | blueMask);

        const redScan = h.FindLeastSignificantSetBit(redMask);
        const greenScan = h.FindLeastSignificantSetBit(greenMask);
        const blueScan = h.FindLeastSignificantSetBit(blueMask);
        const alphaScan = h.FindLeastSignificantSetBit(alphaMask);

        const redShiftDown = @as(u5, @intCast(redScan));
        const greenShiftDown = @as(u5, @intCast(greenScan));
        const blueShiftDown = @as(u5, @intCast(blueScan));
        const alphaShiftDown = @as(u5, @intCast(alphaScan));

        const sourceDest = @as([*]align(1) u32, @ptrCast(result.memory));

        var index = @as(u32, 0);
        while (index < @as(u32, @intCast(header.height * header.width))) : (index += 1) {
            const c = sourceDest[index];

            var texel = h.v4{
                @as(f32, @floatFromInt((c & redMask) >> redShiftDown)),
                @as(f32, @floatFromInt((c & greenMask) >> greenShiftDown)),
                @as(f32, @floatFromInt((c & blueMask) >> blueShiftDown)),
                @as(f32, @floatFromInt((c & alphaMask) >> alphaShiftDown)),
            };

            texel = h.SRGB255ToLinear1(texel);

            if (NOT_IGNORE) {
                // texel.rgb *= texel.a;
                texel = h.ToV4(h.Scale(h.RGB(texel), h.A(texel)), h.A(texel));
            }

            texel = h.Linear1ToSRGB255(texel);

            sourceDest[index] =
                (@as(u32, @intFromFloat((h.A(texel) + 0.5))) << 24 |
                @as(u32, @intFromFloat((h.R(texel) + 0.5))) << 16 |
                @as(u32, @intFromFloat((h.G(texel) + 0.5))) << 8 |
                @as(u32, @intFromFloat((h.B(texel) + 0.5))) << 0);
        }
    }

    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;

    if (!NOT_IGNORE) {
        result.memory += @as(usize, @intCast(result.pitch * (result.height - 1)));
        result.pitch = -result.width;
    }

    return result;
}

const load_bitmap_work = struct {
    assets: *game_assets,
    fileName: [*:0]const u8,
    ID: bitmap_id,
    task: *h.task_with_memory,
    bitmap: *h.loaded_bitmap,

    hasAlignment: bool,
    alignX: i32,
    topDownAlignY: i32,

    finalState: asset_state,
};

fn LoadBitmapWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(LoadBitmapWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *load_bitmap_work = @alignCast(@ptrCast(data));

    if (work.hasAlignment) {
        work.bitmap.* = DEBUGLoadBMP(work.fileName, work.alignX, work.topDownAlignY);
    } else {
        work.bitmap.* = DEBUGLoadBMPDefaultAligned(work.fileName);
    }

    @fence(.SeqCst);

    work.assets.bitmaps[work.ID.value].bitmap = work.bitmap;
    work.assets.bitmaps[work.ID.value].state = work.finalState;
    work.assets.bitmaps[work.ID.value].state = work.finalState;

    h.EndTaskWithMemory(work.task);
}

pub fn LoadBitmap(assets: *game_assets, ID: bitmap_id) void {
    if (h.AtomicCompareExchange(asset_state, &assets.bitmaps[ID.value].state, .AssetState_Unloaded, .AssetState_Queued)) |_| {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            var work: *load_bitmap_work = task.arena.PushStruct(load_bitmap_work);

            work.assets = assets;
            work.fileName = "";
            work.ID = ID;
            work.task = task;
            work.bitmap = assets.assetArena.PushStruct(h.loaded_bitmap);
            work.hasAlignment = false;
            work.finalState = .AssetState_Loaded;

            switch (@as(asset_type_id, @enumFromInt(ID.value))) {
                .Asset_Backdrop => work.fileName = "test/test_background.bmp",
                .Asset_Shadow => {
                    work.fileName = "test/test_hero_shadow.bmp";
                    work.alignX = 72;
                    work.topDownAlignY = 182;
                    work.hasAlignment = true;
                },
                .Asset_Tree => {
                    work.fileName = "test2/tree00.bmp";
                    work.alignX = 40;
                    work.topDownAlignY = 80;
                    work.hasAlignment = true;
                },
                .Asset_Stairwell => work.fileName = "test2/rock02.bmp",
                .Asset_Sword => {
                    work.fileName = "test2/rock03.bmp";
                    work.alignX = 29;
                    work.topDownAlignY = 10;
                    work.hasAlignment = true;
                },

                .Asset_Rock => {},
            }

            h.PlatformAddEntry(assets.tranState.lowPriorityQueue, LoadBitmapWork, work);
        }
    }
}

pub fn LoadSound(assets: *game_assets, ID: audio_id) void {
    _ = assets;
    _ = ID;
}

pub fn GetFirstBitmapID(_: *game_assets, typeID: asset_type_id) bitmap_id {
    var result: bitmap_id = .{ .value = @intFromEnum(typeID) };

    return result;
}

const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_render_group.zig");
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
    Asset_NONE = 0,

    Asset_Shadow,
    Asset_Tree,
    Asset_Sword,
    // Asset_Stairwell,
    Asset_Rock,

    Asset_Grass,
    Asset_Tuft,
    Asset_Stone,

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
    firstAssetIndex: u32,
    onePastLastAssetIndex: u32,
};

pub const asset_bitmap_info = struct {
    filename: [*:0]const u8,
    alignPercentage: h.v2 = .{ 0, 0 },
};

pub const asset_group = struct {
    firstTagIndex: u32,
    onePastLastTagIndex: u32,
};

pub const game_assets = struct {
    tranState: *h.transient_state,
    assetArena: h.memory_arena,

    bitmapCount: u32,
    bitmapInfos: [*]asset_bitmap_info,
    bitmaps: [*]asset_slot,

    soundCount: u32,
    sounds: [*]asset_slot,

    tagCount: u32,
    tags: [*]asset_tag,

    assetCount: u32,
    assets: [*]asset,

    assetTypes: [asset_type_id.len()]asset_type,

    heroBitmaps: [4]hero_bitmaps,

    DEBUGUsedBitmapCount: u32,
    DEBUGUsedAssetCount: u32,
    DEBUGAssetType: ?*asset_type,

    pub inline fn GetBitmap(self: *game_assets, ID: bitmap_id) ?*h.loaded_bitmap {
        var result = self.bitmaps[ID.value].bitmap;
        return result;
    }

    fn DEBUGAddBitmapInfo(self: *game_assets, fileName: [*:0]const u8, alignPercentage: h.v2) bitmap_id {
        assert(self.DEBUGUsedBitmapCount < self.bitmapCount);

        const ID = bitmap_id{ .value = self.DEBUGUsedBitmapCount };
        self.DEBUGUsedBitmapCount += 1;

        var info: *asset_bitmap_info = &self.bitmapInfos[ID.value];
        info.filename = fileName;
        info.alignPercentage = alignPercentage;

        return ID;
    }

    fn BeginAssetType(self: *game_assets, typeID: asset_type_id) void {
        assert(self.DEBUGAssetType == null);

        self.DEBUGAssetType = &self.assetTypes[@intFromEnum(typeID)];
        self.DEBUGAssetType.?.firstAssetIndex = self.DEBUGUsedAssetCount;
        self.DEBUGAssetType.?.onePastLastAssetIndex = self.DEBUGAssetType.?.firstAssetIndex;
    }

    fn EndAssetType(self: *game_assets) void {
        assert(self.DEBUGAssetType != null);
        self.DEBUGUsedAssetCount = self.DEBUGAssetType.?.onePastLastAssetIndex;
        self.DEBUGAssetType = null;
    }

    /// Defaults: ```alignPercentage = .{0.5, 0.5 }```
    fn AddBitmapAsset(self: *game_assets, fileName: [*:0]const u8, alignPercentage: h.v2) void {
        assert(self.DEBUGAssetType != null);

        var a: *asset = &self.assets[self.DEBUGAssetType.?.onePastLastAssetIndex];
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        a.firstTagIndex = 0;
        a.onePastLastTagIndex = 0;
        a.slotId = self.DEBUGAddBitmapInfo(fileName, alignPercentage).value;
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.assetArena.SubArena(arena, 16, size);
        assets.tranState = tranState;

        assets.bitmapCount = 256 * asset_tag_id.len();
        assets.bitmapInfos = arena.PushArray(asset_bitmap_info, assets.bitmapCount);
        assets.bitmaps = arena.PushArray(asset_slot, assets.bitmapCount);

        assets.soundCount = 1;
        assets.sounds = arena.PushArray(asset_slot, assets.soundCount);

        assets.assetCount = assets.soundCount + assets.bitmapCount;
        assets.assets = arena.PushArray(asset, assets.assetCount);

        assets.DEBUGUsedBitmapCount = 1;
        assets.DEBUGUsedAssetCount = 1;

        assets.BeginAssetType(.Asset_Shadow);
        assets.AddBitmapAsset("test/test_hero_shadow.bmp", .{ 0.5, 0.156682029 });
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Tree);
        assets.AddBitmapAsset("test2/tree00.bmp", .{ 0.493827164, 0.295652181 });
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Sword);
        assets.AddBitmapAsset("test2/rock03.bmp", .{ 0.5, 0.65625 });
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Grass);
        assets.AddBitmapAsset("test2/grass00.bmp", .{ 0.5, 0.5 });
        assets.AddBitmapAsset("test2/grass01.bmp", .{ 0.5, 0.5 });
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Tuft);
        assets.AddBitmapAsset("test2/tuft00.bmp", .{ 0.5, 0.5 });
        assets.AddBitmapAsset("test2/tuft01.bmp", .{ 0.5, 0.5 });
        assets.AddBitmapAsset("test2/tuft02.bmp", .{ 0.5, 0.5 });
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Stone);
        assets.AddBitmapAsset("test2/ground00.bmp", .{ 0.5, 0.5 });
        assets.AddBitmapAsset("test2/ground01.bmp", .{ 0.5, 0.5 });
        assets.AddBitmapAsset("test2/ground02.bmp", .{ 0.5, 0.5 });
        assets.AddBitmapAsset("test2/ground03.bmp", .{ 0.5, 0.5 });
        assets.EndAssetType();

        assets.heroBitmaps[0].head = DEBUGLoadBMP("test/test_hero_right_head.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[0].cape = DEBUGLoadBMP("test/test_hero_right_cape.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[0].torso = DEBUGLoadBMP("test/test_hero_right_torso.bmp", .{ 0.5, 0.5 });
        SetTopDownAlignment(&assets.heroBitmaps[0], .{ 72, 182 });

        assets.heroBitmaps[1].head = DEBUGLoadBMP("test/test_hero_back_head.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[1].cape = DEBUGLoadBMP("test/test_hero_back_cape.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[1].torso = DEBUGLoadBMP("test/test_hero_back_torso.bmp", .{ 0.5, 0.5 });
        SetTopDownAlignment(&assets.heroBitmaps[1], .{ 72, 182 });

        assets.heroBitmaps[2].head = DEBUGLoadBMP("test/test_hero_left_head.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[2].cape = DEBUGLoadBMP("test/test_hero_left_cape.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[2].torso = DEBUGLoadBMP("test/test_hero_left_torso.bmp", .{ 0.5, 0.5 });
        SetTopDownAlignment(&assets.heroBitmaps[2], .{ 72, 182 });

        assets.heroBitmaps[3].head = DEBUGLoadBMP("test/test_hero_front_head.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[3].cape = DEBUGLoadBMP("test/test_hero_front_cape.bmp", .{ 0.5, 0.5 });
        assets.heroBitmaps[3].torso = DEBUGLoadBMP("test/test_hero_front_torso.bmp", .{ 0.5, 0.5 });
        SetTopDownAlignment(&assets.heroBitmaps[3], .{ 72, 182 });

        return assets;
    }
};

pub const bitmap_id = struct { value: u32 };

pub const audio_id = struct { value: u32 };

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

/// Defaults: ```alignPercentage = .{0.5, 0.5 }```
fn DEBUGLoadBMP(
    fileName: [*:0]const u8,
    alignPercentage: h.v2,
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
        result.alignPercentage = alignPercentage;
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
    ID: bitmap_id,
    task: *h.task_with_memory,
    bitmap: *h.loaded_bitmap,

    finalState: asset_state,
};

fn LoadBitmapWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(LoadBitmapWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *load_bitmap_work = @alignCast(@ptrCast(data));

    const info: asset_bitmap_info = work.assets.bitmapInfos[work.ID.value];
    work.bitmap.* = DEBUGLoadBMP(info.filename, info.alignPercentage);

    @fence(.SeqCst);

    work.assets.bitmaps[work.ID.value].bitmap = work.bitmap;
    work.assets.bitmaps[work.ID.value].state = work.finalState;

    h.EndTaskWithMemory(work.task);
}

pub fn LoadBitmap(assets: *game_assets, ID: bitmap_id) void {
    if (ID.value == 0) return;

    if (h.AtomicCompareExchange(asset_state, &assets.bitmaps[ID.value].state, .AssetState_Unloaded, .AssetState_Queued)) |_| {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            var work: *load_bitmap_work = task.arena.PushStruct(load_bitmap_work);

            work.assets = assets;
            work.ID = ID;
            work.task = task;
            work.bitmap = assets.assetArena.PushStruct(h.loaded_bitmap);
            work.finalState = .AssetState_Loaded;

            h.PlatformAddEntry(assets.tranState.lowPriorityQueue, LoadBitmapWork, work);
        }
    }
}

pub fn LoadSound(assets: *game_assets, ID: audio_id) void {
    _ = assets;
    _ = ID;
}

pub fn RandomAssetFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) bitmap_id {
    var result: bitmap_id = .{ .value = 0 };

    var assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        const count = assetType.onePastLastAssetIndex - assetType.firstAssetIndex;
        const choice = series.RandomChoice(count);

        var a = assets.assets[choice + assetType.firstAssetIndex];
        result.value = a.slotId;
    }

    return result;
}

pub fn GetFirstBitmapID(assets: *game_assets, typeID: asset_type_id) bitmap_id {
    var result: bitmap_id = .{ .value = 0 };

    var assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        var a = assets.assets[assetType.firstAssetIndex];
        result.value = a.slotId;
    }

    return result;
}

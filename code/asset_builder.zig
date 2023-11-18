const std = @import("std");
const assert = std.debug.assert;
const asset_type_id = @import("handmade_asset_type_id").asset_type_id;

const out: std.fs.File = undefined;

const asset_tag = struct {
    ID: u32,
    value: f32,
};

const asset = struct {
    dataOffset: u64,
    firstTagIndex: u32,
    onePastLastTagIndex: u32,
};

const asset_type = struct {
    firstAssetIndex: u32,
    onePastLastAssetIndex: u32,
};

const bitmap_asset = struct {
    filename: [*:0]const u8,
    alignment: [2]f32,
};

pub const asset_bitmap_info = struct {
    filename: [*:0]const u8,
    alignPercentage: [2]f32 = .{ 0, 0 },
};

pub const asset_sound_info = struct {
    filename: [*:0]const u8,
    firstSampleIndex: u32,
    sampleCount: u32,
    nextIDToPlay: u32,
};

const VERY_LARGE_NO = 4096;

const bitmapCount: u32 = 0;
const soundCount: u32 = 0;
const tagCount: u32 = 0;
const assetCount: u32 = 0;
const bitmapInfos: [VERY_LARGE_NO]asset_bitmap_info = [1]asset_bitmap_info{.{}} ** VERY_LARGE_NO;
const soundInfos: [VERY_LARGE_NO]asset_sound_info = [1]asset_sound_info{.{}} ** VERY_LARGE_NO;
const tags: [VERY_LARGE_NO]asset_tag = [1]asset_tag{.{}} ** VERY_LARGE_NO;
const assets: [VERY_LARGE_NO]asset = [1]asset{.{}} ** VERY_LARGE_NO;
const assetTypes: [asset_type_id.len()]asset_type = undefined;

const DEBUGUsedBitmapCount: u32 = 0;
const DEBUGUsedSoundCount: u32 = 0;
const DEBUGUsedAssetCount: u32 = 0;
const DEBUGUsedTagCount: u32 = 0;
const DEBUGAssetType: ?*asset_type = .{};
const DEBUGAsset: ?*asset = .{};

fn BeginAssetType(typeID: asset_type_id) void {
    assert(DEBUGAssetType == null);

    DEBUGAssetType = &assetTypes[@intFromEnum(typeID)];
    DEBUGAssetType.?.firstAssetIndex = DEBUGUsedAssetCount;
    DEBUGAssetType.?.onePastLastAssetIndex = DEBUGAssetType.?.firstAssetIndex;
}

fn EndAssetType() void {
    assert(DEBUGAssetType != null);
    DEBUGUsedAssetCount = DEBUGAssetType.?.onePastLastAssetIndex;
    DEBUGAssetType = null;
    DEBUGAsset = null;
}

/// Defaults: ```alignPercentage = .{0.5, 0.5 }```
fn AddBitmapAsset(fileName: [*:0]const u8, alignPercentageX: f32, alignPercentageY: f32) void {
    _ = alignPercentageY;
    _ = alignPercentageX;
    _ = fileName;
    assert(DEBUGAssetType != null);
    assert(DEBUGAssetType.?.onePastLastAssetIndex < assets.len);

    var a: *asset = &assets[DEBUGAssetType.?.onePastLastAssetIndex];
    DEBUGAssetType.?.onePastLastAssetIndex += 1;

    a.firstTagIndex = DEBUGUsedTagCount;
    a.onePastLastTagIndex = a.firstTagIndex;
    a.slotId = blk: {
        break :blk 0;
    };

    // DEBUGAddBitmapInfo(fileName, alignPercentageX, alignPercentageY).value;

    // fn DEBUGAddBitmapInfo(fileName: [*:0]const u8, alignPercentage: h.v2) bitmap_id {
    //     assert(DEBUGUsedBitmapCount < bitmaps.len);

    //     const ID = bitmap_id{ .value = DEBUGUsedBitmapCount };
    //     DEBUGUsedBitmapCount += 1;

    //     var info: *asset_bitmap_info = &bitmapInfos[ID.value];
    //     info.filename = assetArena.PushString(fileName);
    //     info.alignPercentage = alignPercentage;

    //     return ID;
    // }

    DEBUGAsset = a;
}

inline fn AddDefaultSoundAsset(self: *game_assets, fileName: [*:0]const u8) void {
    _ = AddSoundAsset(fileName, 0, 0);
}

fn AddSoundAsset(self: *game_assets, fileName: [*:0]const u8, firstSampleIndex: u32, sampleCount: u32) *asset {
    assert(DEBUGAssetType != null);
    assert(DEBUGAssetType.?.onePastLastAssetIndex < assets.len);

    var a: *asset = &assets[DEBUGAssetType.?.onePastLastAssetIndex];
    DEBUGAssetType.?.onePastLastAssetIndex += 1;

    a.firstTagIndex = DEBUGUsedTagCount;
    a.onePastLastTagIndex = a.firstTagIndex;
    a.slotId = DEBUGAddSoundInfo(fileName, firstSampleIndex, sampleCount).value;

    // fn DEBUGAddSoundInfo(fileName: [*:0]const u8, firstSampleIndex: u32, sampleCount: u32) sound_id {
    //     assert(DEBUGUsedSoundCount < sounds.len);

    //     const ID = sound_id{ .value = DEBUGUsedSoundCount };
    //     DEBUGUsedSoundCount += 1;

    //     var info: *asset_sound_info = &soundInfos[ID.value];
    //     info.filename = assetArena.PushString(fileName);
    //     info.firstSampleIndex = firstSampleIndex;
    //     info.sampleCount = sampleCount;
    //     info.nextIDToPlay.value = 0;

    //     return ID;
    // }

    DEBUGAsset = a;

    return a;
}

fn AddTag(self: *game_assets, ID: asset_tag_id, value: f32) void {
    assert(DEBUGAsset != null);

    DEBUGAsset.?.onePastLastTagIndex += 1;

    var tag: *asset_tag = &tags[DEBUGUsedTagCount];
    DEBUGUsedTagCount += 1;

    tag.ID = @intFromEnum(ID);
    tag.value = value;
}

pub fn main() !void {
    const gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};

    const allocator = gpa.allocator();
    _ = allocator;
    defer _ = gpa.detectLeaks();

    // assets.BeginAssetType(.Asset_Shadow);
    // assets.AddBitmapAsset("test/test_hero_shadow.bmp", .{ 0.5, 0.156682029 });
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Tree);
    // assets.AddBitmapAsset("test2/tree00.bmp", .{ 0.493827164, 0.295652181 });
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Sword);
    // assets.AddBitmapAsset("test2/rock03.bmp", .{ 0.5, 0.65625 });
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Grass);
    // assets.AddBitmapAsset("test2/grass00.bmp", .{ 0.5, 0.5 });
    // assets.AddBitmapAsset("test2/grass01.bmp", .{ 0.5, 0.5 });
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Tuft);
    // assets.AddBitmapAsset("test2/tuft00.bmp", .{ 0.5, 0.5 });
    // assets.AddBitmapAsset("test2/tuft01.bmp", .{ 0.5, 0.5 });
    // assets.AddBitmapAsset("test2/tuft02.bmp", .{ 0.5, 0.5 });
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Stone);
    // assets.AddBitmapAsset("test2/ground00.bmp", .{ 0.5, 0.5 });
    // assets.AddBitmapAsset("test2/ground01.bmp", .{ 0.5, 0.5 });
    // assets.AddBitmapAsset("test2/ground02.bmp", .{ 0.5, 0.5 });
    // assets.AddBitmapAsset("test2/ground03.bmp", .{ 0.5, 0.5 });
    // assets.EndAssetType();

    // const angleRight = 0.0 * platform.Tau32;
    // const angleBack = 0.25 * platform.Tau32;
    // const angleLeft = 0.5 * platform.Tau32;
    // const angleFront = 0.75 * platform.Tau32;

    // const heroAlign = h.v2{ 0.5, 0.156682029 };

    // assets.BeginAssetType(.Asset_Head);
    // assets.AddBitmapAsset("test/test_hero_right_head.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleRight);
    // assets.AddBitmapAsset("test/test_hero_back_head.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleBack);
    // assets.AddBitmapAsset("test/test_hero_left_head.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleLeft);
    // assets.AddBitmapAsset("test/test_hero_front_head.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleFront);
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Cape);
    // assets.AddBitmapAsset("test/test_hero_right_cape.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleRight);
    // assets.AddBitmapAsset("test/test_hero_back_cape.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleBack);
    // assets.AddBitmapAsset("test/test_hero_left_cape.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleLeft);
    // assets.AddBitmapAsset("test/test_hero_front_cape.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleFront);
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Torso);
    // assets.AddBitmapAsset("test/test_hero_right_torso.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleRight);
    // assets.AddBitmapAsset("test/test_hero_back_torso.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleBack);
    // assets.AddBitmapAsset("test/test_hero_left_torso.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleLeft);
    // assets.AddBitmapAsset("test/test_hero_front_torso.bmp", heroAlign);
    // assets.AddTag(.Tag_FacingDirection, angleFront);
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Bloop);
    // assets.AddDefaultSoundAsset("test3/bloop_00.wav");
    // assets.AddDefaultSoundAsset("test3/bloop_01.wav");
    // assets.AddDefaultSoundAsset("test3/bloop_02.wav");
    // assets.AddDefaultSoundAsset("test3/bloop_03.wav");
    // assets.AddDefaultSoundAsset("test3/bloop_04.wav");
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Crack);
    // assets.AddDefaultSoundAsset("test3/crack_00.wav");
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Drop);
    // assets.AddDefaultSoundAsset("test3/drop_00.wav");
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Glide);
    // assets.AddDefaultSoundAsset("test3/glide_00.wav");
    // assets.EndAssetType();

    // const oneMusicChunk = 48000 * 10;
    // // const totalMusicSampleCount = 48000 * 20;
    // const totalMusicSampleCount = 7468095;
    // assets.BeginAssetType(.Asset_Music);
    // var lastMusic: ?*asset = null;
    // var firstSampleIndex: u32 = 0;
    // while (firstSampleIndex < totalMusicSampleCount) : (firstSampleIndex += oneMusicChunk) {
    //     var sampleCount = totalMusicSampleCount - firstSampleIndex;
    //     if (sampleCount > oneMusicChunk) {
    //         sampleCount = oneMusicChunk;
    //     }
    //     const thisMusic = assets.AddSoundAsset("test3/music_test.wav", firstSampleIndex, sampleCount);
    //     if (lastMusic) |_| {
    //         assets.soundInfos[lastMusic.?.slotId].nextIDToPlay.value = thisMusic.slotId;
    //     }
    //     lastMusic = thisMusic;
    // }
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_Puhp);
    // assets.AddDefaultSoundAsset("test3/puhp_00.wav");
    // assets.AddDefaultSoundAsset("test3/puhp_00.wav");
    // assets.EndAssetType();

    // assets.BeginAssetType(.Asset_test_stereo);
    // assets.AddDefaultSoundAsset("wave_stereo_test_1min.wav");
    // assets.AddDefaultSoundAsset("wave_stereo_test_1sec.wav");
    // assets.EndAssetType();

    out = try std.fs.openFileAbsolute("test.hha", .{ .mode = .read_write });
    defer out.close();
}

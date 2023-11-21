const std = @import("std");
const assert = std.debug.assert;

const h = struct {
    usingnamespace @import("handmade_asset_type_id");
    usingnamespace @import("handmade/handmade_file_formats.zig");
};

const Pi32 = 3.14159265359; // TODO: these should be in handmade_math
const Tau32 = 6.28318530718;

const asset = struct {
    dataOffset: u64 = 0,
    firstTagIndex: u32 = 0,
    onePastLastTagIndex: u32 = 0,

    info: union {
        bitmap: asset_bitmap_info,
        sound: asset_sound_info,
    } = .{ .bitmap = .{} },
};

const bitmap_id = struct {
    value: u32 = 0,

    pub inline fn IsValid(self: bitmap_id) bool {
        const result = self.value != 0;
        return result;
    }
};

const sound_id = struct {
    value: u32 = 0,

    pub inline fn IsValid(self: sound_id) bool {
        const result = self.value != 0;
        return result;
    }
};

const bitmap_asset = struct {
    filename: [*:0]const u8,
    alignment: [2]f32,
};

const asset_bitmap_info = struct {
    filename: [*:0]const u8 = "",
    alignPercentage: [2]f32 = .{ 0, 0 },
};

const asset_sound_info = struct {
    filename: [*:0]const u8 = "",
    firstSampleIndex: u32 = 0,
    sampleCount: u32 = 0,
    nextIDToPlay: sound_id = .{},
};

const VERY_LARGE_NO = 4096;

const game_assets = struct {
    tagCount: u32,
    tags: [VERY_LARGE_NO]h.hha_tag = undefined,

    assetCount: u32,
    assets: [VERY_LARGE_NO]asset = undefined,

    assetTypeCount: u32,
    assetTypes: [h.asset_type_id.len()]h.hha_asset_type = undefined,

    DEBUGAssetType: ?*h.hha_asset_type = null,
    DEBUGAsset: ?*asset = null,

    fn BeginAssetType(self: *game_assets, typeID: h.asset_type_id) void {
        assert(self.DEBUGAssetType == null);

        self.DEBUGAssetType = &self.assetTypes[@intFromEnum(typeID)];
        self.DEBUGAssetType.?.typeID = @intFromEnum(typeID);
        self.DEBUGAssetType.?.firstAssetIndex = self.assetCount;
        self.DEBUGAssetType.?.onePastLastAssetIndex = self.DEBUGAssetType.?.firstAssetIndex;
    }

    fn EndAssetType(self: *game_assets) void {
        assert(self.DEBUGAssetType != null);
        self.assetCount = self.DEBUGAssetType.?.onePastLastAssetIndex;
        self.DEBUGAssetType = null;
        self.DEBUGAsset = null;
    }

    /// Defaults: ```alignPercentage = .{ 0.5, 0.5 }```
    fn AddBitmapAsset(self: *game_assets, fileName: [*:0]const u8, alignPercentage: [2]f32) bitmap_id {
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        var result: bitmap_id = .{ .value = self.DEBUGAssetType.?.onePastLastAssetIndex };
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        var a: *asset = &self.assets[result.value];
        a.firstTagIndex = self.tagCount;
        a.onePastLastTagIndex = a.firstTagIndex;
        a.info = .{ .bitmap = asset_bitmap_info{
            .filename = fileName,
            .alignPercentage = alignPercentage,
        } };

        self.DEBUGAsset = a;

        return result;
    }

    inline fn AddDefaultSoundAsset(self: *game_assets, fileName: [*:0]const u8) sound_id {
        return self.AddSoundAsset(fileName, 0, 0);
    }

    fn AddSoundAsset(self: *game_assets, fileName: [*:0]const u8, firstSampleIndex: u32, sampleCount: u32) sound_id {
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        var result: sound_id = .{ .value = self.DEBUGAssetType.?.onePastLastAssetIndex };
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        var a: *asset = &self.assets[result.value];
        a.firstTagIndex = self.tagCount;
        a.onePastLastTagIndex = a.firstTagIndex;
        a.info = .{ .sound = asset_sound_info{
            .filename = fileName,
            .firstSampleIndex = firstSampleIndex,
            .sampleCount = sampleCount,
            .nextIDToPlay = .{ .value = 0 },
        } };

        self.DEBUGAsset = a;

        return result;
    }

    fn AddTag(self: *game_assets, ID: h.asset_tag_id, value: f32) void {
        assert(self.DEBUGAsset != null);

        self.DEBUGAsset.?.onePastLastTagIndex += 1;

        var tag: *h.hha_tag = &self.tags[self.tagCount];
        self.tagCount += 1;

        tag.ID = @intFromEnum(ID);
        tag.value = value;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};

    const allocator = gpa.allocator();
    _ = allocator;
    defer {
        _ = gpa.detectLeaks();
    }

    var assets = game_assets{
        .assetCount = 1,
        .tagCount = 1,
        .assetTypeCount = 0,
    };
    assets.BeginAssetType(.Asset_Shadow);
    _ = assets.AddBitmapAsset("test/test_hero_shadow.bmp", .{ 0.5, 0.156682029 });
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Tree);
    _ = assets.AddBitmapAsset("test2/tree00.bmp", .{ 0.493827164, 0.295652181 });
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Sword);
    _ = assets.AddBitmapAsset("test2/rock03.bmp", .{ 0.5, 0.65625 });
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Grass);
    _ = assets.AddBitmapAsset("test2/grass00.bmp", .{ 0.5, 0.5 });
    _ = assets.AddBitmapAsset("test2/grass01.bmp", .{ 0.5, 0.5 });
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Tuft);
    _ = assets.AddBitmapAsset("test2/tuft00.bmp", .{ 0.5, 0.5 });
    _ = assets.AddBitmapAsset("test2/tuft01.bmp", .{ 0.5, 0.5 });
    _ = assets.AddBitmapAsset("test2/tuft02.bmp", .{ 0.5, 0.5 });
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Stone);
    _ = assets.AddBitmapAsset("test2/ground00.bmp", .{ 0.5, 0.5 });
    _ = assets.AddBitmapAsset("test2/ground01.bmp", .{ 0.5, 0.5 });
    _ = assets.AddBitmapAsset("test2/ground02.bmp", .{ 0.5, 0.5 });
    _ = assets.AddBitmapAsset("test2/ground03.bmp", .{ 0.5, 0.5 });
    assets.EndAssetType();

    const angleRight = 0.0 * Tau32;
    const angleBack = 0.25 * Tau32;
    const angleLeft = 0.5 * Tau32;
    const angleFront = 0.75 * Tau32;

    const heroAlign: [2]f32 = .{ 0.5, 0.156682029 };

    assets.BeginAssetType(.Asset_Head);
    _ = assets.AddBitmapAsset("test/test_hero_right_head.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleRight);
    _ = assets.AddBitmapAsset("test/test_hero_back_head.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleBack);
    _ = assets.AddBitmapAsset("test/test_hero_left_head.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleLeft);
    _ = assets.AddBitmapAsset("test/test_hero_front_head.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleFront);
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Cape);
    _ = assets.AddBitmapAsset("test/test_hero_right_cape.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleRight);
    _ = assets.AddBitmapAsset("test/test_hero_back_cape.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleBack);
    _ = assets.AddBitmapAsset("test/test_hero_left_cape.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleLeft);
    _ = assets.AddBitmapAsset("test/test_hero_front_cape.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleFront);
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Torso);
    _ = assets.AddBitmapAsset("test/test_hero_right_torso.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleRight);
    _ = assets.AddBitmapAsset("test/test_hero_back_torso.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleBack);
    _ = assets.AddBitmapAsset("test/test_hero_left_torso.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleLeft);
    _ = assets.AddBitmapAsset("test/test_hero_front_torso.bmp", heroAlign);
    assets.AddTag(.Tag_FacingDirection, angleFront);
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Bloop);
    _ = assets.AddDefaultSoundAsset("test3/bloop_00.wav");
    _ = assets.AddDefaultSoundAsset("test3/bloop_01.wav");
    _ = assets.AddDefaultSoundAsset("test3/bloop_02.wav");
    _ = assets.AddDefaultSoundAsset("test3/bloop_03.wav");
    _ = assets.AddDefaultSoundAsset("test3/bloop_04.wav");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Crack);
    _ = assets.AddDefaultSoundAsset("test3/crack_00.wav");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Drop);
    _ = assets.AddDefaultSoundAsset("test3/drop_00.wav");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Glide);
    _ = assets.AddDefaultSoundAsset("test3/glide_00.wav");
    assets.EndAssetType();

    const oneMusicChunk = 48000 * 10;
    // const totalMusicSampleCount = 48000 * 20;
    const totalMusicSampleCount = 7468095;
    assets.BeginAssetType(.Asset_Music);
    var lastMusic: sound_id = .{};
    var firstSampleIndex: u32 = 0;
    while (firstSampleIndex < totalMusicSampleCount) : (firstSampleIndex += oneMusicChunk) {
        var sampleCount = totalMusicSampleCount - firstSampleIndex;
        if (sampleCount > oneMusicChunk) {
            sampleCount = oneMusicChunk;
        }
        const thisMusic = assets.AddSoundAsset("test3/music_test.wav", firstSampleIndex, sampleCount);
        if (lastMusic.IsValid()) {
            assets.assets[lastMusic.value].info.sound.nextIDToPlay = thisMusic;
        }
        lastMusic = thisMusic;
    }
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Puhp);
    _ = assets.AddDefaultSoundAsset("test3/puhp_00.wav");
    _ = assets.AddDefaultSoundAsset("test3/puhp_00.wav");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_test_stereo);
    _ = assets.AddDefaultSoundAsset("wave_stereo_test_1min.wav");
    _ = assets.AddDefaultSoundAsset("wave_stereo_test_1sec.wav");
    assets.EndAssetType();

    const out = try std.fs.cwd().createFile("test.hha", .{});
    defer out.close();

    {
        var header = h.hha_header{
            .magicValue = h.HHA_MAGIC_VALUE,
            .version = h.HHA_VERSION,
            .tagCount = assets.tagCount,
            .assetCount = assets.assetCount,
            .assetTypeCount = h.asset_type_id.len(),
            .tags = @sizeOf(h.hha_header),
            .assets = 0,
            .assetTypes = 0,
        };

        const tagArraySize = @sizeOf(h.hha_tag) * header.tagCount;
        const assetTypeArraySize = @sizeOf(h.hha_asset_type) * header.assetTypeCount;
        const assetArraySize = @sizeOf(h.hha_asset) * header.assetCount;
        _ = assetArraySize;

        header.assetTypes = header.tags + tagArraySize;
        header.assets = header.assetTypes + assetTypeArraySize;

        try out.writer().writeStruct(header);
        try out.writer().writeAll(std.mem.sliceAsBytes(assets.tags[0..header.tagCount]));
        try out.writer().writeAll(std.mem.sliceAsBytes(&assets.assetTypes));
        // try out.writer().writeStruct(assetsArray);
    }
}

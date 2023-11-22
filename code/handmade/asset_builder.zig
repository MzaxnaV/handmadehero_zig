const std = @import("std");
const assert = std.debug.assert;

const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_asset_type_id");
    usingnamespace @import("handmade_file_formats.zig");
    usingnamespace @import("handmade_math.zig");

    const loaded_bitmap = struct {
        width: i32 = 0,
        height: i32 = 0,
        pitch: i32 = 0,
        memory: [*]u8 = undefined,

        free: []u8 = undefined,
    };

    const loaded_sound = struct {
        /// it is `sampleCount` divided by `8`
        sampleCount: u32 = 0,
        channelCount: u32 = 0,
        samples: [2]?[*]i16 = undefined,

        free: []u8 = undefined,
    };

    // NOTE (Manav): Read this. https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=_BitScanForward&expand=375&ig_expand=465,5629,463
    inline fn FindLeastSignificantSetBit(value: u32) u32 {
        const result = asm ("bsf %[val], %[ret]"
            : [ret] "=r" (-> u32),
            : [val] "rm" (value),
        );

        return result;
    }
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

const asset_type = enum {
    AssetType_Sound,
    AssetType_Bitmap,
};

const asset_source = struct {
    t: asset_type,
    filename: []const u8 = "",
    firstSampleIndex: u32 = 0,
};

const VERY_LARGE_NO = 4096;

const entire_file = struct {
    contents: []u8 = undefined,
};

fn ReadEntireFile(fileName: []const u8, allocator: std.mem.Allocator) !entire_file {
    var result = entire_file{};

    const prefix = "../data/";

    const newFileName = try std.mem.concat(allocator, u8, &[_][]const u8{ prefix, fileName });

    const file = try std.fs.cwd().openFile(newFileName, .{ .mode = .read_only });

    result.contents = try file.readToEndAlloc(allocator, platform.GigaBytes(8));

    allocator.free(newFileName);

    return result;
}

fn LoadBMP(fileName: []const u8, allocator: std.mem.Allocator) !h.loaded_bitmap {
    const bitmap_header = extern struct {
        fileType: u16 align(1),
        fileSize: u32 align(1),
        reserved1: u16 align(1),
        reserved2: u16 align(1),
        bitmapOffset: u32 align(1),
        size: u32 align(1),
        width: i32 align(1),
        height: i32 align(1),
        planes: u16 align(1),
        bitsPerPixel: u16 align(1),
        compression: u32 align(1),
        sizeOfBitmap: u32 align(1),
        horzResolution: u32 align(1),
        vertResolution: u32 align(1),
        colorsUsed: u32 align(1),
        colorsImportant: u32 align(1),

        redMask: u32 align(1),
        greenMask: u32 align(1),
        blueMask: u32 align(1),
    };

    var result = h.loaded_bitmap{};

    const readResult = ReadEntireFile(fileName, allocator) catch |err| {
        std.log.err("{}\nFilename: {s}", .{err, fileName});
        return err;
    };

    const header: *bitmap_header = @ptrCast(readResult.contents);
    const pixels = readResult.contents.ptr + header.bitmapOffset;
    result.width = header.width;
    result.height = header.height;
    result.memory = pixels;
    result.free = readResult.contents;

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

        // if (NOT_IGNORE)
        {
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

    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;

    {
        // result.memory += @as(usize, @intCast(result.pitch * (result.height - 1)));
        // result.pitch = -result.width;
    }

    return result;
}

fn LoadWAV(fileName: []const u8, sectionFirstSampleIndex: u32, sectionSampleCount: u32, allocator: std.mem.Allocator) !h.loaded_sound {
    const wave_header = extern struct {
        riffID: u32 align(1),
        size: u32 align(1),
        waveID: u32 align(1),
    };

    const wave_fmt = extern struct {
        wFormatTag: u16 align(1),
        nChannels: u16 align(1),
        nSamplesPerSec: u32 align(1),
        nAvgBytesPerSec: u32 align(1),
        nBlockAlign: u16 align(1),
        wBitsPerSample: u16 align(1),
        cbSize: u16 align(1),
        wValidBitsPerSample: u16 align(1),
        dwChannelMask: u32 align(1),
        subFormat: [16]u8 align(1),
    };

    const chunk_type = enum(u32) {
        WAVE_ChunkID_fmt = riffCode('f', 'm', 't', ' '),
        WAVE_ChunkID_data = riffCode('d', 'a', 't', 'a'),
        WAVE_ChunkID_RIFF = riffCode('R', 'I', 'F', 'F'),
        WAVE_ChunkID_WAVE = riffCode('W', 'A', 'V', 'E'),
        WAVE_ChunkID_LIST = riffCode('L', 'I', 'S', 'T'),

        fn riffCode(a: u8, b: u8, c: u8, d: u8) u32 {
            return @bitCast(switch (platform.native_endian) {
                .Big => [4]u8{ d, c, b, a },
                .Little => [4]u8{ a, b, c, d },
            });
        }
    };

    const riff_iterator = struct {
        const Self = @This();

        const wave_chunk = extern struct {
            ID: u32 align(1),
            size: u32 align(1),
        };

        at: [*]u8,
        stop: [*]u8,

        fn ParseChunk(at: [*]u8, stop: [*]u8) Self {
            const result = Self{
                .at = at,
                .stop = stop,
            };

            return result;
        }

        fn IsValid(self: *Self) bool {
            const result = @intFromPtr(self.at) < @intFromPtr(self.stop);
            return result;
        }

        fn NextChunk(self: *Self) void {
            const chunk: *wave_chunk = @ptrCast(self.at);

            // align forward chunk.size when it's odd, https://www.mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html
            const size = (chunk.size + 1) & ~(@as(u32, 1));

            self.at += @sizeOf(wave_chunk) + size;
        }

        fn GetType(self: *Self) chunk_type {
            const chunk: *wave_chunk = @ptrCast(self.at);

            const result: chunk_type = @enumFromInt(chunk.ID);
            return result;
        }

        fn GetChunkData(self: *Self) [*]u8 {
            const result: [*]u8 = self.at + @sizeOf(wave_chunk);

            return result;
        }

        fn GetChunkDataSize(self: *Self) u32 {
            const chunk: *wave_chunk = @ptrCast(self.at);

            const result: u32 = chunk.size;
            return result;
        }
    };

    var result = h.loaded_sound{};

    const readResult: entire_file = ReadEntireFile(fileName, allocator)  catch |err| {
        std.log.err("{}\nFilename: {s}", .{err, fileName});
        return err;
    };

    result.free = readResult.contents;

    const header: *wave_header = @ptrCast(readResult.contents);

    assert(header.riffID == @intFromEnum(chunk_type.WAVE_ChunkID_RIFF));
    assert(header.waveID == @intFromEnum(chunk_type.WAVE_ChunkID_WAVE));

    const at = @as([*]u8, @ptrCast(header)) + @sizeOf(wave_header);
    const stop = @as([*]u8, @ptrCast(header)) + @sizeOf(wave_header) + (header.size - 4);

    var iter = riff_iterator.ParseChunk(at, stop);

    var sampleDataSize: u32 = 0;
    var channelCount: u32 = 0;
    var sampleData: ?[*]i16 = null;
    while (iter.IsValid()) : (iter.NextChunk()) {
        switch (iter.GetType()) {
            .WAVE_ChunkID_fmt => {
                const fmt: *wave_fmt = @ptrCast(iter.GetChunkData());

                assert(fmt.wFormatTag == 1);
                assert(fmt.nSamplesPerSec == 48000);
                assert(fmt.wBitsPerSample == 16);
                assert(fmt.nBlockAlign == @sizeOf(u16) * fmt.nChannels);

                channelCount = fmt.nChannels;
            },
            .WAVE_ChunkID_data => {
                sampleData = @alignCast(@ptrCast(iter.GetChunkData()));
                sampleDataSize = iter.GetChunkDataSize();
            },

            else => {},
        }
    }

    assert(channelCount != 0 and sampleData != null);

    result.channelCount = channelCount;
    var sampleCount: u32 = sampleDataSize / (channelCount * @sizeOf(u16));

    if (channelCount == 1) {
        result.samples[0] = @ptrCast(sampleData);
        result.samples[1] = null;
    } else if (channelCount == 2) {
        result.samples[0] = @ptrCast(sampleData);
        result.samples[1] = sampleData.? + sampleCount;

        {
            // for (0..sampleCount) |sampleIndex| {
            //     sampleData.?[2 * sampleIndex + 0] = @intCast(sampleIndex);
            //     sampleData.?[2 * sampleIndex + 1] = @intCast(sampleIndex);
            // }
        }

        for (0..sampleCount) |sampleIndex| {
            var source: i16 = sampleData.?[2 * sampleIndex];
            sampleData.?[2 * sampleIndex] = sampleData.?[sampleIndex];
            sampleData.?[sampleIndex] = source;
        }
    } else {
        platform.InvalidCodePath("invalid channel count in wav file");
    }

    var atEnd = true;
    result.channelCount = 1;
    if (sectionSampleCount != 0) {
        assert(sectionFirstSampleIndex + sectionSampleCount <= sampleCount);
        atEnd = (sectionFirstSampleIndex + sectionSampleCount == sampleCount);
        sampleCount = sectionSampleCount;

        for (0..result.channelCount) |channelIndex| {
            result.samples[channelIndex].? += sectionFirstSampleIndex;
        }
    }

    if (atEnd) {
        for (0..result.channelCount) |channelIndex| {
            for (sampleCount..sampleCount + 8) |sampleIndex| {
                result.samples[channelIndex].?[sampleIndex] = 0;
            }
        }
    }

    result.sampleCount = sampleCount;

    return result;
}

const game_assets = struct {
    tagCount: u32,
    tags: [VERY_LARGE_NO]h.hha_tag = undefined,

    assetTypeCount: u32,
    assetTypes: [h.asset_type_id.len()]h.hha_asset_type = undefined,

    assetCount: u32,
    assetSources: [VERY_LARGE_NO]asset_source = undefined,
    assets: [VERY_LARGE_NO]h.hha_asset = undefined,

    DEBUGAssetType: ?*h.hha_asset_type = null,
    assetIndex: u32,

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
        self.assetIndex = 0;
    }

    /// Defaults: ```alignPercentage = .{ 0.5, 0.5 }```
    fn AddBitmapAsset(self: *game_assets, fileName: []const u8, alignPercentage: [2]f32) bitmap_id {
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        var result: bitmap_id = .{ .value = self.DEBUGAssetType.?.onePastLastAssetIndex };
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        const source: *asset_source = &self.assetSources[result.value];
        const hha: *h.hha_asset = &self.assets[result.value];

        hha.firstTagIndex = self.tagCount;
        hha.onePastLastTagIndex = hha.firstTagIndex;
        hha.data = .{ .bitmap = h.hha_bitmap{
            .dim = .{ 0, 0 },
            .alignPercentage = alignPercentage,
        } };

        source.t = .AssetType_Bitmap;
        source.filename = fileName;

        self.assetIndex = result.value;

        return result;
    }

    inline fn AddDefaultSoundAsset(self: *game_assets, fileName: []const u8) sound_id {
        return self.AddSoundAsset(fileName, 0, 0);
    }

    fn AddSoundAsset(self: *game_assets, fileName: []const u8, firstSampleIndex: u32, sampleCount: u32) sound_id {
        _ = firstSampleIndex;
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        var result: sound_id = .{ .value = self.DEBUGAssetType.?.onePastLastAssetIndex };
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        const source: *asset_source = &self.assetSources[result.value];
        var hha: *h.hha_asset = &self.assets[result.value];

        hha.firstTagIndex = self.tagCount;
        hha.onePastLastTagIndex = hha.firstTagIndex;
        hha.data = .{ .sound = h.hha_sound{
            .channelCount = 0,
            .sampleCount = sampleCount,
            .nextIDToPlay = 0,
        } };

        source.t = .AssetType_Sound;
        source.filename = fileName;

        self.assetIndex = result.value;

        return result;
    }

    fn AddTag(self: *game_assets, ID: h.asset_tag_id, value: f32) void {
        assert(self.assetIndex != 0);

        const hha: *h.hha_asset = &self.assets[self.assetIndex];
        hha.onePastLastTagIndex += 1;

        var tag: *h.hha_tag = &self.tags[self.tagCount];
        self.tagCount += 1;

        tag.ID = @intFromEnum(ID);
        tag.value = value;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};

    const allocator = gpa.allocator();
    defer {
        _ = gpa.detectLeaks();
    }

    var assets = game_assets{
        .assetTypeCount = 0,
        .assetCount = 1,
        .tagCount = 1,
        .assetIndex = 0,
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

    const angleRight = 0.0 * platform.Tau32;
    const angleBack = 0.25 * platform.Tau32;
    const angleLeft = 0.5 * platform.Tau32;
    const angleFront = 0.75 * platform.Tau32;

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
            assets.assets[lastMusic.value].data.sound.nextIDToPlay = thisMusic.value;
        }
        lastMusic = thisMusic;
    }
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Puhp);
    _ = assets.AddDefaultSoundAsset("test3/puhp_00.wav");
    _ = assets.AddDefaultSoundAsset("test3/puhp_01.wav");
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

        header.assetTypes = header.tags + tagArraySize;
        header.assets = header.assetTypes + assetTypeArraySize;

        try out.writer().writeStruct(header);
        try out.writer().writeAll(std.mem.sliceAsBytes(assets.tags[0..header.tagCount]));
        try out.writer().writeAll(std.mem.sliceAsBytes(&assets.assetTypes));
        const cur = try out.getPos();
        try out.seekBy(assetArraySize);
        for (1..header.assetCount) |assetIndex| {
            const source = assets.assetSources[assetIndex];
            var dest = assets.assets[assetIndex];

            dest.dataOffset = try out.seekableStream().getPos();

            switch (source.t) {
                .AssetType_Bitmap => {
                    const b = try LoadBMP(source.filename, allocator);
                    dest.data.bitmap.dim = [2]u32{ @intCast(b.width), @intCast(b.height) };

                    platform.Assert(b.pitch == (b.width * 4));
                    try out.writer().writeAll(std.mem.sliceAsBytes(b.memory[0..@intCast(b.width * b.height * 4)]));

                    allocator.free(b.free);
                },
                .AssetType_Sound => {
                    const w = try LoadWAV(source.filename, source.firstSampleIndex, dest.data.sound.sampleCount, allocator);
                    dest.data.sound.sampleCount = w.sampleCount;
                    dest.data.sound.channelCount = w.channelCount;

                    for (0..w.channelCount) |channelIndex| {
                        try out.writer().writeAll(std.mem.sliceAsBytes(w.samples[channelIndex].?[0 .. dest.data.sound.sampleCount * @sizeOf(i16)]));
                    }

                    allocator.free(w.free);
                },
            }
        }

        std.debug.print("{} {}", .{ cur, header.assets });
        try out.seekTo(cur);
        try out.writer().writeAll(std.mem.sliceAsBytes(assets.assets[0..header.assetCount]));
    }
}

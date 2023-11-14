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

pub const loaded_sound = struct {
    /// it is `sampleCount` divided by `8`
    sampleCount: u32 = 0,
    channelCount: u32 = 0,
    samples: [2]?[*]i16 = undefined,
};

pub const asset_state = enum {
    AssetState_Unloaded,
    AssetState_Queued,
    AssetState_Loaded,
    AssetState_Locked,
};

pub const asset_slot = struct {
    state: asset_state,
    data: union {
        bitmap: ?*h.loaded_bitmap,
        sound: ?*loaded_sound,
    },
};

pub const asset_tag_id = enum {
    Tag_Smoothness,
    Tag_Flatness,
    Tag_FacingDirection,

    fn len() comptime_int {
        comptime {
            return @typeInfo(asset_type_id).Enum.fields.len;
        }
    }
};

pub const asset_type_id = enum(u32) {
    Asset_NONE = 0,

    //
    // Bitmaps
    //

    Asset_Shadow,
    Asset_Tree,
    Asset_Sword,
    // Asset_Stairwell,
    Asset_Rock,

    Asset_Grass,
    Asset_Tuft,
    Asset_Stone,

    Asset_Head,
    Asset_Cape,
    Asset_Torso,

    //
    // Sounds
    //

    Asset_Bloop,
    Asset_Crack,
    Asset_Drop,
    Asset_Glide,
    Asset_Music,
    Asset_Puhp,

    Asset_test_stereo,

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

pub const asset_vector = struct { // use @Vector(asset_tag_id.len(), f32) ??
    e: [asset_tag_id.len()]f32 = [1]f32{0} ** asset_tag_id.len(),
};

pub const asset_type = struct {
    firstAssetIndex: u32,
    onePastLastAssetIndex: u32,
};

pub const asset_bitmap_info = struct {
    filename: [*:0]const u8,
    alignPercentage: h.v2 = .{ 0, 0 },
};

pub const asset_sound_info = struct {
    filename: [*:0]const u8,
    firstSampleIndex: u32,
    sampleCount: u32,
    nextIDToPlay: sound_id,
};

pub const asset_group = struct {
    firstTagIndex: u32,
    onePastLastTagIndex: u32,
};

pub const bitmap_id = struct {
    value: u32,

    pub inline fn IsValid(self: bitmap_id) bool {
        const result = self.value != 0;
        return result;
    }
};

pub const sound_id = struct {
    value: u32,

    pub inline fn IsValid(self: sound_id) bool {
        const result = self.value != 0;
        return result;
    }
};

pub const game_assets = struct {
    tranState: *h.transient_state,
    assetArena: h.memory_arena,

    tagRange: [asset_tag_id.len()]f32,

    bitmapInfos: []asset_bitmap_info,
    bitmaps: []asset_slot,

    soundInfos: []asset_sound_info,
    sounds: []asset_slot,

    tags: []asset_tag,

    assets: []asset,

    assetTypes: [asset_type_id.len()]asset_type,

    // heroBitmaps: [4]hero_bitmaps,

    DEBUGUsedBitmapCount: u32,
    DEBUGUsedSoundCount: u32,
    DEBUGUsedAssetCount: u32,
    DEBUGUsedTagCount: u32,
    DEBUGAssetType: ?*asset_type,
    DEBUGAsset: ?*asset,

    pub inline fn GetBitmap(self: *game_assets, ID: bitmap_id) ?*h.loaded_bitmap {
        const result = self.bitmaps[ID.value].data.bitmap;
        return result;
    }

    pub inline fn GetSound(self: *game_assets, ID: sound_id) ?*loaded_sound {
        const result = self.sounds[ID.value].data.sound;
        return result;
    }

    pub inline fn GetSoundInfo(self: *game_assets, ID: sound_id) *asset_sound_info {
        const result = &self.soundInfos[ID.value];
        return result;
    }

    fn DEBUGAddBitmapInfo(self: *game_assets, fileName: [*:0]const u8, alignPercentage: h.v2) bitmap_id {
        assert(self.DEBUGUsedBitmapCount < self.bitmaps.len);

        const ID = bitmap_id{ .value = self.DEBUGUsedBitmapCount };
        self.DEBUGUsedBitmapCount += 1;

        var info: *asset_bitmap_info = &self.bitmapInfos[ID.value];
        info.filename = self.assetArena.PushString(fileName);
        info.alignPercentage = alignPercentage;

        return ID;
    }

    fn DEBUGAddSoundInfo(self: *game_assets, fileName: [*:0]const u8, firstSampleIndex: u32, sampleCount: u32) sound_id {
        assert(self.DEBUGUsedSoundCount < self.sounds.len);

        const ID = sound_id{ .value = self.DEBUGUsedSoundCount };
        self.DEBUGUsedSoundCount += 1;

        var info: *asset_sound_info = &self.soundInfos[ID.value];
        info.filename = self.assetArena.PushString(fileName);
        info.firstSampleIndex = firstSampleIndex;
        info.sampleCount = sampleCount;
        info.nextIDToPlay.value = 0;

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
        self.DEBUGAsset = null;
    }

    /// Defaults: ```alignPercentage = .{0.5, 0.5 }```
    fn AddBitmapAsset(self: *game_assets, fileName: [*:0]const u8, alignPercentage: h.v2) void {
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        var a: *asset = &self.assets[self.DEBUGAssetType.?.onePastLastAssetIndex];
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        a.firstTagIndex = self.DEBUGUsedTagCount;
        a.onePastLastTagIndex = a.firstTagIndex;
        a.slotId = self.DEBUGAddBitmapInfo(fileName, alignPercentage).value;

        self.DEBUGAsset = a;
    }

    inline fn AddDefaultSoundAsset(self: *game_assets, fileName: [*:0]const u8) void {
        _ = self.AddSoundAsset(fileName, 0, 0);
    }

    fn AddSoundAsset(self: *game_assets, fileName: [*:0]const u8, firstSampleIndex: u32, sampleCount: u32) *asset {
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        var a: *asset = &self.assets[self.DEBUGAssetType.?.onePastLastAssetIndex];
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        a.firstTagIndex = self.DEBUGUsedTagCount;
        a.onePastLastTagIndex = a.firstTagIndex;
        a.slotId = self.DEBUGAddSoundInfo(fileName, firstSampleIndex, sampleCount).value;

        self.DEBUGAsset = a;

        return a;
    }

    fn AddTag(self: *game_assets, ID: asset_tag_id, value: f32) void {
        assert(self.DEBUGAsset != null);

        self.DEBUGAsset.?.onePastLastTagIndex += 1;

        var tag: *asset_tag = &self.tags[self.DEBUGUsedTagCount];
        self.DEBUGUsedTagCount += 1;

        tag.ID = @intFromEnum(ID);
        tag.value = value;
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.assetArena.SubArena(arena, 16, size);
        assets.tranState = tranState;

        for (0..asset_tag_id.len()) |tagType| {
            assets.tagRange[tagType] = 1000000.0;
        }

        assets.tagRange[@intFromEnum(asset_tag_id.Tag_FacingDirection)] = platform.Tau32;

        const bitmapCount = 256 * asset_tag_id.len();
        assets.bitmapInfos = arena.PushSlice(asset_bitmap_info, bitmapCount);
        assets.bitmaps = arena.PushSlice(asset_slot, bitmapCount);

        // setup bitmaps
        {
            for (0..assets.bitmaps.len) |index| {
                assets.bitmaps[index].data = .{ .bitmap = null };
            }
        }

        const soundCount = 256 * asset_tag_id.len();
        assets.soundInfos = arena.PushSlice(asset_sound_info, soundCount);
        assets.sounds = arena.PushSlice(asset_slot, soundCount);

        // setup sounds
        {
            for (0..assets.sounds.len) |index| {
                assets.sounds[index].data = .{ .sound = null };
            }
        }

        const assetCount = soundCount + bitmapCount;
        assets.assets = arena.PushSlice(asset, assetCount);

        const tagCount = 1024 * asset_tag_id.len();
        assets.tags = arena.PushSlice(asset_tag, tagCount);

        assets.DEBUGUsedBitmapCount = 1;
        assets.DEBUGUsedSoundCount = 1;
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

        const angleRight = 0.0 * platform.Tau32;
        const angleBack = 0.25 * platform.Tau32;
        const angleLeft = 0.5 * platform.Tau32;
        const angleFront = 0.75 * platform.Tau32;

        const heroAlign = h.v2{ 0.5, 0.156682029 };

        assets.BeginAssetType(.Asset_Head);
        assets.AddBitmapAsset("test/test_hero_right_head.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleRight);
        assets.AddBitmapAsset("test/test_hero_back_head.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleBack);
        assets.AddBitmapAsset("test/test_hero_left_head.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleLeft);
        assets.AddBitmapAsset("test/test_hero_front_head.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleFront);
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Cape);
        assets.AddBitmapAsset("test/test_hero_right_cape.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleRight);
        assets.AddBitmapAsset("test/test_hero_back_cape.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleBack);
        assets.AddBitmapAsset("test/test_hero_left_cape.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleLeft);
        assets.AddBitmapAsset("test/test_hero_front_cape.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleFront);
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Torso);
        assets.AddBitmapAsset("test/test_hero_right_torso.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleRight);
        assets.AddBitmapAsset("test/test_hero_back_torso.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleBack);
        assets.AddBitmapAsset("test/test_hero_left_torso.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleLeft);
        assets.AddBitmapAsset("test/test_hero_front_torso.bmp", heroAlign);
        assets.AddTag(.Tag_FacingDirection, angleFront);
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Bloop);
        assets.AddDefaultSoundAsset("test3/bloop_00.wav");
        assets.AddDefaultSoundAsset("test3/bloop_01.wav");
        assets.AddDefaultSoundAsset("test3/bloop_02.wav");
        assets.AddDefaultSoundAsset("test3/bloop_03.wav");
        assets.AddDefaultSoundAsset("test3/bloop_04.wav");
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Crack);
        assets.AddDefaultSoundAsset("test3/crack_00.wav");
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Drop);
        assets.AddDefaultSoundAsset("test3/drop_00.wav");
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Glide);
        assets.AddDefaultSoundAsset("test3/glide_00.wav");
        assets.EndAssetType();

        const oneMusicChunk = 48000 * 10;
        // const totalMusicSampleCount = 48000 * 20;
        const totalMusicSampleCount = 7468095;
        assets.BeginAssetType(.Asset_Music);
        var lastMusic: ?*asset = null;
        var firstSampleIndex: u32 = 0;
        while (firstSampleIndex < totalMusicSampleCount) : (firstSampleIndex += oneMusicChunk) {
            var sampleCount = totalMusicSampleCount - firstSampleIndex;
            if (sampleCount > oneMusicChunk) {
                sampleCount = oneMusicChunk;
            }
            const thisMusic = assets.AddSoundAsset("test3/music_test.wav", firstSampleIndex, sampleCount);
            if (lastMusic) |_| {
                assets.soundInfos[lastMusic.?.slotId].nextIDToPlay.value = thisMusic.slotId;
            }
            lastMusic = thisMusic;
        }
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_Puhp);
        assets.AddDefaultSoundAsset("test3/puhp_00.wav");
        assets.AddDefaultSoundAsset("test3/puhp_00.wav");
        assets.EndAssetType();

        assets.BeginAssetType(.Asset_test_stereo);
        assets.AddDefaultSoundAsset("wave_stereo_test_1min.wav");
        assets.AddDefaultSoundAsset("wave_stereo_test_1sec.wav");
        assets.EndAssetType();

        return assets;
    }
};

inline fn TopDownAlign(bitmap: *const h.loaded_bitmap, alignment: h.v2) h.v2 {
    const fixedAlignment = h.v2{
        h.SafeRatiof0(h.X(alignment), @as(f32, @floatFromInt(bitmap.width))),
        h.SafeRatiof0(@as(f32, @floatFromInt(bitmap.height - 1)) - h.Y(alignment), @as(f32, @floatFromInt(bitmap.height))),
    };
    return fixedAlignment;
}

/// Defaults: ```alignPercentage = .{0.5, 0.5 }```
fn DEBUGLoadBMP(fileName: [*:0]const u8, alignPercentage: h.v2) h.loaded_bitmap {
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

    const readResult = h.DEBUGPlatformReadEntireFile.?(fileName);
    if (readResult.contentSize != 0) {
        const header: *bitmap_header = @ptrCast(readResult.contents);
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
    at: [*]u8,
    stop: [*]u8,

    fn ParseChunk(at: [*]u8, stop: [*]u8) riff_iterator {
        const result = riff_iterator{
            .at = at,
            .stop = stop,
        };

        return result;
    }

    fn IsValid(self: *riff_iterator) bool {
        const result = @intFromPtr(self.at) < @intFromPtr(self.stop);
        return result;
    }

    fn NextChunk(self: *riff_iterator) void {
        const chunk: *wave_chunk = @ptrCast(self.at);

        // align forward chunk.size when it's odd, https://www.mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html
        const size = (chunk.size + 1) & ~(@as(u32, 1));

        self.at += @sizeOf(wave_chunk) + size;
    }

    fn GetType(self: *riff_iterator) chunk_type {
        const chunk: *wave_chunk = @ptrCast(self.at);

        const result: chunk_type = @enumFromInt(chunk.ID);
        return result;
    }

    fn GetChunkData(self: *riff_iterator) [*]u8 {
        const result: [*]u8 = self.at + @sizeOf(wave_chunk);

        return result;
    }

    fn GetChunkDataSize(self: *riff_iterator) u32 {
        const chunk: *wave_chunk = @ptrCast(self.at);

        const result: u32 = chunk.size;
        return result;
    }
};

const wave_chunk = extern struct {
    ID: u32 align(1),
    size: u32 align(1),
};

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

fn DEBUGLoadWAV(fileName: [*:0]const u8, sectionFirstSampleIndex: u32, sectionSampleCount: u32) loaded_sound {
    var result = loaded_sound{};

    const readResult = h.DEBUGPlatformReadEntireFile.?(fileName);
    if (readResult.contentSize != 0) {
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

            if (!NOT_IGNORE) {
                for (0..sampleCount) |sampleIndex| {
                    sampleData.?[2 * sampleIndex + 0] = @intCast(sampleIndex);
                    sampleData.?[2 * sampleIndex + 1] = @intCast(sampleIndex);
                }
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
        
        if (atEnd)
        {
            for (0..result.channelCount) |channelIndex| {
                for(sampleCount..sampleCount + 8) |sampleIndex| {
                    result.samples[channelIndex].?[sampleIndex] = 0;
                }
            }
        }

        result.sampleCount = sampleCount;
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

    work.assets.bitmaps[work.ID.value].data = .{ .bitmap = work.bitmap };
    work.assets.bitmaps[work.ID.value].state = work.finalState;

    h.EndTaskWithMemory(work.task);
}

pub fn LoadBitmap(assets: *game_assets, ID: bitmap_id) void {
    if (ID.value == 0) return;

    if (h.AtomicCompareExchange(asset_state, &assets.bitmaps[ID.value].state, .AssetState_Queued, .AssetState_Unloaded) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            var work: *load_bitmap_work = task.arena.PushStruct(load_bitmap_work);

            work.assets = assets;
            work.ID = ID;
            work.task = task;
            work.bitmap = assets.assetArena.PushStruct(h.loaded_bitmap);
            work.finalState = .AssetState_Loaded;

            h.PlatformAddEntry(assets.tranState.lowPriorityQueue, LoadBitmapWork, work);
        } else {
            assets.bitmaps[ID.value].state = .AssetState_Unloaded;
        }
    }
}

pub inline fn PrefetchBitmap(assets: *game_assets, ID: bitmap_id) void {
    return LoadBitmap(assets, ID);
}

const load_sound_work = struct {
    assets: *game_assets,
    ID: sound_id,
    task: *h.task_with_memory,
    sound: *loaded_sound,

    finalState: asset_state,
};

fn LoadSoundWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(LoadSoundWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *load_sound_work = @alignCast(@ptrCast(data));

    const info: asset_sound_info = work.assets.soundInfos[work.ID.value];
    work.sound.* = DEBUGLoadWAV(info.filename, info.firstSampleIndex, info.sampleCount);

    @fence(.SeqCst);

    work.assets.sounds[work.ID.value].data = .{ .sound = work.sound };
    work.assets.sounds[work.ID.value].state = work.finalState;

    h.EndTaskWithMemory(work.task);
}

pub fn LoadSound(assets: *game_assets, ID: sound_id) void {
    if (ID.value == 0) return;

    if (h.AtomicCompareExchange(asset_state, &assets.sounds[ID.value].state, .AssetState_Queued, .AssetState_Unloaded) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            var work: *load_sound_work = task.arena.PushStruct(load_sound_work);

            work.assets = assets;
            work.ID = ID;
            work.task = task;
            work.sound = assets.assetArena.PushStruct(loaded_sound);
            work.finalState = .AssetState_Loaded;

            h.PlatformAddEntry(assets.tranState.lowPriorityQueue, LoadSoundWork, work);
        }
    } else {
        assets.sounds[ID.value].state = .AssetState_Unloaded;
    }
}

pub inline fn PrefetchSound(assets: *game_assets, ID: sound_id) void {
    return LoadSound(assets, ID);
}

pub fn GetBestMatchAssetFrom(assets: *game_assets, typeID: asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) u32 {
    var result: u32 = 0;

    var bestDiff = platform.F32MAXIMUM;
    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        for (assetType.firstAssetIndex..assetType.onePastLastAssetIndex) |assetIndex| {
            const a = &assets.assets[assetIndex];

            var totalWeightedDiff: f32 = 0.0;

            for (a.firstTagIndex..a.onePastLastTagIndex) |tagIndex| {
                var tag: asset_tag = assets.tags[tagIndex];

                const _a = matchVector.e[tag.ID];
                const _b = tag.value;
                const d0 = h.AbsoluteValue(_a - _b);
                const d1 = h.AbsoluteValue((_a - assets.tagRange[tag.ID] * h.SignOf(f32, _a)) - _b);
                const difference = @min(d0, d1);

                const weightedDiff = weightVector.e[tag.ID] * difference;
                totalWeightedDiff += weightedDiff;
            }

            if (bestDiff > totalWeightedDiff) {
                bestDiff = totalWeightedDiff;
                result = a.slotId;
            }
        }
    }

    return result;
}

fn GetRandomSlotFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) u32 {
    var result: u32 = 0;

    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        const count = assetType.onePastLastAssetIndex - assetType.firstAssetIndex;
        const choice = series.RandomChoice(count);

        var a = assets.assets[choice + assetType.firstAssetIndex];
        result = a.slotId;
    }

    return result;
}

fn GetFirstSlotFrom(assets: *game_assets, typeID: asset_type_id) u32 {
    var result: u32 = 0;

    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        var a = assets.assets[assetType.firstAssetIndex];
        result = a.slotId;
    }

    return result;
}

pub inline fn GetBestMatchBitmapFrom(assets: *game_assets, typeID: asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) bitmap_id {
    const result = bitmap_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstBitmapFrom(assets: *game_assets, typeID: asset_type_id) bitmap_id {
    const result = bitmap_id{ .value = GetFirstSlotFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomBitmapFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) bitmap_id {
    const result = bitmap_id{ .value = GetRandomSlotFrom(assets, typeID, series) };
    return result;
}

pub inline fn GetBestMatchSoundFrom(assets: *game_assets, typeID: asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) sound_id {
    const result = sound_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstSoundFrom(assets: *game_assets, typeID: asset_type_id) sound_id {
    const result = sound_id{ .value = GetFirstSlotFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomSoundFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) sound_id {
    const result = sound_id{ .value = GetRandomSlotFrom(assets, typeID, series) };
    return result;
}

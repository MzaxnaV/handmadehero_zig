const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade.zig");

    usingnamespace @import("handmade_file_formats.zig");
};

const hi = platform.handmade_internal;
const assert = platform.Assert;

const NOT_IGNORE = platform.NOT_IGNORE;

// data types -----------------------------------------------------------------------------------------------------------------------------

const asset_tag_id = @import("handmade_asset_type_id").asset_tag_id;
const asset_type_id = @import("handmade_asset_type_id").asset_type_id;

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
    data: extern union {
        bitmap: ?*h.loaded_bitmap,
        sound: ?*loaded_sound,
    },
};

pub const asset = struct {
    hha: h.hha_asset,
    fileIndex: u32,
};

pub const asset_vector = struct {
    e: [asset_tag_id.len()]f32 = [1]f32{0} ** asset_tag_id.len(),
};

pub const asset_type = struct {
    firstAssetIndex: u32,
    onePastLastAssetIndex: u32,
};

pub const asset_group = struct {
    firstTagIndex: u32,
    onePastLastTagIndex: u32,
};

pub const asset_file = struct {
    handle: *platform.file_handle,

    header: h.hha_header,
    assetTypeArray: []h.hha_asset_type,

    tagBase: u32,
};

pub const game_assets = struct {
    tranState: *h.transient_state,
    assetArena: h.memory_arena,

    tagRange: [asset_tag_id.len()]f32,

    // fileCount: u32,
    files: []asset_file,

    tagCount: u32,
    tags: [*]h.hha_tag,

    assetCount: u32,
    assets: [*]asset,

    slots: []asset_slot,

    assetTypes: [asset_type_id.count()]asset_type,

    // hhaContents: []u8,
    // heroBitmaps: [4]hero_bitmaps,

    // DEBUGUsedAssetCount: u32,
    // DEBUGUsedTagCount: u32,
    // DEBUGAssetType: ?*asset_type,
    // DEBUGAsset: ?*asset,

    pub inline fn GetBitmap(self: *game_assets, ID: h.bitmap_id) ?*h.loaded_bitmap {
        assert(ID.value <= self.assetCount);
        const slot: *asset_slot = &self.slots[ID.value];

        var result: ?*h.loaded_bitmap = null;
        if (@intFromEnum(slot.state) >= @intFromEnum(asset_state.AssetState_Loaded)) {
            @fence(.SeqCst);
            result = slot.data.bitmap;
        }

        return result;
    }

    pub inline fn GetSound(self: *game_assets, ID: h.sound_id) ?*loaded_sound {
        assert(ID.value <= self.assetCount);
        const slot: *asset_slot = &self.slots[ID.value];

        var result: ?*loaded_sound = null;
        if (@intFromEnum(slot.state) >= @intFromEnum(asset_state.AssetState_Loaded)) {
            @fence(.SeqCst);
            result = slot.data.sound;
        }

        return result;
    }

    pub inline fn GetSoundInfo(self: *game_assets, ID: h.sound_id) *h.hha_sound {
        const result = &self.assets[ID.value].hha.data.sound;
        return result;
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.assetArena.SubArena(arena, 16, size);
        assets.tranState = tranState;

        for (0..asset_tag_id.len()) |tagType| {
            assets.tagRange[tagType] = 1000000.0;
        }

        assets.tagRange[@intFromEnum(asset_tag_id.Tag_FacingDirection)] = platform.Tau32;

        {
            assets.assetCount = 0;
            assets.tagCount = 0;

            {
                var fileGroup: platform.file_group = h.platformAPI.GetAllFilesOfTypeBegin("hha");
                defer h.platformAPI.GetAllFilesOfTypeEnd(fileGroup);

                assets.files = arena.PushSlice(asset_file, fileGroup.fileCount);

                for (0..assets.files.len) |fileIndex| {
                    var file: *asset_file = &assets.files[fileIndex];

                    file.tagBase = assets.tagCount;

                    h.ZeroStruct(h.hha_header, &file.header);
                    file.handle = h.platformAPI.OpenFile(fileGroup, @intCast(fileIndex));
                    h.platformAPI.ReadDataFromFile(file.handle, 0, @sizeOf(@TypeOf(file.header)), &file.header);

                    file.assetTypeArray = arena.PushSlice(h.hha_asset_type, file.header.assetTypeCount);
                    const assetTypeArraySize = file.header.assetTypeCount * @sizeOf(h.hha_asset_type);

                    h.platformAPI.ReadDataFromFile(file.handle, file.header.assetTypes, assetTypeArraySize, file.assetTypeArray.ptr);

                    if (file.header.magicValue != h.HHA_MAGIC_VALUE) {
                        h.platformAPI.FileError(file.handle, "HHA file has invalid magic value.");
                    }

                    if (file.header.version > h.HHA_VERSION) {
                        h.platformAPI.FileError(file.handle, "HHA file is of a later version.");
                    }

                    if (platform.NoFileErrors(file.handle)) {
                        assets.tagCount += file.header.tagCount;
                        assets.assetCount += file.header.assetCount;
                    } else {
                        platform.InvalidCodePath("");
                    }
                }
            }

            assets.assets = arena.PushSlice(asset, assets.assetCount).ptr;
            assets.slots = arena.PushSlice(asset_slot, assets.assetCount);
            assets.tags = arena.PushSlice(h.hha_tag, assets.tagCount).ptr;

            for (0..assets.files.len) |fileIndex| {
                var file: *asset_file = &assets.files[fileIndex];
                if (platform.NoFileErrors(file.handle)) {
                    const tagArraySize = @sizeOf(h.hha_tag) * file.header.tagCount;
                    h.platformAPI.ReadDataFromFile(file.handle, file.header.tags, tagArraySize, assets.tags + file.tagBase);
                }
            }

            var assetCount: u32 = 0;
            for (0..asset_type_id.count()) |destTypeID| {
                var destType: *asset_type = &assets.assetTypes[destTypeID];
                destType.firstAssetIndex = assetCount;

                for (0..assets.files.len) |fileIndex| {
                    var file: *asset_file = &assets.files[fileIndex];
                    if (platform.NoFileErrors(file.handle)) {
                        for (0..file.header.assetTypeCount) |sourceIndex| {
                            var sourceType: *h.hha_asset_type = &file.assetTypeArray[sourceIndex];

                            if (sourceType.typeID == destTypeID) {
                                const assetCountForType: u32 = (sourceType.onePastLastAssetIndex - sourceType.firstAssetIndex);

                                const tempMem = h.BeginTemporaryMemory(&tranState.tranArena);
                                defer h.EndTemporaryMemory(tempMem);

                                const hhaAssetArray = tempMem.arena.PushSlice(h.hha_asset, assetCountForType);

                                h.platformAPI.ReadDataFromFile(
                                    file.handle,
                                    file.header.assets + sourceType.firstAssetIndex * @sizeOf(h.hha_asset),
                                    assetCountForType * @sizeOf(h.hha_asset),
                                    hhaAssetArray.ptr,
                                );

                                for (0..assetCountForType) |assetIndex| {
                                    const hhaAsset: h.hha_asset = hhaAssetArray[assetIndex];

                                    assert(assetCount < assets.assetCount);
                                    var a: *asset = &assets.assets[assetCount + assetIndex];
                                    assetCount += 1;

                                    a.fileIndex = @intCast(fileIndex);
                                    a.hha = hhaAsset;
                                    a.hha.firstTagIndex += file.tagBase;
                                    a.hha.onePastLastTagIndex += file.tagBase;
                                }
                            }
                        }
                    }
                }

                destType.onePastLastAssetIndex = assetCount;
            }

            assert(assetCount == assets.assetCount);
        }

        // if (false) {
        //     const readResult = h.platformAPI.DEBUGReadEntireFile("test.hha");
        //     if (readResult.contentSize != 0) {
        //         const header: *h.hha_header = @ptrCast(readResult.contents);

        //         assert(header.magicValue == h.HHA_MAGIC_VALUE);
        //         assert(header.version == h.HHA_VERSION);

        //         assets.assetCount = header.assetCount;
        //         assets.assets = @alignCast(@ptrCast(@as([*]u8, @ptrCast(header)) + header.assets));
        //         assets.slots = arena.PushSlice(asset_slot, assets.assetCount);

        //         assets.tagCount = header.tagCount;
        //         assets.tags = @ptrCast(@as([*]u8, @ptrCast(header)) + header.tags);

        //         const hhaAssetTypes: [*]h.hha_asset_type = @ptrCast(@as([*]u8, @ptrCast(header)) + header.assetTypes);

        //         for (0..header.assetTypeCount) |index| {
        //             const source: h.hha_asset_type = hhaAssetTypes[index];
        //             if (source.typeID < asset_type_id.count()) {
        //                 var dest: *asset_type = &assets.assetTypes[source.typeID];

        //                 platform.Assert(dest.firstAssetIndex == 0);
        //                 platform.Assert(dest.onePastLastAssetIndex == 0);
        //                 dest.firstAssetIndex = source.firstAssetIndex;
        //                 dest.onePastLastAssetIndex = source.onePastLastAssetIndex;
        //             }
        //         }

        //         assets.hhaContents.ptr = readResult.contents;
        //         assets.hhaContents.len = readResult.contentSize;
        //     }
        // }

        return assets;
    }
};

const load_asset_work = struct {
    task: *h.task_with_memory,
    slot: *asset_slot,

    handle: *platform.file_handle,
    offset: u64,
    size: u64,
    destination: *anyopaque,

    finalState: asset_state,
};

fn LoadAssetWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(LoadAssetWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *load_asset_work = @alignCast(@ptrCast(data));

    h.platformAPI.ReadDataFromFile(work.handle, work.offset, work.size, work.destination);

    @fence(.SeqCst);

    if (platform.NoFileErrors(work.handle)) {
        work.slot.state = work.finalState;
    }

    h.EndTaskWithMemory(work.task);
}

inline fn GetFileHandleFor(assets: *game_assets, fileIndex: u32) *platform.file_handle {
    const result: *platform.file_handle = assets.files[fileIndex].handle;
    return result;
}

pub fn LoadBitmap(assets: *game_assets, ID: h.bitmap_id) void {
    if (ID.value == 0) return;

    if (h.AtomicCompareExchange(asset_state, &assets.slots[ID.value].state, .AssetState_Queued, .AssetState_Unloaded) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            const a: *asset = &assets.assets[ID.value];
            const info: h.hha_bitmap = a.hha.data.bitmap;
            const bitmap: *h.loaded_bitmap = assets.assetArena.PushStruct(h.loaded_bitmap);

            bitmap.alignPercentage = info.alignPercentage;
            bitmap.widthOverHeight = @as(f32, @floatFromInt(info.dim[0])) / @as(f32, @floatFromInt(info.dim[1]));

            bitmap.width = @intCast(info.dim[0]);
            bitmap.height = @intCast(info.dim[1]);
            bitmap.pitch = 4 * @as(i32, @intCast(info.dim[0]));
            const memorySize: u64 = @intCast(bitmap.pitch * bitmap.height);

            bitmap.memory = assets.assetArena.PushSize(memorySize);

            var work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.task = task;
            work.slot = &assets.slots[ID.value];
            work.handle = GetFileHandleFor(assets, a.fileIndex);
            work.offset = a.hha.dataOffset;
            work.size = memorySize;
            work.destination = bitmap.memory;
            work.finalState = .AssetState_Loaded;
            work.slot.data = .{ .bitmap = bitmap };

            h.platformAPI.AddEntry(assets.tranState.lowPriorityQueue, LoadAssetWork, work);
        } else {
            assets.slots[ID.value].state = .AssetState_Unloaded;
        }
    }
}

pub inline fn PrefetchBitmap(assets: *game_assets, ID: h.bitmap_id) void {
    return LoadBitmap(assets, ID);
}

pub fn LoadSound(assets: *game_assets, ID: h.sound_id) void {
    if (ID.value == 0) return;

    if (h.AtomicCompareExchange(asset_state, &assets.slots[ID.value].state, .AssetState_Queued, .AssetState_Unloaded) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            const a: *asset = &assets.assets[ID.value];
            const info: *h.hha_sound = &a.hha.data.sound;

            const sound: *loaded_sound = assets.assetArena.PushStruct(loaded_sound);
            sound.sampleCount = info.sampleCount;
            sound.channelCount = info.channelCount;

            const channelSize = sound.sampleCount * @sizeOf(i16);
            const memorySize = sound.channelCount * channelSize;

            var memory = assets.assetArena.PushSize(memorySize);

            var soundAt: [*]i16 = @alignCast(@ptrCast(memory));
            for (0..sound.channelCount) |channelIndex| {
                sound.samples[channelIndex] = soundAt;
                soundAt += channelSize;
            }

            var work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.task = task;
            work.slot = &assets.slots[ID.value];
            work.handle = GetFileHandleFor(assets, a.fileIndex);
            work.offset = a.hha.dataOffset;
            work.size = memorySize;
            work.destination = memory;
            work.finalState = .AssetState_Loaded;
            work.slot.data = .{ .sound = sound };

            work.finalState = .AssetState_Loaded;

            h.platformAPI.AddEntry(assets.tranState.lowPriorityQueue, LoadAssetWork, work);
        } else {
            assets.slots[ID.value].state = .AssetState_Unloaded;
        }
    }
}

pub inline fn PrefetchSound(assets: *game_assets, ID: h.sound_id) void {
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

            for (a.hha.firstTagIndex..a.hha.onePastLastTagIndex) |tagIndex| {
                var tag: h.hha_tag = assets.tags[tagIndex];

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
                result = @intCast(assetIndex);
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
        result = choice + assetType.firstAssetIndex;
    }

    return result;
}

fn GetFirstSlotFrom(assets: *game_assets, typeID: asset_type_id) u32 {
    var result: u32 = 0;

    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        result = assetType.firstAssetIndex;
    }

    return result;
}

pub inline fn GetBestMatchBitmapFrom(assets: *game_assets, typeID: asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstBitmapFrom(assets: *game_assets, typeID: asset_type_id) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetFirstSlotFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomBitmapFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetRandomSlotFrom(assets, typeID, series) };
    return result;
}

pub inline fn GetBestMatchSoundFrom(assets: *game_assets, typeID: asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) h.sound_id {
    const result = h.sound_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstSoundFrom(assets: *game_assets, typeID: asset_type_id) h.sound_id {
    const result = h.sound_id{ .value = GetFirstSlotFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomSoundFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) h.sound_id {
    const result = h.sound_id{ .value = GetRandomSlotFrom(assets, typeID, series) };
    return result;
}

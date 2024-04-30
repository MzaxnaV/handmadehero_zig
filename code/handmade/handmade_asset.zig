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

pub const loaded_sound = extern struct {
    /// it is `sampleCount` divided by `8`
    samples: [2]?[*]i16 = undefined,
    sampleCount: u32 = 0,
    channelCount: u32 = 0,
};

pub const asset_state = enum(u32) {
    AssetState_Unloaded,
    AssetState_Queued,
    AssetState_Loaded,
    AssetState_StateMask = 0xfff,

    AssetState_Sound = 0x1000,
    AssetState_Bitmap = 0x2000,
    AssetState_TypeMask = 0xf000,

    AssetState_Lock = 0x10000,

    // TODO (Manav):
    // AssetState_Sound_Unloaded = 0x1000 | 0,
    // AssetState_Sound_Queued = 0x1000 | 1,
    // AssetState_Sound_Loaded = 0x1000 | 2,

    // AssetState_Bitmap_Unloaded = 0x2000 | 0,
    // AssetState_Bitmap_Queued = 0x2000 | 1,
    // AssetState_Bitmap_Loaded = 0x2000 | 2,

    pub fn or_operator(a: asset_state, b: asset_state) u32 {
        return @intFromEnum(a) | @intFromEnum(b);
    }
};

pub const asset_memory_header = extern struct {
    next: *align(1) asset_memory_header,
    prev: *align(1) asset_memory_header,
    assetIndex: u32,
    reserved: u32,
};

pub const asset = extern struct {
    state: u32,
    data: extern union { // TODO (Manav): use zig union instead ?
        bitmap: h.loaded_bitmap,
        sound: loaded_sound,
    },
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
    arena: h.memory_arena,

    targetMemoryUsed: u64,
    totalMemoryUsed: u64,
    loadedAssetSentinel: asset_memory_header,

    tagRange: [asset_tag_id.len()]f32,

    // fileCount: u32,
    files: []asset_file,

    tagCount: u32,
    tags: [*]h.hha_tag,

    assetCount: u32,
    assets: [*]asset,

    assetTypes: [asset_type_id.count()]asset_type,

    // hhaContents: []u8,
    // heroBitmaps: [4]hero_bitmaps,

    // DEBUGUsedAssetCount: u32,
    // DEBUGUsedTagCount: u32,
    // DEBUGAssetType: ?*asset_type,
    // DEBUGAsset: ?*asset,

    pub inline fn GetBitmap(self: *game_assets, ID: h.bitmap_id, mustBeLocked: bool) ?*h.loaded_bitmap {
        assert(ID.value <= self.assetCount);
        const asset_: *asset = &self.assets[ID.value];

        var result: ?*h.loaded_bitmap = null;
        if (GetState(asset_) >= @intFromEnum(asset_state.AssetState_Loaded)) {
            platform.Assert(!mustBeLocked or IsLocked(asset_));
            @fence(.seq_cst);
            result = &asset_.data.bitmap;
            MoveHeaderToFront(self, ID.value, asset_);
        }

        return result;
    }

    pub inline fn GetSound(self: *game_assets, ID: h.sound_id) ?*loaded_sound {
        assert(ID.value <= self.assetCount);
        const asset_: *asset = &self.assets[ID.value];

        var result: ?*loaded_sound = null;
        if (GetState(asset_) >= @intFromEnum(asset_state.AssetState_Loaded)) {
            @fence(.seq_cst);
            result = &asset_.data.sound;
            MoveHeaderToFront(self, ID.value, asset_);
        }

        return result;
    }

    pub inline fn GetSoundInfo(self: *game_assets, ID: h.sound_id) *h.hha_sound {
        const result = &self.assets[ID.value].hha.data.sound;
        return result;
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.arena.SubArena(arena, 16, size);
        assets.tranState = tranState;

        assets.totalMemoryUsed = 0;
        assets.targetMemoryUsed = size;
        assets.loadedAssetSentinel.next = &assets.loadedAssetSentinel;
        assets.loadedAssetSentinel.prev = &assets.loadedAssetSentinel;

        for (0..asset_tag_id.len()) |tagType| {
            assets.tagRange[tagType] = 1000000.0;
        }

        assets.tagRange[@intFromEnum(asset_tag_id.Tag_FacingDirection)] = platform.Tau32;

        assets.tagCount = 1;
        assets.assetCount = 1;

        {
            const fileGroup = h.platformAPI.GetAllFilesOfTypeBegin("hha");
            defer h.platformAPI.GetAllFilesOfTypeEnd(fileGroup);

            assets.files = arena.PushSlice(asset_file, fileGroup.fileCount);

            for (0..assets.files.len) |fileIndex| {
                var file: *asset_file = &assets.files[fileIndex];

                file.tagBase = assets.tagCount;

                h.ZeroStruct(h.hha_header, &file.header);
                file.handle = h.platformAPI.OpenNextFile(fileGroup).?;
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
                    assets.tagCount += (file.header.tagCount - 1);
                    assets.assetCount += (file.header.assetCount - 1);
                } else {
                    platform.InvalidCodePath("");
                }
            }
        }

        assets.assets = arena.PushSlice(asset, assets.assetCount).ptr;
        // assets.assets = arena.PushSlice(asset, assets.assetCount);
        assets.tags = arena.PushSlice(h.hha_tag, assets.tagCount).ptr;

        h.ZeroStruct(h.hha_tag, &assets.tags[0]);

        for (0..assets.files.len) |fileIndex| {
            const file: *asset_file = &assets.files[fileIndex];
            if (platform.NoFileErrors(file.handle)) {
                const tagArraySize = @sizeOf(h.hha_tag) * (file.header.tagCount - 1);
                h.platformAPI.ReadDataFromFile(file.handle, file.header.tags + @sizeOf(h.hha_tag), tagArraySize, assets.tags + file.tagBase);
            }
        }

        var assetCount: u32 = 0;
        h.ZeroStruct(asset, &assets.assets[assetCount]);
        assetCount += 1;

        for (0..asset_type_id.count()) |destTypeID| {
            var destType: *asset_type = &assets.assetTypes[destTypeID];
            destType.firstAssetIndex = assetCount;

            for (0..assets.files.len) |fileIndex| {
                var file: *asset_file = &assets.files[fileIndex];
                if (platform.NoFileErrors(file.handle)) {
                    for (0..file.header.assetTypeCount) |sourceIndex| {
                        const sourceType: *h.hha_asset_type = &file.assetTypeArray[sourceIndex];

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
                                var a: *asset = &assets.assets[assetCount];
                                assetCount += 1;

                                a.fileIndex = @intCast(fileIndex);
                                a.hha = hhaAsset;
                                if (a.hha.firstTagIndex == 0) {
                                    a.hha.onePastLastTagIndex = 0;
                                    a.hha.firstTagIndex = 0;
                                } else {
                                    a.hha.firstTagIndex += (file.tagBase - 1);
                                    a.hha.onePastLastTagIndex += (file.tagBase - 1);
                                }
                            }
                        }
                    }
                }
            }

            destType.onePastLastAssetIndex = assetCount;
        }

        assert(assetCount == assets.assetCount);

        return assets;
    }
};

inline fn IsLocked(asset_: *asset) bool {
    const result: u32 = asset_.state & @intFromEnum(asset_state.AssetState_Loaded);
    return result != 0;
}

inline fn GetType(asset_: *asset) u32 {
    const result: u32 = asset_.state & @intFromEnum(asset_state.AssetState_TypeMask);
    return result;
}

inline fn GetState(asset_: *asset) u32 {
    const result: u32 = asset_.state & @intFromEnum(asset_state.AssetState_StateMask);
    return result;
}

const load_asset_work = struct {
    task: *h.task_with_memory,
    asset_: *asset,

    handle: *platform.file_handle,
    offset: u64,
    size: u64,
    destination: *anyopaque,

    finalState: u32,
};

fn LoadAssetWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).Pointer.child != @TypeOf(LoadAssetWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *load_asset_work = @alignCast(@ptrCast(data));

    h.platformAPI.ReadDataFromFile(work.handle, work.offset, work.size, work.destination);

    @fence(.seq_cst);

    if (!platform.NoFileErrors(work.handle)) {
        h.ZeroSize(work.size, @ptrCast(work.destination));
    }
    work.asset_.state = work.finalState;

    h.EndTaskWithMemory(work.task);
}

inline fn GetFileHandleFor(assets: *game_assets, fileIndex: u32) *platform.file_handle {
    const result: *platform.file_handle = assets.files[fileIndex].handle;
    return result;
}

inline fn AcquireAssetMemory(assets: *game_assets, size: platform.memory_index) ?*anyopaque {
    const result = h.platformAPI.AllocateMemory(size);
    if (result) |_| {
        assets.totalMemoryUsed += size;
    }

    return result;
}

inline fn ReleaseAssetMemory(assets: *game_assets, size: platform.memory_index, memory: ?*anyopaque) void {
    if (memory) |_| {
        assets.totalMemoryUsed -= size;
    }
    h.platformAPI.DeallocateMemory(memory);
}

const asset_memory_size = struct {
    total: u32 = 0,
    data: u32 = 0,
    section: u32 = 0,
};

fn GetSizeOfAsset(assets: *game_assets, t: u32, assetIndex: u32) asset_memory_size {
    const a: *asset = &assets.assets[assetIndex];

    var result: asset_memory_size = .{};

    if (t == @intFromEnum(asset_state.AssetState_Sound)) {
        const info: *h.hha_sound = &a.hha.data.sound;

        result.section = info.sampleCount * @sizeOf(i16);
        result.data = result.section * info.channelCount;
    } else {
        platform.Assert(t == @intFromEnum(asset_state.AssetState_Bitmap));

        const info: h.hha_bitmap = a.hha.data.bitmap;

        const width: u32 = info.dim[0];
        const height: u32 = info.dim[1];

        result.section = 4 * width;
        result.data = result.section * height;
    }

    result.total = result.data + @sizeOf(asset_memory_header);

    return result;
}

inline fn InsertAssetHeaderAtFront(assets: *game_assets, header: *align(1) asset_memory_header) void {
    const sentinel = &assets.loadedAssetSentinel;

    header.prev = sentinel;
    header.next = sentinel.next;

    header.next.prev = header;
    header.prev.next = header;
}

inline fn AddAssetHeaderToList(assets: *game_assets, assetIndex: u32, memory: [*]u8, size: asset_memory_size) void {
    const header: *align(1) asset_memory_header = @ptrCast(memory + size.data);
    header.assetIndex = assetIndex;

    InsertAssetHeaderAtFront(assets, header);
}

inline fn RemoveAssetHeaderFromList(header: *align(1) asset_memory_header) void {
    header.prev.next = header.next;
    header.next.prev = header.prev;

    header.next = undefined;
    header.prev = undefined;
}

pub fn LoadBitmap(assets: *game_assets, ID: h.bitmap_id, locked: bool) void {
    if (ID.value == 0) return;

    const asset_: *asset = &assets.assets[ID.value];

    if (h.AtomicCompareExchange(u32, &asset_.state, @intFromEnum(asset_state.AssetState_Queued), @intFromEnum(asset_state.AssetState_Unloaded)) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            const a: *asset = &assets.assets[ID.value];
            const info: h.hha_bitmap = a.hha.data.bitmap;
            const bitmap: *h.loaded_bitmap = &asset_.data.bitmap;

            bitmap.alignPercentage = info.alignPercentage;
            bitmap.widthOverHeight = @as(f32, @floatFromInt(info.dim[0])) / @as(f32, @floatFromInt(info.dim[1]));
            bitmap.width = @intCast(info.dim[0]);
            bitmap.height = @intCast(info.dim[1]);

            const size = GetSizeOfAsset(assets, @intFromEnum(asset_state.AssetState_Bitmap), ID.value);
            bitmap.pitch = @intCast(size.section);
            bitmap.memory = @ptrCast(AcquireAssetMemory(assets, size.total).?); // assets.arena.PushSize(memorySize);

            var work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.task = task;
            work.asset_ = &assets.assets[ID.value];
            work.handle = GetFileHandleFor(assets, a.fileIndex);
            work.offset = a.hha.dataOffset;
            work.size = size.data;
            work.destination = bitmap.memory;
            work.finalState = asset_state.or_operator(.AssetState_Loaded, .AssetState_Bitmap) | (if (locked) @intFromEnum(asset_state.AssetState_Lock) else 0);

            asset_.state |= @intFromEnum(asset_state.AssetState_Lock);

            if (!locked) {
                AddAssetHeaderToList(assets, ID.value, bitmap.memory, size);
            }

            h.platformAPI.AddEntry(assets.tranState.lowPriorityQueue, LoadAssetWork, work);
        } else {
            asset_.state = @intFromEnum(asset_state.AssetState_Unloaded);
        }
    }
}

pub inline fn PrefetchBitmap(assets: *game_assets, ID: h.bitmap_id, locked: bool) void {
    return LoadBitmap(assets, ID, locked);
}

pub fn LoadSound(assets: *game_assets, ID: h.sound_id) void {
    if (ID.value == 0) return;

    const asset_: *asset = &assets.assets[ID.value];

    if (h.AtomicCompareExchange(u32, &asset_.state, @intFromEnum(asset_state.AssetState_Queued), @intFromEnum(asset_state.AssetState_Unloaded)) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            const a: *asset = &assets.assets[ID.value];
            const info: *h.hha_sound = &a.hha.data.sound;

            const sound: *loaded_sound = &asset_.data.sound;
            sound.sampleCount = info.sampleCount;
            sound.channelCount = info.channelCount;

            const size: asset_memory_size = GetSizeOfAsset(assets, @intFromEnum(asset_state.AssetState_Sound), ID.value);
            const channelSize = size.section;
            const memory = AcquireAssetMemory(assets, size.total).?; // assets.arena.PushSize(memorySize);

            var soundAt: [*]i16 = @alignCast(@ptrCast(memory));
            for (0..sound.channelCount) |channelIndex| {
                sound.samples[channelIndex] = soundAt;
                soundAt += channelSize;
            }

            var work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.task = task;
            work.asset_ = &assets.assets[ID.value];
            work.handle = GetFileHandleFor(assets, a.fileIndex);
            work.offset = a.hha.dataOffset;
            work.size = size.data;
            work.destination = memory;
            work.finalState = asset_state.or_operator(.AssetState_Loaded, .AssetState_Sound);

            AddAssetHeaderToList(assets, ID.value, @ptrCast(memory), size);

            h.platformAPI.AddEntry(assets.tranState.lowPriorityQueue, LoadAssetWork, work);
        } else {
            asset_.state = @intFromEnum(asset_state.AssetState_Unloaded);
        }
    }
}

pub inline fn PrefetchSound(assets: *game_assets, ID: h.sound_id) void {
    return LoadSound(assets, ID);
}

pub inline fn GetNextSoundInChain(assets: *game_assets, ID: h.sound_id) h.sound_id {
    var result = h.sound_id{};

    const info = assets.GetSoundInfo(ID);
    switch (info.chain) {
        .HHASOUNDCHAIN_None => {},
        .HHASOUNDCHAIN_Loop => result = ID,
        .HHASOUNDCHAIN_Advance => result.value = ID.value + 1,
    }

    return result;
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
                const tag: h.hha_tag = assets.tags[tagIndex];

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

fn GetRandomAssetFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) u32 {
    var result: u32 = 0;

    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        const count = assetType.onePastLastAssetIndex - assetType.firstAssetIndex;
        const choice = series.RandomChoice(count);
        result = choice + assetType.firstAssetIndex;
    }

    return result;
}

fn GetFirstAssetFrom(assets: *game_assets, typeID: asset_type_id) u32 {
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
    const result = h.bitmap_id{ .value = GetFirstAssetFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomBitmapFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetRandomAssetFrom(assets, typeID, series) };
    return result;
}

pub inline fn GetBestMatchSoundFrom(assets: *game_assets, typeID: asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) h.sound_id {
    const result = h.sound_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstSoundFrom(assets: *game_assets, typeID: asset_type_id) h.sound_id {
    const result = h.sound_id{ .value = GetFirstAssetFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomSoundFrom(assets: *game_assets, typeID: asset_type_id, series: *h.random_series) h.sound_id {
    const result = h.sound_id{ .value = GetRandomAssetFrom(assets, typeID, series) };
    return result;
}

fn MoveHeaderToFront(assets: *game_assets, assetIndex: u32, asset_: *asset) void {
    if (!IsLocked(asset_)) {
        const size = GetSizeOfAsset(assets, GetType(asset_), assetIndex);
        var memory: [*]u8 = undefined;

        if (GetType(asset_) == @intFromEnum(asset_state.AssetState_Sound)) {
            memory = @ptrCast(asset_.data.bitmap.memory);
        } else {
            platform.Assert(GetType(asset_) == @intFromEnum(asset_state.AssetState_Bitmap));
            memory = @ptrCast(&asset_.data.sound.samples[0]);
        }

        const header: *align(1) asset_memory_header = @ptrCast(memory + size.data);

        RemoveAssetHeaderFromList(header);
        InsertAssetHeaderAtFront(assets, header);
    }
}

pub fn EvictAsset(assets: *game_assets, header: *align(1) asset_memory_header) void {
    const assetIndex = header.assetIndex;

    const asset_: *asset = &assets.assets[assetIndex];

    platform.Assert(GetState(asset_) == @intFromEnum(asset_state.AssetState_Loaded));
    platform.Assert(!IsLocked(asset_));

    const size = GetSizeOfAsset(assets, GetType(asset_), assetIndex);
    var memory: ?*anyopaque = null;
    if (GetType(asset_) == @intFromEnum(asset_state.AssetState_Sound)) {
        memory = @ptrCast(&asset_.data.sound.samples);
    } else {
        platform.Assert(GetType(asset_) == @intFromEnum(asset_state.AssetState_Bitmap));
        memory = @ptrCast(&asset_.data.bitmap.memory);
    }

    RemoveAssetHeaderFromList(header);
    ReleaseAssetMemory(assets, size.total, memory);

    asset_.state = @intFromEnum(asset_state.AssetState_Unloaded);
}

pub fn EvictAssetsAsNecessary(assets: *game_assets) void {
    while (assets.totalMemoryUsed > assets.targetMemoryUsed) {
        const header = assets.loadedAssetSentinel.prev;
        if (header != &assets.loadedAssetSentinel) {
            const asset_: *asset = &assets.assets[header.assetIndex];

            if (GetState(asset_) >= @intFromEnum(asset_state.AssetState_Loaded)) {
                EvictAsset(assets, header);
            }
        } else {
            platform.InvalidCodePath("");
            break;
        }
    }
}

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

    AssetState_Lock = 0x10000,

    // TODO (Manav): use zig enum and combine some of the states to eliminate @intFromEnum()
};

pub const asset_memory_header = struct {
    next: *asset_memory_header,
    prev: *asset_memory_header,

    assetIndex: u32,
    totalSize: u32,

    data: extern union {
        bitmap: h.loaded_bitmap,
        sound: loaded_sound,
    },
};

pub const asset = extern struct {
    state: u32,
    header: *asset_memory_header,
    hha: h.hha_asset,
    fileIndex: u32,
};

pub const asset_vector = struct {
    e: [h.asset_tag_id.len()]f32 = [1]f32{0} ** h.asset_tag_id.len(),
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
    handle: platform.file_handle,

    header: h.hha_header,
    assetTypeArray: []h.hha_asset_type,

    tagBase: u32,
};

pub const asset_memory_block_flags = packed struct(u64) {
    used: bool = false,
    _padding: u63 = 0,
};

pub const asset_memory_block = extern struct {
    prev: *asset_memory_block,
    next: *asset_memory_block,
    flags: asset_memory_block_flags,
    size: platform.memory_index,
};

pub const game_assets = struct {
    tranState: *h.transient_state,

    memorySentinel: asset_memory_block,

    loadedAssetSentinel: asset_memory_header,

    tagRange: [h.asset_tag_id.len()]f32,

    // fileCount: u32,
    files: []asset_file,

    tagCount: u32,
    tags: [*]h.hha_tag,

    assetCount: u32,
    assets: [*]asset,

    assetTypes: [h.asset_type_id.count()]asset_type,

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
            result = &asset_.header.data.bitmap;
            MoveHeaderToFront(self, asset_);
        }

        return result;
    }

    pub inline fn GetSound(self: *game_assets, ID: h.sound_id) ?*loaded_sound {
        assert(ID.value <= self.assetCount);
        const asset_: *asset = &self.assets[ID.value];

        var result: ?*loaded_sound = null;
        if (GetState(asset_) >= @intFromEnum(asset_state.AssetState_Loaded)) {
            @fence(.seq_cst);
            result = &asset_.header.data.sound;
            MoveHeaderToFront(self, asset_);
        }

        return result;
    }

    pub inline fn GetSoundInfo(self: *game_assets, ID: h.sound_id) *h.hha_sound {
        const result = &self.assets[ID.value].hha.data.sound;
        return result;
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.memorySentinel.flags = .{ .used = false };
        assets.memorySentinel.size = 0;
        assets.memorySentinel.prev = &assets.memorySentinel;
        assets.memorySentinel.next = &assets.memorySentinel;

        _ = InsertBlock(&assets.memorySentinel, size, arena.PushSizeAlign(16, size));

        assets.tranState = tranState;

        assets.loadedAssetSentinel.next = &assets.loadedAssetSentinel;
        assets.loadedAssetSentinel.prev = &assets.loadedAssetSentinel;

        for (0..h.asset_tag_id.len()) |tagType| {
            assets.tagRange[tagType] = 1000000.0;
        }

        assets.tagRange[@intFromEnum(h.asset_tag_id.Tag_FacingDirection)] = platform.Tau32;

        assets.tagCount = 1;
        assets.assetCount = 1;

        {
            var fileGroup = h.platformAPI.GetAllFilesOfTypeBegin(.PlatformFileType_AssetFile);
            defer h.platformAPI.GetAllFilesOfTypeEnd(&fileGroup);

            assets.files = arena.PushSlice(asset_file, fileGroup.fileCount);

            for (0..assets.files.len) |fileIndex| {
                var file: *asset_file = &assets.files[fileIndex];

                file.tagBase = assets.tagCount;

                h.ZeroStruct(h.hha_header, &file.header);
                file.handle = h.platformAPI.OpenNextFile(&fileGroup);
                h.platformAPI.ReadDataFromFile(&file.handle, 0, @sizeOf(@TypeOf(file.header)), &file.header);

                file.assetTypeArray = arena.PushSlice(h.hha_asset_type, file.header.assetTypeCount);
                const assetTypeArraySize = file.header.assetTypeCount * @sizeOf(h.hha_asset_type);

                h.platformAPI.ReadDataFromFile(&file.handle, file.header.assetTypes, assetTypeArraySize, file.assetTypeArray.ptr);

                if (file.header.magicValue != h.HHA_MAGIC_VALUE) {
                    h.platformAPI.FileError(&file.handle, "HHA file has invalid magic value.");
                }

                if (file.header.version > h.HHA_VERSION) {
                    h.platformAPI.FileError(&file.handle, "HHA file is of a later version.");
                }

                if (platform.NoFileErrors(&file.handle)) {
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
            if (platform.NoFileErrors(&file.handle)) {
                const tagArraySize = @sizeOf(h.hha_tag) * (file.header.tagCount - 1);
                h.platformAPI.ReadDataFromFile(&file.handle, file.header.tags + @sizeOf(h.hha_tag), tagArraySize, assets.tags + file.tagBase);
            }
        }

        var assetCount: u32 = 0;
        h.ZeroStruct(asset, &assets.assets[assetCount]);
        assetCount += 1;

        for (0..h.asset_type_id.count()) |destTypeID| {
            var destType: *asset_type = &assets.assetTypes[destTypeID];
            destType.firstAssetIndex = assetCount;

            for (0..assets.files.len) |fileIndex| {
                var file: *asset_file = &assets.files[fileIndex];
                if (platform.NoFileErrors(&file.handle)) {
                    for (0..file.header.assetTypeCount) |sourceIndex| {
                        const sourceType: *h.hha_asset_type = &file.assetTypeArray[sourceIndex];

                        if (sourceType.typeID == destTypeID) {
                            const assetCountForType: u32 = (sourceType.onePastLastAssetIndex - sourceType.firstAssetIndex);

                            const tempMem = h.BeginTemporaryMemory(&tranState.tranArena);
                            defer h.EndTemporaryMemory(tempMem);

                            const hhaAssetArray = tempMem.arena.PushSlice(h.hha_asset, assetCountForType);

                            h.platformAPI.ReadDataFromFile(
                                &file.handle,
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
    const result: u32 = asset_.state & @intFromEnum(asset_state.AssetState_Lock);
    return result != 0;
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
    const result: *platform.file_handle = &assets.files[fileIndex].handle;
    return result;
}

fn InsertBlock(prev: *asset_memory_block, size: u64, memory: *anyopaque) *asset_memory_block {
    platform.Assert(size > @sizeOf(asset_memory_block));

    var block: *asset_memory_block = @alignCast(@ptrCast(memory));
    block.flags = .{ .used = false };
    block.size = size - @sizeOf(asset_memory_block);
    block.prev = prev;
    block.next = prev.next;
    block.prev.next = block;
    block.next.prev = block;

    return block;
}

fn FindBlockForSize(assets: *game_assets, size: platform.memory_index) ?*asset_memory_block {
    var result: ?*asset_memory_block = null;

    var block: *asset_memory_block = assets.memorySentinel.next;
    while (block != &assets.memorySentinel) : (block = block.next) {
        if (!block.flags.used) {
            if (block.size >= size) {
                result = block;
                break;
            }
        }
    }

    return result;
}

fn MergeIfPossible(assets: *game_assets, first: *asset_memory_block, second: *asset_memory_block) bool {
    var result = false;

    if ((first != &assets.memorySentinel) and (second != &assets.memorySentinel)) {
        if (!(first.flags.used) and !(second.flags.used)) {
            const expectedSecond: [*]u8 = @as([*]u8, @ptrCast(first)) + @sizeOf(asset_memory_block) + first.size;
            if (@as([*]u8, @ptrCast(second)) == expectedSecond) {
                @import("std").debug.print("Merging first: {}, second: {}\n", .{ @intFromPtr(first), @intFromPtr(second) });
                second.next.prev = second.prev;
                second.prev.next = second.next;

                // NOTE (Manav): investigate this
                first.size += @sizeOf(asset_memory_block) + second.size;

                result = true;
            }
        }
    }

    return result;
}

fn AcquireAssetMemory(assets: *game_assets, size_: platform.memory_index) ?*anyopaque {
    var result: ?*anyopaque = null;

    // NOTE (Manav): Hack, blocks are always aligned (check AllocateGameAssets())
    // and since @sizeOf(asset_memory_block) is 32, we only need to forward align size
    // so headers in LoadSound() and LoadBitmap() points to aligned memory address.
    // This might have introduced the flickering bug with evicting assets
    const size = platform.Align(size_, 16);

    var block = FindBlockForSize(assets, size);

    while (true) {
        if (block != null and size <= block.?.size) {
            block.?.flags = .{ .used = true };

            const resPtr: [*]u8 = @ptrCast(@as([*]asset_memory_block, @ptrCast(block)) + 1);

            result = resPtr;

            const remainingSize = block.?.size - size;
            const blockSplitThreshold = 4096;
            if (remainingSize > blockSplitThreshold) {
                block.?.size -= remainingSize;
                _ = InsertBlock(block.?, remainingSize, resPtr + size);
            } else {
                //
            }

            break;
        } else {
            var header: *asset_memory_header = assets.loadedAssetSentinel.prev;
            while (header != &assets.loadedAssetSentinel) : (header = header.prev) {
                // TODO (Manav): investigate a potential bug here with evicting assets
                const asset_: *asset = &assets.assets[header.assetIndex];

                if (GetState(asset_) >= @intFromEnum(asset_state.AssetState_Loaded)) {
                    platform.Assert(GetState(asset_) == @intFromEnum(asset_state.AssetState_Loaded));
                    platform.Assert(!IsLocked(asset_));

                    RemoveAssetHeaderFromList(header);

                    block = &(@as([*]asset_memory_block, @alignCast(@ptrCast(asset_.header))) - 1)[0];
                    block.?.flags = .{ .used = false };

                    if (MergeIfPossible(assets, block.?.prev, block.?)) {
                        block = block.?.prev;
                    }

                    _ = MergeIfPossible(assets, block.?.next, block.?);

                    asset_.state = @intFromEnum(asset_state.AssetState_Unloaded);
                    asset_.header = undefined;

                    break;
                }
            }
        }
    }

    return result;
}

const asset_memory_size = struct {
    total: u32 = 0,
    data: u32 = 0,
    section: u32 = 0,
};

fn InsertAssetHeaderAtFront(assets: *game_assets, header: *asset_memory_header) void {
    const sentinel = &assets.loadedAssetSentinel;

    header.prev = sentinel;
    header.next = sentinel.next;

    header.next.prev = header;
    header.prev.next = header;
}

fn AddAssetHeaderToList(assets: *game_assets, assetIndex: u32, size: asset_memory_size) void {
    const header: *asset_memory_header = assets.assets[assetIndex].header;
    header.assetIndex = assetIndex;
    header.totalSize = size.total;
    InsertAssetHeaderAtFront(assets, header);
}

fn RemoveAssetHeaderFromList(header: *align(1) asset_memory_header) void {
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
            const info: h.hha_bitmap = asset_.hha.data.bitmap;

            var size: asset_memory_size = .{};

            const width: u32 = info.dim[0];
            const height: u32 = info.dim[1];

            size.section = 4 * width;
            size.data = size.section * height;

            size.total = size.data + @sizeOf(asset_memory_header);

            asset_.header = @alignCast(@ptrCast(AcquireAssetMemory(assets, size.total).?));

            const bitmap: *h.loaded_bitmap = &asset_.header.data.bitmap;
            bitmap.alignPercentage = info.alignPercentage;
            bitmap.widthOverHeight = @as(f32, @floatFromInt(info.dim[0])) / @as(f32, @floatFromInt(info.dim[1]));
            bitmap.width = @intCast(info.dim[0]);
            bitmap.height = @intCast(info.dim[1]);

            bitmap.pitch = @intCast(size.section);
            bitmap.memory = @ptrCast(@as([*]asset_memory_header, @ptrCast(asset_.header)) + 1);

            var work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.task = task;
            work.asset_ = &assets.assets[ID.value];
            work.handle = GetFileHandleFor(assets, asset_.fileIndex);
            work.offset = asset_.hha.dataOffset;
            work.size = size.data;
            work.destination = bitmap.memory;
            work.finalState = @intFromEnum(asset_state.AssetState_Loaded) | (if (locked) @intFromEnum(asset_state.AssetState_Lock) else 0);

            asset_.state |= @intFromEnum(asset_state.AssetState_Lock);

            if (!locked) {
                AddAssetHeaderToList(assets, ID.value, size);
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
            const info: *h.hha_sound = &asset_.hha.data.sound;

            var size: asset_memory_size = .{};

            size.section = info.sampleCount * @sizeOf(i16);
            size.data = size.section * info.channelCount;
            size.total = size.data + @sizeOf(asset_memory_header);

            asset_.header = @alignCast(@ptrCast(AcquireAssetMemory(assets, size.total).?));
            const sound: *loaded_sound = &asset_.header.data.sound;

            sound.sampleCount = info.sampleCount;
            sound.channelCount = info.channelCount;

            const channelSize = size.section;

            const memory: *anyopaque = @ptrCast(@as([*]asset_memory_header, @ptrCast(asset_.header)) + 1);

            var soundAt: [*]i16 = @alignCast(@ptrCast(memory));
            for (0..sound.channelCount) |channelIndex| {
                sound.samples[channelIndex] = soundAt;
                soundAt += channelSize;
            }

            var work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.task = task;
            work.asset_ = &assets.assets[ID.value];
            work.handle = GetFileHandleFor(assets, asset_.fileIndex);
            work.offset = asset_.hha.dataOffset;
            work.size = size.data;
            work.destination = @ptrCast(memory);
            work.finalState = @intFromEnum(asset_state.AssetState_Loaded);

            AddAssetHeaderToList(assets, ID.value, size);

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

pub fn GetBestMatchAssetFrom(assets: *game_assets, typeID: h.asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) u32 {
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

fn GetRandomAssetFrom(assets: *game_assets, typeID: h.asset_type_id, series: *h.random_series) u32 {
    var result: u32 = 0;

    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        const count = assetType.onePastLastAssetIndex - assetType.firstAssetIndex;
        const choice = series.RandomChoice(count);
        result = choice + assetType.firstAssetIndex;
    }

    return result;
}

fn GetFirstAssetFrom(assets: *game_assets, typeID: h.asset_type_id) u32 {
    var result: u32 = 0;

    const assetType = assets.assetTypes[@intFromEnum(typeID)];

    if (assetType.firstAssetIndex != assetType.onePastLastAssetIndex) {
        result = assetType.firstAssetIndex;
    }

    return result;
}

pub inline fn GetBestMatchBitmapFrom(assets: *game_assets, typeID: h.asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstBitmapFrom(assets: *game_assets, typeID: h.asset_type_id) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetFirstAssetFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomBitmapFrom(assets: *game_assets, typeID: h.asset_type_id, series: *h.random_series) h.bitmap_id {
    const result = h.bitmap_id{ .value = GetRandomAssetFrom(assets, typeID, series) };
    return result;
}

pub inline fn GetBestMatchSoundFrom(assets: *game_assets, typeID: h.asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) h.sound_id {
    const result = h.sound_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

pub inline fn GetFirstSoundFrom(assets: *game_assets, typeID: h.asset_type_id) h.sound_id {
    const result = h.sound_id{ .value = GetFirstAssetFrom(assets, typeID) };
    return result;
}

pub inline fn GetRandomSoundFrom(assets: *game_assets, typeID: h.asset_type_id, series: *h.random_series) h.sound_id {
    const result = h.sound_id{ .value = GetRandomAssetFrom(assets, typeID, series) };
    return result;
}

fn MoveHeaderToFront(assets: *game_assets, asset_: *asset) void {
    if (!IsLocked(asset_)) {
        const header: *asset_memory_header = asset_.header;

        RemoveAssetHeaderFromList(header);
        InsertAssetHeaderAtFront(assets, header);
    }
}

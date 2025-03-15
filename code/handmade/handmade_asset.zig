const platform = @import("handmade_platform");
const debug = @import("handmade_debug.zig");

const h = struct {
    usingnamespace @import("intrinsics");

    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_math.zig");
    usingnamespace @import("handmade_random.zig");
    usingnamespace @import("handmade_render_group.zig");
    usingnamespace @import("handmade.zig");

    usingnamespace @import("handmade_file_formats.zig");
};

const assert = platform.Assert;
const ignore = platform.ignore;

// data types -----------------------------------------------------------------------------------------------------------------------------

pub const loaded_sound = extern struct {
    /// it is `sampleCount` divided by `8`
    samples: [2]?[*]i16 = undefined,
    sampleCount: u32 = 0,
    channelCount: u32 = 0,
};

pub const loaded_font = extern struct {
    glyphs: [*]h.hha_font_glyph,
    horizontalAdvance: [*]f32,
    bitmapIDOffset: u32,
    unicodeMap: [*]u16,
};

pub const asset_state = enum(u32) {
    AssetState_Unloaded,
    AssetState_Queued,
    AssetState_Loaded,
};

pub const asset_memory_header = struct {
    next: *asset_memory_header,
    prev: *asset_memory_header,

    assetIndex: u32,
    totalSize: u32,
    generationID: u32,

    data: extern union {
        bitmap: h.loaded_bitmap,
        sound: loaded_sound,
        font: loaded_font,
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
    fontBitmapIDOffset: i32,
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
    nextGenerationID: u32,

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

    operationLock: u32,

    inFlightGenerationCount: u32,
    inFlightGenerations: [16]u32,

    pub inline fn GetAsset(self: *game_assets, ID: u32, generationID: u32) ?*asset_memory_header {
        assert(ID <= self.assetCount);
        const asset_: *asset = &self.assets[ID];

        var result: ?*asset_memory_header = null;

        self.BeginAssetLock();

        if (asset_.state == @intFromEnum(asset_state.AssetState_Loaded)) {
            result = asset_.header;
            RemoveAssetHeaderFromList(result.?);
            InsertAssetHeaderAtFront(self, result.?);

            // if (asset_.header.generationID < generationID) {
            //     asset_.header.generationID = generationID;
            // }
            _ = @atomicRmw(u32, &asset_.header.generationID, .Max, generationID, .seq_cst);
        }

        self.EndAssetLock();

        return result;
    }

    pub inline fn GetBitmap(self: *game_assets, ID: h.bitmap_id, generationID: u32) ?*h.loaded_bitmap {
        var result: ?*h.loaded_bitmap = null;

        if (self.GetAsset(ID.value, generationID)) |header| {
            result = &header.data.bitmap;
        }

        return result;
    }

    pub inline fn GetSound(self: *game_assets, ID: h.sound_id, generationID: u32) ?*loaded_sound {
        var result: ?*loaded_sound = null;

        if (self.GetAsset(ID.value, generationID)) |header| {
            result = &header.data.sound;
        }

        return result;
    }

    pub inline fn GetFont(self: *game_assets, ID: h.font_id, generationID: u32) ?*loaded_font {
        var result: ?*loaded_font = null;

        if (self.GetAsset(ID.value, generationID)) |header| {
            result = &header.data.font;
        }

        return result;
    }

    pub inline fn GetBitmapInfo(self: *game_assets, ID: h.bitmap_id) *h.hha_bitmap {
        const result = &self.assets[ID.value].hha.data.bitmap;
        return result;
    }

    pub inline fn GetSoundInfo(self: *game_assets, ID: h.sound_id) *h.hha_sound {
        const result = &self.assets[ID.value].hha.data.sound;
        return result;
    }

    pub inline fn GetFontInfo(self: *game_assets, ID: h.font_id) *h.hha_font {
        const result = &self.assets[ID.value].hha.data.font;
        return result;
    }

    pub inline fn BeginAssetLock(self: *game_assets) void {
        while (true) {
            if (h.AtomicCompareExchange(u32, &self.operationLock, 1, 0) == null) {
                break;
            }
        }
    }

    pub inline fn EndAssetLock(self: *game_assets) void {
        @atomicStore(u32, &self.operationLock, 0, .seq_cst);
    }

    pub fn AllocateGameAssets(arena: *h.memory_arena, size: platform.memory_index, tranState: *h.transient_state) *game_assets {
        var assets: *game_assets = arena.PushStruct(game_assets);

        assets.nextGenerationID = 0;
        assets.inFlightGenerationCount = 0;

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

                file.fontBitmapIDOffset = 0;
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
                            if (sourceType.typeID == @intFromEnum(h.asset_type_id.Asset_FontGlyph)) {
                                file.fontBitmapIDOffset = @as(i32, @intCast(assetCount)) - @as(i32, @intCast(sourceType.firstAssetIndex));
                            }

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

fn InsertAssetHeaderAtFront(assets: *game_assets, header: *asset_memory_header) void {
    const sentinel = &assets.loadedAssetSentinel;

    header.prev = sentinel;
    header.next = sentinel.next;

    header.next.prev = header;
    header.prev.next = header;
}

fn RemoveAssetHeaderFromList(header: *asset_memory_header) void {
    header.prev.next = header.next;
    header.next.prev = header.prev;

    header.next = undefined;
    header.prev = undefined;
}

const finalize_asset_operation = enum {
    FinalizeAsset_NONE,
    FinalizeAsset_Font,
};

const load_asset_work = struct {
    task: ?*h.task_with_memory,
    asset_: *asset, // TODO: (change code style to match with casey? or switch to zig?)

    handle: *platform.file_handle,
    offset: u64,
    size: u64,
    destination: *anyopaque,

    finalState: u32,

    finalizeOperation: finalize_asset_operation,
};

fn LoadAssetWorkDirectly(work: *load_asset_work) void {
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__10 = debug.TIMED_FUNCTION__impl(10, @src()).Init(.{});
    defer __t_blk__10.End();
    // AUTOGENERATED ----------------------------------------------------------

    h.platformAPI.ReadDataFromFile(work.handle, work.offset, work.size, work.destination);

    if (platform.NoFileErrors(work.handle)) {
        switch (work.finalizeOperation) {
            .FinalizeAsset_Font => {
                const font = &work.asset_.header.data.font;
                const hha = &work.asset_.hha.data.font;
                for (1..hha.glyphCount) |glyphIndex| {
                    const glyph = &font.glyphs[glyphIndex];

                    assert(glyph.unicodeCodePoint < hha.onePastHighestCodepoint);
                    font.unicodeMap[glyph.unicodeCodePoint] = @intCast(glyphIndex);
                }
            },
            else => {},
        }
    }

    if (!platform.NoFileErrors(work.handle)) {
        h.ZeroSize(work.size, @ptrCast(work.destination));
    }

    @atomicStore(u32, &work.asset_.state, work.finalState, .seq_cst);
}

fn LoadAssetWork(_: ?*platform.work_queue, data: *anyopaque) void {
    comptime {
        if (@typeInfo(platform.work_queue_callback).pointer.child != @TypeOf(LoadAssetWork)) {
            @compileError("Function signature mismatch!");
        }
    }
    const work: *load_asset_work = @alignCast(@ptrCast(data));

    LoadAssetWorkDirectly(work);

    h.EndTaskWithMemory(work.task.?);
}

inline fn GetFile(assets: *game_assets, fileIndex: u32) *asset_file {
    const result: *asset_file = &assets.files[fileIndex];
    return result;
}

inline fn GetFileHandleFor(assets: *game_assets, fileIndex: u32) *platform.file_handle {
    const result: *platform.file_handle = &GetFile(assets, fileIndex).handle;
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

fn GenerationHasCompleted(assets: *game_assets, checkID: u32) bool {
    var result = true;

    for (0..assets.inFlightGenerationCount) |index| {
        if (assets.inFlightGenerations[index] == checkID) {
            result = false;
            break;
        }
    }

    return result;
}

fn AcquireAssetMemory(assets: *game_assets, size_: u32, assetIndex: u32) ?*asset_memory_header {
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__11 = debug.TIMED_FUNCTION__impl(11, @src()).Init(.{});
    defer __t_blk__11.End();
    // AUTOGENERATED ----------------------------------------------------------

    var result: ?*asset_memory_header = null;

    // NOTE (Manav): Hack, blocks are always aligned (check AllocateGameAssets())
    // and since @sizeOf(asset_memory_block) is 32, we only need to forward align size
    // so headers in LoadSound(), LoadBitmap(), etc, all points to aligned memory address.
    const size: u32 = @intCast(platform.Align(size_, 16));

    assets.BeginAssetLock();

    var block = FindBlockForSize(assets, size);

    while (true) {
        if (block != null and size <= block.?.size) {
            block.?.flags = .{ .used = true };

            const resPtr: [*]u8 = @ptrCast(@as([*]asset_memory_block, @ptrCast(block)) + 1);

            result = @alignCast(@ptrCast(resPtr));

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
                // NOTE: fixing this
                const asset_: *asset = &assets.assets[header.assetIndex];

                if (asset_.state >= @intFromEnum(asset_state.AssetState_Loaded) and GenerationHasCompleted(assets, asset_.header.generationID)) {
                    platform.Assert(asset_.state == @intFromEnum(asset_state.AssetState_Loaded));

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

    if (result) |header| {
        header.assetIndex = assetIndex;
        header.totalSize = size; // NOTE (Manav): use aligned size
        InsertAssetHeaderAtFront(assets, header);
    }

    assets.EndAssetLock();

    return result;
}

const asset_memory_size = struct {
    total: u32 = 0,
    data: u32 = 0,
    section: u32 = 0,
};

pub fn LoadBitmap(assets: *game_assets, ID: h.bitmap_id, immediate: bool) void {
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__12 = debug.TIMED_FUNCTION__impl(12, @src()).Init(.{});
    defer __t_blk__12.End();
    // AUTOGENERATED ----------------------------------------------------------

    if (ID.value == 0) return;

    const asset_: *asset = &assets.assets[ID.value];

    if (h.AtomicCompareExchange(u32, &asset_.state, @intFromEnum(asset_state.AssetState_Queued), @intFromEnum(asset_state.AssetState_Unloaded)) == null) {
        var task: ?*h.task_with_memory = null;

        if (!immediate) {
            task = h.BeginTaskWithMemory(assets.tranState);
        }
        if (immediate or task != null) {
            const info: h.hha_bitmap = asset_.hha.data.bitmap;

            var size: asset_memory_size = .{};

            const width: u32 = info.dim[0];
            const height: u32 = info.dim[1];

            size.section = 4 * width;
            size.data = size.section * height;

            size.total = size.data + @sizeOf(asset_memory_header);

            asset_.header = AcquireAssetMemory(assets, size.total, ID.value).?;

            const bitmap: *h.loaded_bitmap = &asset_.header.data.bitmap;
            bitmap.alignPercentage = info.alignPercentage;
            bitmap.widthOverHeight = @as(f32, @floatFromInt(info.dim[0])) / @as(f32, @floatFromInt(info.dim[1]));
            bitmap.width = @intCast(info.dim[0]);
            bitmap.height = @intCast(info.dim[1]);

            bitmap.pitch = @intCast(size.section);
            bitmap.memory = @ptrCast(@as([*]asset_memory_header, @ptrCast(asset_.header)) + 1);

            var work = load_asset_work{
                .task = task,
                .asset_ = &assets.assets[ID.value],
                .handle = GetFileHandleFor(assets, asset_.fileIndex),
                .offset = asset_.hha.dataOffset,
                .size = size.data,
                .destination = bitmap.memory,
                .finalState = @intFromEnum(asset_state.AssetState_Loaded),
                .finalizeOperation = .FinalizeAsset_NONE,
            };

            if (task) |_| {
                const taskWork: *load_asset_work = task.?.arena.PushStruct(load_asset_work);
                taskWork.* = work;
                h.platformAPI.AddEntry(assets.tranState.lowPriorityQueue, LoadAssetWork, taskWork);
            } else {
                LoadAssetWorkDirectly(&work);
            }
        } else {
            asset_.state = @intFromEnum(asset_state.AssetState_Unloaded);
        }
    } else if (immediate) {
        while (@atomicLoad(u32, &asset_.state, .unordered) == @intFromEnum(asset_state.AssetState_Queued)) {}
    }
}

pub inline fn PrefetchBitmap(assets: *game_assets, ID: h.bitmap_id) void {
    return LoadBitmap(assets, ID, false);
}

pub fn LoadFont(assets: *game_assets, ID: h.font_id, immediate: bool) void {
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__13 = debug.TIMED_FUNCTION__impl(13, @src()).Init(.{});
    defer __t_blk__13.End();
    // AUTOGENERATED ----------------------------------------------------------

    if (ID.value == 0) return;

    const asset_: *asset = &assets.assets[ID.value];

    if (h.AtomicCompareExchange(u32, &asset_.state, @intFromEnum(asset_state.AssetState_Queued), @intFromEnum(asset_state.AssetState_Unloaded)) == null) {
        var task: ?*h.task_with_memory = null;

        if (!immediate) {
            task = h.BeginTaskWithMemory(assets.tranState);
        }
        if (immediate or task != null) {
            const info: h.hha_font = asset_.hha.data.font;

            const horizontalAdvanceSize = info.glyphCount * info.glyphCount * @sizeOf(f32);
            const glyphsSize = info.glyphCount * @sizeOf(h.hha_font_glyph);
            const unicodeMapSize = @sizeOf(u16) * info.onePastHighestCodepoint;
            const sizeData = glyphsSize + horizontalAdvanceSize;
            const sizeTotal = sizeData + @sizeOf(asset_memory_header) + unicodeMapSize;

            asset_.header = AcquireAssetMemory(assets, sizeTotal, ID.value).?;

            const font: *loaded_font = &asset_.header.data.font;
            font.bitmapIDOffset = @intCast(GetFile(assets, asset_.fileIndex).fontBitmapIDOffset);
            font.glyphs = @ptrCast(@as([*]asset_memory_header, @ptrCast(asset_.header)) + 1);
            font.horizontalAdvance = @alignCast(@ptrCast(@as([*]u8, @ptrCast(font.glyphs)) + glyphsSize));
            font.unicodeMap = @alignCast(@ptrCast(@as([*]u8, @ptrCast(font.horizontalAdvance)) + horizontalAdvanceSize));

            h.ZeroSize(unicodeMapSize, @ptrCast(font.unicodeMap));

            var work = load_asset_work{
                .task = task,
                .asset_ = &assets.assets[ID.value],
                .handle = GetFileHandleFor(assets, asset_.fileIndex),
                .offset = asset_.hha.dataOffset,
                .size = sizeData,
                .destination = font.glyphs,
                .finalState = @intFromEnum(asset_state.AssetState_Loaded),
                .finalizeOperation = .FinalizeAsset_Font,
            };

            if (task) |_| {
                const taskWork: *load_asset_work = task.?.arena.PushStruct(load_asset_work);
                taskWork.* = work;
                h.platformAPI.AddEntry(assets.tranState.lowPriorityQueue, LoadAssetWork, taskWork);
            } else {
                LoadAssetWorkDirectly(&work);
            }
        } else {
            asset_.state = @intFromEnum(asset_state.AssetState_Unloaded);
        }
    } else if (immediate) {
        while (@atomicLoad(u32, &asset_.state, .unordered) == @intFromEnum(asset_state.AssetState_Queued)) {}
    }
}

pub inline fn PrefetchFont(assets: *game_assets, ID: h.font_id) void {
    return LoadFont(assets, ID, false);
}

pub fn LoadSound(assets: *game_assets, ID: h.sound_id) void {
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__14 = debug.TIMED_FUNCTION__impl(14, @src()).Init(.{});
    defer __t_blk__14.End();
    // AUTOGENERATED ----------------------------------------------------------

    if (ID.value == 0) return;

    const asset_: *asset = &assets.assets[ID.value];

    if (h.AtomicCompareExchange(u32, &asset_.state, @intFromEnum(asset_state.AssetState_Queued), @intFromEnum(asset_state.AssetState_Unloaded)) == null) {
        if (h.BeginTaskWithMemory(assets.tranState)) |task| {
            const info: *h.hha_sound = &asset_.hha.data.sound;

            var size: asset_memory_size = .{};

            size.section = info.sampleCount * @sizeOf(i16);
            size.data = size.section * info.channelCount;
            size.total = size.data + @sizeOf(asset_memory_header);

            asset_.header = @alignCast(@ptrCast(AcquireAssetMemory(assets, size.total, ID.value).?));
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

            const work: *load_asset_work = task.arena.PushStruct(load_asset_work);
            work.* = .{
                .task = task,
                .asset_ = &assets.assets[ID.value],
                .handle = GetFileHandleFor(assets, asset_.fileIndex),
                .offset = asset_.hha.dataOffset,
                .size = size.data,
                .destination = @ptrCast(memory),
                .finalState = @intFromEnum(asset_state.AssetState_Loaded),
                .finalizeOperation = .FinalizeAsset_NONE,
            };

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
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__15 = debug.TIMED_FUNCTION__impl(15, @src()).Init(.{});
    defer __t_blk__15.End();
    // AUTOGENERATED ----------------------------------------------------------

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
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__16 = debug.TIMED_FUNCTION__impl(16, @src()).Init(.{});
    defer __t_blk__16.End();
    // AUTOGENERATED ----------------------------------------------------------

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
    debug.TIMED_FUNCTION(.{});
    // AUTOGENERATED ----------------------------------------------------------
    var __t_blk__17 = debug.TIMED_FUNCTION__impl(17, @src()).Init(.{});
    defer __t_blk__17.End();
    // AUTOGENERATED ----------------------------------------------------------

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

pub inline fn GetBestMatchFontFrom(assets: *game_assets, typeID: h.asset_type_id, matchVector: *asset_vector, weightVector: *asset_vector) h.font_id {
    const result = h.font_id{ .value = GetBestMatchAssetFrom(assets, typeID, matchVector, weightVector) };
    return result;
}

inline fn GetGlyphFromCodePoint(info: *h.hha_font, font: *loaded_font, codePoint: u32) u32 {
    var result: u32 = 0;

    if (codePoint < info.onePastHighestCodepoint) {
        result = font.unicodeMap[codePoint];
        assert(result < info.glyphCount);
    }

    return result;
}

pub fn GetHorizontalAdvanceForPair(info: *h.hha_font, font: *loaded_font, desiredPrevCodePoint: u32, desiredCodePoint: u32) f32 {
    const prevGlyph = GetGlyphFromCodePoint(info, font, desiredPrevCodePoint);
    const glyph = GetGlyphFromCodePoint(info, font, desiredCodePoint);
    const result = font.horizontalAdvance[prevGlyph * info.glyphCount + glyph];

    return result;
}

pub fn GetBitmapForGlyph(_: *game_assets, info: *h.hha_font, font: *loaded_font, desiredCodePoint: u32) h.bitmap_id {
    const glyph = GetGlyphFromCodePoint(info, font, desiredCodePoint);
    var result = font.glyphs[glyph].bitmapID;
    result.value += font.bitmapIDOffset;
    return result;
}

pub fn GetLineAdvanceFor(info: *h.hha_font) f32 {
    const result = info.ascenderHeight + info.descenderHeight + info.externalLeading;

    return result;
}

pub fn GetStartingBaselineY(info: *h.hha_font) f32 {
    const result = info.ascenderHeight;

    return result;
}

pub inline fn BeginGeneration(assets: *game_assets) u32 {
    assets.BeginAssetLock();

    assert(assets.inFlightGenerationCount < assets.inFlightGenerations.len);

    const result = assets.nextGenerationID;
    assets.nextGenerationID += 1;

    assets.inFlightGenerations[assets.inFlightGenerationCount] = result;
    assets.inFlightGenerationCount += 1;

    assets.EndAssetLock();

    return result;
}

pub inline fn EndGeneration(assets: *game_assets, generationID: u32) void {
    assets.BeginAssetLock();

    for (0..assets.inFlightGenerationCount) |index| {
        if (assets.inFlightGenerations[index] == generationID) {
            assets.inFlightGenerationCount -= 1;
            assets.inFlightGenerations[index] = assets.inFlightGenerations[assets.inFlightGenerationCount];
            break;
        }
    }

    assets.EndAssetLock();
}

const std = @import("std");

const s = @cImport({
    @cInclude("stb_truetype.h");
});

const win32 = @import("win32").everything;

const h = @import("handmade_all.zig");

// imported types -------------------------------------------------------------------------------------------------------------------------------
const platform = @import("platform");
const math = h.math_ns;
const asset_type_id = h.file_formats_ns.asset_type_id;

const assert = std.debug.assert;
const FindLeastSignificantSetBit = h.intrinsics_ns.FindLeastSignificantSetBit;

// constants and types  --------------------------------------------------------------------------------------------------------------------------

const USE_FONTS_FROM_WINDOWS = true;

const ONE_PAST_MAX_FONT_CODEPOINT = (0x10ffff + 1);
const MAX_FONT_WIDTH = 1024;
const MAX_FONT_HEIGHT = 1024;

const global = struct {
    var fontBits: ?*anyopaque = null;
    var fontDeviceContext: ?win32.HDC = null;
};

const loaded_bitmap = struct {
    width: i32 = 0,
    height: i32 = 0,
    pitch: i32 = 0,
    memory: [*]u8 = undefined,

    free: ?[]u8 = null,
};

const loaded_sound = struct {
    /// it is `sampleCount` divided by `8`
    sampleCount: u32 = 0,
    channelCount: u32 = 0,
    samples: [2]?[*]i16 = undefined,

    free: ?[]u8 = null,
};

const loaded_font = struct {
    win32Handle: ?win32.HFONT,
    textMetric: win32.TEXTMETRICW,
    lineAdvance: f32,

    /// `glyphs.len` is `maxGlyphCount`
    glyphs: []h.file_formats_ns.hha_font_glyph,
    horizontalAdvance: []f32,

    minCodePoint: u32,
    maxCodePoint: u32,

    glyphCount: u32,

    onePastHighestCodepoint: u32,
    glyphIndexFromCodePoint: []u32,
};

const asset_type = enum {
    AssetType_Sound,
    AssetType_Bitmap,
    AssetType_Font,
    AssetType_FontGlyph,
};

const asset_source_font = struct {
    font: *loaded_font,
};

const asset_source_font_glyph = struct {
    font: *loaded_font,
    codePoint: u32,
};

const asset_source_sound = struct {
    fileName: [:0]const u8,
    firstSampleIndex: u32,
};

const asset_source_bitmap = struct {
    fileName: [:0]const u8,
};

const asset_source = struct { // TODO (Manav): replace with tagged union.
    t: asset_type,
    data: union {
        bitmap: asset_source_bitmap,
        sound: asset_source_sound,
        font: asset_source_font,
        glyph: asset_source_font_glyph,
    },
};

const VERY_LARGE_NO = 4096;

const entire_file = struct {
    contents: []u8 = undefined,
};

fn ReadEntireFile(file: struct { name: []const u8, absolute: bool = false }, allocator: std.mem.Allocator) !entire_file {
    var result = entire_file{};

    const prefix = if (file.absolute) "" else "../data/";

    const newFileName = try std.mem.concat(allocator, u8, &[_][]const u8{ prefix, file.name });

    const f = try std.fs.cwd().openFile(newFileName, .{ .mode = .read_only });
    defer f.close();

    result.contents = try f.readToEndAlloc(allocator, platform.GigaBytes(8));

    allocator.free(newFileName);

    return result;
}

fn LoadBMP(fileName: []const u8, allocator: std.mem.Allocator) !loaded_bitmap {
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

    var result = loaded_bitmap{};

    const readResult = ReadEntireFile(.{ .name = fileName }, allocator) catch |err| {
        std.log.err("{}\nFilename: {s}", .{ err, fileName });
        return err;
    };

    const header: *bitmap_header = @ptrCast(readResult.contents);
    const pixels = readResult.contents.ptr + header.bitmapOffset;
    result.width = header.width;
    result.height = header.height;
    result.memory = pixels;
    result.free = readResult.contents;

    // std.debug.print("size of bitmap: {}\n", .{header.sizeOfBitmap});

    assert(header.height >= 0);
    assert(header.compression == 3);

    const redMask = header.redMask;
    const greenMask = header.greenMask;
    const blueMask = header.blueMask;
    const alphaMask = ~(redMask | greenMask | blueMask);

    const redScan = FindLeastSignificantSetBit(redMask);
    const greenScan = FindLeastSignificantSetBit(greenMask);
    const blueScan = FindLeastSignificantSetBit(blueMask);
    const alphaScan = FindLeastSignificantSetBit(alphaMask);

    assert(redScan.found);
    assert(greenScan.found);
    assert(blueScan.found);
    assert(alphaScan.found);

    const redShiftDown = @as(u5, @intCast(redScan.index));
    const greenShiftDown = @as(u5, @intCast(greenScan.index));
    const blueShiftDown = @as(u5, @intCast(blueScan.index));
    const alphaShiftDown = @as(u5, @intCast(alphaScan.index));

    const sourceDest = @as([*]align(1) u32, @ptrCast(result.memory));

    var index = @as(u32, 0);
    while (index < @as(u32, @intCast(header.height * header.width))) : (index += 1) {
        const c = sourceDest[index];

        var texel = math.v4{
            @as(f32, @floatFromInt((c & redMask) >> redShiftDown)),
            @as(f32, @floatFromInt((c & greenMask) >> greenShiftDown)),
            @as(f32, @floatFromInt((c & blueMask) >> blueShiftDown)),
            @as(f32, @floatFromInt((c & alphaMask) >> alphaShiftDown)),
        };

        texel = math.SRGB255ToLinear1(texel);

        // if (!ignore)
        {
            // texel.rgb *= texel.a;
            texel = math.ToV4(math.Scale(math.RGB(texel), math.A(texel)), math.A(texel));
        }

        texel = math.Linear1ToSRGB255(texel);

        sourceDest[index] =
            (@as(u32, @intFromFloat((math.A(texel) + 0.5))) << 24 |
                @as(u32, @intFromFloat((math.R(texel) + 0.5))) << 16 |
                @as(u32, @intFromFloat((math.G(texel) + 0.5))) << 8 |
                @as(u32, @intFromFloat((math.B(texel) + 0.5))) << 0);
    }

    result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;

    {
        // result.memory += @as(usize, @intCast(result.pitch * (result.height - 1)));
        // result.pitch = -result.width;
    }

    return result;
}

fn LoadFont(fileName: [:0]const u8, fontName: [:0]const u8, pixelHeight: i32, allocator: std.mem.Allocator) !*loaded_font {
    var font = try allocator.create(loaded_font);

    _ = win32.AddFontResourceExA(
        fileName.ptr,
        win32.FONT_RESOURCE_CHARACTERISTICS.PRIVATE,
        null,
    );

    font.win32Handle = win32.CreateFontA(
        pixelHeight,
        0,
        0,
        0,
        win32.FW_NORMAL,
        win32.FALSE,
        win32.FALSE,
        win32.FALSE,
        win32.DEFAULT_CHARSET,
        win32.OUT_DEFAULT_PRECIS,
        win32.CLIP_DEFAULT_PRECIS,
        win32.ANTIALIASED_QUALITY,
        win32.FF_DONTCARE,
        fontName.ptr,
    );

    _ = win32.SelectObject(global.fontDeviceContext, font.win32Handle);
    _ = win32.GetTextMetricsW(global.fontDeviceContext, &font.textMetric);

    font.minCodePoint = platform.MAXUINT32;
    font.maxCodePoint = 0;

    const maxGlyphCount = 5000;
    font.glyphCount = 0;

    font.glyphIndexFromCodePoint = try allocator.alloc(u32, ONE_PAST_MAX_FONT_CODEPOINT);
    @memset(font.glyphIndexFromCodePoint, 0);

    font.glyphs = try allocator.alloc(h.file_formats_ns.hha_font_glyph, maxGlyphCount);
    font.horizontalAdvance = try allocator.alloc(f32, font.glyphs.len * font.glyphs.len);
    @memset(font.horizontalAdvance, 0);

    // NOTE (Manav): this has to be set to zero otherwise 0xaa will be written which would point to invalid bitmap_ids
    @memset(font.glyphs, h.file_formats_ns.hha_font_glyph{ .bitmapID = .{ .value = 0 }, .unicodeCodePoint = 0 });

    font.onePastHighestCodepoint = 0;

    font.glyphCount = 1; // NOTE: null glyph
    font.glyphs[0].unicodeCodePoint = 0;
    font.glyphs[0].bitmapID.value = 0;

    return font;
}

fn FinalizeFontKerning(font: *loaded_font, allocator: std.mem.Allocator) !void {
    _ = win32.SelectObject(global.fontDeviceContext, font.win32Handle);

    const kerningPairCount = win32.GetKerningPairsW(global.fontDeviceContext, 0, null);
    const kerningPairs = try allocator.alloc(win32.KERNINGPAIR, kerningPairCount);
    defer allocator.free(kerningPairs);

    _ = win32.GetKerningPairsW(global.fontDeviceContext, kerningPairCount, kerningPairs.ptr);
    for (0..kerningPairCount) |kerningPairIndex| {
        const pair: *win32.KERNINGPAIR = &kerningPairs[kerningPairIndex];
        if (pair.wFirst < ONE_PAST_MAX_FONT_CODEPOINT and pair.wSecond < ONE_PAST_MAX_FONT_CODEPOINT) {
            const first = font.glyphIndexFromCodePoint[pair.wFirst];
            const second = font.glyphIndexFromCodePoint[pair.wSecond];

            if (first != 0 and second != 0) {
                font.horizontalAdvance[first * font.glyphs.len + second] += @floatFromInt(pair.iKernAmount);
            }
        }
    }
}

fn FreeFont(font: *loaded_font, allocator: std.mem.Allocator) void {
    _ = win32.DeleteObject(font.win32Handle);
    allocator.free(font.glyphs);
    allocator.free(font.horizontalAdvance);
    allocator.free(font.glyphIndexFromCodePoint);
    allocator.destroy(font);
}

fn InitializeFontDC() void {
    global.fontDeviceContext = win32.CreateCompatibleDC(win32.GetDC(null));

    const info: win32.BITMAPINFO = .{
        .bmiHeader = win32.BITMAPINFOHEADER{
            .biSize = @sizeOf(win32.BITMAPINFOHEADER),
            .biWidth = MAX_FONT_WIDTH,
            .biHeight = MAX_FONT_HEIGHT,
            .biPlanes = 1,
            .biBitCount = 32,
            .biCompression = win32.BI_RGB,
            .biSizeImage = 0,
            .biXPelsPerMeter = 0,
            .biYPelsPerMeter = 0,
            .biClrUsed = 0,
            .biClrImportant = 0,
        },
        .bmiColors = [1]win32.RGBQUAD{.{
            .rgbBlue = 0,
            .rgbGreen = 0,
            .rgbRed = 0,
            .rgbReserved = 0,
        }},
    };

    const bitmap = win32.CreateDIBSection(
        global.fontDeviceContext,
        &info,
        win32.DIB_RGB_COLORS,
        &global.fontBits,
        null,
        0,
    );
    _ = win32.SelectObject(global.fontDeviceContext, bitmap);
    _ = win32.SetBkColor(global.fontDeviceContext, 0x00000000);
}

fn LoadGlyphBitmap(font: *loaded_font, codePoint: u32, asset: *h.file_formats_ns.hha_asset, allocator: std.mem.Allocator) !loaded_bitmap {
    var result = loaded_bitmap{};

    const glyphIndex: u32 = font.glyphIndexFromCodePoint[codePoint];

    if (USE_FONTS_FROM_WINDOWS) {
        _ = win32.SelectObject(global.fontDeviceContext, font.win32Handle);

        const globalFontBits: [*]align(4) u32 = @ptrCast(@alignCast(global.fontBits.?));
        @memset(globalFontBits[0 .. MAX_FONT_WIDTH * MAX_FONT_HEIGHT], 0);

        const cheesePoint = [1:0]u16{@intCast(codePoint)};

        var size: win32.SIZE = undefined;
        _ = win32.GetTextExtentPoint32W(global.fontDeviceContext, cheesePoint[0..], 1, &size);

        const preStepX = 128;

        var boundWidth = size.cx + 2 * preStepX;
        if (boundWidth >= MAX_FONT_WIDTH) {
            boundWidth = MAX_FONT_WIDTH;
        }
        var boundHeight = size.cy;
        if (boundHeight >= MAX_FONT_HEIGHT) {
            boundHeight = MAX_FONT_HEIGHT;
        }

        // _ = win32.PatBlt(static.deviceContext, 0, 0, width, height, win32.BLACKNESS);
        // _ = win32.SetBkMode(static.deviceContext, win32.TRANSPARENT);
        _ = win32.SetTextColor(global.fontDeviceContext, 0x00ffffff); // TODO: Make an RGB macro for this
        _ = win32.TextOutW(global.fontDeviceContext, preStepX, 0, cheesePoint[0..], 1);

        var minX: i32 = 10000;
        var minY: i32 = 10000;
        var maxX: i32 = -10000;
        var maxY: i32 = -10000;

        var row: [*]u32 = globalFontBits + (MAX_FONT_HEIGHT - 1) * MAX_FONT_WIDTH;
        // const baseline = 0;
        for (0..@intCast(boundHeight)) |y| {
            var pixel = row;
            for (0..@intCast(boundWidth)) |x| {
                if (false) {
                    const refPixel = win32.GetPixel(global.fontDeviceContext, @intCast(x), @intCast(y));
                    assert(refPixel == pixel[0]);
                }
                if (pixel[0] != 0) {
                    if (minY > y) {
                        minY = @intCast(y);
                    }
                    if (minX > x) {
                        minX = @intCast(x);
                    }
                    if (maxY < y) {
                        maxY = @intCast(y);
                    }
                    if (maxX < x) {
                        maxX = @intCast(x);
                    }
                }

                pixel += 1;
            }
            row -= MAX_FONT_WIDTH;
        }

        var kerningChange: f32 = 0;

        if (minX <= maxX) {
            const width = (maxX - minX) + 1;
            const height = (maxY - minY) + 1;

            result.width = width + 2;
            result.height = height + 2;
            result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;

            const memory = allocator.alloc(u8, @intCast(result.pitch * result.height)) catch |err| {
                std.log.err("{}\nCodepoint: {}\n", .{ err, codePoint });
                return err;
            };
            result.memory = memory.ptr;
            result.free = memory;

            @memset(result.memory[0..@intCast(result.pitch * result.height)], 0);

            var destRow: [*]u8 = result.memory + @as(usize, @intCast((result.height - 1 - 1) * result.pitch));
            var sourceRow: [*]u32 = globalFontBits + @as(usize, @intCast((MAX_FONT_HEIGHT - 1 - minY) * MAX_FONT_WIDTH));
            var y = minY;
            while (y <= maxY) : (y += 1) {
                var source: [*]u32 = sourceRow + @as(usize, @intCast(minX));
                var dest: [*]align(4) u32 = @ptrCast(@alignCast(destRow));
                dest += 1;

                var x = minX;
                while (x <= maxX) : (x += 1) {

                    // const pixel = win32.GetPixel(global.fontDeviceContext, x, y);
                    // assert(pixel == source[0]);
                    const pixel = source[0];

                    const gray: f32 = @floatFromInt(pixel & 0xff);
                    var texel = math.v4{ 255, 255, 255, gray };

                    texel = math.SRGB255ToLinear1(texel);

                    // texel.rgb *= texel.a;
                    texel = math.ToV4(math.Scale(math.RGB(texel), math.A(texel)), math.A(texel));

                    texel = math.Linear1ToSRGB255(texel);

                    dest[0] =
                        (@as(u32, @intFromFloat((math.A(texel) + 0.5))) << 24 |
                            @as(u32, @intFromFloat((math.R(texel) + 0.5))) << 16 |
                            @as(u32, @intFromFloat((math.G(texel) + 0.5))) << 8 |
                            @as(u32, @intFromFloat((math.B(texel) + 0.5))) << 0);
                    dest += 1;

                    source += 1;
                }

                destRow -= @as(usize, @intCast(result.pitch));
                sourceRow -= MAX_FONT_WIDTH;
            }

            asset.data.bitmap.alignPercentage = [2]f32{
                1.0 / @as(f32, @floatFromInt(result.width)),
                (1.0 + @as(f32, @floatFromInt(maxY - (boundHeight - font.textMetric.tmDescent)))) / @as(f32, @floatFromInt(result.height)),
            };

            kerningChange = @floatFromInt(minX - preStepX);
        } else {
            result.width = 0;
            result.height = 0;
            result.pitch = 0;
            result.free = null;
        }

        var charAdvance: f32 = 0;

        if (false) {
            var thisABC: win32.ABC = .{ .abcA = 0, .abcB = 0, .abcC = 0 };
            _ = win32.GetCharABCWidthsW(global.fontDeviceContext, codePoint, codePoint, &thisABC);
            charAdvance = @as(f32, @floatFromInt(thisABC.abcA)) + @as(f32, @floatFromInt(thisABC.abcB)) + @as(f32, @floatFromInt(thisABC.abcC));
        } else {
            var thisWidth: i32 = 0;
            _ = win32.GetCharWidth32W(global.fontDeviceContext, codePoint, codePoint, &thisWidth);
            charAdvance = @floatFromInt(thisWidth);
        }

        for (0..font.glyphs.len) |otherGlyphIndex| {
            font.horizontalAdvance[glyphIndex * font.glyphs.len + otherGlyphIndex] += charAdvance - kerningChange;
            if (otherGlyphIndex != 0) {
                font.horizontalAdvance[otherGlyphIndex * font.glyphs.len + glyphIndex] += kerningChange;
            }
        }
    } else {
        //     const ttfFile = ReadEntireFile(.{ .name = fileName, .absolute = true }, allocator) catch |err| {
        //         std.log.err("{}\nFilename: {s}\n", .{ err, fileName });
        //         return err;
        //     };

        //     var font = s.stbtt_fontinfo{};
        //     _ = s.stbtt_InitFont(&font, ttfFile.contents.ptr, s.stbtt_GetFontOffsetForIndex(ttfFile.contents.ptr, 0));

        //     var width: i32 = 0;
        //     var height: i32 = 0;
        //     var xOffset: i32 = 0;
        //     var yOffset: i32 = 0;

        //     const monoBitmap: [*]u8 = s.stbtt_GetCodepointBitmap(
        //         &font,
        //         0,
        //         s.stbtt_ScaleForPixelHeight(&font, 128.0),
        //         @intCast(codePoint),
        //         &width,
        //         &height,
        //         &xOffset,
        //         &yOffset,
        //     );

        //     result.width = width;
        //     result.height = height;
        //     result.pitch = result.width * platform.BITMAP_BYTES_PER_PIXEL;

        //     const memory = allocator.alloc(u8, @intCast(result.pitch * height)) catch |err| {
        //         std.log.err("{}\nCodepoint: {c}\n", .{ err, codePoint });
        //         return err;
        //     };
        //     result.memory = memory.ptr;
        //     result.free = memory;

        //     var source: [*]u8 = monoBitmap;
        //     var destRow: [*]u8 = result.memory + @as(usize, @intCast((height - 1) * result.pitch));
        //     for (0..@intCast(height)) |_| {
        //         var dest: [*]u32 = @alignCast(@ptrCast(destRow));
        //         for (0..@intCast(width)) |_| {
        //             const gray: u32 = @intCast(source[0]);
        //             const alpha: u32 = 0xff;

        //             source += 1;

        //             dest[0] = ((alpha << 24) | (gray << 16) | (gray << 8) | (gray << 0));
        //             dest += 1;
        //         }

        //         destRow -= @as(usize, @intCast(result.pitch));
        //     }

        //     s.stbtt_FreeBitmap(monoBitmap, null);

        //     if (ttfFile.free) |buf| allocator.free(buf);
    }

    return result;
}

fn LoadWAV(fileName: []const u8, sectionFirstSampleIndex: u32, sectionSampleCount: u32, allocator: std.mem.Allocator) !loaded_sound {
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
                .big => [4]u8{ d, c, b, a },
                .little => [4]u8{ a, b, c, d },
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

    var result = loaded_sound{};

    const readResult: entire_file = ReadEntireFile(.{ .name = fileName }, allocator) catch |err| {
        std.log.err("{}\nFilename: {s}", .{ err, fileName });
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
                sampleData = @ptrCast(@alignCast(iter.GetChunkData()));
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
            const source: i16 = sampleData.?[2 * sampleIndex];
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

const added_asset = struct {
    id: u32,
    hha: *h.file_formats_ns.hha_asset,
    source: *asset_source,
};

const game_assets = struct {
    tagCount: u32 = 0,
    tags: [VERY_LARGE_NO]h.file_formats_ns.hha_tag = undefined,

    assetTypeCount: u32 = 0,
    assetTypes: [h.file_formats_ns.asset_type_id.count()]h.file_formats_ns.hha_asset_type = undefined,

    assetCount: u32 = 0,
    assetSources: [VERY_LARGE_NO]asset_source = undefined,
    assets: [VERY_LARGE_NO]h.file_formats_ns.hha_asset = undefined,

    DEBUGAssetType: ?*h.file_formats_ns.hha_asset_type = null,
    assetIndex: u32 = 0,

    fn Initialize(self: *game_assets) void {
        self.assetCount = 1;
        self.tagCount = 1;
        self.DEBUGAssetType = null;
        self.assetIndex = 0;

        // NOTE (Manav): Not really needed for us
        self.assetTypeCount = h.file_formats_ns.asset_type_id.count();
        self.assetTypes = [1]h.file_formats_ns.hha_asset_type{.{ .typeID = 0, .firstAssetIndex = 0, .onePastLastAssetIndex = 0 }} ** h.file_formats_ns.asset_type_id.count();
    }

    fn BeginAssetType(self: *game_assets, typeID: h.file_formats_ns.asset_type_id) void {
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

    fn AddAsset(self: *game_assets) added_asset {
        assert(self.DEBUGAssetType != null);
        assert(self.DEBUGAssetType.?.onePastLastAssetIndex < self.assets.len);

        const index = self.DEBUGAssetType.?.onePastLastAssetIndex;
        self.DEBUGAssetType.?.onePastLastAssetIndex += 1;

        const source: *asset_source = &self.assetSources[index];
        const hha: *h.file_formats_ns.hha_asset = &self.assets[index];
        hha.firstTagIndex = self.tagCount;
        hha.onePastLastTagIndex = hha.firstTagIndex;

        self.assetIndex = index;
        return added_asset{
            .id = index,
            .hha = hha,
            .source = source,
        };
    }

    fn AddBitmapAsset(self: *game_assets, fileName: [:0]const u8, alignPercentage: [2]f32) h.file_formats_ns.bitmap_id {
        var asset = self.AddAsset();

        asset.hha.data = .{ .bitmap = h.file_formats_ns.hha_bitmap{
            .dim = .{ 0, 0 },
            .alignPercentage = alignPercentage,
        } };

        asset.source.t = .AssetType_Bitmap;
        asset.source.data = .{ .bitmap = .{
            .fileName = fileName,
        } };

        return h.file_formats_ns.bitmap_id{ .value = asset.id };
    }

    /// Defaults: ```alignPercentage = .{ 0.5, 0.5 }```
    inline fn AddDefaultBitmapAsset(self: *game_assets, fileName: [:0]const u8) h.file_formats_ns.bitmap_id {
        return self.AddBitmapAsset(fileName, .{ 0.5, 0.5 });
    }

    fn AddCharacterAsset(self: *game_assets, font: *loaded_font, codePoint: u32) h.file_formats_ns.bitmap_id {
        var asset = self.AddAsset();

        asset.hha.data = .{ .bitmap = h.file_formats_ns.hha_bitmap{
            .dim = .{ 0, 0 },
            .alignPercentage = .{ 0, 0 },
        } };

        asset.source.t = .AssetType_FontGlyph;
        asset.source.data = .{ .glyph = .{
            .font = font,
            .codePoint = codePoint,
        } };

        const result = h.file_formats_ns.bitmap_id{ .value = asset.id };

        const glyphIndex = font.glyphCount;
        font.glyphCount += 1;

        const glyph = &font.glyphs[glyphIndex];
        glyph.* = .{
            .unicodeCodePoint = codePoint,
            .bitmapID = result,
        };

        font.glyphIndexFromCodePoint[codePoint] = glyphIndex;

        if (font.onePastHighestCodepoint <= codePoint) {
            font.onePastHighestCodepoint = codePoint + 1;
        }

        return result;
    }

    fn AddSoundAsset(self: *game_assets, fileName: [:0]const u8, firstSampleIndex: u32, sampleCount: u32) h.file_formats_ns.sound_id {
        var asset = self.AddAsset();

        asset.hha.data = .{ .sound = h.file_formats_ns.hha_sound{
            .channelCount = 0,
            .sampleCount = sampleCount,
            .chain = .HHASOUNDCHAIN_None,
        } };

        asset.source.t = .AssetType_Sound;
        asset.source.data = .{ .sound = .{
            .fileName = fileName,
            .firstSampleIndex = firstSampleIndex,
        } };

        return h.file_formats_ns.sound_id{ .value = asset.id };
    }

    /// Defaults: ```firstSampleIndex = 0, sampleCount = 0```
    inline fn AddDefaultSoundAsset(self: *game_assets, fileName: [:0]const u8) h.file_formats_ns.sound_id {
        return self.AddSoundAsset(fileName, 0, 0);
    }

    /// Defaults: ```alignPercentage = .{ 0.5, 0.5 }```
    fn AddFontAsset(self: *game_assets, font: *loaded_font) h.file_formats_ns.font_id {
        var asset = self.AddAsset();

        asset.hha.data = .{ .font = .{
            .onePastHighestCodepoint = font.onePastHighestCodepoint,
            .glyphCount = font.glyphCount,
            .ascenderHeight = @floatFromInt(font.textMetric.tmAscent),
            .descenderHeight = @floatFromInt(font.textMetric.tmDescent),
            .externalLeading = @floatFromInt(font.textMetric.tmExternalLeading),
        } };

        std.debug.print("GlyphCount: {}\n", .{font.glyphCount});

        asset.source.t = .AssetType_Font;
        asset.source.data = .{ .font = .{
            .font = font,
        } };

        return h.file_formats_ns.font_id{ .value = asset.id };
    }

    fn AddTag(self: *game_assets, ID: h.file_formats_ns.asset_tag_id, value: f32) void {
        assert(self.assetIndex != 0);

        const hha: *h.file_formats_ns.hha_asset = &self.assets[self.assetIndex];
        hha.onePastLastTagIndex += 1;

        var tag: *h.file_formats_ns.hha_tag = &self.tags[self.tagCount];
        self.tagCount += 1;

        tag.ID = @intFromEnum(ID);
        tag.value = value;
    }
};

fn WriteHHA(assets: *game_assets, filename: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    defer {
        const st = gpa.deinit();
        if (st == .leak) @panic("memory leak");
    }
    const allocator = gpa.allocator();

    const out = try std.fs.cwd().createFile(filename, .{});
    defer out.close();

    {
        var header = h.file_formats_ns.hha_header{
            .magicValue = h.file_formats_ns.HHA_MAGIC_VALUE,
            .version = h.file_formats_ns.HHA_VERSION,
            .tagCount = assets.tagCount,
            .assetCount = assets.assetCount,
            .assetTypeCount = h.file_formats_ns.asset_type_id.count(),
            .tags = @sizeOf(h.file_formats_ns.hha_header),
            .assets = 0,
            .assetTypes = 0,
        };

        const tagArraySize = @sizeOf(h.file_formats_ns.hha_tag) * header.tagCount;
        const assetTypeArraySize = @sizeOf(h.file_formats_ns.hha_asset_type) * header.assetTypeCount;
        const assetArraySize = @sizeOf(h.file_formats_ns.hha_asset) * header.assetCount;

        header.assetTypes = header.tags + tagArraySize;
        header.assets = header.assetTypes + assetTypeArraySize;

        try out.writeAll(std.mem.asBytes(&header));
        try out.writeAll(std.mem.sliceAsBytes(assets.tags[0..header.tagCount]));
        try out.writeAll(std.mem.sliceAsBytes(assets.assetTypes[0..header.assetTypeCount]));
        try out.seekBy(assetArraySize);

        for (1..@as(usize, header.assetCount)) |assetIndex| {
            const source = assets.assetSources[assetIndex];
            var dest: *h.file_formats_ns.hha_asset = &assets.assets[assetIndex];

            dest.dataOffset = try out.getPos();

            switch (source.t) {
                .AssetType_Sound => {
                    const w = try LoadWAV(
                        source.data.sound.fileName,
                        source.data.sound.firstSampleIndex,
                        dest.data.sound.sampleCount,
                        allocator,
                    );
                    defer if (w.free) |buf| allocator.free(buf);

                    dest.data.sound.sampleCount = w.sampleCount;
                    dest.data.sound.channelCount = w.channelCount;

                    for (0..w.channelCount) |channelIndex| {
                        const data: []i16 = w.samples[channelIndex].?[0..dest.data.sound.sampleCount];
                        try out.writeAll(std.mem.sliceAsBytes(data));
                    }
                },
                .AssetType_Font => {
                    const font = source.data.font.font;

                    try FinalizeFontKerning(font, allocator);

                    try out.writeAll(std.mem.sliceAsBytes(font.glyphs[0..font.glyphCount]));
                    var horizontalAdvance: [*]u8 = @ptrCast(font.horizontalAdvance.ptr);
                    for (0..font.glyphCount) |_| {
                        try out.writeAll(horizontalAdvance[0 .. font.glyphCount * @sizeOf(f32)]);
                        horizontalAdvance += font.glyphs.len * @sizeOf(f32);
                    }
                },
                else => {
                    const b = if (source.t == .AssetType_FontGlyph)
                        try LoadGlyphBitmap(
                            source.data.glyph.font,
                            source.data.glyph.codePoint,
                            dest,
                            allocator,
                        )
                    else
                        try LoadBMP(source.data.bitmap.fileName, allocator);

                    defer if (b.free) |buf| allocator.free(buf);

                    dest.data.bitmap.dim = [2]u32{ @intCast(b.width), @intCast(b.height) };

                    platform.Assert(b.pitch == (b.width * 4));

                    if (b.width > 0 and b.height > 0) {
                        const data: []u8 = b.memory[0..@intCast(b.width * b.height * 4)];
                        try out.writeAll(data);
                    }
                },
            }
        }

        try out.seekTo(header.assets);
        try out.writeAll(std.mem.sliceAsBytes(assets.assets[0..header.assetCount]));
    }
}

fn WriteFonts() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = false }){};
    defer {
        const st = gpa.deinit();
        if (st == .leak) @panic("memory leak");
    }

    const allocator = gpa.allocator();

    var assets = game_assets{};
    assets.Initialize();

    const fonts = [_]*loaded_font{
        LoadFont("c:/windows/fonts/arial.ttf", "Arial", 128, allocator) catch |err| {
            std.debug.print("Failed to load debug font, {}\n", .{err});
            return;
        },
        LoadFont("c:/windows/fonts/LiberationMono-Regular.ttf", "Liberation Mono", 20, allocator) catch |err| {
            std.debug.print("Failed to load debug font, {}\n", .{err});
            return;
        },
    };

    assets.BeginAssetType(.Asset_FontGlyph);
    for (fonts) |font| {
        _ = assets.AddCharacterAsset(font, ' ');

        for ('!'..'~' + 1) |character| {
            _ = assets.AddCharacterAsset(font, @intCast(character));
        }

        _ = assets.AddCharacterAsset(font, '小'); // 5c0f - 小
        _ = assets.AddCharacterAsset(font, '耳'); // 8033 - 耳
        _ = assets.AddCharacterAsset(font, '木'); // 6728 - 木
        _ = assets.AddCharacterAsset(font, '兎'); // 514e - 兎

    }
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Font);
    _ = assets.AddFontAsset(fonts[0]);
    _ = assets.AddTag(.Tag_FontType, @floatFromInt(@as(u32, @intFromEnum(h.file_formats_ns.asset_font_type.FontType_Default))));
    _ = assets.AddFontAsset(fonts[1]);
    _ = assets.AddTag(.Tag_FontType, @floatFromInt(@as(u32, @intFromEnum(h.file_formats_ns.asset_font_type.FontType_Debug))));

    assets.EndAssetType();

    WriteHHA(&assets, "testfonts.hha") catch |err| {
        std.debug.print("{}\n", .{err});
        return;
    };
}

fn WriteHero() void {
    var assets = game_assets{};
    assets.Initialize();

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

    WriteHHA(&assets, "test1.hha") catch |err| {
        std.debug.print("{}\n", .{err});
        return;
    };
}

fn WriteNonHero() void {
    var assets = game_assets{};
    assets.Initialize();

    assets.BeginAssetType(.Asset_Test_Bitmap);
    _ = assets.AddBitmapAsset("structured_art.bmp", .{ 0, 0 });
    assets.EndAssetType();

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
    _ = assets.AddDefaultBitmapAsset("test2/grass00.bmp");
    _ = assets.AddDefaultBitmapAsset("test2/grass01.bmp");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Tuft);
    _ = assets.AddDefaultBitmapAsset("test2/tuft00.bmp");
    _ = assets.AddDefaultBitmapAsset("test2/tuft01.bmp");
    _ = assets.AddDefaultBitmapAsset("test2/tuft02.bmp");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Stone);
    _ = assets.AddDefaultBitmapAsset("test2/ground00.bmp");
    _ = assets.AddDefaultBitmapAsset("test2/ground01.bmp");
    _ = assets.AddDefaultBitmapAsset("test2/ground02.bmp");
    _ = assets.AddDefaultBitmapAsset("test2/ground03.bmp");
    assets.EndAssetType();

    WriteHHA(&assets, "test2.hha") catch |err| {
        std.debug.print("{}\n", .{err});
        return;
    };
}

fn WriteSounds() void {
    var assets = game_assets{};
    assets.Initialize();

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
    var firstSampleIndex: u32 = 0;
    while (firstSampleIndex < totalMusicSampleCount) : (firstSampleIndex += oneMusicChunk) {
        var sampleCount = totalMusicSampleCount - firstSampleIndex;
        if (sampleCount > oneMusicChunk) {
            sampleCount = oneMusicChunk;
        }
        const thisMusic = assets.AddSoundAsset("test3/music_test.wav", firstSampleIndex, sampleCount);
        if ((firstSampleIndex + oneMusicChunk) < totalMusicSampleCount) {
            assets.assets[thisMusic.value].data.sound.chain = .HHASOUNDCHAIN_Advance;
        }
    }
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_Puhp);
    _ = assets.AddDefaultSoundAsset("test3/puhp_00.wav");
    _ = assets.AddDefaultSoundAsset("test3/puhp_01.wav");
    assets.EndAssetType();

    assets.BeginAssetType(.Asset_test_stereo);
    _ = assets.AddDefaultSoundAsset("wave_stereo_test_1sec.wav");
    assets.EndAssetType();

    WriteHHA(&assets, "test3.hha") catch |err| {
        std.debug.print("{}\n", .{err});
        return;
    };
}

pub fn main() void {
    InitializeFontDC();

    WriteFonts();
    WriteNonHero();
    WriteHero();
    WriteSounds();
}

const native_endian = @import("builtin").target.cpu.arch.endian();

pub fn HHA_CODE(comptime a: u8, comptime b: u8, comptime c: u8, comptime d: u8) u32 {
    comptime {
        return @bitCast(switch (native_endian) {
            .Big => [4]u8{ d, c, b, a },
            .Little => [4]u8{ a, b, c, d },
        });
    }
}

pub const HHA_MAGIC_VALUE = HHA_CODE('h', 'h', 'a', 'f');
pub const HHA_VERSION = 0;

pub const bitmap_id = extern struct {
    value: u32 align(1) = 0,

    pub inline fn IsValid(self: bitmap_id) bool {
        const result = self.value != 0;
        return result;
    }
};

pub const sound_id = extern struct {
    value: u32 align(1) = 0,

    pub inline fn IsValid(self: sound_id) bool {
        const result = self.value != 0;
        return result;
    }
};

pub const hha_header = extern struct {
    /// `HHA_MAGIC_VALUE`
    magicValue: u32 align(1),
    /// `HHA_VERSION`
    version: u32 align(1),

    tagCount: u32 align(1),
    assetTypeCount: u32 align(1),
    assetCount: u32 align(1),

    /// stores `[tagCount]hha_tag`
    tags: u64 align(1),
    /// stores `[assetTypeEntryCount]hha_asset_type`
    assetTypes: u64 align(1),
    /// stores `[assetCount]hha_asset`
    assets: u64 align(1),

    // fileGUID: [8]u32,
    // removalCount: u32,
    // hha_asset_removal = struct {
    //     fileGUID: [8]u32,
    //     assetIndex: u32
    // };
};

pub const hha_tag = extern struct {
    ID: u32 align(1),
    value: f32 align(1),
};

pub const hha_asset_type = extern struct {
    typeID: u32 align(1),
    firstAssetIndex: u32 align(1),
    onePastLastAssetIndex: u32 align(1),
};

pub const hha_sound_chain = enum(u32) {
    HHASOUNDCHAIN_None,
    HHASOUNDCHAIN_Loop,
    HHASOUNDCHAIN_Advance,
};

pub const hha_bitmap = extern struct {
    dim: [2]u32 align(1),
    alignPercentage: [2]f32 align(1),
};

pub const hha_sound = extern struct {
    sampleCount: u32 align(1),
    channelCount: u32 align(1),
    chain: hha_sound_chain align(1),
};

pub const hha_asset = extern struct {
    dataOffset: u64 align(1),
    firstTagIndex: u32 align(1),
    onePastLastTagIndex: u32 align(1),
    data: extern union {
        bitmap: hha_bitmap align(1),
        sound: hha_sound align(1),
    } align(1),
};

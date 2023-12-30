pub const asset_type_id = enum(u32) {
    Asset_NONE = 0,

    //
    // Bitmaps
    //

    Asset_Test_Bitmap,

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

    pub fn count() comptime_int {
        comptime {
            return @typeInfo(asset_type_id).Enum.fields.len;
        }
    }
};

pub const asset_tag_id = enum {
    Tag_Smoothness,
    Tag_Flatness,
    Tag_FacingDirection,

    pub fn len() comptime_int {
        comptime {
            return @typeInfo(asset_type_id).Enum.fields.len;
        }
    }
};

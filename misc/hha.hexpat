// hha file pattern for imhex

enum tag_id: u32 {
    Tag_Smoothness,
    Tag_Flatness,
    Tag_FacingDirection,
};

struct hha_tag {
    tag_id ID;
    u32 value;
};

enum type_id: u32 {
    Asset_NONE,

    Asset_Test_Bitmap,

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

};

struct hha_asset_type {
    type_id typeID;
    u32 firstAssetIndex;
    u32 onePastAssetIndex;
};

struct asset_id {
    u32 value;
};

struct hha_bitmap {
    u32 dim[2];
    float alignPercentage[2];
};

struct hha_sound {
    u32 sampleCount;
    u32 channelCount;
    asset_id nextIDToPlay;
};

union hha_data {
    hha_bitmap bitmap;
    hha_sound sound;
};

struct hha_asset {
    u8* dataOffset[4]: u64;
    u32 firstTagIndex;
    u32 onePastLastTagIndex;
    hha_data data;
};

struct hha_header {
    u32 magicValue;
    u32 version;
    u32 tagCount;
    u32 assetTypeCount;
    u32 assetCount;
    
    hha_tag* tags[tagCount] : u64;
    hha_asset_type* assetTypes[assetTypeCount] : u64;
    hha_asset* assets[assetCount] : u64;
};

hha_header header @ 0x00;
// hha file pattern for imhex

#include <std/io.pat>

enum type_id: u32 {
    Asset_NONE,

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

    Asset_Font,
    Asset_FontGlyph,

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

enum tag_id: u32 {
    Tag_Smoothness,
    Tag_Flatness,
    Tag_FacingDirection,
};

namespace hha {
    struct tag {
        tag_id ID;
        u32 value;
    };
    
    struct asset_type {
        type_id typeID;
        u32 firstAssetIndex;
        u32 onePastAssetIndex;
    };
    
    struct asset_id {
        u32 value;
    };
    
    struct bitmap {
        u32 dim[2];
        float alignPercentage[2];
    };
    
    struct sound {
        u32 sampleCount;
        u32 channelCount;
        asset_id chain;
    };

    struct font {
        u32 onePastHighestCodepoint;
        u32 glyphCount;
        float descenderHeight;
        float ascenderHeight;
        float externalLeadin;
    };

    struct font_glyph {
        char16 unicodeCodePoint;
        u16 [[hidden]]; 
        asset_id bitmapID;
    };

    union type {
        bitmap bitmap;
        sound sound;
        font font;
    };
    
    struct asset {
        u64 dataOffset;
        u32 firstTagIndex;
        u32 onePastLastTagIndex;
        type t;
    };
    
    struct header {
        u32 magicValue;
        u32 version;
        u32 tagCount;
        u32 assetTypeCount;
        u32 assetCount;
        
        tag* tags[tagCount] : u64;
        asset_type* assetTypes[assetTypeCount] : u64;
        asset* assets[assetCount] : u64;
    };
}

namespace vis {
    // Visualizer from custom plugin, inside ./misc/enhanced_bitmap_visualizer.hexplug
    struct bitmap_data<auto width, auto height> {
        u32 data[width * height];
    } [[hex::visualize("custom_bitmap", data, width, height, 0x03020104)]]; // BGRA
        
    struct sound_data<auto channels, auto samples> {
        u32 sample_rate = 48000;    // fixed sample rate
        u16 data[channels * samples];
    } [[hex::visualize("sound", data, channels, sample_rate)]];

    struct font_data<auto glyphCount> {
        hha::font_glyph codePoints[glyphCount];
        float horizontalAdvance[glyphCount * glyphCount];
    };
    
    fn print_assets() {
        hha::header header @ 0x00;
        
        for (u32 i = 0, i < header.assetTypeCount, i = i + 1) {
            hha::asset_type type = header.assetTypes[i];
            match (type.typeID) {
                (type_id::Asset_NONE) : {
                    //
                }
                (type_id::Asset_Test_Bitmap ... type_id::Asset_Torso) : {
                    for(u32 ai = type.firstAssetIndex, ai < type.onePastAssetIndex, ai = ai + 1) {
                        u32 width = header.assets[ai].t.bitmap.dim[0];
                        u32 height = header.assets[ai].t.bitmap.dim[1];
                        
                        // print all bitmaps to be copied later
                        std::print("vis::bitmap_data<{}, {}> bmp{} @ header.assets[{}].dataOffset;", width, height, ai, ai);
                    }
                }
                (type_id::Asset_FontGlyph) : {
                    u32 index = 0;
                    for(u32 ai = type.firstAssetIndex, ai < type.onePastAssetIndex, ai = ai + 1) {
                        u32 width = header.assets[ai].t.bitmap.dim[0];
                        u32 height = header.assets[ai].t.bitmap.dim[1];
                        
                        // print all bitmaps to be copied later
                        std::print("vis::bitmap_data<{}, {}> fnt_g{} @ header.assets[{}].dataOffset;", width, height, index, ai);
                        index = index + 1;
                    }
                }
                (type_id::Asset_Font) : {
                    u32 index = 0;
                    for(u32 ai = type.firstAssetIndex, ai < type.onePastAssetIndex, ai = ai + 1) {
                        u32 glyphCount = header.assets[ai].t.font.glyphCount;

                        // print all bitmaps to be copied later
                        std::print("vis::font_data<{}> fnt{} @ header.assets[{}].dataOffset;", glyphCount, index, ai);
                        index = index + 1;
                    }
                }
                (type_id::Asset_Bloop ... type_id::Asset_test_stereo) : {
                    for(u32 ai = type.firstAssetIndex, ai < type.onePastAssetIndex, ai = ai + 1) {
                        u32 channels = header.assets[ai].t.sound.channelCount;
                        u32 samples = header.assets[ai].t.sound.sampleCount;
        
                        // print all sounds to be copied later
                        std::print("vis::sound_data<{}, {}> snd{} @ header.assets[{}].dataOffset;", channels, samples, ai, ai);
                    }
                }
            }
        }
    };
}

vis::print_assets();

hha::header header @ 0x00;

// copy the printed outputs here:
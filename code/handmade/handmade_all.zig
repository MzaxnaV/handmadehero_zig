pub const Asset = @import("handmade_asset.zig");
pub const Audio = @import("handmade_audio.zig");
pub const Data = @import("handmade_data.zig");
pub const DebugVars = @import("handmade_debug_variables.zig");
pub const Entity = @import("handmade_entity.zig");
pub const FileFormats = @import("handmade_file_formats.zig");
pub const Intrinsics = @import("handmade_intrinsics.zig");
pub const Math = @import("handmade_math.zig");
pub const Random = @import("handmade_random.zig");
pub const RenderGroup = @import("handmade_render_group.zig");
pub const SimRegion = @import("handmade_sim_region.zig");
pub const World = @import("handmade_world.zig");

// convenience re-exports

pub const v2 = Math.v2;
pub const v3 = Math.v3;
pub const v4 = Math.v4;
pub const rect2 = Math.rect2;
pub const rect3 = Math.rect3;

pub const V2 = Math.V2;
pub const V3 = Math.V3;
pub const ToV3 = Math.ToV3;
pub const ToV4 = Math.ToV4;

pub const Add = Math.Add;
pub const AddTo = Math.AddTo;
pub const Sub = Math.Sub;
pub const SubFrom = Math.SubFrom;
pub const Scale = Math.Scale;
pub const Clampf01 = Math.Clampf01;

pub const X = Math.X;
pub const Y = Math.Y;
pub const Z = Math.Z;
pub const W = Math.W;

pub const XY = Math.XY;
pub const XYZ = Math.XYZ;

pub const SetX = Math.SetX;
pub const SetY = Math.SetY;

pub const R = Math.R;
pub const G = Math.G;
pub const B = Math.B;
pub const A = Math.A;

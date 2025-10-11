pub const asset_ns = @import("handmade_asset.zig");
pub const audio_ns = @import("handmade_audio.zig");
pub const data_ns = @import("handmade_data.zig");
pub const debug_variables_ns = @import("handmade_debug_variables.zig");
pub const entity_ns = @import("handmade_entity.zig");
pub const file_formats_ns = @import("handmade_file_formats.zig");
pub const intrinsics_ns = @import("handmade_intrinsics.zig");
pub const math_ns = @import("handmade_math.zig");
pub const random_ns = @import("handmade_random.zig");
pub const render_group_ns = @import("handmade_render_group.zig");
pub const sim_region_ns = @import("handmade_sim_region.zig");
pub const world_ns = @import("handmade_world.zig");

pub const v2 = math_ns.v2;
pub const v3 = math_ns.v3;
pub const v4 = math_ns.v4;
pub const rect2 = math_ns.rect2;
pub const rect3 = math_ns.rect3;

pub const V2 = math_ns.V2;
pub const V3 = math_ns.V3;
pub const ToV3 = math_ns.ToV3;
pub const ToV4 = math_ns.ToV4;

pub const Sin = intrinsics_ns.Sin;
pub const Cos = intrinsics_ns.Cos;
pub const Atan2 = intrinsics_ns.Atan2;

pub const Add = math_ns.Add;
pub const AddTo = math_ns.AddTo;
pub const Sub = math_ns.Sub;
pub const SubFrom = math_ns.SubFrom;
pub const Scale = math_ns.Scale;
pub const Clampf01 = math_ns.Clampf01;

pub const X = math_ns.X;
pub const Y = math_ns.Y;
pub const Z = math_ns.Z;
pub const W = math_ns.W;

pub const XY = math_ns.XY;
pub const XYZ = math_ns.XYZ;

pub const SetX = math_ns.SetX;
pub const SetY = math_ns.SetY;

pub const R = math_ns.R;
pub const G = math_ns.G;
pub const B = math_ns.B;
pub const A = math_ns.A;

// pub const handmade = blk: {
//     const modules = .{
//         .{ "intrinsics", @import("intrinsics") },
//         .{ "audio", @import("handmade_audio.zig") },
//         .{ "asset", @import("handmade_asset.zig") },
//         .{ "data", @import("handmade_data.zig") },
//         .{ "entity", @import("handmade_entity.zig") },
//         .{ "file_formats", @import("handmade_file_formats.zig") },
//         .{ "math", @import("handmade_math.zig") },
//         .{ "random", @import("handmade_random.zig") },
//         .{ "render_group", @import("handmade_render_group.zig") },
//         .{ "sim_region", @import("handmade_sim_region.zig") },
//         .{ "world", @import("handmade_world.zig") },
//     };

//     var result = struct {};
//     for (modules) |mod| {
//         const decls = @typeInfo(mod[1]).Struct.decls;
//         for (decls) |decl| {
//             if (decl.is_pub) {
//                 @field(result, decl.name) = @field(mod[1], decl.name);
//             }
//         }
//     }
//     break :blk result;
// };

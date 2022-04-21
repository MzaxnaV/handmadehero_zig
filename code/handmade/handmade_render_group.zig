const std = @import("std");
const assert = std.debug.assert;

const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const render_basis = struct {
    p: hm.v3 = hm.v3{ 0, 0, 0 },
};

pub const entity_visible_piece = struct {
    basis: *render_basis,
    bitmap: ?*hi.loaded_bitmap,
    offset: hm.v2 = hm.v2{ 0, 0 },
    offsetZ: f32 = 0,
    entityZC: f32 = 0,

    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,
    a: f32 = 0,

    dim: hm.v2 = hm.v2{ 0, 0 },
};

pub const render_group = struct {
    defaultBasis: *render_basis,
    metersToPixels: f32,
    pieceCount: u32,

    pushBufferSize: u32,
    maxPushBufferSize: u32,
    pushBufferBase: [*]u8,
};

// functions ------------------------------------------------------------------------------------------------------------------------------

pub fn PushRenderElements(group: *render_group, size: u32) [*]u8 {
    var result: [*]u8 = undefined;

    if ((group.pushBufferSize + size) < group.maxPushBufferSize) {
        result = group.pushBufferBase + group.pushBufferSize;
        group.pushBufferSize += size;
    } else {
        unreachable;
    }

    return result;
}

// zig fmt: off
pub fn PushPiece(group: *render_group, bitmap: ?*hi.loaded_bitmap, offset: hm.v2, offsetZ: f32, alignment: hm.v2, 
                        dim: hm.v2, colour: hm.v4, entityZC: f32) void 
// zig fmt: on
{
    const piece = @ptrCast(*entity_visible_piece, @alignCast(@alignOf(entity_visible_piece), PushRenderElements(group, @sizeOf(entity_visible_piece))));
    piece.basis = group.defaultBasis;
    piece.bitmap = bitmap;
    piece.offset = (hm.V2(group.metersToPixels, group.metersToPixels) * hm.v2{ offset[0], -offset[1] }) - alignment;
    piece.offsetZ = offsetZ;
    piece.entityZC = entityZC;
    piece.r = hm.R(colour);
    piece.g = hm.G(colour);
    piece.b = hm.B(colour);
    piece.a = hm.A(colour);
    piece.dim = dim;
}

// zig fmt: off
pub fn PushBitmap(group: *render_group, bitmap: *hi.loaded_bitmap, offset: hm.v2, offsetZ: f32, alignment: hm.v2,
                         alpha: f32, entityZC: f32) void 
// zig fmt: on
{
    // NOTE (Manav): alpha > 1 mess up our rendering, as cAlpha will make rSA > 1 and invRSA negative
    assert(alpha <= 1);
    PushPiece(group, bitmap, offset, offsetZ, alignment, .{ 0, 0 }, .{ 1, 1, 1, alpha }, entityZC);
}

pub inline fn PushRect(group: *render_group, offset: hm.v2, offsetZ: f32, dim: hm.v2, colour: hm.v4, entityZC: f32) void {
    PushPiece(group, null, offset, offsetZ, .{ 0, 0 }, dim, colour, entityZC);
}

pub inline fn PushRectOutline(group: *render_group, offset: hm.v2, offsetZ: f32, dim: hm.v2, colour: hm.v4, entityZC: f32) void {
    const thickness = 0.1;

    PushPiece(group, null, offset - hm.v2{ 0, 0.5 * hm.Y(dim) }, offsetZ, .{ 0, 0 }, .{ hm.X(dim), thickness }, colour, entityZC);
    PushPiece(group, null, offset + hm.v2{ 0, 0.5 * hm.Y(dim) }, offsetZ, .{ 0, 0 }, .{ hm.X(dim), thickness }, colour, entityZC);

    PushPiece(group, null, offset - hm.v2{ 0.5 * hm.X(dim), 0 }, offsetZ, .{ 0, 0 }, .{ thickness, hm.Y(dim) }, colour, entityZC);
    PushPiece(group, null, offset + hm.v2{ 0.5 * hm.X(dim), 0 }, offsetZ, .{ 0, 0 }, .{ thickness, hm.Y(dim) }, colour, entityZC);
}

pub fn AllocateRenderGroup(arena: *hi.memory_arena, maxPushBufferSize: u32, metersToPixels: f32) *render_group {
    var result: *render_group = arena.PushStruct(render_group);
    result.pushBufferBase = arena.PushSize(@alignOf(u8), maxPushBufferSize);
    result.defaultBasis = arena.PushStruct(render_basis);
    result.defaultBasis.p = .{ 0, 0, 0 };
    result.metersToPixels = metersToPixels;
    result.pieceCount = 0;

    result.pushBufferSize = 0;
    result.maxPushBufferSize = maxPushBufferSize;

    return result;
}

const std = @import("std");
const assert = std.debug.assert;

const platform = @import("handmade_platform");

const hi = @import("handmade_internals.zig");
const hm = @import("handmade_math.zig");
const hintrinsics = @import("handmade_intrinsics.zig");

const Round = hintrinsics.RoundF32ToInt;
const Floor = hintrinsics.FloorF32ToI32;
const Ceil = hintrinsics.CeilF32ToI32;

// game data types ------------------------------------------------------------------------------------------------------------------------

pub const render_basis = struct {
    p: hm.v3 = hm.v3{ 0, 0, 0 },
};

pub const render_entity_basis = struct {
    basis: *render_basis,
    offset: hm.v2 = hm.v2{ 0, 0 },

    offsetZ: f32 = 0,
    entityZC: f32 = 0,
};

pub const render_group_entry_type = enum {
    Clear,
    Bitmap,
    Rectangle,
    CoordinateSystem,

    pub fn Type(self: render_group_entry_type) type {
        return switch (self) {
            .Clear => render_entry_clear,
            .Bitmap => render_entry_bitmap,
            .Rectangle => render_entry_rectangle,
            .CoordinateSystem => render_entry_coordinate_system,
        };
    }
};

pub const render_group_entry_header = struct {
    entryType: render_group_entry_type,
};

pub const render_entry_clear = struct {
    header: render_group_entry_header,
    // NOTE (Manav): Vectors in zig have 16 byte alignment so use arrays here for safety
    colour: [4]f32,
};

pub const render_entry_coordinate_system = struct {
    header: render_group_entry_header,
    // NOTE (Manav): Vectors in zig have 16 byte alignment so use arrays here for safety
    origin: [2]f32,
    xAxis: [2]f32,
    yAxis: [2]f32,
    colour: [4]f32,

    points: [16]hm.v2,
};

pub const render_entry_bitmap = struct {
    header: render_group_entry_header,
    entityBasis: render_entity_basis,
    bitmap: *hi.loaded_bitmap,
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const render_entry_rectangle = struct {
    header: render_group_entry_header,
    entityBasis: render_entity_basis,

    r: f32,
    g: f32,
    b: f32,
    a: f32,

    // NOTE (Manav): Vectors in zig have 16 byte alignment so use arrays here for safety
    dim: [2]f32,
};

pub const render_group = struct {
    defaultBasis: *render_basis,
    metersToPixels: f32,

    pushBufferSize: u32,
    maxPushBufferSize: u32,
    pushBufferBase: [*]u8,
};

// functions ------------------------------------------------------------------------------------------------------------------------------

pub fn DrawRectangleOutline(buffer: *hi.loaded_bitmap, vMin: hm.v2, vMax: hm.v2, colour: hm.v3, r: f32) void {
    DrawRectangle(buffer, .{ hm.X(vMin) - r, hm.Y(vMin) - r }, .{ hm.X(vMax) + r, hm.Y(vMin) + r }, hm.R(colour), hm.G(colour), hm.B(colour), 1);
    DrawRectangle(buffer, .{ hm.X(vMin) - r, hm.Y(vMax) - r }, .{ hm.X(vMax) + r, hm.Y(vMax) + r }, hm.R(colour), hm.G(colour), hm.B(colour), 1);

    DrawRectangle(buffer, .{ hm.X(vMin) - r, hm.Y(vMin) - r }, .{ hm.X(vMin) + r, hm.Y(vMax) + r }, hm.R(colour), hm.G(colour), hm.B(colour), 1);
    DrawRectangle(buffer, .{ hm.X(vMax) - r, hm.Y(vMin) - r }, .{ hm.X(vMax) + r, hm.Y(vMax) + r }, hm.R(colour), hm.G(colour), hm.B(colour), 1);
}

pub fn DrawRectangle(buffer: *hi.loaded_bitmap, vMin: hm.v2, vMax: hm.v2, r: f32, g: f32, b: f32, a: f32) void {
    var minX = Round(i32, vMin[0]);
    var minY = Round(i32, vMin[1]);
    var maxX = Round(i32, vMax[0]);
    var maxY = Round(i32, vMax[1]);

    if (minX < 0) {
        minX = 0;
    }

    if (minY < 0) {
        minY = 0;
    }

    if (maxX > buffer.width) {
        maxX = buffer.width;
    }

    if (maxY > buffer.height) {
        maxY = buffer.height;
    }

    // zig fmt: off
    const colour: u32 = (Round(u32, a * 255.0) << 24) | 
                        (Round(u32, r * 255.0) << 16) | 
                        (Round(u32, g * 255.0) << 8) | 
                        (Round(u32, b * 255) << 0);
    // zig fmt: on

    var row = @ptrCast([*]u8, buffer.memory) + @intCast(u32, minX) * platform.BITMAP_BYTES_PER_PIXEL + @intCast(u32, minY * buffer.pitch);

    var y = minY;
    while (y < maxY) : (y += 1) {
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        var x = minX;
        while (x < maxX) : (x += 1) {
            pixel.* = colour;
            pixel += 1;
        }
        row += @intCast(u32, buffer.pitch);
    }
}

pub fn DrawRectangleSlowly(buffer: *hi.loaded_bitmap, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, colour: hm.v4) void {
    // zig fmt: off
    const colour32: u32 = (Round(u32, hm.A(colour) * 255.0) << 24) | 
                          (Round(u32, hm.R(colour) * 255.0) << 16) | 
                          (Round(u32, hm.G(colour) * 255.0) << 8) | 
                          (Round(u32, hm.B(colour) * 255) << 0);
    // zig fmt: on

    const widthMax = buffer.width - 1;
    const heightMax = buffer.height - 1;

    var xMin = widthMax;
    var xMax = @as(i32, 0);

    var yMin = heightMax;
    var yMax = @as(i32, 0);

    const points: [4]hm.v2 = .{ origin, origin + xAxis, origin + xAxis + yAxis, origin + yAxis };

    for (points) |p| {
        const floorX = Floor(hm.X(p));
        const ceilX = Ceil(hm.X(p));
        const floorY = Floor(hm.Y(p));
        const ceilY = Ceil(hm.Y(p));

        if (xMin > floorX) xMin = floorX;
        if (yMin > floorY) yMin = floorY;
        if (xMax < ceilX) xMax = ceilX;
        if (yMax < ceilY) yMax = ceilY;
    }

    if (xMin < 0) xMin = 0;
    if (yMin < 0) yMin = 0;
    if (xMax > widthMax) xMax = widthMax;
    if (yMax > heightMax) yMax = heightMax;

    var row = @ptrCast([*]u8, buffer.memory) + @intCast(u32, xMin) * platform.BITMAP_BYTES_PER_PIXEL + @intCast(u32, yMin * buffer.pitch);

    var y = yMin;
    while (y <= yMax) : (y += 1) {
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        var x = xMin;
        while (x <= xMax) : (x += 1) {
            const pixelP = hm.V2(x, y);

            const edge0 = hm.Inner(pixelP - origin, -hm.Perp(xAxis));
            const edge1 = hm.Inner(pixelP - (origin + xAxis), -hm.Perp(yAxis));
            const edge2 = hm.Inner(pixelP - (origin + xAxis + yAxis), hm.Perp(xAxis));
            const edge3 = hm.Inner(pixelP - (origin + yAxis), hm.Perp(yAxis));

            if (edge0 < 0 and edge1 < 0 and edge2 < 0 and edge3 < 0) {
                pixel.* = colour32;
            }
            pixel += 1;
        }
        row += @intCast(u32, buffer.pitch);
    }
}

pub fn DrawBitmap(buffer: *hi.loaded_bitmap, bitmap: *const hi.loaded_bitmap, realX: f32, realY: f32, cAlpha: f32) void {
    var minX = Round(i32, realX);
    var minY = Round(i32, realY);
    var maxX = minX + bitmap.width;
    var maxY = minY + bitmap.height;

    var sourceOffesetX = @as(i32, 0);
    if (minX < 0) {
        sourceOffesetX = -minX;
        minX = 0;
    }

    var sourceOffesetY = @as(i32, 0);
    if (minY < 0) {
        sourceOffesetY = -minY;
        minY = 0;
    }

    if (maxX > buffer.width) {
        maxX = buffer.width;
    }

    if (maxY > buffer.height) {
        maxY = buffer.height;
    }

    const offset = sourceOffesetY * bitmap.pitch + platform.BITMAP_BYTES_PER_PIXEL * sourceOffesetX;

    var sourceRow = if (offset > 0) bitmap.memory + @intCast(usize, offset) else bitmap.memory - @intCast(usize, -offset);
    var destRow = buffer.memory + @intCast(usize, minX * platform.BITMAP_BYTES_PER_PIXEL + minY * buffer.pitch);

    var y = minY;
    while (y < maxY) : (y += 1) {
        const dest = @ptrCast([*]u32, @alignCast(@alignOf(u32), destRow));
        const source = @ptrCast([*]align(1) u32, sourceRow);
        var x = minX;
        while (x < maxX) : (x += 1) {
            const index = @intCast(u32, x - minX);

            const sA = cAlpha * @intToFloat(f32, ((source[index] >> 24) & 0xff));
            const rSA = (sA / 255.0) * cAlpha;
            const sR = cAlpha * @intToFloat(f32, ((source[index] >> 16) & 0xff));
            const sG = cAlpha * @intToFloat(f32, ((source[index] >> 8) & 0xff));
            const sB = cAlpha * @intToFloat(f32, ((source[index] >> 0) & 0xff));

            const dA = @intToFloat(f32, ((dest[index] >> 24) & 0xff));
            const dR = @intToFloat(f32, ((dest[index] >> 16) & 0xff));
            const dG = @intToFloat(f32, ((dest[index] >> 8) & 0xff));
            const dB = @intToFloat(f32, ((dest[index] >> 0) & 0xff));
            const rDA = (dA / 255.0);

            const invRSA = 1 - rSA;
            const a = (rSA + rDA - rSA * rDA) * 255.0;
            const r = invRSA * dR + sR;
            const g = invRSA * dG + sG;
            const b = invRSA * dB + sB;

            dest[index] = (@floatToInt(u32, a + 0.5) << 24) |
                (@floatToInt(u32, r + 0.5) << 16) |
                (@floatToInt(u32, g + 0.5) << 8) |
                (@floatToInt(u32, b + 0.5) << 0);
        }

        destRow += @intCast(usize, buffer.pitch);
        sourceRow = if (bitmap.pitch > 0) sourceRow + @intCast(usize, bitmap.pitch) else sourceRow - @intCast(usize, -bitmap.pitch);
    }
}

pub fn DrawMatte(buffer: *hi.loaded_bitmap, bitmap: *const hi.loaded_bitmap, realX: f32, realY: f32, cAlpha: f32) void {
    var minX = Round(i32, realX);
    var minY = Round(i32, realY);
    var maxX = minX + bitmap.width;
    var maxY = minY + bitmap.height;

    var sourceOffesetX = @as(i32, 0);
    if (minX < 0) {
        sourceOffesetX = -minX;
        minX = 0;
    }

    var sourceOffesetY = @as(i32, 0);
    if (minY < 0) {
        sourceOffesetY = -minY;
        minY = 0;
    }

    if (maxX > buffer.width) {
        maxX = buffer.width;
    }

    if (maxY > buffer.height) {
        maxY = buffer.height;
    }

    const offset = sourceOffesetY * bitmap.pitch + platform.BITMAP_BYTES_PER_PIXEL * sourceOffesetX;

    var sourceRow = if (offset > 0) bitmap.memory + @intCast(usize, offset) else bitmap.memory - @intCast(usize, -offset);
    var destRow = buffer.memory + @intCast(usize, minX * platform.BITMAP_BYTES_PER_PIXEL + minY * buffer.pitch);

    var y = minY;
    while (y < maxY) : (y += 1) {
        const dest = @ptrCast([*]u32, @alignCast(@alignOf(u32), destRow));
        const source = @ptrCast([*]align(1) u32, sourceRow);
        var x = minX;
        while (x < maxX) : (x += 1) {
            const index = @intCast(u32, x - minX);

            const sA = cAlpha * @intToFloat(f32, ((source[index] >> 24) & 0xff));
            const rSA = (sA / 255.0) * cAlpha;
            // const sR = cAlpha * @intToFloat(f32, ((source[index] >> 16) & 0xff));
            // const sG = cAlpha * @intToFloat(f32, ((source[index] >> 8) & 0xff));
            // const sB = cAlpha * @intToFloat(f32, ((source[index] >> 0) & 0xff));

            const dA = @intToFloat(f32, ((dest[index] >> 24) & 0xff));
            const dR = @intToFloat(f32, ((dest[index] >> 16) & 0xff));
            const dG = @intToFloat(f32, ((dest[index] >> 8) & 0xff));
            const dB = @intToFloat(f32, ((dest[index] >> 0) & 0xff));
            // const rDA = (dA / 255.0);

            const invRSA = 1 - rSA;
            const a = invRSA * dA;
            const r = invRSA * dR;
            const g = invRSA * dG;
            const b = invRSA * dB;

            dest[index] = (@floatToInt(u32, a + 0.5) << 24) |
                (@floatToInt(u32, r + 0.5) << 16) |
                (@floatToInt(u32, g + 0.5) << 8) |
                (@floatToInt(u32, b + 0.5) << 0);
        }

        destRow += @intCast(usize, buffer.pitch);
        sourceRow = if (bitmap.pitch > 0) sourceRow + @intCast(usize, bitmap.pitch) else sourceRow - @intCast(usize, -bitmap.pitch);
    }
}

inline fn GetRenderEntityBasisP(group: *render_group, entityBasis: *render_entity_basis, screenCenter: hm.v2) hm.v2 {
    const entityBaseP = entityBasis.basis.p;
    const zFudge = 1 + 0.1 * (hm.Z(entityBaseP) + entityBasis.offsetZ);

    const entityGroundPointX = hm.X(screenCenter) + group.metersToPixels * zFudge * hm.X(entityBaseP);
    const entityGroundPointY = hm.Y(screenCenter) - group.metersToPixels * zFudge * hm.Y(entityBaseP);
    const entityz = -group.metersToPixels * hm.Z(entityBaseP);

    const center = hm.v2{
        entityGroundPointX + entityBasis.offset[0],
        entityGroundPointY + entityBasis.offset[1] + entityBasis.entityZC * entityz,
    };

    return center;
}

pub fn PushRenderElements(group: *render_group, comptime t: render_group_entry_type) ?*align(@alignOf(u8)) t.Type() {
    const element_type = t.Type();
    const element_ptr_type = ?*align(@alignOf(u8)) element_type;

    var result: element_ptr_type = null;

    const size = @sizeOf(element_type);
    if ((group.pushBufferSize + size) < group.maxPushBufferSize) {
        result = @ptrCast(element_ptr_type, group.pushBufferBase + group.pushBufferSize);
        result.?.header.entryType = t;
        group.pushBufferSize += size;
    } else {
        unreachable;
    }

    return result;
}

// zig fmt: off
pub fn PushPiece(group: *render_group, bitmap: *hi.loaded_bitmap, offset: hm.v2, offsetZ: f32, alignment: hm.v2, 
                        _: hm.v2, colour: hm.v4, entityZC: f32) void 
// zig fmt: on
{
    if (PushRenderElements(group, .Bitmap)) |piece| {
        piece.entityBasis.basis = group.defaultBasis;
        piece.bitmap = bitmap;
        piece.entityBasis.offset = (hm.V2(group.metersToPixels, group.metersToPixels) * hm.v2{ offset[0], -offset[1] }) - alignment;
        piece.entityBasis.offsetZ = offsetZ;
        piece.entityBasis.entityZC = entityZC;
        piece.r = hm.R(colour);
        piece.g = hm.G(colour);
        piece.b = hm.B(colour);
        piece.a = hm.A(colour);
    }
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
    const halfDim = dim * @splat(2, 0.5 * group.metersToPixels);

    if (PushRenderElements(group, .Rectangle)) |piece| {
        piece.entityBasis.basis = group.defaultBasis;
        piece.entityBasis.offset = (hm.V2(group.metersToPixels, group.metersToPixels) * hm.v2{ offset[0], -offset[1] }) - halfDim;
        piece.entityBasis.offsetZ = offsetZ;
        piece.entityBasis.entityZC = entityZC;
        piece.r = hm.R(colour);
        piece.g = hm.G(colour);
        piece.b = hm.B(colour);
        piece.a = hm.A(colour);
        piece.dim = @splat(2, group.metersToPixels) * dim;
    }
}

pub inline fn PushRectOutline(group: *render_group, offset: hm.v2, offsetZ: f32, dim: hm.v2, colour: hm.v4, entityZC: f32) void {
    const thickness = 0.1;

    PushRect(group, offset - hm.v2{ 0, 0.5 * hm.Y(dim) }, offsetZ, .{ hm.X(dim), thickness }, colour, entityZC);
    PushRect(group, offset + hm.v2{ 0, 0.5 * hm.Y(dim) }, offsetZ, .{ hm.X(dim), thickness }, colour, entityZC);

    PushRect(group, offset - hm.v2{ 0.5 * hm.X(dim), 0 }, offsetZ, .{ thickness, hm.Y(dim) }, colour, entityZC);
    PushRect(group, offset + hm.v2{ 0.5 * hm.X(dim), 0 }, offsetZ, .{ thickness, hm.Y(dim) }, colour, entityZC);
}

pub inline fn Clear(group: *render_group, colour: hm.v4) void {
    if (PushRenderElements(group, .Clear)) |entry| {
        entry.colour = colour;
    }
}

pub fn CoordinateSystem(group: *render_group, origin: hm.v2, xAxis: hm.v2, yAxis: hm.v2, colour: hm.v4) *align(1) render_entry_coordinate_system {
    const entryElement = PushRenderElements(group, .CoordinateSystem);
    if (entryElement) |entry| {
        entry.origin = origin;
        entry.xAxis = xAxis;
        entry.yAxis = yAxis;
        entry.colour = colour;
    }

    return entryElement.?;
}

pub fn AllocateRenderGroup(arena: *hi.memory_arena, maxPushBufferSize: u32, metersToPixels: f32) *render_group {
    var result: *render_group = arena.PushStruct(render_group);
    result.pushBufferBase = arena.PushSize(@alignOf(u8), maxPushBufferSize);
    result.defaultBasis = arena.PushStruct(render_basis);
    result.defaultBasis.p = .{ 0, 0, 0 };
    result.metersToPixels = metersToPixels;

    result.pushBufferSize = 0;
    result.maxPushBufferSize = maxPushBufferSize;

    return result;
}

pub fn RenderGroupToOutput(renderGroup: *render_group, outputTarget: *hi.loaded_bitmap) void {
    const screenCenter = hm.v2{
        0.5 * @intToFloat(f32, outputTarget.width),
        0.5 * @intToFloat(f32, outputTarget.height),
    };

    var baseAddress = @as(u32, 0);
    while (baseAddress < renderGroup.pushBufferSize) {
        const header: *render_group_entry_header = @ptrCast(*render_group_entry_header, @alignCast(@alignOf(render_group_entry_header), renderGroup.pushBufferBase + baseAddress));

        switch (header.entryType) {
            .Clear => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_clear, header);
                const colour: hm.v4 = entry.colour;
                baseAddress += @sizeOf(@TypeOf(entry.*));
                DrawRectangle(
                    outputTarget,
                    .{ 0, 0 },
                    .{ @intToFloat(f32, outputTarget.width), @intToFloat(f32, outputTarget.height) },
                    hm.R(colour),
                    hm.G(colour),
                    hm.B(colour),
                    hm.A(colour),
                );
            },
            .Bitmap => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_bitmap, header);
                const p = GetRenderEntityBasisP(renderGroup, &entry.entityBasis, screenCenter);
                DrawBitmap(outputTarget, entry.bitmap, hm.X(p), hm.Y(p), entry.a);

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },
            .Rectangle => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_rectangle, header);
                const p = GetRenderEntityBasisP(renderGroup, &entry.entityBasis, screenCenter);
                const dim: hm.v2 = entry.dim;
                DrawRectangle(outputTarget, p, p + dim, entry.r, entry.g, entry.b, 1);

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },

            .CoordinateSystem => {
                const entry = @ptrCast(*align(@alignOf(u8)) render_entry_coordinate_system, header); // zig fmt: off
                const origin: hm.v2 = entry.origin;
                const xAxis: hm.v2 = entry.xAxis;
                const yAxis: hm.v2 = entry.yAxis;
                var colour: hm.v4 = entry.colour;

                const vMax: hm.v2 = (origin + xAxis + yAxis);
                DrawRectangleSlowly(outputTarget, origin, xAxis, yAxis, colour);

                colour = .{ 1, 1, 0, 1 };
                var p = origin;
                const dim = hm.v2{ 2, 2 };
                DrawRectangle(outputTarget, p - dim, p + dim, colour[0], colour[1], colour[2], colour[3]);

                p = origin + xAxis;
                DrawRectangle(outputTarget, p - dim, p + dim, colour[0], colour[1], colour[2], colour[3]);

                p = origin + yAxis;
                DrawRectangle(outputTarget, p - dim, p + dim, colour[0], colour[1], colour[2], colour[3]);

                DrawRectangle(outputTarget, vMax - dim, vMax + dim, colour[0], colour[1], colour[2], colour[3]);

                // for (entry.points) |point| {
                //     p = point;
                //     p = origin + @splat(2, hm.X(p)) * xAxis + @splat(2, hm.Y(p)) * yAxis;
                //     DrawRectangle(outputTarget, p - dim, p + dim, entry.colour[0], entry.colour[1], entry.colour[2], entry.colour[3]);
                // }

                baseAddress += @sizeOf(@TypeOf(entry.*));
            },
        }
    }
}

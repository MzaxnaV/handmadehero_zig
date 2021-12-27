pub const offscreen_buffer = struct {
    memory: ?*anyopaque, 
    width: i32, 
    height: i32, 
    pitch: usize 
};

fn RenderWeirdGradient(buffer: *offscreen_buffer, xOffset: i32, yOffset: i32) void {
    var row = @ptrCast([*]u8, buffer.memory);

    var y: u32 = 0;
    while (y < buffer.height) : (y += 1) {
        var x: u32 = 0;
        var pixel = @ptrCast([*]u32, @alignCast(@alignOf(u32), row));
        while (x < buffer.width) : (x += 1) {
            // Pixel in memory: BB GG RR xx
            // Little endian arch: 0x xxRRGGBB
            var blue = x + @intCast(u32, xOffset);
            var green = y + @intCast(u32, yOffset);

            pixel.* = (green << 8) | blue;
            pixel += 1;
        }
        row += buffer.pitch;
    }
}

pub fn UpdateAndRender(buffer: *offscreen_buffer, blueOffset: i32, greenOffset: i32) void {
    RenderWeirdGradient(buffer, blueOffset, greenOffset);
}
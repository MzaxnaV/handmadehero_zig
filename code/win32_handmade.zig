const std = @import("std");
const WINAPI = std.os.windows.WINAPI;

const win32 = struct {
    usingnamespace @import("win32").graphics.gdi;
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").system.memory;
    usingnamespace @import("win32").ui.windows_and_messaging;
    usingnamespace @import("win32").zig;
};

// TODO: these are globals for now
var running: bool = undefined;

var bitmapInfo: win32.BITMAPINFO = undefined;
var bitmapMemory: ?*c_void = undefined;
var bitmapWidth: i32 = 0;
var bitmapHeight: i32 = 0;
var bytesPerPixel: u8 = 4;

fn RenderWeirdGradient(xOffset: i32, yOffset: i32) void {
    // var width = bitmapWidth;
    // var height = bitmapHeight;

    var pitch = @intCast(usize, bitmapWidth * bytesPerPixel);
    var row = @ptrCast([*]u8, bitmapMemory);
    var y: u32 = 0;

    while (y < bitmapHeight) {
        var x: u32 = 0;
        var pixel = @ptrCast([*]u32, @alignCast(4, row));
        while (x < bitmapWidth) {
            // Pixel in memory: BB GG RR xx
            // Little endian arch: 0x xxRRGGBB
            var blue = x + @intCast(u32, xOffset);
            var green = y + @intCast(u32, yOffset);

            var color = (green << 8) | blue;

            pixel.* = color;
            pixel += 1;
            x += 1;
        }
        row += pitch;
        y += 1;
    }
}

fn Win32ResizeDIBSection(width: i32, height: i32) void {
    // TODO: Bullet proof this.
    // Maybe don't free	first, free after, then free first if that failes.

    if (bitmapMemory != null) {
        _ = win32.VirtualFree(bitmapMemory, 0, win32.MEM_RELEASE);
    }

    bitmapWidth = width;
    bitmapHeight = height;

    bitmapInfo = win32.BITMAPINFO{ .bmiHeader = win32.BITMAPINFOHEADER{
        .biSize = @sizeOf(win32.BITMAPINFOHEADER),
        .biWidth = bitmapWidth,
        .biHeight = bitmapHeight,
        .biPlanes = 1,
        .biBitCount = 32,
        .biCompression = win32.BI_RGB,
        .biSizeImage = 0,
        .biXPelsPerMeter = 0,
        .biYPelsPerMeter = 0,
        .biClrUsed = 0,
        .biClrImportant = 0,
    }, .bmiColors = [1]win32.RGBQUAD{win32.RGBQUAD{
        .rgbBlue = 0,
        .rgbGreen = 0,
        .rgbRed = 0,
        .rgbReserved = 0,
    }} };

    const bitmapMemorySize = @intCast(usize, bytesPerPixel * (width * height));
    bitmapMemory = win32.VirtualAlloc(null, bitmapMemorySize, win32.MEM_COMMIT, win32.PAGE_READWRITE);

    // TODO: probably clear this to black
}

fn Win32UpdateWindow(deviceContext: win32.HDC, clientRect: *win32.RECT, x: i32, y: i32, width: i32, height: i32) void {
    _ = x;
    _ = y;
    _ = width;
    _ = height;

    var windowWidth = clientRect.right - clientRect.left;
    var windowHeight = clientRect.bottom - clientRect.top;

    _ = win32.StretchDIBits(
        deviceContext,
        0,
        0,
        bitmapWidth,
        bitmapHeight,
        0,
        0,
        windowWidth,
        windowHeight,
        bitmapMemory,
        &bitmapInfo,
        win32.DIB_RGB_COLORS,
        win32.SRCCOPY,
    );
}

fn WindowProc(windowHandle: win32.HWND, message: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    var result: win32.LRESULT = 0;

    switch (message) {
        win32.WM_SIZE => {
            var clientRect = win32.RECT{ .left = 0, .right = 0, .top = 0, .bottom = 0 };
            _ = win32.GetClientRect(windowHandle, &clientRect);
            var height = clientRect.bottom - clientRect.top;
            var width = clientRect.right - clientRect.left;
            Win32ResizeDIBSection(width, height);
        },

        win32.WM_DESTROY => running = false, // TODO: handle this as an error = recreate window?

        win32.WM_CLOSE => running = false, // TODO: handle this with a message to a user?

        win32.WM_ACTIVATEAPP => win32.OutputDebugStringA("WM_ACTIVATEAPP\n"),

        win32.WM_PAINT => {
            var paint: win32.PAINTSTRUCT = undefined;
            var deviceContext = win32.BeginPaint(windowHandle, &paint);
            var x = paint.rcPaint.left;
            var y = paint.rcPaint.top;
            var height = paint.rcPaint.bottom - paint.rcPaint.top;
            var width = paint.rcPaint.right - paint.rcPaint.left;

            var clientRect: win32.RECT = undefined;
            _ = win32.GetClientRect(windowHandle, &clientRect);
            if (deviceContext) |context| {
                Win32UpdateWindow(context, &clientRect, x, y, width, height);
            }
            _ = win32.EndPaint(windowHandle, &paint);
        },

        else => result = win32.DefWindowProc(windowHandle, message, wParam, lParam),
    }

    return result;
}

pub export fn wWinMain(hInstance: ?win32.HINSTANCE, _: ?win32.HINSTANCE, _: [*:0]u16, _: u32) callconv(WINAPI) c_int {
    const windowclass = win32.WNDCLASS{
        .style = @intToEnum(win32.WNDCLASS_STYLES, 0),
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = win32.L("HandmadeHeroWindowClass"),
    };

    if (win32.RegisterClass(&windowclass) != 0) {
        if (win32.CreateWindowEx(@intToEnum(win32.WINDOW_EX_STYLE, 0), windowclass.lpszClassName, win32.L("HandmadeHero"), @intToEnum(win32.WINDOW_STYLE, @enumToInt(win32.WS_OVERLAPPEDWINDOW) | @enumToInt(win32.WS_VISIBLE)), win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, hInstance, null)) |windowHandle| {
            var xOffset: i32 = 0;
            var yOffset: i32 = 0;

            running = true;
            while (running) {
                var message: win32.MSG = undefined;
                while (win32.PeekMessage(&message, null, 0, 0, win32.PM_REMOVE) != 0) {
                    if (message.message == win32.WM_QUIT) {
                        running = false;
                    }
                    _ = win32.TranslateMessage(&message);
                    _ = win32.DispatchMessage(&message);
                }

                RenderWeirdGradient(xOffset, yOffset);

                if (win32.GetDC(windowHandle)) |deviceContext| {
                    var clientRect: win32.RECT = undefined;
                    _ = win32.GetClientRect(windowHandle, &clientRect);

                    var windowWidth = clientRect.right - clientRect.left;
                    var windowHeight = clientRect.bottom - clientRect.top;

                    Win32UpdateWindow(deviceContext, &clientRect, 0, 0, windowWidth, windowHeight);
                    _ = win32.ReleaseDC(windowHandle, deviceContext);
                    xOffset += 1;
                }
            }
        } else {
            // TODO: LOGGING
        }
    } else {
        // TODO: LOGGING
    }

    return 0;
}

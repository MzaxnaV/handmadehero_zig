const std = @import("std");
const WINAPI = std.os.windows.WINAPI;

const win32 = struct {
    usingnamespace @import("win32").graphics.gdi;
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").ui.windows_and_messaging;
    usingnamespace @import("win32").zig;
};

// TODO: these are globals for now
var running: bool = undefined;

var bitmapInfo: win32.BITMAPINFO = undefined;
var bitmapMemory: ?*c_void = undefined;
var bitmapHandle: ?win32.HBITMAP = undefined;
var bitmapDeviceContext: ?win32.HDC = undefined;

fn ResizeDIBSection(width: i32, height: i32) void {
    // TODO: Bullet proof this.
    // Maybe don't free	first, free after, then free first if that failes.

    // TODO: Free out dibsection

    if (bitmapHandle != null) {
        _ = win32.DeleteObject(bitmapHandle);
    }

    if (bitmapDeviceContext == null) {
        //TODO: Should we recreate these under special circumstances
        bitmapDeviceContext = win32.CreateCompatibleDC(null);
    }

    bitmapInfo = win32.BITMAPINFO{ .bmiHeader = win32.BITMAPINFOHEADER{
        .biSize = @sizeOf(win32.BITMAPINFOHEADER),
        .biWidth = width,
        .biHeight = height,
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

    bitmapHandle = win32.CreateDIBSection(
        bitmapDeviceContext,
        &bitmapInfo,
        win32.DIB_RGB_COLORS,
        &bitmapMemory,
        null,
        0,
    );
}

fn UpdateWindow(deviceContext: win32.HDC, x: i32, y: i32, width: i32, height: i32) void {
    win32.StretchDIBits(
        deviceContext,
        x,
        y,
        width,
        height,
        x,
        y,
        width,
        height,
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
            ResizeDIBSection(width, height);
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
            _ = win32.PatBlt(deviceContext, x, y, width, height, win32.WHITENESS);
            _ = win32.EndPaint(windowHandle, &paint);
        },
        else => result = win32.DefWindowProc(windowHandle, message, wParam, lParam),
    }

    return result;
}

pub export fn wWinMain(hInstance: ?win32.HINSTANCE, _: ?win32.HINSTANCE, _: [*:0]u16, _: u32) callconv(WINAPI) c_int {
    const windowClass = win32.WNDCLASS{
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

    if (win32.RegisterClass(&windowClass) != 0) {
        const windowHandle = win32.CreateWindowEx(@intToEnum(win32.WINDOW_EX_STYLE, 0), windowClass.lpszClassName, win32.L("HandmadeHero"), @intToEnum(win32.WINDOW_STYLE, @enumToInt(win32.WS_OVERLAPPEDWINDOW) | @enumToInt(win32.WS_VISIBLE)), win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, hInstance, null);

        if (windowHandle != null) {
            running = true;
            var message: win32.MSG = undefined;
            while (running) {
                var messageResult = win32.GetMessage(&message, null, 0, 0);
                if (messageResult > 0) {
                    _ = win32.TranslateMessage(&message);
                    _ = win32.DispatchMessage(&message);
                } else {
                    break;
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

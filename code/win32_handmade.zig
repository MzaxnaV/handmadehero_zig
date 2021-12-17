const std = @import("std");
const WINAPI = std.os.windows.WINAPI;

const win32 = struct {
    usingnamespace @import("win32").graphics.gdi;
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").ui.windows_and_messaging;
    usingnamespace @import("win32").zig;
};

fn WindowProc(windowHandle: win32.HWND, message: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    var result: win32.LRESULT = 0;

    switch (message) {
        win32.WM_SIZE => win32.OutputDebugStringA("WM_SIZE\n"),
        win32.WM_DESTROY => win32.OutputDebugStringA("WM_DESTROY\n"),
        win32.WM_CLOSE => win32.OutputDebugStringA("WM_CLOSE\n"),
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
            var message: win32.MSG = undefined;
            while (true) {
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

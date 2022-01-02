const std = @import("std");

const WINAPI = std.os.windows.WINAPI;
const DWORD = std.os.windows.DWORD;

const win32 = struct {
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").graphics.gdi;
    usingnamespace @import("win32").media;
    usingnamespace @import("win32").media.audio;
    usingnamespace @import("win32").media.audio.direct_sound;
    usingnamespace @import("win32").storage.file_system;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").system.com;
    usingnamespace @import("win32").system.library_loader;
    usingnamespace @import("win32").system.memory;
    usingnamespace @import("win32").system.performance;
    usingnamespace @import("win32").system.threading;
    usingnamespace @import("win32").ui.input.keyboard_and_mouse;
    usingnamespace @import("win32").ui.input.xbox_controller;
    usingnamespace @import("win32").ui.windows_and_messaging;
    // usingnamespace @import("win32").ui.shell;

    usingnamespace @import("win32").zig;

    pub extern "SHLWAPI" fn wnsprintfW(
        pszDest: [*:0]u16,
        cchDest: i32,
        pszFmt: ?[*:0]const u16,
        ...,
    ) callconv(@import("std").os.windows.WINAPI) i32;
};

const game = @import("handmade.zig");

// constants ------------------------------------------------------------------------------------------------------------------------------

const IGNORE = @import("build_consts").IGNORE;
const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

const allocationType = @intToEnum(win32.VIRTUAL_ALLOCATION_TYPE, @enumToInt(win32.MEM_RESERVE) | @enumToInt(win32.MEM_COMMIT));

// data types -----------------------------------------------------------------------------------------------------------------------------

const win32_offscreen_buffer = struct {
    info: win32.BITMAPINFO,
    memory: ?*anyopaque,
    width: i32 = 0,
    height: i32 = 0,
    pitch: usize = 0,
};

const win32_window_dimension = struct {
    width: i32 = 0,
    height: i32 = 0,
};

const win32_sound_output = struct {
    samplesPerSecond: u32,
    runningSampleIndex: u32,
    bytesPerSample: u32,
    secondaryBufferSize: u32,
    tSine: f32,
    latencySampleCount: u32,
};

// globals --------------------------------------------------------------------------------------------------------------------------------

pub var globalRunning: bool = undefined;
pub var globalBackBuffer = win32_offscreen_buffer{
    .info = win32.BITMAPINFO{
        .bmiHeader = win32.BITMAPINFOHEADER{
            .biSize = @sizeOf(win32.BITMAPINFOHEADER),
            .biWidth = 0,
            .biHeight = 0,
            .biPlanes = 0,
            .biBitCount = 0,
            .biCompression = 0,
            .biSizeImage = 0,
            .biXPelsPerMeter = 0,
            .biYPelsPerMeter = 0,
            .biClrUsed = 0,
            .biClrImportant = 0,
        },
        .bmiColors = [1]win32.RGBQUAD{win32.RGBQUAD{
            .rgbBlue = 0,
            .rgbGreen = 0,
            .rgbRed = 0,
            .rgbReserved = 0,
        }},
    },
    .memory = undefined,
};
pub var globalSecondaryBuffer: *win32.IDirectSoundBuffer = undefined;
pub var globalPerfCounterFrequency: i64 = undefined;

const win32Platform = game.platform{
    .DEBUGPlatformFreeFileMemory = DEBUGWin32FreeFileMemory,
    .DEBUGPlatformReadEntireFile = DEBUGWin32ReadEntireFile,
    .DEBUGPlatformWriteEntireFile = DEBUGWin32WriteEntireFile,
};

// library defs ---------------------------------------------------------------------------------------------------------------------------

var XInputGetState: fn (u32, ?*win32.XINPUT_STATE) callconv(WINAPI) isize = undefined;
var XInputSetState: fn (u32, ?*win32.XINPUT_VIBRATION) callconv(WINAPI) isize = undefined;

// local Win32 functions ------------------------------------------------------------------------------------------------------------------

fn DEBUGWin32FreeFileMemory(memory: *anyopaque) void {
    _ = win32.VirtualFree(memory, 0, win32.MEM_RELEASE);
}

fn DEBUGWin32ReadEntireFile(filename: [*:0]const u8) game.debug_read_file_result {
    var result = game.debug_read_file_result{};
    var fileHandle = win32.CreateFileA(filename, win32.FILE_GENERIC_READ, win32.FILE_SHARE_READ, null, win32.OPEN_EXISTING, win32.SECURITY_ANONYMOUS, null);

    if (fileHandle != null and fileHandle != win32.INVALID_HANDLE_VALUE) {
        var fileSize = win32.LARGE_INTEGER{ .QuadPart = 0 };
        if (win32.GetFileSizeEx(fileHandle, &fileSize) != 0) {
            var fileSize32 = if (fileSize.QuadPart < 0xFFFFFFFF) @intCast(u32, fileSize.QuadPart) else unreachable;
            if (win32.VirtualAlloc(null, fileSize32, allocationType, win32.PAGE_READWRITE)) |data| {
                var bytesRead: DWORD = 0;
                if (win32.ReadFile(fileHandle, data, fileSize32, &bytesRead, null) != 0 and fileSize32 == bytesRead) {
                    result.contents = data;
                    result.contentSize = fileSize32;
                } else {
                    DEBUGWin32FreeFileMemory(data);
                }
            } else {
                // TODO: Logging
            }
        } else {
            // TODO: logging
        }
        _ = win32.CloseHandle(fileHandle);
    } else {
        // TODO: logging
    }

    return result;
}

fn DEBUGWin32WriteEntireFile(fileName: [*:0]const u8, memorySize: u32, memory: *anyopaque) bool {
    var result = false;
    var fileHandle = win32.CreateFileA(fileName, win32.FILE_GENERIC_WRITE, win32.FILE_SHARE_MODE.NONE, null, win32.CREATE_ALWAYS, win32.SECURITY_ANONYMOUS, null);

    if (fileHandle != null and fileHandle != win32.INVALID_HANDLE_VALUE) {
        var bytesWritten: DWORD = 0;
        if (win32.WriteFile(fileHandle, memory, memorySize, &bytesWritten, null) != 0) {
            // File written successfully
            result = (bytesWritten == memorySize);
        } else {
            // TODO: logging
        }

        _ = win32.CloseHandle(fileHandle);
    } else {
        // TODO: logging
    }

    return result;
}

fn Win32LoadXinput() void {
    if (win32.LoadLibraryW(win32.L("xinput1_4.dll"))) |XInputLibrary| {
        // NO TYPESAFETY TO WARN YOU, BEWARE :D
        if (win32.GetProcAddress(XInputLibrary, "XInputGetState")) |funcptr| {
            XInputGetState = @ptrCast(@TypeOf(XInputGetState), funcptr);
        } else {
            const state = struct {
                fn XInputGetStateInternal(_: u32, _: ?*win32.XINPUT_STATE) callconv(WINAPI) isize {
                    return @enumToInt(win32.ERROR_DEVICE_NOT_CONNECTED);
                }
            };
            XInputGetState = state.XInputGetStateInternal;
        }

        if (win32.GetProcAddress(XInputLibrary, "XInputSetState")) |funcptr| {
            XInputSetState = @ptrCast(@TypeOf(XInputSetState), funcptr);
        } else {
            const state = struct {
                fn XInputSetStateInternal(_: u32, _: ?*win32.XINPUT_VIBRATION) callconv(WINAPI) isize {
                    return @enumToInt(win32.ERROR_DEVICE_NOT_CONNECTED);
                }
            };
            XInputSetState = state.XInputSetStateInternal;
        }

        // TODO: diagnostic
    } else {
        // TODO: diagnostic
    }
}

fn Win32InitDSound(window: win32.HWND, samplesPerSecond: u32, bufferSize: u32) void {
    var DirectSoundCreate: fn (?*const win32.Guid, ?*?*win32.IDirectSound, ?*win32.IUnknown) callconv(WINAPI) i32 = undefined;
    if (win32.LoadLibraryW(win32.L("dsound.dll"))) |DSoundLibrary| {
        if (win32.GetProcAddress(DSoundLibrary, "DirectSoundCreate")) |funcptr| {
            DirectSoundCreate = @ptrCast(@TypeOf(DirectSoundCreate), funcptr);

            var dS: ?*win32.IDirectSound = undefined;
            if (win32.SUCCEEDED(DirectSoundCreate(null, &dS, null))) {
                if (dS) |directSound| {
                    var waveFormat = win32.WAVEFORMATEX{
                        .wFormatTag = win32.WAVE_FORMAT_PCM,
                        .nChannels = 2,
                        .nSamplesPerSec = samplesPerSecond,
                        .nAvgBytesPerSec = undefined,
                        .nBlockAlign = undefined,
                        .wBitsPerSample = 16,
                        .cbSize = 0,
                    };
                    waveFormat.nBlockAlign = (waveFormat.nChannels * waveFormat.wBitsPerSample) / 8;
                    waveFormat.nAvgBytesPerSec = waveFormat.nSamplesPerSec * waveFormat.nBlockAlign;

                    const GUID_NULL = win32.Guid.initString("00000000-0000-0000-0000-000000000000");
                    if (win32.SUCCEEDED(directSound.vtable.SetCooperativeLevel(directSound, window, win32.DSSCL_PRIORITY))) {
                        // https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ee416820(v=vs.85)#remarks
                        var bufferDescription = win32.DSBUFFERDESC{
                            .dwSize = @sizeOf(win32.DSBUFFERDESC),
                            .dwFlags = win32.DSBCAPS_PRIMARYBUFFER,
                            .dwBufferBytes = 0,
                            .dwReserved = 0,
                            .lpwfxFormat = null,
                            .guid3DAlgorithm = GUID_NULL,
                        };

                        var pB: ?*win32.IDirectSoundBuffer = undefined;
                        if (win32.SUCCEEDED(directSound.vtable.CreateSoundBuffer(directSound, &bufferDescription, &pB, null))) {
                            if (pB) |primaryBuffer| {
                                if (win32.SUCCEEDED(primaryBuffer.vtable.SetFormat(primaryBuffer, &waveFormat))) {
                                    // we have finally set the format
                                    win32.OutputDebugStringW(win32.L("Primary buffer format was set\n"));
                                } else {
                                    // TODO: diagnostic
                                }
                            }
                        } else {
                            // TODO: diagnostic
                        }
                    } else {
                        // TODO: diagnostic
                    }

                    // DSBCAPS_GETCURRENTPOSITION2?
                    var bufferDescription = win32.DSBUFFERDESC{
                        .dwSize = @sizeOf(win32.DSBUFFERDESC),
                        .dwFlags = 0,
                        .dwBufferBytes = bufferSize,
                        .dwReserved = 0,
                        .lpwfxFormat = &waveFormat,
                        .guid3DAlgorithm = GUID_NULL,
                    };

                    // Create a secondary buffer
                    var secondaryBuffer: ?*win32.IDirectSoundBuffer = undefined;
                    if (win32.SUCCEEDED(directSound.vtable.CreateSoundBuffer(directSound, &bufferDescription, &secondaryBuffer, null))) {
                        if (secondaryBuffer) |value| {
                            globalSecondaryBuffer = value;
                            win32.OutputDebugStringW(win32.L("Secondary buffer created successfully\n"));
                        }
                    } else {
                        // TODO: diagnostic
                    }
                }
            } else {

                // TODO: diagnostic
            }
        }
    } else {
        // TODO: diagnostic
    }
}

fn Win32GetWindowDimenstion(windowHandle: win32.HWND) win32_window_dimension {
    var result = win32_window_dimension{};

    var clientRect: win32.RECT = undefined;
    _ = win32.GetClientRect(windowHandle, &clientRect);
    result.height = clientRect.bottom - clientRect.top;
    result.width = clientRect.right - clientRect.left;

    return result;
}

fn Win32ResizeDIBSection(buffer: *win32_offscreen_buffer, width: i32, height: i32) void {
    // TODO: Bullet proof this.
    // Maybe don't free	first, free after, then free first if that failes.

    if (buffer.memory != null) {
        _ = win32.VirtualFree(buffer.memory, 0, win32.MEM_RELEASE);
    }

    buffer.width = width;
    buffer.height = height;
    const bytesPerPixel = 4;

    // NOTE: When the biHeight field is neative, this is clue to windows to treat bitmap
    // as top-down, not bottom-up, meaning that the first three byte of the image are the
    // colour for the top left pixel in the bitmap, not the bottom left

    buffer.info.bmiHeader.biSize = @sizeOf(win32.BITMAPINFOHEADER);
    buffer.info.bmiHeader.biWidth = buffer.width;
    buffer.info.bmiHeader.biHeight = buffer.height;
    buffer.info.bmiHeader.biPlanes = 1;
    buffer.info.bmiHeader.biBitCount = 32;
    buffer.info.bmiHeader.biCompression = win32.BI_RGB;

    const bitmapMemorySize = @intCast(usize, bytesPerPixel * (buffer.width * buffer.height));
    buffer.memory = win32.VirtualAlloc(null, bitmapMemorySize, @intToEnum(win32.VIRTUAL_ALLOCATION_TYPE, @enumToInt(win32.MEM_RESERVE) | @enumToInt(win32.MEM_COMMIT)), win32.PAGE_READWRITE);
    buffer.pitch = @intCast(usize, width) * bytesPerPixel;

    // TODO: probably clear this to black
}

fn Win32DisplayBufferInWindow(buffer: *win32_offscreen_buffer, deviceContext: win32.HDC, windowWidth: i32, windowHeight: i32) void {
    // TODO: Aespect Ratio correction
    // TODO: Play with Stretch modes
    _ = win32.StretchDIBits(deviceContext, 0, 0, windowWidth, windowHeight, 0, 0, buffer.width, buffer.height, buffer.memory, &buffer.info, win32.DIB_RGB_COLORS, win32.SRCCOPY);
}

fn Win32WindowProc(windowHandle: win32.HWND, message: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    var result: win32.LRESULT = 0;

    switch (message) {
        win32.WM_CLOSE => globalRunning = false, // TODO: handle this with a message to a user?

        win32.WM_ACTIVATEAPP => win32.OutputDebugStringW(win32.L("WM_ACTIVATEAPP\n")),

        win32.WM_DESTROY => globalRunning = false, // TODO: handle this as an error = recreate window?

        win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
            std.debug.print("{s}", .{"Keyboard input came in through a non-dispatch message!"});
            unreachable;
        },
        win32.WM_PAINT => {
            var paint: win32.PAINTSTRUCT = undefined;
            if (win32.BeginPaint(windowHandle, &paint)) |deviceContext| {
                var dimension = Win32GetWindowDimenstion(windowHandle);
                Win32DisplayBufferInWindow(&globalBackBuffer, deviceContext, dimension.width, dimension.height);
            }
            _ = win32.EndPaint(windowHandle, &paint);
        },

        else => result = win32.DefWindowProc(windowHandle, message, wParam, lParam),
    }

    return result;
}

fn Win32ClearBuffer(soundOutput: *win32_sound_output) void {
    var region1: ?*anyopaque = undefined;
    var region1Size: DWORD = undefined;
    var region2: ?*anyopaque = undefined;
    var region2Size: DWORD = undefined;

    if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.Lock(globalSecondaryBuffer, 0, soundOutput.secondaryBufferSize, &region1, &region1Size, &region2, &region2Size, 0))) {
        if (region1) |ptr| {
            var destSample = @ptrCast([*]u8, ptr);
            var byteIndex: DWORD = 0;
            while (byteIndex < region1Size) : (byteIndex += 1) {
                destSample.* = 0;
                destSample += 1;
            }
        }

        if (region2) |ptr| {
            var destSample = @ptrCast([*]u8, ptr);
            var byteIndex: DWORD = 0;
            while (byteIndex < region2Size) : (byteIndex += 1) {
                destSample.* = 0;
                destSample += 1;
            }
        }

        _ = globalSecondaryBuffer.vtable.Unlock(globalSecondaryBuffer, region1, region1Size, region2, region2Size);
    }
}

fn Win32ProcessKeyboardMessage(newState: *game.button_state, isDown: u32) void {
    std.debug.assert(newState.endedDown != isDown);
    newState.endedDown = isDown;
    newState.haltTransitionCount += 1;
}

fn Win32ProcessXinputDigitalButton(xInputButtonState: DWORD, oldState: *game.button_state, buttonBit: DWORD, newState: *game.button_state) void {
    newState.endedDown = if (((xInputButtonState & buttonBit) == buttonBit)) 1 else 0;
    newState.haltTransitionCount = if (oldState.endedDown != newState.endedDown) 1 else 0;
}

fn Win32FillSoundBuffer(soundOutput: *win32_sound_output, byteToLock: DWORD, bytesToWrite: DWORD, sourceBuffer: *game.sound_output_buffer) void {
    // TODO: more strenous test :)
    var region1: ?*anyopaque = undefined;
    var region1Size: DWORD = undefined;
    var region2: ?*anyopaque = undefined;
    var region2Size: DWORD = undefined;

    if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.Lock(globalSecondaryBuffer, byteToLock, bytesToWrite, &region1, &region1Size, &region2, &region2Size, 0))) {
        // TODO: asset that region1Size/region2Size is valid
        // TODO: collapse the two loops
        if (region1) |ptr| {
            const region1SampleCount = region1Size / soundOutput.bytesPerSample;
            var destSample = @ptrCast([*]i16, @alignCast(@alignOf(i16), ptr));
            var sourceSample = sourceBuffer.samples;
            var sampleIndex: DWORD = 0;

            while (sampleIndex < region1SampleCount) : (sampleIndex += 1) {
                destSample[2 * sampleIndex] = sourceSample[2 * sampleIndex];
                destSample[2 * sampleIndex + 1] = sourceSample[2 * sampleIndex + 1];

                soundOutput.runningSampleIndex += 1;
            }
        }

        if (region2) |ptr| {
            const region2SampleCount = region2Size / soundOutput.bytesPerSample;
            var destSample = @ptrCast([*]i16, @alignCast(@alignOf(i16), ptr));
            var sourceSample = sourceBuffer.samples;
            var sampleIndex: DWORD = 0;

            while (sampleIndex < region2SampleCount) : (sampleIndex += 1) {
                destSample[2 * sampleIndex] = sourceSample[2 * sampleIndex];
                destSample[2 * sampleIndex + 1] = sourceSample[2 * sampleIndex + 1];

                soundOutput.runningSampleIndex += 1;
            }
        }

        _ = globalSecondaryBuffer.vtable.Unlock(globalSecondaryBuffer, region1, region1Size, region2, region2Size);
    }
}

fn Win32MessageLoop(keyboardController: *game.controller_input) void {
    var message: win32.MSG = undefined;
    while (win32.PeekMessage(&message, null, 0, 0, win32.PM_REMOVE) != 0) {
        switch (message.message) {
            win32.WM_QUIT => globalRunning = false,
            win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
                const vkCode = @intToEnum(win32.VIRTUAL_KEY, message.wParam);
                // DOCUMENTATION: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
                const wasDown = ((message.lParam & (1 << 30)) != 0);
                const isDown = ((message.lParam & (1 << 31)) == 0);

                if (wasDown != isDown) {
                    switch (vkCode) {
                        win32.VK_W => Win32ProcessKeyboardMessage(&keyboardController.buttons.moveUp, @as(u32, @boolToInt(isDown))),
                        win32.VK_A => Win32ProcessKeyboardMessage(&keyboardController.buttons.moveLeft, @as(u32, @boolToInt(isDown))),
                        win32.VK_S => Win32ProcessKeyboardMessage(&keyboardController.buttons.moveDown, @as(u32, @boolToInt(isDown))),
                        win32.VK_D => Win32ProcessKeyboardMessage(&keyboardController.buttons.moveRight, @as(u32, @boolToInt(isDown))),
                        win32.VK_Q => Win32ProcessKeyboardMessage(&keyboardController.buttons.leftShoulder, @as(u32, @boolToInt(isDown))),
                        win32.VK_E => Win32ProcessKeyboardMessage(&keyboardController.buttons.rightShoulder, @as(u32, @boolToInt(isDown))),
                        win32.VK_UP => Win32ProcessKeyboardMessage(&keyboardController.buttons.actionUp, @as(u32, @boolToInt(isDown))),
                        win32.VK_LEFT => Win32ProcessKeyboardMessage(&keyboardController.buttons.actionLeft, @as(u32, @boolToInt(isDown))),
                        win32.VK_DOWN => Win32ProcessKeyboardMessage(&keyboardController.buttons.actionDown, @as(u32, @boolToInt(isDown))),
                        win32.VK_RIGHT => Win32ProcessKeyboardMessage(&keyboardController.buttons.actionRight, @as(u32, @boolToInt(isDown))),
                        win32.VK_ESCAPE => Win32ProcessKeyboardMessage(&keyboardController.buttons.start, @as(u32, @boolToInt(isDown))),
                        win32.VK_SPACE => Win32ProcessKeyboardMessage(&keyboardController.buttons.back, @as(u32, @boolToInt(isDown))),
                        else => {},
                    }
                }

                const altKeyWasDown = ((message.lParam & (1 << 29)) != 0);
                if ((vkCode == win32.VK_F4) and altKeyWasDown) {
                    globalRunning = false;
                }
            },
            else => {
                _ = win32.TranslateMessage(&message);
                _ = win32.DispatchMessage(&message);
            },
        }
    }
}

fn Win32ProcessXInputStickValue(value: i16, deadZoneThreshold: u32) f32 {
    var result: f32 = 0;

    if (value < -@intCast(i32, deadZoneThreshold)) {
        result = @intToFloat(f32, @as(i32, value) + @intCast(i32, deadZoneThreshold)) / (32768.0 - @intToFloat(f32, deadZoneThreshold));
    } else if (value > deadZoneThreshold) {
        result = @intToFloat(f32, @as(i32, value) + @intCast(i32, deadZoneThreshold)) / (32767.0 - @intToFloat(f32, deadZoneThreshold));
    }

    return result;
}

// inline defs ----------------------------------------------------------------------------------------------------------------------------

inline fn Win32GetWallClock() win32.LARGE_INTEGER {
    var result: win32.LARGE_INTEGER = undefined;
    _ = win32.QueryPerformanceCounter(&result);
    return result;
}

inline fn Win32GetSecondsElapsed(start: win32.LARGE_INTEGER, end: win32.LARGE_INTEGER) f32 {
    const result = @intToFloat(f32, (end.QuadPart - start.QuadPart)) / @intToFloat(f32, globalPerfCounterFrequency);

    return result;
}

inline fn rdtsc() u64 {
    var low: u64 = undefined;
    var high: u64 = undefined;

    asm volatile ("rdtsc"
        : [low] "={eax}" (low),
          [high] "={edx}" (high),
    );

    return (high << 32) | low;
}

// main -----------------------------------------------------------------------------------------------------------------------------------

pub export fn wWinMain(hInstance: ?win32.HINSTANCE, _: ?win32.HINSTANCE, _: [*:0]u16, _: u32) callconv(WINAPI) c_int {
    var perfCountFrequencyResult: win32.LARGE_INTEGER = undefined;
    _ = win32.QueryPerformanceFrequency(&perfCountFrequencyResult);
    globalPerfCounterFrequency = perfCountFrequencyResult.QuadPart;

    const desiredSchedulerMS = 1;
    const sleepIsGranular = (win32.timeBeginPeriod(desiredSchedulerMS) == win32.TIMERR_NOERROR);

    Win32LoadXinput();

    Win32ResizeDIBSection(&globalBackBuffer, 1280, 720);

    const windowclass = win32.WNDCLASS{
        .style = @intToEnum(
            win32.WNDCLASS_STYLES,
            @enumToInt(win32.CS_HREDRAW) | @enumToInt(win32.CS_VREDRAW) | @enumToInt(win32.CS_OWNDC),
        ),
        .lpfnWndProc = Win32WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = win32.L("HandmadeHeroWindowClass"),
    };

    const monitorRefreshHz = 60;
    const gameUpdateHz = monitorRefreshHz / 2;
    const targetSecondsPerFrame = 1 / @intToFloat(f32, gameUpdateHz);

    if (win32.RegisterClass(&windowclass) != 0) {
        if (win32.CreateWindowEx(@intToEnum(win32.WINDOW_EX_STYLE, 0), windowclass.lpszClassName, win32.L("HandmadeHero"), @intToEnum(win32.WINDOW_STYLE, @enumToInt(win32.WS_OVERLAPPEDWINDOW) | @enumToInt(win32.WS_VISIBLE)), win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, hInstance, null)) |windowHandle| {
            if (win32.GetDC(windowHandle)) |deviceContext| {
                defer _ = win32.ReleaseDC(windowHandle, deviceContext);
                var soundOutput = win32_sound_output{
                    .samplesPerSecond = 48000,
                    .runningSampleIndex = 0,
                    .bytesPerSample = @sizeOf(i16) * 2,
                    .secondaryBufferSize = undefined,
                    .tSine = 0,
                    .latencySampleCount = undefined,
                };

                soundOutput.secondaryBufferSize = soundOutput.samplesPerSecond * soundOutput.bytesPerSample;
                soundOutput.latencySampleCount = soundOutput.samplesPerSecond / 15; //(15 - fps)

                Win32InitDSound(windowHandle, soundOutput.samplesPerSecond, soundOutput.secondaryBufferSize);
                Win32ClearBuffer(&soundOutput);
                _ = globalSecondaryBuffer.vtable.Play(globalSecondaryBuffer, 0, 0, win32.DSBPLAY_LOOPING);

                globalRunning = true;

                if (@ptrCast(?[*]i16, @alignCast(
                    @alignOf(i16),
                    win32.VirtualAlloc(
                        null,
                        soundOutput.secondaryBufferSize,
                        allocationType,
                        win32.PAGE_READWRITE,
                    ),
                ))) |samples| {
                    // defer _ = win32.VirtualFree();

                    var gameMemory = game.memory{
                        .permanentStorageSize = game.MegaBytes(64),
                        .transientStorageSize = game.GigaBytes(4),
                        .permanentStorage = undefined,
                        .transientStorage = undefined,
                    };

                    const baseAddress = if (HANDMADE_INTERNAL) (@intToPtr([*]u8, game.TeraBytes(2))) else null;
                    const totalSize: u64 = gameMemory.permanentStorageSize + gameMemory.transientStorageSize;

                    if (win32.VirtualAlloc(baseAddress, totalSize, allocationType, win32.PAGE_READWRITE)) |memory| {
                        // defer _ = win32.VirtualFree();

                        gameMemory.permanentStorage = @ptrCast([*]u8, memory);
                        gameMemory.transientStorage = gameMemory.permanentStorage + gameMemory.permanentStorageSize;

                        var inputs = [1]game.input{
                            game.input{
                                .controllers = [1]game.controller_input{
                                    game.controller_input{
                                        .buttons = .{},
                                    },
                                } ** 5,
                            },
                        } ** 2;

                        var newInput = &inputs[0];
                        var oldInput = &inputs[1];

                        var lastCounter = Win32GetWallClock();
                        var lastCycleCount = rdtsc();

                        while (globalRunning) {
                            const oldKeyboardController: *game.controller_input = &oldInput.controllers[0];
                            const newKeyboardController: *game.controller_input = &newInput.controllers[0];
                            // TODO: can't zero everything because the up/down state will be wrong
                            newKeyboardController.* = game.controller_input{
                                .isConnected = true,
                                .buttons = .{},
                            };

                            var buttonIndex: u8 = 0;
                            while (buttonIndex < 12) : (buttonIndex += 1) { // hardcoded for now
                                newKeyboardController.buttons.Get(buttonIndex).endedDown = oldKeyboardController.buttons.Get(buttonIndex).endedDown;
                            }

                            Win32MessageLoop(newKeyboardController);

                            const maxControllerCount = win32.XUSER_MAX_COUNT;
                            if (maxControllerCount > newInput.controllers.len - 1) {
                                maxControllerCount = newInput.controllers.len - 1; // why are we doing this?
                            }

                            // TODO: should we poll this more frequently
                            var controllerIndex: DWORD = 0;
                            while (controllerIndex < maxControllerCount) : (controllerIndex += 1) {
                                const ourControllerIndex = controllerIndex + 1;
                                const oldController = &oldInput.controllers[ourControllerIndex];
                                const newController = &newInput.controllers[ourControllerIndex];

                                var controllerState: win32.XINPUT_STATE = undefined;
                                if (XInputGetState(controllerIndex, &controllerState) == @enumToInt(win32.ERROR_SUCCESS)) {
                                    newController.isConnected = true;

                                    // This controller is plugged in
                                    // TODO: see if ControllerState.dwPacketNumber increments too rapidly
                                    const pad = &controllerState.Gamepad;

                                    newController.stickAverageX = Win32ProcessXInputStickValue(pad.sThumbLX, win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE);
                                    newController.stickAverageY = Win32ProcessXInputStickValue(pad.sThumbLY, win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE);

                                    if (newController.stickAverageX != 0 or newController.stickAverageY != 0) {
                                        newController.isAnalog = true;
                                    }

                                    if ((pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_UP) != 0) {
                                        newController.stickAverageY = 1;
                                        newController.isAnalog = false;
                                    }

                                    if ((pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_DOWN) != 0) {
                                        newController.stickAverageY = -1;
                                        newController.isAnalog = false;
                                    }

                                    if ((pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_LEFT) != 0) {
                                        newController.stickAverageX = -1;
                                        newController.isAnalog = false;
                                    }

                                    if ((pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_RIGHT) != 0) {
                                        newController.stickAverageX = 1;
                                        newController.isAnalog = false;
                                    }

                                    const threshold = 0.5;

                                    Win32ProcessXinputDigitalButton(
                                        if (newController.stickAverageX < -threshold) 1 else 0,
                                        &oldController.buttons.moveLeft,
                                        1,
                                        &newController.buttons.moveLeft,
                                    );

                                    Win32ProcessXinputDigitalButton(
                                        if (newController.stickAverageX > threshold) 1 else 0,
                                        &oldController.buttons.moveRight,
                                        1,
                                        &newController.buttons.moveRight,
                                    );

                                    Win32ProcessXinputDigitalButton(
                                        if (newController.stickAverageY < -threshold) 1 else 0,
                                        &oldController.buttons.moveDown,
                                        1,
                                        &newController.buttons.moveDown,
                                    );

                                    Win32ProcessXinputDigitalButton(
                                        if (newController.stickAverageY > threshold) 1 else 0,
                                        &oldController.buttons.moveUp,
                                        1,
                                        &newController.buttons.moveUp,
                                    );

                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.actionDown, win32.XINPUT_GAMEPAD_A, &newController.buttons.actionDown);
                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.actionRight, win32.XINPUT_GAMEPAD_B, &newController.buttons.actionRight);
                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.actionLeft, win32.XINPUT_GAMEPAD_X, &newController.buttons.actionLeft);
                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.actionUp, win32.XINPUT_GAMEPAD_Y, &newController.buttons.actionUp);
                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.leftShoulder, win32.XINPUT_GAMEPAD_LEFT_SHOULDER, &newController.buttons.leftShoulder);
                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.rightShoulder, win32.XINPUT_GAMEPAD_RIGHT_SHOULDER, &newController.buttons.rightShoulder);
                                } else {
                                    // This controller is not available
                                    newController.isConnected = false;
                                }
                            }

                            var byteToLock: DWORD = 0;
                            var targetCursor: DWORD = 0;
                            var bytesToWrite: DWORD = 0;
                            var playCursor: DWORD = 0;
                            var writeCursor: DWORD = 0;
                            var soundIsValid = false;
                            // TODO: tighten up sound logic so we know where we should be writing to and can anticipate the time spent in the game update
                            if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor))) {
                                soundIsValid = true;

                                byteToLock = (soundOutput.runningSampleIndex * soundOutput.bytesPerSample) % soundOutput.secondaryBufferSize;

                                targetCursor = (playCursor + (soundOutput.latencySampleCount * soundOutput.bytesPerSample)) % soundOutput.secondaryBufferSize;

                                if (byteToLock > targetCursor) {
                                    bytesToWrite = soundOutput.secondaryBufferSize - byteToLock;
                                    bytesToWrite += targetCursor;
                                } else {
                                    bytesToWrite = targetCursor - byteToLock;
                                }
                            }

                            var soundBuffer = game.sound_output_buffer{
                                .samplesPerSecond = soundOutput.samplesPerSecond,
                                .sampleCount = @divTrunc(bytesToWrite, soundOutput.bytesPerSample),
                                .samples = samples,
                            };

                            var buffer = game.offscreen_buffer{
                                .memory = globalBackBuffer.memory,
                                .width = globalBackBuffer.width,
                                .height = globalBackBuffer.height,
                                .pitch = globalBackBuffer.pitch,
                            };

                            game.UpdateAndRender(&win32Platform, &gameMemory, newInput, &buffer, &soundBuffer);

                            if (soundIsValid) {
                                Win32FillSoundBuffer(&soundOutput, byteToLock, bytesToWrite, &soundBuffer);
                            }

                            const workCounter = Win32GetWallClock();
                            const workSecondsElapsed = Win32GetSecondsElapsed(lastCounter, workCounter);

                            // TODO: not tested yet, probably buggy
                            var secondsElapsedForFrame = workSecondsElapsed;
                            if (secondsElapsedForFrame < targetSecondsPerFrame) {
                                if (sleepIsGranular) {
                                    const sleepMS = @floatToInt(DWORD, (1000 * (targetSecondsPerFrame - secondsElapsedForFrame)));
                                    if (sleepMS > 0) win32.Sleep(sleepMS);
                                }

                                // const testSecondsElapsedForFrame = Win32GetSecondsElapsed(lastCounter, Win32GetWallClock());
                                // std.debug.assert(testSecondsElapsedForFrame < targetSecondsPerFrame); // this assert fires? o.o

                                while (secondsElapsedForFrame < targetSecondsPerFrame) {
                                    secondsElapsedForFrame = Win32GetSecondsElapsed(lastCounter, Win32GetWallClock());
                                }
                            } else {
                                // TODO: missed frame rate!,
                                // TODO: logging
                            }

                            const dimension = Win32GetWindowDimenstion(windowHandle);
                            Win32DisplayBufferInWindow(&globalBackBuffer, deviceContext, dimension.width, dimension.height);

                            const temp = newInput;
                            newInput = oldInput;
                            oldInput = temp;
                            // TODO: should I clear these here?

                            var endCycleCount = rdtsc();
                            const cyclesElapsed = endCycleCount - lastCycleCount;
                            lastCycleCount = endCycleCount;

                            const endCounter: win32.LARGE_INTEGER = Win32GetWallClock();
                            const msPerFrame = 1000 * Win32GetSecondsElapsed(lastCounter, endCounter);
                            lastCounter = endCounter;

                            const fps: f64 = 0;
                            const mcpf = @intToFloat(f64, cyclesElapsed) / (1000 * 1000);

                            var fpsBuffer: [256:0]u16 = undefined;
                            _ = win32.wnsprintfW(&fpsBuffer, @sizeOf(@TypeOf(fpsBuffer)), win32.L("%.02fms/f,  %.02ff/s,  %.02fmc/f\n"), msPerFrame, fps, mcpf);
                            _ = win32.OutputDebugStringW(&fpsBuffer);
                        }
                    } else {
                        // TODO: LOGGING
                    }
                } else {
                    // TODO: LOGGING
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

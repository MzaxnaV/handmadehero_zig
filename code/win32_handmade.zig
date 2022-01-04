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

    usingnamespace @import("win32").zig;
};

const game = @import("handmade.zig");

// constants ------------------------------------------------------------------------------------------------------------------------------

const IGNORE = @import("build_consts").IGNORE;
const HANDMADE_INTERNAL = (@import("builtin").mode == std.builtin.Mode.Debug);

const allocationType = @intToEnum(win32.VIRTUAL_ALLOCATION_TYPE, @enumToInt(win32.MEM_RESERVE) | @enumToInt(win32.MEM_COMMIT));

// data types -----------------------------------------------------------------------------------------------------------------------------

const win32_offscreen_buffer = struct {
    // NOTE: Pixels are alwasy 32-bits wide, Memory Order BB GG RR XX
    info: win32.BITMAPINFO = win32.BITMAPINFO{
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
    memory: ?*anyopaque = undefined,
    width: i32 = 0,
    height: i32 = 0,
    pitch: usize = 0,
    bytesPerPixe: u32 = 0,
};

const win32_window_dimension = struct {
    width: i32 = 0,
    height: i32 = 0,
};

const win32_sound_output = struct {
    samplesPerSecond: u32,
    runningSampleIndex: u32,
    bytesPerSample: u32,
    secondaryBufferSize: DWORD,
    safetyBytes: DWORD,
    tSine: f32,
    latencySampleCount: u32,
    // TODO: Should running sample index be in bytes as well
    // TODO: Math gets simpler if we add a "bytes per second" field?
};

const win32_debug_time_marker = struct {
    outputPlayCursor: DWORD = 0,
    outputWriteCursor: DWORD = 0,
    outputLocation: DWORD = 0,
    outputByteCount: DWORD = 0,
    expectedFlipPlayCursor: DWORD = 0,

    flipPlayCursor: DWORD = 0,
    flipWriteCursor: DWORD = 0,
};

// globals --------------------------------------------------------------------------------------------------------------------------------

pub var globalRunning: bool = undefined;
pub var globalPause: bool = undefined;
pub var globalBackBuffer = win32_offscreen_buffer{};
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

                    var bufferDescription = win32.DSBUFFERDESC{
                        .dwSize = @sizeOf(win32.DSBUFFERDESC),
                        .dwFlags = win32.DSBCAPS_GETCURRENTPOSITION2,
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
    buffer.bytesPerPixe = bytesPerPixel;

    // NOTE: When the biHeight field is neative, this is clue to windows to treat bitmap
    // as top-down, not bottom-up, meaning that the first three byte of the image are the
    // colour for the top left pixel in the bitmap, not the bottom left
    buffer.info.bmiHeader.biSize = @sizeOf(win32.BITMAPINFOHEADER);
    buffer.info.bmiHeader.biWidth = buffer.width;
    buffer.info.bmiHeader.biHeight = -buffer.height;
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

fn Win32MainWindowCallback(windowHandle: win32.HWND, message: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
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

        else => result = win32.DefWindowProcW(windowHandle, message, wParam, lParam),
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

fn Win32ProcessKeyboardMessage(newState: *game.button_state, isDown: u32) void {
    std.debug.assert(newState.endedDown != isDown);
    newState.endedDown = isDown;
    newState.haltTransitionCount += 1;
}

fn Win32ProcessXinputDigitalButton(xInputButtonState: DWORD, oldState: *game.button_state, buttonBit: DWORD, newState: *game.button_state) void {
    newState.endedDown = if (((xInputButtonState & buttonBit) == buttonBit)) 1 else 0;
    newState.haltTransitionCount = if (oldState.endedDown != newState.endedDown) 1 else 0;
}

fn Win32ProcessXInputStickValue(value: i16, deadZoneThreshold: u32) f32 {
    var result: f32 = 0;

    if (value < -@intCast(i32, deadZoneThreshold)) {
        result = @intToFloat(f32, @as(i32, value) + @intCast(i32, deadZoneThreshold)) / (32768.0 - @intToFloat(f32, deadZoneThreshold));
    } else if (value > deadZoneThreshold) {
        result = @intToFloat(f32, @as(i32, value) - @intCast(i32, deadZoneThreshold)) / (32767.0 - @intToFloat(f32, deadZoneThreshold));
    }

    return result;
}

fn Win32ProcessPendingMessages(keyboardController: *game.controller_input) void {
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
                        win32.VK_W => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveUp, @as(u32, @boolToInt(isDown))),
                        win32.VK_A => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveLeft, @as(u32, @boolToInt(isDown))),
                        win32.VK_S => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveDown, @as(u32, @boolToInt(isDown))),
                        win32.VK_D => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveRight, @as(u32, @boolToInt(isDown))),
                        win32.VK_Q => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.leftShoulder, @as(u32, @boolToInt(isDown))),
                        win32.VK_E => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.rightShoulder, @as(u32, @boolToInt(isDown))),
                        win32.VK_UP => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionUp, @as(u32, @boolToInt(isDown))),
                        win32.VK_LEFT => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionLeft, @as(u32, @boolToInt(isDown))),
                        win32.VK_DOWN => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionDown, @as(u32, @boolToInt(isDown))),
                        win32.VK_RIGHT => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionRight, @as(u32, @boolToInt(isDown))),
                        win32.VK_ESCAPE => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.start, @as(u32, @boolToInt(isDown))),
                        win32.VK_SPACE => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.back, @as(u32, @boolToInt(isDown))),
                        win32.VK_P => {
                            if (HANDMADE_INTERNAL) {
                                if (isDown) {
                                    globalPause = !globalPause;
                                }
                            }
                        },
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

fn Win32DebugDrawVertical(backBuffer: *win32_offscreen_buffer, x: u32, top: u32, bottom: i32, colour: u32) void {
    var safeTop = top;
    var safeBottom = bottom;
    
    if (safeBottom > backBuffer.height) {
        safeBottom = backBuffer.height;
    }
    if (x < backBuffer.width) {
        var pixel: [*]u8 = @ptrCast([*]u8, backBuffer.memory) + x * backBuffer.bytesPerPixe + safeTop * backBuffer.pitch;
        var y = safeTop;
        while (y < safeBottom) : (y += 1) {
            @ptrCast(*u32, @alignCast(@alignOf(u32), pixel)).* = colour;
            pixel += backBuffer.pitch;
        }
    }
}

inline fn Win32DrawSoundBufferMarker(backBuffer: *win32_offscreen_buffer, soundOutput: *win32_sound_output, coeff: f32, padX: u32, top: u32, bottom: i32, value: DWORD, colour: u32) void {
    _ = soundOutput;
    const xReal32 = coeff * @intToFloat(f32, value);
    const x = padX + @floatToInt(u32, xReal32);

    Win32DebugDrawVertical(backBuffer, x, top, bottom, colour);
}

fn Win32DebugSyncDisplay(backBuffer: *win32_offscreen_buffer, markerCount: u32, markers: [*]win32_debug_time_marker, currentMarkerIndex: u32, soundOutput: *win32_sound_output, targetSecondsPerFrame: f32) void {
    // TODO: draw where we're writing our sound
    _ = targetSecondsPerFrame;

    const padX = 16;
    const padY = 16;

    const lineHeight = 64;

    const coeff = @intToFloat(f32, (backBuffer.width - 2 * padX)) / @intToFloat(f32, soundOutput.secondaryBufferSize);
    var markerIndex: u32 = 0;
    while (markerIndex < markerCount) : (markerIndex += 1) {
        const thisMarker = &markers[markerIndex];
        std.debug.assert(thisMarker.outputPlayCursor < soundOutput.secondaryBufferSize);
        std.debug.assert(thisMarker.outputWriteCursor < soundOutput.secondaryBufferSize);
        std.debug.assert(thisMarker.outputLocation < soundOutput.secondaryBufferSize);
        std.debug.assert(thisMarker.outputByteCount < soundOutput.secondaryBufferSize);
        std.debug.assert(thisMarker.flipPlayCursor < soundOutput.secondaryBufferSize);
        std.debug.assert(thisMarker.flipWriteCursor < soundOutput.secondaryBufferSize);

        const playColour = 0xffffffff;
        const writeColour = 0xffffffff;
        const expectedFlipColour = 0xffffffff;
        const playWindowColour = 0xffffffff;

        var top:u32 = padY;
        var bottom:i32 = lineHeight - padY;
        if (markerIndex == currentMarkerIndex) {
            top += lineHeight + padY;
            bottom += lineHeight + padY;

            const firstTop = top;
            Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputPlayCursor, playColour);
            Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputWriteCursor, writeColour);

            top += lineHeight + padY;
            bottom += lineHeight + padY;

            Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputLocation, playColour);
            Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputLocation + thisMarker.outputByteCount, writeColour);

            top += lineHeight + padY;
            bottom += lineHeight + padY;

            Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, firstTop, bottom, thisMarker.expectedFlipPlayCursor, expectedFlipColour);
        }

        Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipPlayCursor, playColour);
        Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipPlayCursor + 480 * soundOutput.bytesPerSample, playWindowColour);
        Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipWriteCursor, writeColour);
    }
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
        .lpfnWndProc = Win32MainWindowCallback,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = win32.L("HandmadeHeroWindowClass"),
    };

    // TODO: how do we reliably query this on windows?
    const monitorRefreshHz = 60;
    const gameUpdateHz = @divTrunc(monitorRefreshHz, 2);
    const targetSecondsPerFrame = 1.0 / @intToFloat(f32, gameUpdateHz);

    if (win32.RegisterClass(&windowclass) != 0) {
        if (win32.CreateWindowExW(@intToEnum(win32.WINDOW_EX_STYLE, 0), windowclass.lpszClassName, win32.L("HandmadeHero"), @intToEnum(win32.WINDOW_STYLE, @enumToInt(win32.WS_OVERLAPPEDWINDOW) | @enumToInt(win32.WS_VISIBLE)), win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, hInstance, null)) |windowHandle| {
            // NOTE: Since we specified CS_OWNDC, we can just
            // get one device context and use it forever because we
            // are not sharing it with anyone.
            if (win32.GetDC(windowHandle)) |deviceContext| {
                defer _ = win32.ReleaseDC(windowHandle, deviceContext);
                var soundOutput = win32_sound_output{
                    .samplesPerSecond = 48000,
                    .runningSampleIndex = 0,
                    .bytesPerSample = @sizeOf(i16) * 2,
                    .secondaryBufferSize = undefined,
                    .safetyBytes = undefined,
                    .tSine = 0,
                    .latencySampleCount = undefined,
                };

                soundOutput.secondaryBufferSize = soundOutput.samplesPerSecond * soundOutput.bytesPerSample;
                soundOutput.latencySampleCount = 3 * @divTrunc(soundOutput.samplesPerSecond, gameUpdateHz);
                soundOutput.safetyBytes = @divTrunc(soundOutput.samplesPerSecond * soundOutput.bytesPerSample, gameUpdateHz) / 3;

                Win32InitDSound(windowHandle, soundOutput.samplesPerSecond, soundOutput.secondaryBufferSize);
                Win32ClearBuffer(&soundOutput);
                _ = globalSecondaryBuffer.vtable.Play(globalSecondaryBuffer, 0, 0, win32.DSBPLAY_LOOPING);

                globalRunning = true;

                if (!IGNORE) {
                    // NOTE: This tests the PlayCursor/WriteCursor update frequency
                    // for this machine it was 1920
                    while (globalRunning) {
                        var playCursor: DWORD = 0;
                        var writeCursor: DWORD = 0;
                        _ = globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor);

                        std.debug.print("{} {}\n", .{ playCursor, writeCursor });
                    }
                }

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
                                    game.controller_input{},
                                } ** 5,
                            },
                        } ** 2;

                        var newInput = &inputs[0];
                        var oldInput = &inputs[1];

                        var lastCounter = Win32GetWallClock();
                        var flipWallClock = Win32GetWallClock();

                        var debugTimeMarkerIndex: u32 = 0;
                        var debugTimeMarkers = [1]win32_debug_time_marker{win32_debug_time_marker{}} ** @divTrunc(@intCast(u32, gameUpdateHz), 2);

                        var audioLatencyBytes: DWORD = 0;
                        var audioLatencySeconds: f32 = 0;
                        var soundIsValid = false;

                        var lastCycleCount = rdtsc();

                        while (globalRunning) {
                            const oldKeyboardController: *game.controller_input = &oldInput.controllers[0];
                            const newKeyboardController: *game.controller_input = &newInput.controllers[0];
                            // TODO: can't zero everything because the up/down state will be wrong
                            newKeyboardController.* = game.controller_input{
                                .isConnected = true,
                            };

                            var buttonIndex: u8 = 0;
                            while (buttonIndex < 12) : (buttonIndex += 1) { // hardcoded for now
                                newKeyboardController.buttons.states[buttonIndex].endedDown = oldKeyboardController.buttons.states[buttonIndex].endedDown;
                            }

                            Win32ProcessPendingMessages(newKeyboardController);

                            if (!globalPause) {

                                // TODO: Need to not poll disconnected controllers to avoid xinput frame rate hit on older libraries...
                                // TODO: Should we poll this more frequently
                                const maxControllerCount = win32.XUSER_MAX_COUNT;
                                if (maxControllerCount > newInput.controllers.len - 1) {
                                    maxControllerCount = newInput.controllers.len - 1;
                                }

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

                                        // TODO: This is a square deadzone, check XInput to
                                        // verify that the deadzone is "round" and show how to do
                                        // round deadzone processing.
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
                                            &oldController.buttons.mapped.moveLeft,
                                            1,
                                            &newController.buttons.mapped.moveLeft,
                                        );

                                        Win32ProcessXinputDigitalButton(
                                            if (newController.stickAverageX > threshold) 1 else 0,
                                            &oldController.buttons.mapped.moveRight,
                                            1,
                                            &newController.buttons.mapped.moveRight,
                                        );

                                        Win32ProcessXinputDigitalButton(
                                            if (newController.stickAverageY < -threshold) 1 else 0,
                                            &oldController.buttons.mapped.moveDown,
                                            1,
                                            &newController.buttons.mapped.moveDown,
                                        );

                                        Win32ProcessXinputDigitalButton(
                                            if (newController.stickAverageY > threshold) 1 else 0,
                                            &oldController.buttons.mapped.moveUp,
                                            1,
                                            &newController.buttons.mapped.moveUp,
                                        );

                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.actionDown, win32.XINPUT_GAMEPAD_A, &newController.buttons.mapped.actionDown);
                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.actionRight, win32.XINPUT_GAMEPAD_B, &newController.buttons.mapped.actionRight);
                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.actionLeft, win32.XINPUT_GAMEPAD_X, &newController.buttons.mapped.actionLeft);
                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.actionUp, win32.XINPUT_GAMEPAD_Y, &newController.buttons.mapped.actionUp);
                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.leftShoulder, win32.XINPUT_GAMEPAD_LEFT_SHOULDER, &newController.buttons.mapped.leftShoulder);
                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.rightShoulder, win32.XINPUT_GAMEPAD_RIGHT_SHOULDER, &newController.buttons.mapped.rightShoulder);

                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.back, win32.XINPUT_GAMEPAD_BACK, &newController.buttons.mapped.back);
                                        Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.start, win32.XINPUT_GAMEPAD_START, &newController.buttons.mapped.start);
                                    } else {
                                        // This controller is not available
                                        newController.isConnected = false;
                                    }
                                }

                                var buffer = game.offscreen_buffer{
                                    .memory = globalBackBuffer.memory,
                                    .width = globalBackBuffer.width,
                                    .height = globalBackBuffer.height,
                                    .pitch = globalBackBuffer.pitch,
                                };

                                game.UpdateAndRender(&win32Platform, &gameMemory, newInput, &buffer);

                                const audioWallClock = Win32GetWallClock();
                                const fromBeginToAudioSeconds = Win32GetSecondsElapsed(flipWallClock, audioWallClock);

                                var playCursor: DWORD = 0;
                                var writeCursor: DWORD = 0;

                                if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor))) {
                                    // NOTE:
                                    // Here is how sound output computation works.

                                    // We define a safety value that is the number of samples we think our game update loop may vary by (let's say upto 2ms).

                                    // When we wake up to write audio, we will look and see what the play cursor position is and we will forecast ahead where we think the
                                    // play cursor will be on the next frame boundary.

                                    // We will then look to see if the write cursor is before that by at least our safety value. If it is, the target fill position is that frame boundary plus one frame.
                                    // This gives us perfect audio sync in the case of a card that has low enough latency.

                                    // If the write cursor is _after_ that safety margin, then we assume we can never sync the audio perfectly. So we will write one frame's
                                    // worth of audio plus the satefy margin's worth of guard samples.

                                    if (!soundIsValid) {
                                        soundOutput.runningSampleIndex = @divTrunc(writeCursor, soundOutput.bytesPerSample);
                                        soundIsValid = true;
                                    }

                                    const byteToLock = (soundOutput.runningSampleIndex * soundOutput.bytesPerSample) % soundOutput.secondaryBufferSize;

                                    const expectedSoundBytesPerFrame = @divTrunc(soundOutput.samplesPerSecond * soundOutput.bytesPerSample, gameUpdateHz);
                                    const secondsLeftUntilFLip = (targetSecondsPerFrame - fromBeginToAudioSeconds);
                                    const expectedBytesUntiFlip = @floatToInt(DWORD, (secondsLeftUntilFLip / targetSecondsPerFrame) * @intToFloat(f32, expectedSoundBytesPerFrame));
                                    _ = expectedBytesUntiFlip;
                                    const expectedFrameBoundaryByte = playCursor + expectedSoundBytesPerFrame;

                                    var safeWriteCursor = writeCursor;
                                    if (safeWriteCursor < playCursor) {
                                        safeWriteCursor +%= soundOutput.secondaryBufferSize;
                                    }
                                    std.debug.assert(safeWriteCursor >= playCursor);
                                    safeWriteCursor +%= soundOutput.safetyBytes;

                                    const audioCardIsLowLatency = safeWriteCursor < expectedFrameBoundaryByte;

                                    var targetCursor: DWORD = 0;
                                    if (audioCardIsLowLatency) {
                                        targetCursor = expectedFrameBoundaryByte + expectedSoundBytesPerFrame;
                                    } else {
                                        targetCursor = writeCursor + expectedSoundBytesPerFrame + soundOutput.safetyBytes;
                                    }

                                    targetCursor = targetCursor % soundOutput.secondaryBufferSize;

                                    var bytesToWrite: DWORD = 0;
                                    if (byteToLock > targetCursor) {
                                        bytesToWrite = soundOutput.secondaryBufferSize - byteToLock;
                                        bytesToWrite += targetCursor;
                                    } else {
                                        bytesToWrite = targetCursor - byteToLock;
                                    }

                                    var soundBuffer = game.sound_output_buffer{
                                        .samplesPerSecond = soundOutput.samplesPerSecond,
                                        .sampleCount = @divTrunc(bytesToWrite, soundOutput.bytesPerSample),
                                        .samples = samples,
                                    };

                                    game.GetSoundSamples(&gameMemory, &soundBuffer);

                                    if (HANDMADE_INTERNAL) {
                                        const marker: *win32_debug_time_marker = &debugTimeMarkers[debugTimeMarkerIndex];
                                        marker.outputPlayCursor = playCursor;
                                        marker.outputWriteCursor = writeCursor;
                                        marker.outputLocation = byteToLock;
                                        marker.outputByteCount = bytesToWrite;
                                        marker.expectedFlipPlayCursor = expectedFrameBoundaryByte;

                                        var unwrappedWriteCursor = writeCursor;
                                        if (unwrappedWriteCursor < playCursor) {
                                            unwrappedWriteCursor += soundOutput.secondaryBufferSize;
                                        }
                                        audioLatencyBytes = unwrappedWriteCursor - playCursor;
                                        audioLatencySeconds = (@intToFloat(f32, audioLatencyBytes) / @intToFloat(f32, soundOutput.bytesPerSample)) / @intToFloat(f32, soundOutput.samplesPerSecond);

                                        std.debug.print("BTL:{} BTW:{} - PC:{} WC: {} DELTA {} ({}s)\n", .{ byteToLock, bytesToWrite, playCursor, writeCursor, audioLatencyBytes, audioLatencySeconds });
                                        Win32FillSoundBuffer(&soundOutput, byteToLock, bytesToWrite, &soundBuffer);
                                    }
                                } else {
                                    soundIsValid = false;
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

                                    const testSecondsElapsedForFrame = Win32GetSecondsElapsed(lastCounter, Win32GetWallClock());

                                    if (testSecondsElapsedForFrame < targetSecondsPerFrame) {
                                        // TODO: Log missed sleep here
                                    }

                                    while (secondsElapsedForFrame < targetSecondsPerFrame) {
                                        secondsElapsedForFrame = Win32GetSecondsElapsed(lastCounter, Win32GetWallClock());
                                    }
                                } else {
                                    // TODO: missed frame rate!,
                                    // TODO: logging
                                }

                                const endCounter: win32.LARGE_INTEGER = Win32GetWallClock();
                                const msPerFrame = 1000 * Win32GetSecondsElapsed(lastCounter, endCounter);
                                lastCounter = endCounter;

                                const dimension = Win32GetWindowDimenstion(windowHandle);

                                if (HANDMADE_INTERNAL) {
                                    Win32DebugSyncDisplay(&globalBackBuffer, debugTimeMarkers.len, &debugTimeMarkers, debugTimeMarkerIndex -% 1, &soundOutput, targetSecondsPerFrame);
                                }

                                Win32DisplayBufferInWindow(&globalBackBuffer, deviceContext, dimension.width, dimension.height);

                                flipWallClock = Win32GetWallClock();

                                if (HANDMADE_INTERNAL) {
                                    var play: DWORD = 0;
                                    var write: DWORD = 0;

                                    if (win32.SUCCEEDED((globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor)))) {
                                        std.debug.assert(debugTimeMarkerIndex < debugTimeMarkers.len);
                                        const marker: *win32_debug_time_marker = &debugTimeMarkers[debugTimeMarkerIndex];

                                        marker.flipPlayCursor = play;
                                        marker.flipWriteCursor = write;
                                    }
                                }

                                const temp = newInput;
                                newInput = oldInput;
                                oldInput = temp;
                                // TODO: should I clear these here?

                                var endCycleCount = rdtsc();
                                const cyclesElapsed = endCycleCount - lastCycleCount;
                                lastCycleCount = endCycleCount;

                                const fps: f64 = 0;
                                const mcpf = @intToFloat(f64, cyclesElapsed) / (1000 * 1000);

                                std.debug.print("{d:.2}ms/f, {d:.2}f/s, {d:.2}mc/f\n", .{ msPerFrame, fps, mcpf });

                                if (HANDMADE_INTERNAL) {
                                    debugTimeMarkerIndex += 1;
                                    if (debugTimeMarkerIndex == debugTimeMarkers.len) {
                                        debugTimeMarkerIndex = 0;
                                    }
                                }
                            }
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

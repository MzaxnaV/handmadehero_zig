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

    const extra = struct {
        extern "USER32" fn wsprintfW(
            param0: ?win32.PWSTR,
            param1: ?[*:0]const u16,
            ...,
        ) callconv(@import("std").os.windows.WINAPI) i32;
    };
};

const handmade = @import("handmade_platform");

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = @import("build_consts").NOT_IGNORE;
const HANDMADE_INTERNAL = @import("build_consts").HANDMADE_INTERNAL;
const WIN32_STATE_FILE_NAME_COUNT = win32.MAX_PATH;

const allocationType = @intToEnum(win32.VIRTUAL_ALLOCATION_TYPE, @enumToInt(win32.MEM_RESERVE) | @enumToInt(win32.MEM_COMMIT));

// data types -----------------------------------------------------------------------------------------------------------------------------

const win32_offscreen_buffer = struct {
    info: win32.BITMAPINFO = .{
        .bmiHeader = .{
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
        .bmiColors = [1]win32.RGBQUAD{.{
            .rgbBlue = 0,
            .rgbGreen = 0,
            .rgbRed = 0,
            .rgbReserved = 0,
        }},
    },
    memory: ?*anyopaque = undefined,
    width: u32 = 0,
    height: u32 = 0,
    pitch: usize = 0,
    bytesPerPixel: u32 = 0,
};

const win32_window_dimension = struct {
    width: i32 = 0,
    height: i32 = 0,
};

const win32_sound_output = struct {
    samplesPerSecond: u32 = 0,
    runningSampleIndex: u32 = 0,
    bytesPerSample: u32 = 0,
    secondaryBufferSize: DWORD = 0,
    safetyBytes: DWORD = 0,
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

const win32_game_code = struct {
    gameCodeDLL: ?win32.HINSTANCE = undefined,
    dllLastWriteTime: win32.FILETIME = undefined,
    UpdateAndRender: ?handmade.UpdateAndRenderType = null,
    GetSoundSamples: ?handmade.GetSoundSamplesType = null,

    isValid: bool = false,
};

const win32_replay_buffer = struct {
    fileHandle: ?win32.HANDLE = null,
    memoryMap: ?win32.HANDLE = null,
    fileName: [WIN32_STATE_FILE_NAME_COUNT:0]u16 = undefined,
    memoryBlock: ?*anyopaque = null,
};

const win32_state = struct {
    totalSize: u64 = 0,
    gameMemoryBlock: *anyopaque,
    replayBuffers: [4]win32_replay_buffer = [1]win32_replay_buffer{.{}} ** 4,

    recordingHandle: win32.HANDLE,
    inputRecordingIndex: u32 = 0,

    playBackHandle: win32.HANDLE,
    inputPlayingIndex: u32 = 0,

    exeFileName: [WIN32_STATE_FILE_NAME_COUNT:0]u16 = undefined,
    onePastLastEXEFileNameSlashIndex: usize = 0,
};

// globals --------------------------------------------------------------------------------------------------------------------------------

var globalRunning: bool = undefined;
var globalPause: bool = undefined;
var globalBackBuffer = win32_offscreen_buffer{};
var globalSecondaryBuffer: *win32.IDirectSoundBuffer = undefined;
var globalPerfCounterFrequency: i64 = undefined;
var debugGlobalShowCursor: bool = undefined;
var globalWindowPosition = win32.WINDOWPLACEMENT{
    .length = @sizeOf(win32.WINDOWPLACEMENT),
    .flags = undefined,
    .showCmd = undefined,
    .ptMinPosition = undefined,
    .ptMaxPosition = undefined,
    .rcNormalPosition = undefined,
};

// library defs ---------------------------------------------------------------------------------------------------------------------------

var XInputGetState: fn (u32, ?*win32.XINPUT_STATE) callconv(WINAPI) isize = undefined;
var XInputSetState: fn (u32, ?*win32.XINPUT_VIBRATION) callconv(WINAPI) isize = undefined;

// Debug/temp functions ------------------------------------------------------------------------------------------------------------------

fn CatStrings(sourceA: []const u16, sourceB: []const u16, dest: [:0]u16) void {
    var i: usize = 0;
    for (sourceA) |charA, index| {
        dest[index] = charA;
        i = index;
    }

    for (sourceB) |charB, index| {
        dest[i + index] = charB;
    }
}

fn Win32GetEXEFileName(gameState: *win32_state) void {
    const sizeOfFilename = win32.GetModuleFileNameW(null, &gameState.exeFileName, @sizeOf(@TypeOf(gameState.exeFileName)));
    _ = sizeOfFilename;

    for (gameState.exeFileName) |char, scanIndex| {
        if (char == '\\') gameState.onePastLastEXEFileNameSlashIndex = scanIndex + 2;
    }
}

fn Win32BuildEXEPathFileName(gameState: *win32_state, filename: []const u16, dest: [:0]u16) void {
    CatStrings(gameState.exeFileName[0..gameState.onePastLastEXEFileNameSlashIndex], filename, dest);
}

fn DEBUGWin32FreeFileMemory(_: *handmade.thread_context, memory: *anyopaque) void {
    _ = win32.VirtualFree(memory, 0, win32.MEM_RELEASE);
}

fn DEBUGWin32ReadEntireFile(thread: *handmade.thread_context, filename: [*:0]const u8) handmade.debug_read_file_result {
    var result = handmade.debug_read_file_result{};
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
                    DEBUGWin32FreeFileMemory(thread, data);
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

fn DEBUGWin32WriteEntireFile(_: *handmade.thread_context, fileName: [*:0]const u8, memorySize: u32, memory: *anyopaque) bool {
    var result = false;
    var fileHandle = win32.CreateFileA(fileName, win32.FILE_GENERIC_WRITE, win32.FILE_SHARE_MODE.NONE, null, win32.CREATE_ALWAYS, win32.SECURITY_ANONYMOUS, null);

    if (fileHandle != null and fileHandle != win32.INVALID_HANDLE_VALUE) {
        var bytesWritten: DWORD = 0;
        if (win32.WriteFile(fileHandle, memory, memorySize, &bytesWritten, null) != 0) {
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

// local Win32 functions ------------------------------------------------------------------------------------------------------------------

fn Win32GetLastWriteTime(fileName: [*:0]const u16) win32.FILETIME {
    var lastWriteTime = win32.FILETIME{
        .dwLowDateTime = 0,
        .dwHighDateTime = 0,
    };

    var data: win32.WIN32_FILE_ATTRIBUTE_DATA = undefined;
    if (win32.GetFileAttributesExW(fileName, win32.GetFileExInfoStandard, &data) != win32.FALSE) {
        lastWriteTime = data.ftLastWriteTime;
    }

    return lastWriteTime;
}

fn Win32LoadGameCode(sourceDLLName: [:0]const u16, tempDLLName: [:0]const u16, lockFileName: [:0]const u16) win32_game_code {
    var result = win32_game_code{};

    // NOTE (Manav): no lock file, so this is useless for now :(
    var ignored = win32.WIN32_FILE_ATTRIBUTE_DATA{
        .dwFileAttributes = 0,
        .ftCreationTime = .{
            .dwLowDateTime = 0,
            .dwHighDateTime = 0,
        },
        .ftLastAccessTime = .{
            .dwLowDateTime = 0,
            .dwHighDateTime = 0,
        },
        .ftLastWriteTime = .{
            .dwLowDateTime = 0,
            .dwHighDateTime = 0,
        },
        .nFileSizeHigh = 0,
        .nFileSizeLow = 0,
    };

    if (win32.GetFileAttributesExW(lockFileName, win32.GetFileExInfoStandard, &ignored) == win32.FALSE) {
        result.dllLastWriteTime = Win32GetLastWriteTime(sourceDLLName);

        _ = win32.CopyFileW(sourceDLLName, tempDLLName, win32.FALSE);

        result.gameCodeDLL = win32.LoadLibraryW(tempDLLName);
        if (result.gameCodeDLL) |HANDMADE_DLL| {
            result.isValid = true;

            if (win32.GetProcAddress(HANDMADE_DLL, "UpdateAndRender")) |funcptr| {
                result.UpdateAndRender = @ptrCast(@TypeOf(result.UpdateAndRender), funcptr);
            } else {
                result.isValid = false;
            }

            if (win32.GetProcAddress(HANDMADE_DLL, "GetSoundSamples")) |funcptr| {
                result.GetSoundSamples = @ptrCast(@TypeOf(result.GetSoundSamples), funcptr);
            } else {
                result.isValid = false;
            }
        }
    }

    if (!result.isValid) {
        result.UpdateAndRender = null;
        result.GetSoundSamples = null;
    }

    return result;
}

fn Win32UnloadGameCode(gameCode: *win32_game_code) void {
    if (gameCode.gameCodeDLL) |dll| {
        _ = win32.FreeLibrary(dll);
        gameCode.gameCodeDLL = null;
    }

    gameCode.isValid = false;
    gameCode.UpdateAndRender = null;
    gameCode.GetSoundSamples = null;
}

fn Win32LoadXinput() void {
    if (win32.LoadLibraryW(win32.L("xinput1_4.dll"))) |XInputLibrary| {
        // NOTE (Manav): NO TYPESAFETY TO WARN YOU, BEWARE :D
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
    if (win32.LoadLibraryW(win32.L("dsound.dll"))) |DSoundLibrary| {
        if (win32.GetProcAddress(DSoundLibrary, "DirectSoundCreate")) |funcptr| {
            const DirectSoundCreateType = fn (?*const win32.Guid, ?*?*win32.IDirectSound, ?*win32.IUnknown) callconv(WINAPI) i32;
            const DirectSoundCreate = @ptrCast(DirectSoundCreateType, funcptr);

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

fn Win32ResizeDIBSection(buffer: *win32_offscreen_buffer, width: u32, height: u32) void {
    if (buffer.memory) |_| {
        _ = win32.VirtualFree(buffer.memory, 0, win32.MEM_RELEASE);
    }

    buffer.width = width;
    buffer.height = height;

    const bytesPerPixel = 4;
    buffer.bytesPerPixel = bytesPerPixel;

    buffer.info.bmiHeader.biSize = @sizeOf(win32.BITMAPINFOHEADER);
    buffer.info.bmiHeader.biWidth = @intCast(i32, buffer.width);
    buffer.info.bmiHeader.biHeight = -@intCast(i32, buffer.height);
    buffer.info.bmiHeader.biPlanes = 1;
    buffer.info.bmiHeader.biBitCount = 32;
    buffer.info.bmiHeader.biCompression = win32.BI_RGB;

    const bitmapMemorySize = @intCast(usize, bytesPerPixel * (buffer.width * buffer.height));
    buffer.memory = win32.VirtualAlloc(null, bitmapMemorySize, @intToEnum(win32.VIRTUAL_ALLOCATION_TYPE, @enumToInt(win32.MEM_RESERVE) | @enumToInt(win32.MEM_COMMIT)), win32.PAGE_READWRITE);
    buffer.pitch = @intCast(usize, width) * bytesPerPixel;
}

fn Win32DisplayBufferInWindow(buffer: *win32_offscreen_buffer, deviceContext: win32.HDC, windowWidth: i32, windowHeight: i32) void {
    if ((windowWidth >= buffer.width * 2) and (windowHeight >= buffer.height * 2)) {
        _ = win32.StretchDIBits(
            deviceContext,
            0,
            0,
            @intCast(i32, 2 * buffer.width),
            @intCast(i32, 2 * buffer.height),
            0,
            0,
            @intCast(i32, buffer.width),
            @intCast(i32, buffer.height),
            buffer.memory,
            &buffer.info,
            win32.DIB_RGB_COLORS,
            win32.SRCCOPY,
        );
    } else {
        const offsetX = 10;
        const offsetY = 10;

        _ = win32.PatBlt(deviceContext, 0, 0, windowWidth, offsetY, win32.ROP_CODE.BLACKNESS);
        _ = win32.PatBlt(deviceContext, 0, offsetY + @intCast(i32, buffer.height), windowWidth, windowHeight, win32.ROP_CODE.BLACKNESS);
        _ = win32.PatBlt(deviceContext, 0, 0, offsetX, windowHeight, win32.ROP_CODE.BLACKNESS);
        _ = win32.PatBlt(deviceContext, offsetX + @intCast(i32, buffer.width), 0, windowWidth, windowHeight, win32.ROP_CODE.BLACKNESS);

        _ = win32.StretchDIBits(
            deviceContext,
            offsetX,
            offsetY,
            @intCast(i32, buffer.width),
            @intCast(i32, buffer.height),
            0,
            0,
            @intCast(i32, buffer.width),
            @intCast(i32, buffer.height),
            buffer.memory,
            &buffer.info,
            win32.DIB_RGB_COLORS,
            win32.SRCCOPY,
        );
    }
}

fn Win32MainWindowCallback(windowHandle: win32.HWND, message: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    var result: win32.LRESULT = 0;

    switch (message) {
        win32.WM_CLOSE => globalRunning = false,

        win32.WM_SETCURSOR => {
            if (debugGlobalShowCursor) {
                result = win32.DefWindowProcW(windowHandle, message, wParam, lParam);
            } else {
                _ = win32.SetCursor(null);
            }
        },

        win32.WM_ACTIVATEAPP => {
            if (!NOT_IGNORE) {
                if (wParam == win32.TRUE) {
                    _ = win32.SetLayeredWindowAttributes(windowHandle, @bitCast(u32, win32.RGBQUAD{ .rgbBlue = 0, .rgbGreen = 0, .rgbRed = 0, .rgbReserved = 0 }), 255, win32.LWA_ALPHA);
                } else {
                    _ = win32.SetLayeredWindowAttributes(windowHandle, @bitCast(u32, win32.RGBQUAD{ .rgbBlue = 0, .rgbGreen = 0, .rgbRed = 0, .rgbReserved = 0 }), 128, win32.LWA_ALPHA);
                }
            }
        },

        win32.WM_DESTROY => globalRunning = false,

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

fn Win32FillSoundBuffer(soundOutput: *win32_sound_output, byteToLock: DWORD, bytesToWrite: DWORD, sourceBuffer: *handmade.sound_output_buffer) void {
    var region1: ?*anyopaque = undefined;
    var region1Size: DWORD = undefined;
    var region2: ?*anyopaque = undefined;
    var region2Size: DWORD = undefined;

    if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.Lock(globalSecondaryBuffer, byteToLock, bytesToWrite, &region1, &region1Size, &region2, &region2Size, 0))) {
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

fn Win32ProcessKeyboardMessage(newState: *handmade.button_state, isDown: u32) void {
    if (newState.endedDown != isDown) {
        newState.endedDown = isDown;
        newState.haltTransitionCount += 1;
    }
}

fn Win32ProcessXinputDigitalButton(xInputButtonState: DWORD, oldState: *handmade.button_state, buttonBit: DWORD, newState: *handmade.button_state) void {
    newState.endedDown = @as(u32, @boolToInt((xInputButtonState & buttonBit) == buttonBit));
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

fn Win32GetInputFileLocation(state: *win32_state, inputStream: bool, slotIndex: u32, dest: [:0]u16) void {
    var exeName: [64]u16 = [1]u16{0} ** 64;
    _ = win32.extra.wsprintfW(&exeName, win32.L("loop_edit_%d_%s.hmi"), slotIndex, if (inputStream) win32.L("input") else win32.L("state"));
    Win32BuildEXEPathFileName(state, exeName[0..64], dest);
}

fn Win32GetReplayBuffer(state: *win32_state, index: u32) *win32_replay_buffer {
    std.debug.assert(index > 0);
    const result = &(state.replayBuffers[index]);

    return result;
}

fn Win32BeginRecordingInput(state: *win32_state, inputRecordingIndex: u32) void {
    const replayBuffer = Win32GetReplayBuffer(state, inputRecordingIndex);

    if (replayBuffer.memoryBlock) |replayMemBlock| {
        state.inputRecordingIndex = inputRecordingIndex;

        var fileName = [_:0]u16{0} ** WIN32_STATE_FILE_NAME_COUNT;
        Win32GetInputFileLocation(state, true, inputRecordingIndex, fileName[0..WIN32_STATE_FILE_NAME_COUNT :0]);

        if (win32.CreateFileW(&fileName, win32.FILE_GENERIC_WRITE, win32.FILE_SHARE_NONE, null, win32.CREATE_ALWAYS, win32.SECURITY_ANONYMOUS, null)) |handle| {
            state.recordingHandle = handle;
        }

        if (!NOT_IGNORE) {
            var filePosition: win32.LARGE_INTEGER = undefined;
            filePosition.QuadPart = state.totalSize;
            _ = win32.SetFilePointerEx(state.recordingHandle, filePosition, null, win32.FILE_BEGIN);
        }

        CopyMemory(replayMemBlock, state.gameMemoryBlock, state.totalSize);
    }
}

fn Win32EndRecordingInput(state: *win32_state) void {
    _ = win32.CloseHandle(state.recordingHandle);
    state.inputRecordingIndex = 0;
}

fn Win32BeginInputPlayBack(state: *win32_state, inputPlayingIndex: u32) void {
    const replayBuffer = Win32GetReplayBuffer(state, inputPlayingIndex);

    if (replayBuffer.memoryBlock) |replayMemBlock| {
        state.inputPlayingIndex = inputPlayingIndex;

        var fileName = [_:0]u16{0} ** WIN32_STATE_FILE_NAME_COUNT;
        Win32GetInputFileLocation(state, true, inputPlayingIndex, fileName[0..WIN32_STATE_FILE_NAME_COUNT :0]);

        if (win32.CreateFileW(&fileName, win32.FILE_GENERIC_READ, win32.FILE_SHARE_NONE, null, win32.OPEN_EXISTING, win32.SECURITY_ANONYMOUS, null)) |handle| {
            state.playBackHandle = handle;
        }

        if (!NOT_IGNORE) {
            var filePosition: win32.LARGE_INTEGER = undefined;
            filePosition.QuadPart = state.totalSize;
            _ = win32.SetFilePointerEx(state.playBackHandle, filePosition, null, win32.FILE_BEGIN);
        }

        CopyMemory(state.gameMemoryBlock, replayMemBlock, state.totalSize);
    }
}

fn Win32EndInputPlayBack(state: *win32_state) void {
    _ = win32.CloseHandle(state.playBackHandle);
    state.inputPlayingIndex = 0;
}

fn Win32RecordInput(state: *win32_state, newInput: *handmade.input) void {
    var bytesWritten = @as(DWORD, 0);
    _ = win32.WriteFile(state.recordingHandle, newInput, @sizeOf(@TypeOf(newInput.*)), &bytesWritten, null);
}

fn Win32PlayBackInput(state: *win32_state, newInput: *handmade.input) void {
    var bytesRead = @as(DWORD, 0);
    if (win32.ReadFile(state.playBackHandle, newInput, @sizeOf(@TypeOf(newInput.*)), &bytesRead, null) != win32.FALSE) {
        if (bytesRead == 0) {
            const playingIndex = state.inputPlayingIndex;
            Win32EndInputPlayBack(state);
            Win32BeginInputPlayBack(state, playingIndex);
            _ = win32.ReadFile(state.playBackHandle, newInput, @sizeOf(@TypeOf(newInput.*)), &bytesRead, null);
        }
    }
}

fn ToggleFullscreen(window: win32.HWND) void {
    const style = @intCast(u32, win32.GetWindowLongW(window, win32.GWL_STYLE));
    if ((style & @enumToInt(win32.WS_OVERLAPPEDWINDOW)) != 0) {
        var monitorInfo: win32.MONITORINFO = undefined;
        monitorInfo.cbSize = @sizeOf(win32.MONITORINFO);
        const windowPlacementSucceded = win32.GetWindowPlacement(window, &globalWindowPosition);
        const monitorFromWindow = win32.MonitorFromWindow(window, win32.MONITOR_DEFAULTTOPRIMARY);
        const monitorInfoSucceded = win32.GetMonitorInfoW(monitorFromWindow, &monitorInfo);

        if ((windowPlacementSucceded != win32.FALSE) and (monitorInfoSucceded) != win32.FALSE) {
            _ = win32.SetWindowLongW(window, win32.GWL_STYLE, @bitCast(i32, style & ~@enumToInt(win32.WS_OVERLAPPEDWINDOW)));
            _ = win32.SetWindowPos(
                window,
                null,
                monitorInfo.rcMonitor.left,
                monitorInfo.rcMonitor.top,
                monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left,
                monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top,
                @intToEnum(win32.SET_WINDOW_POS_FLAGS, @enumToInt(win32.SWP_NOOWNERZORDER) | @enumToInt(win32.SWP_FRAMECHANGED)),
            );
        }
    } else {
        _ = win32.SetWindowLongW(window, win32.GWL_STYLE, @bitCast(i32, style | @enumToInt(win32.WS_OVERLAPPEDWINDOW)));
        _ = win32.SetWindowPlacement(window, &globalWindowPosition);
        _ = win32.SetWindowPos(window, null, 0, 0, 0, 0, @intToEnum(
            win32.SET_WINDOW_POS_FLAGS,
            @enumToInt(win32.SWP_NOMOVE) | @enumToInt(win32.SWP_NOSIZE) | @enumToInt(win32.SWP_NOZORDER) | @enumToInt(win32.SWP_NOOWNERZORDER) | @enumToInt(win32.SWP_FRAMECHANGED),
        ));
    }
}

fn Win32ProcessPendingMessages(state: *win32_state, keyboardController: *handmade.controller_input) void {
    var message: win32.MSG = undefined;
    while (win32.PeekMessage(&message, null, 0, 0, win32.PM_REMOVE) != 0) {
        switch (message.message) {
            win32.WM_QUIT => globalRunning = false,
            win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
                const vkCode = @intToEnum(win32.VIRTUAL_KEY, message.wParam);
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
                        win32.VK_ESCAPE => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.back, @as(u32, @boolToInt(isDown))),
                        win32.VK_SPACE => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.start, @as(u32, @boolToInt(isDown))),
                        win32.VK_P => {
                            if (HANDMADE_INTERNAL) {
                                if (isDown) {
                                    globalPause = !globalPause;
                                }
                            }
                        },
                        win32.VK_L => {
                            if (HANDMADE_INTERNAL) {
                                if (isDown) {
                                    if (state.inputPlayingIndex == 0) {
                                        if (state.inputRecordingIndex == 0) {
                                            Win32BeginRecordingInput(state, 1);
                                        } else {
                                            Win32EndRecordingInput(state);
                                            Win32BeginInputPlayBack(state, 1);
                                        }
                                    } else {
                                        Win32EndInputPlayBack(state);
                                    }
                                }
                            }
                        },
                        else => {},
                    }
                }

                if (isDown) {
                    const altKeyWasDown = ((message.lParam & (1 << 29)) != 0);
                    if ((vkCode == win32.VK_F4) and altKeyWasDown) {
                        globalRunning = false;
                    }
                    if ((vkCode == win32.VK_RETURN) and altKeyWasDown) {
                        if (message.hwnd) |window| {
                            ToggleFullscreen(window);
                        }
                    }
                }
            },
            else => {
                _ = win32.TranslateMessage(&message);
                _ = win32.DispatchMessage(&message);
            },
        }
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

inline fn CopyMemory(dest: *anyopaque, source: *const anyopaque, size: usize) void {
    @memcpy(@ptrCast([*]u8, dest), @ptrCast([*]const u8, source), size);

    // NOTE (Manav): loop below is notoriously slow.
    // for (@ptrCast([*]const u8, source)[0..size]) |byte, index| {
    //     @ptrCast([*]u8, dest)[index] = byte;
    // }
}

// NOTE (Manav): Read this: https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=rdtsc&expand=375&ig_expand=465,463,5629,5629
inline fn rdtsc() u64 {
    var low: u64 = undefined;
    var high: u64 = undefined;

    asm ("rdtsc"
        : [low] "={eax}" (low),
          [high] "={edx}" (high),
    );

    return (high << 32) | low;
}

// !NOT_IGNORE:
// fn Win32DebugDrawVertical(backBuffer: *win32_offscreen_buffer, x: u32, top: u32, bottom: u32, colour: u32) void {
//     var safeTop = top;
//     var safeBottom = bottom;

//     if (safeBottom > backBuffer.height) {
//         safeBottom = backBuffer.height;
//     }
//     if (x < backBuffer.width) {
//         var pixel: [*]u8 = @ptrCast([*]u8, backBuffer.memory) + x * backBuffer.bytesPerPixel + safeTop * backBuffer.pitch;
//         var y = safeTop;
//         while (y < safeBottom) : (y += 1) {
//             @ptrCast(*u32, @alignCast(@alignOf(u32), pixel)).* = colour;
//             pixel += backBuffer.pitch;
//         }
//     }
// }

// fn Win32DebugSyncDisplay(backBuffer: *win32_offscreen_buffer, markerCount: u32, markers: [*]win32_debug_time_marker, currentMarkerIndex: u32, soundOutput: *win32_sound_output, targetSecondsPerFrame: f32) void {
//     _ = targetSecondsPerFrame;

//     const padX = 16;
//     const padY = 16;

//     const lineHeight = 64;

//     const coeff = @intToFloat(f32, (backBuffer.width - 2 * padX)) / @intToFloat(f32, soundOutput.secondaryBufferSize);
//     var markerIndex: u32 = 0;
//     while (markerIndex < markerCount) : (markerIndex += 1) {
//         const thisMarker = &markers[markerIndex];
//         std.debug.assert(thisMarker.outputPlayCursor < soundOutput.secondaryBufferSize);
//         std.debug.assert(thisMarker.outputWriteCursor < soundOutput.secondaryBufferSize);
//         std.debug.assert(thisMarker.outputLocation < soundOutput.secondaryBufferSize);
//         std.debug.assert(thisMarker.outputByteCount < soundOutput.secondaryBufferSize);
//         std.debug.assert(thisMarker.flipPlayCursor < soundOutput.secondaryBufferSize);
//         std.debug.assert(thisMarker.flipWriteCursor < soundOutput.secondaryBufferSize);

//         const playColour = 0xffffffff;
//         const writeColour = 0xffff0000;
//         const expectedFlipColour = 0xffffff00;
//         const playWindowColour = 0xffff00ff;

//         var top: u32 = padY;
//         var bottom: u32 = lineHeight + padY;
//         if (markerIndex == currentMarkerIndex) {
//             top += lineHeight + padY;
//             bottom += lineHeight + padY;

//             const firstTop = top;

//             Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputPlayCursor, playColour);
//             Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputWriteCursor, writeColour);

//             top += lineHeight + padY;
//             bottom += lineHeight + padY;

//             Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputLocation, playColour);
//             Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputLocation + thisMarker.outputByteCount, writeColour);

//             top += lineHeight + padY;
//             bottom += lineHeight + padY;

//             Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, firstTop, bottom, thisMarker.expectedFlipPlayCursor, expectedFlipColour);
//         }

//         Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipPlayCursor, playColour);
//         Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipPlayCursor + 480 * soundOutput.bytesPerSample, playWindowColour);
//         Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipWriteCursor, writeColour);
//     }
// }

// inline fn Win32DrawSoundBufferMarker(backBuffer: *win32_offscreen_buffer, soundOutput: *win32_sound_output, coeff: f32, padX: u32, top: u32, bottom: u32, value: DWORD, colour: u32) void {
//     _ = soundOutput;
//     const xReal32 = coeff * @intToFloat(f32, value);
//     const x = padX + @floatToInt(u32, xReal32);

//     Win32DebugDrawVertical(backBuffer, x, top, bottom, colour);
// }

// main -----------------------------------------------------------------------------------------------------------------------------------

pub export fn wWinMain(hInstance: ?win32.HINSTANCE, _: ?win32.HINSTANCE, _: [*:0]u16, _: u32) callconv(WINAPI) c_int {
    var win32State = win32_state{
        .gameMemoryBlock = undefined,
        .recordingHandle = undefined,
        .playBackHandle = undefined,
    };

    var perfCountFrequencyResult: win32.LARGE_INTEGER = undefined;
    _ = win32.QueryPerformanceFrequency(&perfCountFrequencyResult);
    globalPerfCounterFrequency = perfCountFrequencyResult.QuadPart;

    Win32GetEXEFileName(&win32State);

    var sourceGameCodeDLLFullPath = [_:0]u16{0} ** WIN32_STATE_FILE_NAME_COUNT;
    Win32BuildEXEPathFileName(&win32State, win32.L("handmade.dll"), sourceGameCodeDLLFullPath[0..WIN32_STATE_FILE_NAME_COUNT :0]);

    var tempGameCodeDLLFullPath = [_:0]u16{0} ** WIN32_STATE_FILE_NAME_COUNT;
    Win32BuildEXEPathFileName(&win32State, win32.L("handmade_temp.dll"), tempGameCodeDLLFullPath[0..WIN32_STATE_FILE_NAME_COUNT :0]);

    var gameCodeLockFullPath = [_:0]u16{0} ** WIN32_STATE_FILE_NAME_COUNT;
    Win32BuildEXEPathFileName(&win32State, win32.L("lock.tmp"), gameCodeLockFullPath[0..WIN32_STATE_FILE_NAME_COUNT :0]);

    const desiredSchedulerMS = 1;
    const sleepIsGranular = (win32.timeBeginPeriod(desiredSchedulerMS) == win32.TIMERR_NOERROR);

    Win32LoadXinput();

    Win32ResizeDIBSection(&globalBackBuffer, 960, 540);

    debugGlobalShowCursor = HANDMADE_INTERNAL;

    const windowclass = .{
        .style = @intToEnum(win32.WNDCLASS_STYLES, 0), // WS_EX_TOPMOST|WS_EX_LAYERED
        .lpfnWndProc = Win32MainWindowCallback,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = win32.L("HandmadeHeroWindowClass"),
    };

    if (win32.RegisterClass(&windowclass) != 0) {
        if (win32.CreateWindowExW(
            @intToEnum(win32.WINDOW_EX_STYLE, 0),
            windowclass.lpszClassName,
            win32.L("HandmadeHero"),
            @intToEnum(win32.WINDOW_STYLE, @enumToInt(win32.WS_OVERLAPPEDWINDOW) | @enumToInt(win32.WS_VISIBLE)),
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            null,
            null,
            hInstance,
            null,
        )) |windowHandle| {
            var monitorRefreshHz: u32 = 60;
            var win32RefreshRate: i32 = undefined;

            if (win32.GetDC(windowHandle)) |refreshDC| {
                defer _ = win32.ReleaseDC(windowHandle, refreshDC);

                win32RefreshRate = win32.GetDeviceCaps(refreshDC, win32.GET_DEVICE_CAPS_INDEX.VREFRESH);
            }

            if (win32RefreshRate > 1) {
                monitorRefreshHz = @intCast(u32, win32RefreshRate);
            }

            const gameUpdateHz = @divTrunc(monitorRefreshHz, 2);
            const targetSecondsPerFrame = 1.0 / @intToFloat(f32, gameUpdateHz);

            var soundOutput = win32_sound_output{
                .samplesPerSecond = 48000,
                .bytesPerSample = @sizeOf(i16) * 2,
            };

            soundOutput.secondaryBufferSize = soundOutput.samplesPerSecond * soundOutput.bytesPerSample;
            soundOutput.safetyBytes = @floatToInt(u32, (@intToFloat(f32, soundOutput.samplesPerSecond) * @intToFloat(f32, soundOutput.bytesPerSample) / @intToFloat(f32, gameUpdateHz)) / 3.0);

            Win32InitDSound(windowHandle, soundOutput.samplesPerSecond, soundOutput.secondaryBufferSize);
            Win32ClearBuffer(&soundOutput);
            _ = globalSecondaryBuffer.vtable.Play(globalSecondaryBuffer, 0, 0, win32.DSBPLAY_LOOPING);

            globalRunning = true;

            if (!NOT_IGNORE) {
                while (globalRunning) {
                    var playCursor: DWORD = 0;
                    var writeCursor: DWORD = 0;
                    _ = globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor);
                }
            }

            if (@ptrCast(?[*]i16, @alignCast(@alignOf(i16), win32.VirtualAlloc(
                null,
                soundOutput.secondaryBufferSize,
                allocationType,
                win32.PAGE_READWRITE,
            )))) |samples| {
                // defer _ = win32.VirtualFree();

                var gameMemory = handmade.memory{
                    .permanentStorageSize = handmade.MegaBytes(256),
                    .transientStorageSize = handmade.GigaBytes(1),
                    .permanentStorage = undefined,
                    .transientStorage = undefined,
                    .DEBUGPlatformFreeFileMemory = DEBUGWin32FreeFileMemory,
                    .DEBUGPlatformReadEntireFile = DEBUGWin32ReadEntireFile,
                    .DEBUGPlatformWriteEntireFile = DEBUGWin32WriteEntireFile,
                };

                const baseAddress = if (HANDMADE_INTERNAL) (@intToPtr([*]u8, handmade.TeraBytes(2))) else null;
                win32State.totalSize = gameMemory.permanentStorageSize + gameMemory.transientStorageSize;

                if (win32.VirtualAlloc(baseAddress, win32State.totalSize, allocationType, win32.PAGE_READWRITE)) |memory| {
                    // defer _ = win32.VirtualFree();

                    win32State.gameMemoryBlock = memory;
                    gameMemory.permanentStorage = @ptrCast([*]u8, win32State.gameMemoryBlock);
                    gameMemory.transientStorage = gameMemory.permanentStorage + gameMemory.permanentStorageSize;

                    var replayIndex: u32 = 1;
                    while (replayIndex < win32State.replayBuffers.len) : (replayIndex += 1) {
                        var replayBuffer = &win32State.replayBuffers[replayIndex];

                        Win32GetInputFileLocation(&win32State, false, replayIndex, replayBuffer.fileName[0..WIN32_STATE_FILE_NAME_COUNT :0]);

                        if (win32.CreateFileW(
                            &replayBuffer.fileName,
                            @intToEnum(win32.FILE_ACCESS_FLAGS, @enumToInt(win32.FILE_GENERIC_WRITE) | @enumToInt(win32.FILE_GENERIC_READ)),
                            win32.FILE_SHARE_NONE,
                            null,
                            win32.CREATE_ALWAYS,
                            win32.SECURITY_ANONYMOUS,
                            null,
                        )) |handle| {
                            replayBuffer.fileHandle = handle;
                        } else {
                            std.debug.print("Failed to create File Handle\n", .{});
                        }

                        var maxSize: win32.ULARGE_INTEGER = undefined;
                        maxSize.QuadPart = win32State.totalSize;

                        if (win32.CreateFileMappingW(
                            replayBuffer.fileHandle,
                            null,
                            win32.PAGE_READWRITE,
                            maxSize.u.HighPart,
                            maxSize.u.LowPart,
                            null,
                        )) |memoryMap| {
                            replayBuffer.memoryMap = memoryMap;
                        } else {
                            std.debug.print("Failed to create File Mapping\n", .{});
                        }

                        if (win32.MapViewOfFile(replayBuffer.memoryMap, win32.FILE_MAP_ALL_ACCESS, 0, 0, win32State.totalSize)) |memoryBlock| {
                            replayBuffer.memoryBlock = memoryBlock;
                        } else {
                            // TODO: diagnostic
                        }
                    }

                    var inputs = [1]handmade.input{handmade.input{}} ** 2;

                    var newInput = &inputs[0];
                    var oldInput = &inputs[1];

                    var lastCounter = Win32GetWallClock();
                    var flipWallClock = Win32GetWallClock();

                    var debugTimeMarkerIndex: u32 = 0;
                    var debugTimeMarkers = [1]win32_debug_time_marker{.{}} ** 30;

                    var audioLatencyBytes: DWORD = 0;
                    var audioLatencySeconds: f32 = 0;
                    var soundIsValid = false;

                    var gameCode = Win32LoadGameCode(&sourceGameCodeDLLFullPath, &tempGameCodeDLLFullPath, &gameCodeLockFullPath);
                    var loadCounter: u32 = 0;

                    var lastCycleCount = rdtsc();

                    while (globalRunning) {
                        newInput.dtForFrame = targetSecondsPerFrame;
                        const newDLLWriteTime = Win32GetLastWriteTime(&sourceGameCodeDLLFullPath);
                        if (win32.CompareFileTime(&newDLLWriteTime, &gameCode.dllLastWriteTime) != 0) {
                            Win32UnloadGameCode(&gameCode);
                            gameCode = Win32LoadGameCode(&sourceGameCodeDLLFullPath, &tempGameCodeDLLFullPath, &gameCodeLockFullPath);
                            loadCounter = 0;
                        }

                        const oldKeyboardController: *handmade.controller_input = &oldInput.controllers[0];
                        const newKeyboardController: *handmade.controller_input = &newInput.controllers[0];

                        newKeyboardController.* = handmade.controller_input{
                            .isConnected = true,
                        };

                        var buttonIndex: u8 = 0;
                        while (buttonIndex < newKeyboardController.buttons.states.len) : (buttonIndex += 1) {
                            newKeyboardController.buttons.states[buttonIndex].endedDown = oldKeyboardController.buttons.states[buttonIndex].endedDown;
                        }

                        Win32ProcessPendingMessages(&win32State, newKeyboardController);

                        if (!globalPause) {
                            var mouseP: win32.POINT = .{ .x = 0, .y = 0 };
                            _ = win32.GetCursorPos(&mouseP);
                            _ = win32.ScreenToClient(windowHandle, &mouseP);

                            newInput.mouseX = mouseP.x;
                            newInput.mouseY = mouseP.y;
                            newInput.mouseZ = 0;

                            Win32ProcessKeyboardMessage(
                                &newInput.mouseButtons[0],
                                @as(u32, (@bitCast(u16, win32.GetKeyState(@enumToInt(win32.VK_LBUTTON))) & (1 << 15))),
                            );
                            Win32ProcessKeyboardMessage(
                                &newInput.mouseButtons[1],
                                @as(u32, (@bitCast(u16, win32.GetKeyState(@enumToInt(win32.VK_MBUTTON))) & (1 << 15))),
                            );
                            Win32ProcessKeyboardMessage(
                                &newInput.mouseButtons[2],
                                @as(u32, (@bitCast(u16, win32.GetKeyState(@enumToInt(win32.VK_RBUTTON))) & (1 << 15))),
                            );
                            Win32ProcessKeyboardMessage(
                                &newInput.mouseButtons[3],
                                @as(u32, (@bitCast(u16, win32.GetKeyState(@enumToInt(win32.VK_XBUTTON1))) & (1 << 15))),
                            );
                            Win32ProcessKeyboardMessage(
                                &newInput.mouseButtons[4],
                                @as(u32, (@bitCast(u16, win32.GetKeyState(@enumToInt(win32.VK_XBUTTON2))) & (1 << 15))),
                            );

                            var maxControllerCount = win32.XUSER_MAX_COUNT;
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
                                    newController.isAnalog = oldController.isAnalog;

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

                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.start, win32.XINPUT_GAMEPAD_START, &newController.buttons.mapped.start);
                                    Win32ProcessXinputDigitalButton(pad.wButtons, &oldController.buttons.mapped.back, win32.XINPUT_GAMEPAD_BACK, &newController.buttons.mapped.back);
                                } else {
                                    newController.isConnected = false;
                                }
                            }

                            var thread = handmade.thread_context{};

                            var buffer = handmade.offscreen_buffer{
                                .memory = globalBackBuffer.memory,
                                .width = globalBackBuffer.width,
                                .height = globalBackBuffer.height,
                                .pitch = globalBackBuffer.pitch,
                                .bytesPerPixel = globalBackBuffer.bytesPerPixel,
                            };

                            if (win32State.inputRecordingIndex != 0) {
                                Win32RecordInput(&win32State, newInput);
                            }

                            if (win32State.inputPlayingIndex != 0) {
                                Win32PlayBackInput(&win32State, newInput);
                            }

                            if (gameCode.UpdateAndRender) |UpdateAndRender| {
                                UpdateAndRender(&thread, &gameMemory, newInput, &buffer);
                            }

                            const audioWallClock = Win32GetWallClock();
                            const fromBeginToAudioSeconds = Win32GetSecondsElapsed(flipWallClock, audioWallClock);

                            var playCursor: DWORD = 0;
                            var writeCursor: DWORD = 0;

                            if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor))) {
                                if (!soundIsValid) {
                                    soundOutput.runningSampleIndex = @divTrunc(writeCursor, soundOutput.bytesPerSample);
                                    soundIsValid = true;
                                }

                                const byteToLock = (soundOutput.runningSampleIndex * soundOutput.bytesPerSample) % soundOutput.secondaryBufferSize;

                                const expectedSoundBytesPerFrame = @divTrunc(soundOutput.samplesPerSecond * soundOutput.bytesPerSample, gameUpdateHz);
                                const secondsLeftUntilFLip = (targetSecondsPerFrame - fromBeginToAudioSeconds);
                                const expectedBytesUntilFlip = @floatToInt(i32, (secondsLeftUntilFLip / targetSecondsPerFrame) * @intToFloat(f32, expectedSoundBytesPerFrame));

                                const expectedFrameBoundaryByte = playCursor +% @bitCast(u32, expectedBytesUntilFlip);

                                var safeWriteCursor = writeCursor;
                                if (safeWriteCursor < playCursor) {
                                    safeWriteCursor +%= soundOutput.secondaryBufferSize;
                                }
                                std.debug.assert(safeWriteCursor >= playCursor);
                                safeWriteCursor +%= soundOutput.safetyBytes;

                                const audioCardIsLowLatency = safeWriteCursor < expectedFrameBoundaryByte;

                                var targetCursor: DWORD = 0;
                                if (audioCardIsLowLatency) {
                                    targetCursor = expectedFrameBoundaryByte +% expectedSoundBytesPerFrame;
                                } else {
                                    targetCursor = writeCursor +% expectedSoundBytesPerFrame +% soundOutput.safetyBytes;
                                }

                                targetCursor = targetCursor % soundOutput.secondaryBufferSize;

                                var bytesToWrite: DWORD = 0;
                                if (byteToLock > targetCursor) {
                                    bytesToWrite = soundOutput.secondaryBufferSize - byteToLock;
                                    bytesToWrite += targetCursor;
                                } else {
                                    bytesToWrite = targetCursor - byteToLock;
                                }

                                var soundBuffer = handmade.sound_output_buffer{
                                    .samplesPerSecond = soundOutput.samplesPerSecond,
                                    .sampleCount = @divTrunc(bytesToWrite, soundOutput.bytesPerSample),
                                    .samples = samples,
                                };

                                if (gameCode.GetSoundSamples) |GetSoundSamples| {
                                    GetSoundSamples(&thread, &gameMemory, &soundBuffer);
                                }

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

                                    if (!NOT_IGNORE) {
                                        var textbuffer = [1]u16{0} ** 256;
                                        _ = win32.extra.wsprintfW(&textbuffer, win32.L("BTL:%u TC:%u BTW:%u - PC:%u WC:%u DELTA:%u (%fs)\n"), byteToLock, targetCursor, bytesToWrite, playCursor, writeCursor, audioLatencyBytes, audioLatencySeconds);
                                        _ = win32.OutputDebugStringW(&textbuffer);
                                    }
                                }
                                Win32FillSoundBuffer(&soundOutput, byteToLock, bytesToWrite, &soundBuffer);
                            } else {
                                soundIsValid = false;
                            }

                            const workCounter = Win32GetWallClock();
                            const workSecondsElapsed = Win32GetSecondsElapsed(lastCounter, workCounter);

                            var secondsElapsedForFrame = workSecondsElapsed;
                            if (secondsElapsedForFrame < targetSecondsPerFrame) {
                                if (sleepIsGranular) {
                                    const sleepMS = @floatToInt(DWORD, (1000.0 * (targetSecondsPerFrame - secondsElapsedForFrame)));
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

                            if (win32.GetDC(windowHandle)) |deviceContext| {
                                defer _ = win32.ReleaseDC(windowHandle, deviceContext);

                                Win32DisplayBufferInWindow(&globalBackBuffer, deviceContext, dimension.width, dimension.height);
                            }

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

                            if (!NOT_IGNORE) {
                                var endCycleCount = rdtsc();
                                const cyclesElapsed = endCycleCount - lastCycleCount;
                                lastCycleCount = endCycleCount;

                                const fps: f64 = 0;
                                const mcpf = @intToFloat(f64, cyclesElapsed) / (1000 * 1000);
                                var fpsBuffer = [1]u16{0} ** 256;
                                _ = win32.extra.wsprintfW(&fpsBuffer, win32.L("%.02fms/f,  %.02ff/s,  %.02fmc/f\n"), msPerFrame, fps, mcpf);
                                _ = win32.OutputDebugStringW(&fpsBuffer);
                            }

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
        } else {
            // TODO: LOGGING
        }
    } else {
        // TODO: LOGGING
    }

    return 0;
}

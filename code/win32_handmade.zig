const std = @import("std");

const WINAPI = std.os.windows.WINAPI;
const DWORD = std.os.windows.DWORD;

pub const UNICODE = true;

const win32 = struct {
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").graphics.gdi;
    usingnamespace @import("win32").media;
    usingnamespace @import("win32").media.audio;
    usingnamespace @import("win32").media.audio.direct_sound;
    usingnamespace @import("win32").storage.file_system;
    usingnamespace @import("win32").system.com;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").system.io;
    usingnamespace @import("win32").system.library_loader;
    usingnamespace @import("win32").system.memory;
    usingnamespace @import("win32").system.performance;
    usingnamespace @import("win32").system.threading;
    usingnamespace @import("win32").ui.input.keyboard_and_mouse;
    usingnamespace @import("win32").ui.input.xbox_controller;
    usingnamespace @import("win32").ui.windows_and_messaging;

    usingnamespace @import("win32").zig;

    const x = struct {
        extern "USER32" fn wsprintfW(
            param0: ?win32.PWSTR,
            param1: ?[*:0]const u16,
            ...,
        ) callconv(@import("std").os.windows.WINAPI) i32;

        extern "USER32" fn wsprintfA(
            param0: ?win32.PSTR,
            param1: ?[*:0]const u8,
            ...,
        ) callconv(@import("std").os.windows.WINAPI) i32;

        const SEMAPHORE_ALL_ACCESS = 0x1f003;
        const INFINITE = @as(u32, 4294967295);
        const INVALID_FIND_HANDLE_VALUE = @as(win32.FindFileHandle, -1);
    };
};

const Atomic = std.atomic.Atomic;

const platform = @import("handmade_platform");
const handmade_internal = platform.handmade_internal;

// constants ------------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = platform.NOT_IGNORE;
const HANDMADE_INTERNAL = platform.HANDMADE_INTERNAL;
const WIN32_STATE_FILE_NAME_COUNT = win32.MAX_PATH;

const allocationReserveCommit = win32.VIRTUAL_ALLOCATION_TYPE{ .RESERVE = 1, .COMMIT = 1 }; // = @enumFromInt(@intFromEnum(win32.MEM_RESERVE) | @intFromEnum(win32.MEM_COMMIT));

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
    gameCodeDLL: ?win32.HINSTANCE = null,
    dllLastWriteTime: win32.FILETIME = undefined,
    UpdateAndRender: ?platform.UpdateAndRenderFnPtrType = null,
    GetSoundSamples: ?platform.GetSoundSamplesFnPtrType = null,

    isValid: bool = false,
};

const win32_replay_buffer = struct {
    fileHandle: win32.HANDLE = undefined,
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

var globalDebug: platform.debug = .{};

// library defs ---------------------------------------------------------------------------------------------------------------------------

var XInputGetState: *const fn (u32, ?*win32.XINPUT_STATE) callconv(WINAPI) isize = undefined;
var XInputSetState: *const fn (u32, ?*win32.XINPUT_VIBRATION) callconv(WINAPI) isize = undefined;

// Debug/temp functions ------------------------------------------------------------------------------------------------------------------

fn CatStrings(sourceA: []const u16, sourceB: []const u16, dest: [:0]u16) void {
    var i: usize = 0;
    for (sourceA, 0..) |charA, index| {
        dest[index] = charA;
        i = index;
    }

    for (sourceB, 0..) |charB, index| {
        dest[i + index] = charB;
    }
}

fn Win32GetEXEFileName(gameState: *win32_state) void {
    const sizeOfFilename = win32.GetModuleFileNameW(null, &gameState.exeFileName, @sizeOf(@TypeOf(gameState.exeFileName)));
    _ = sizeOfFilename;

    for (gameState.exeFileName, 0..) |char, scanIndex| {
        if (char == '\\') gameState.onePastLastEXEFileNameSlashIndex = scanIndex + 2;
    }
}

fn Win32BuildEXEPathFileName(gameState: *win32_state, filename: []const u16, dest: [:0]u16) void {
    CatStrings(gameState.exeFileName[0..gameState.onePastLastEXEFileNameSlashIndex], filename, dest);
}

fn DEBUGWin32FreeFileMemory(memory: *anyopaque) void {
    _ = win32.VirtualFree(memory, 0, win32.MEM_RELEASE);
}

fn DEBUGWin32ReadEntireFile(filename: [*:0]const u8) handmade_internal.debug_read_file_result {
    var result = handmade_internal.debug_read_file_result{};
    var fileHandle = win32.CreateFileA(filename, win32.FILE_GENERIC_READ, win32.FILE_SHARE_READ, null, win32.OPEN_EXISTING, win32.SECURITY_ANONYMOUS, null);

    if (fileHandle != win32.INVALID_HANDLE_VALUE) {
        var fileSize = win32.LARGE_INTEGER{ .QuadPart = 0 };
        if (win32.GetFileSizeEx(fileHandle, &fileSize) != 0) {
            var fileSize32 = if (fileSize.QuadPart < 0xFFFFFFFF) @as(u32, @intCast(fileSize.QuadPart)) else platform.InvalidCodePath("");
            if (win32.VirtualAlloc(null, fileSize32, allocationReserveCommit, win32.PAGE_READWRITE)) |data| {
                var bytesRead: DWORD = 0;
                if (win32.ReadFile(fileHandle, data, fileSize32, &bytesRead, null) != 0 and fileSize32 == bytesRead) {
                    result.contents = @as([*]u8, @ptrCast(data));
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
        std.debug.print("Failed to create File Handle: {s}\n", .{"DEBUGWin32ReadEntireFile"});
    }

    return result;
}

fn DEBUGWin32WriteEntireFile(fileName: [*:0]const u8, memorySize: u32, memory: *anyopaque) bool {
    var result = false;
    var fileHandle = win32.CreateFileA(fileName, win32.FILE_GENERIC_WRITE, win32.FILE_SHARE_NONE, null, win32.CREATE_ALWAYS, win32.SECURITY_ANONYMOUS, null);

    if (fileHandle != win32.INVALID_HANDLE_VALUE) {
        var bytesWritten: DWORD = 0;
        if (win32.WriteFile(fileHandle, memory, memorySize, &bytesWritten, null) != 0) {
            result = (bytesWritten == memorySize);
        } else {
            // TODO: logging
        }

        _ = win32.CloseHandle(fileHandle);
    } else {
        std.debug.print("Failed to create File Handle: {s}\n", .{"DEBUGWin32WriteEntireFile"});
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
        if (result.gameCodeDLL != null) {
            result.UpdateAndRender = @ptrCast(win32.GetProcAddress(result.gameCodeDLL, "UpdateAndRender"));
            result.GetSoundSamples = @ptrCast(win32.GetProcAddress(result.gameCodeDLL, "GetSoundSamples"));

            result.isValid = (result.UpdateAndRender != null and result.GetSoundSamples != null);
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
            XInputGetState = @as(@TypeOf(XInputGetState), @ptrCast(funcptr));
        } else {
            const state = struct {
                fn XInputGetStateInternal(_: u32, _: ?*win32.XINPUT_STATE) callconv(WINAPI) isize {
                    return @intFromEnum(win32.ERROR_DEVICE_NOT_CONNECTED);
                }
            };
            XInputGetState = state.XInputGetStateInternal;
        }

        if (win32.GetProcAddress(XInputLibrary, "XInputSetState")) |funcptr| {
            XInputSetState = @as(@TypeOf(XInputSetState), @ptrCast(funcptr));
        } else {
            const state = struct {
                fn XInputSetStateInternal(_: u32, _: ?*win32.XINPUT_VIBRATION) callconv(WINAPI) isize {
                    return @intFromEnum(win32.ERROR_DEVICE_NOT_CONNECTED);
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
            const DirectSoundCreateFnPtrType = *const fn (?*const win32.Guid, ?*?*win32.IDirectSound, ?*win32.IUnknown) callconv(WINAPI) i32;
            const DirectSoundCreate = @as(DirectSoundCreateFnPtrType, @ptrCast(funcptr));

            var dS: ?*win32.IDirectSound = null;
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

                    if (HANDMADE_INTERNAL) {
                        bufferDescription.dwFlags |= win32.DSBCAPS_GLOBALFOCUS;
                    }

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
    buffer.info.bmiHeader.biWidth = @as(i32, @intCast(buffer.width));
    buffer.info.bmiHeader.biHeight = @as(i32, @intCast(buffer.height));
    buffer.info.bmiHeader.biPlanes = 1;
    buffer.info.bmiHeader.biBitCount = 32;
    buffer.info.bmiHeader.biCompression = win32.BI_RGB;

    buffer.pitch = platform.Align(@as(usize, @intCast(width)) * bytesPerPixel, @alignOf(u16));

    const bitmapMemorySize: usize = buffer.pitch * buffer.height;
    buffer.memory = win32.VirtualAlloc(null, bitmapMemorySize, allocationReserveCommit, win32.PAGE_READWRITE);
}

fn Win32DisplayBufferInWindow(buffer: *win32_offscreen_buffer, deviceContext: win32.HDC, windowWidth: i32, windowHeight: i32) void {
    if ((windowWidth >= buffer.width * 2) and (windowHeight >= buffer.height * 2)) {
        _ = win32.StretchDIBits(
            deviceContext,
            0,
            0,
            @as(i32, @intCast(2 * buffer.width)),
            @as(i32, @intCast(2 * buffer.height)),
            0,
            0,
            @as(i32, @intCast(buffer.width)),
            @as(i32, @intCast(buffer.height)),
            buffer.memory,
            &buffer.info,
            win32.DIB_RGB_COLORS,
            win32.SRCCOPY,
        );
    } else {
        var offsetX: i32 = 0;
        var offsetY: i32 = 0;

        if (!NOT_IGNORE) {
            offsetX = 10;
            offsetY = 10;

            _ = win32.PatBlt(deviceContext, 0, 0, windowWidth, offsetY, win32.ROP_CODE.BLACKNESS);
            _ = win32.PatBlt(deviceContext, 0, offsetY + @as(i32, @intCast(buffer.height)), windowWidth, windowHeight, win32.ROP_CODE.BLACKNESS);
            _ = win32.PatBlt(deviceContext, 0, 0, offsetX, windowHeight, win32.ROP_CODE.BLACKNESS);
            _ = win32.PatBlt(deviceContext, offsetX + @as(i32, @intCast(buffer.width)), 0, windowWidth, windowHeight, win32.ROP_CODE.BLACKNESS);
        }

        _ = win32.StretchDIBits(
            deviceContext,
            offsetX,
            offsetY,
            @as(i32, @intCast(buffer.width)),
            @as(i32, @intCast(buffer.height)),
            0,
            0,
            @as(i32, @intCast(buffer.width)),
            @as(i32, @intCast(buffer.height)),
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
                    _ = win32.SetLayeredWindowAttributes(windowHandle, @as(u32, @bitCast(win32.RGBQUAD{ .rgbBlue = 0, .rgbGreen = 0, .rgbRed = 0, .rgbReserved = 0 })), 255, win32.LWA_ALPHA);
                } else {
                    _ = win32.SetLayeredWindowAttributes(windowHandle, @as(u32, @bitCast(win32.RGBQUAD{ .rgbBlue = 0, .rgbGreen = 0, .rgbRed = 0, .rgbReserved = 0 })), 128, win32.LWA_ALPHA);
                }
            }
        },

        win32.WM_DESTROY => globalRunning = false,

        win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
            platform.InvalidCodePath("Keyboard input came in through a non-dispatch message!");
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
            var destSample = @as([*]u8, @ptrCast(ptr));
            var byteIndex: DWORD = 0;
            while (byteIndex < region1Size) : (byteIndex += 1) {
                destSample[byteIndex] = 0;
            }
        }

        if (region2) |ptr| {
            var destSample = @as([*]u8, @ptrCast(ptr));
            var byteIndex: DWORD = 0;
            while (byteIndex < region2Size) : (byteIndex += 1) {
                destSample[byteIndex] = 0;
            }
        }

        _ = globalSecondaryBuffer.vtable.Unlock(globalSecondaryBuffer, region1, region1Size, region2, region2Size);
    }
}

fn Win32FillSoundBuffer(soundOutput: *win32_sound_output, byteToLock: DWORD, bytesToWrite: DWORD, sourceBuffer: *platform.sound_output_buffer) void {
    var region1: ?*anyopaque = undefined;
    var region1Size: DWORD = undefined;
    var region2: ?*anyopaque = undefined;
    var region2Size: DWORD = undefined;

    if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.Lock(globalSecondaryBuffer, byteToLock, bytesToWrite, &region1, &region1Size, &region2, &region2Size, 0))) {
        if (region1) |ptr| {
            const region1SampleCount = region1Size / soundOutput.bytesPerSample;
            var destSample: [*]i16 = @alignCast(@ptrCast(ptr));
            var sourceSample = sourceBuffer.samples;

            for (0..region1SampleCount) |sampleIndex| {
                destSample[2 * sampleIndex] = sourceSample[2 * sampleIndex];
                destSample[2 * sampleIndex + 1] = sourceSample[2 * sampleIndex + 1];

                soundOutput.runningSampleIndex += 1;
            }
        }

        if (region2) |ptr| {
            const region2SampleCount = region2Size / soundOutput.bytesPerSample;
            var destSample: [*]i16 = @alignCast(@ptrCast(ptr));
            var sourceSample = sourceBuffer.samples;

            for (0..region2SampleCount) |sampleIndex| {
                destSample[2 * sampleIndex] = sourceSample[2 * sampleIndex];
                destSample[2 * sampleIndex + 1] = sourceSample[2 * sampleIndex + 1];

                soundOutput.runningSampleIndex += 1;
            }
        }

        _ = globalSecondaryBuffer.vtable.Unlock(globalSecondaryBuffer, region1, region1Size, region2, region2Size);
    }
}

fn Win32ProcessKeyboardMessage(newState: *platform.button_state, isDown: u32) void {
    if (newState.endedDown != isDown) {
        newState.endedDown = isDown;
        newState.haltTransitionCount += 1;
    }
}

fn Win32ProcessXinputDigitalButton(xInputButtonState: DWORD, oldState: *platform.button_state, buttonBit: DWORD, newState: *platform.button_state) void {
    newState.endedDown = @as(u32, @intFromBool((xInputButtonState & buttonBit) == buttonBit));
    newState.haltTransitionCount = if (oldState.endedDown != newState.endedDown) 1 else 0;
}

fn Win32ProcessXInputStickValue(value: i16, deadZoneThreshold: u32) f32 {
    var result: f32 = 0;

    if (value < -@as(i32, @intCast(deadZoneThreshold))) {
        result = @as(f32, @floatFromInt(@as(i32, value) + @as(i32, @intCast(deadZoneThreshold)))) / (32768.0 - @as(f32, @floatFromInt(deadZoneThreshold)));
    } else if (value > deadZoneThreshold) {
        result = @as(f32, @floatFromInt(@as(i32, value) - @as(i32, @intCast(deadZoneThreshold)))) / (32767.0 - @as(f32, @floatFromInt(deadZoneThreshold)));
    }

    return result;
}

fn Win32GetInputFileLocation(state: *win32_state, inputStream: bool, slotIndex: usize, dest: [:0]u16) void {
    var exeName: [64]u16 = [1]u16{0} ** 64;

    const s = if (inputStream) win32.L("input") else win32.L("state");

    _ = win32.x.wsprintfW(@ptrCast(&exeName), win32.L("loop_edit_%d_%s.hmi"), slotIndex, s);

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

        const handle = win32.CreateFileW(&fileName, win32.FILE_GENERIC_WRITE, win32.FILE_SHARE_NONE, null, win32.CREATE_ALWAYS, win32.SECURITY_ANONYMOUS, null);

        if (handle != win32.INVALID_HANDLE_VALUE) {
            state.recordingHandle = handle;
        } else {
            std.debug.print("Failed to create File Handle: {s}\n", .{"Win32BeginRecordingInput"});
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

        const handle = win32.CreateFileW(&fileName, win32.FILE_GENERIC_READ, win32.FILE_SHARE_NONE, null, win32.OPEN_EXISTING, win32.SECURITY_ANONYMOUS, null);

        if (handle != win32.INVALID_HANDLE_VALUE) {
            state.playBackHandle = handle;
        } else {
            std.debug.print("Failed to create File Handle: {s}\n", .{"Win32BeginInputPlayBack"});
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

fn Win32RecordInput(state: *win32_state, newInput: *platform.input) void {
    var bytesWritten = @as(DWORD, 0);
    _ = win32.WriteFile(state.recordingHandle, newInput, @sizeOf(@TypeOf(newInput.*)), &bytesWritten, null);
}

fn Win32PlayBackInput(state: *win32_state, newInput: *platform.input) void {
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
    const style = @as(u32, @intCast(win32.GetWindowLongW(window, win32.GWL_STYLE)));
    if ((style & @as(u32, @bitCast(win32.WS_OVERLAPPEDWINDOW))) != 0) {
        var monitorInfo: win32.MONITORINFO = undefined;
        monitorInfo.cbSize = @sizeOf(win32.MONITORINFO);
        const windowPlacementSucceded = win32.GetWindowPlacement(window, &globalWindowPosition);
        const monitorFromWindow = win32.MonitorFromWindow(window, win32.MONITOR_DEFAULTTOPRIMARY);
        const monitorInfoSucceded = win32.GetMonitorInfoW(monitorFromWindow, &monitorInfo);

        if ((windowPlacementSucceded != win32.FALSE) and (monitorInfoSucceded) != win32.FALSE) {
            _ = win32.SetWindowLongW(window, win32.GWL_STYLE, @as(i32, @bitCast(style & ~@as(u32, @bitCast(win32.WS_OVERLAPPEDWINDOW)))));
            _ = win32.SetWindowPos(
                window,
                null,
                monitorInfo.rcMonitor.left,
                monitorInfo.rcMonitor.top,
                monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left,
                monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top,
                win32.SET_WINDOW_POS_FLAGS{ .NOOWNERZORDER = 1, .DRAWFRAME = 1 }, // win32.SWP_NOOWNERZORDER ! win32.SWP_FRAMECHANGED
            );
        }
    } else {
        _ = win32.SetWindowLongW(window, win32.GWL_STYLE, @as(i32, @bitCast(style | @as(u32, @bitCast(win32.WS_OVERLAPPEDWINDOW)))));
        _ = win32.SetWindowPlacement(window, &globalWindowPosition);
        _ = win32.SetWindowPos(window, null, 0, 0, 0, 0, win32.SET_WINDOW_POS_FLAGS{
            // win32.SWP_NOMOVE | win32.SWP_NOSIZE | win32.SWP_NOZORDER | win32.SWP_NOOWNERZORDER | win32.SWP_FRAMECHANGED
            .NOMOVE = 1,
            .NOSIZE = 1,
            .NOZORDER = 1,
            .NOOWNERZORDER = 1,
            .DRAWFRAME = 1,
        });
    }
}

fn Win32ProcessPendingMessages(state: *win32_state, keyboardController: *platform.controller_input) void {
    var message: win32.MSG = undefined;
    while (win32.PeekMessage(&message, null, 0, 0, win32.PM_REMOVE) != 0) {
        switch (message.message) {
            win32.WM_QUIT => globalRunning = false,
            win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
                const vkCode: win32.VIRTUAL_KEY = @enumFromInt(message.wParam);
                const wasDown = ((message.lParam & (1 << 30)) != 0);
                const isDown = ((message.lParam & (1 << 31)) == 0);

                if (wasDown != isDown) {
                    switch (vkCode) {
                        win32.VK_W => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveUp, @intFromBool(isDown)),
                        win32.VK_A => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveLeft, @intFromBool(isDown)),
                        win32.VK_S => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveDown, @intFromBool(isDown)),
                        win32.VK_D => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.moveRight, @intFromBool(isDown)),
                        win32.VK_Q => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.leftShoulder, @intFromBool(isDown)),
                        win32.VK_E => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.rightShoulder, @intFromBool(isDown)),
                        win32.VK_UP => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionUp, @intFromBool(isDown)),
                        win32.VK_LEFT => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionLeft, @intFromBool(isDown)),
                        win32.VK_DOWN => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionDown, @intFromBool(isDown)),
                        win32.VK_RIGHT => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.actionRight, @intFromBool(isDown)),
                        win32.VK_ESCAPE => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.back, @intFromBool(isDown)),
                        win32.VK_SPACE => Win32ProcessKeyboardMessage(&keyboardController.buttons.mapped.start, @intFromBool(isDown)),
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

fn HandleDebugCycleCounters(gameMemory: *platform.memory) void {
    if (HANDMADE_INTERNAL) {
        _ = win32.OutputDebugStringW(win32.L("DEBUG CYCLE COUNTS:\n"));
        for (&gameMemory.counters) |*counter| {
            if (counter.hitCount > 0) {
                var textbuffer = [1]u16{0} ** 256;
                _ = win32.x.wsprintfW(
                    @as([*:0]u16, @ptrCast(&textbuffer)),
                    win32.L("%S - %I64ucy %dh %I64ucy/h\n"),
                    @tagName(counter.t).ptr,
                    counter.cycleCount,
                    counter.hitCount,
                    counter.cycleCount / counter.hitCount,
                );
                _ = win32.OutputDebugStringW(@as([*:0]u16, @ptrCast(&textbuffer)));

                counter.hitCount = 0;
                counter.cycleCount = 0;
            }
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
    const result = @as(f32, @floatFromInt((end.QuadPart - start.QuadPart))) / @as(f32, @floatFromInt(globalPerfCounterFrequency));

    return result;
}

inline fn CopyMemory(dest: *anyopaque, source: *const anyopaque, size: usize) void {
    const d: [*]u8 = @ptrCast(dest);
    const s: [*]const u8 = @ptrCast(source);

    @memcpy(d[0..size], s[0..size]);

    // // NOTE (Manav): loop below is incredibly slow.
    // for (@as([*]const u8, @ptrCast(source))[0..size], 0..) |byte, index| {
    //     @as([*]u8, @ptrCast(dest))[index] = byte;
    // }
}

// TODO (Manav): Do something about this, rdtsc already exists in handmade_internal
inline fn rdtsc() u64 {
    var low: u64 = undefined;
    var high: u64 = undefined;

    asm volatile ("rdtsc"
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
//         var pixel: [*]u8 = @as([*]u8, @ptrCast(backBuffer.memory)) + x * backBuffer.bytesPerPixel + safeTop * backBuffer.pitch;
//         var y = safeTop;
//         while (y < safeBottom) : (y += 1) {
//             @as(*u32, @ptrCast(@alignCast(pixel))).* = colour;
//             pixel += backBuffer.pitch;
//         }
//     }
// }

// fn Win32DebugSyncDisplay(backBuffer: *win32_offscreen_buffer, markerCount: u32, markers: [*]win32_debug_time_marker, currentMarkerIndex: u32, soundOutput: *win32_sound_output, targetSecondsPerFrame: f32) void {
//     _ = targetSecondsPerFrame;

//     const padX = 16;
//     const padY = 16;

//     const lineHeight = 64;

//     const coeff = @as(f32, @floatFromInt((backBuffer.width - 2 * padX))) / @as(f32, @floatFromInt(soundOutput.secondaryBufferSize));
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
//         _ = playWindowColour;

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

//             // Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputLocation, playColour);
//             // Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.outputLocation + thisMarker.outputByteCount, writeColour);

//             top += lineHeight + padY;
//             bottom += lineHeight + padY;

//             Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, firstTop, bottom, thisMarker.expectedFlipPlayCursor, expectedFlipColour);
//         }

//         // Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipPlayCursor, playColour);
//         // Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipPlayCursor + 480 * soundOutput.bytesPerSample, playWindowColour);
//         // Win32DrawSoundBufferMarker(backBuffer, soundOutput, coeff, padX, top, bottom, thisMarker.flipWriteCursor, writeColour);
//     }
// }

// inline fn Win32DrawSoundBufferMarker(backBuffer: *win32_offscreen_buffer, soundOutput: *win32_sound_output, coeff: f32, padX: u32, top: u32, bottom: u32, value: DWORD, colour: u32) void {
//     _ = soundOutput;
//     const xReal32 = coeff * @as(f32, @floatFromInt(value));
//     const x = padX + @as(u32, @intFromFloat(xReal32));

//     Win32DebugDrawVertical(backBuffer, x, top, bottom, colour);
// }

// main -----------------------------------------------------------------------------------------------------------------------------------

const win32_work_queue_entry = struct {
    callback: ?platform.work_queue_callback = null,
    data: ?*anyopaque = null,
};

const win32_work_queue = struct {
    const Self = @This();

    completionGoal: Atomic(u32) = Atomic(u32).init(0),
    completionCount: Atomic(u32) = Atomic(u32).init(0),

    nextEntryToWrite: Atomic(u32) = Atomic(u32).init(0),
    nextEntryToRead: Atomic(u32) = Atomic(u32).init(0),
    semaphoreHandle: ?win32.HANDLE = null,

    entries: [256]win32_work_queue_entry = [1]win32_work_queue_entry{.{}} ** 256,

    fn MakeQueue(queue: *win32_work_queue, comptime threadCount: comptime_int) void {
        const initialCount = 0;

        queue.semaphoreHandle = win32.CreateSemaphoreEx(null, initialCount, threadCount, null, 0, win32.x.SEMAPHORE_ALL_ACCESS);

        var threadIndex = @as(u32, 0);
        while (threadIndex < threadCount) : (threadIndex += 1) {
            var threadID: DWORD = 0;
            var threadHandle = win32.CreateThread(
                null,
                0,
                ThreadProc,
                @ptrCast(queue),
                win32.THREAD_CREATE_RUN_IMMEDIATELY,
                &threadID,
            );

            // std.debug.print("Created thread {} with id: {}\n", .{ info.logicalThreadIndex, threadID });
            _ = win32.CloseHandle(threadHandle);
        }
    }

    fn from(queue: *platform.work_queue) *Self {
        return @alignCast(@ptrCast(queue));
    }

    fn to(self: *Self) *platform.work_queue {
        return @ptrCast(self);
    }
};

fn Win32AddEntry(q: *platform.work_queue, callback: platform.work_queue_callback, data: *anyopaque) void {
    const queue = win32_work_queue.from(q);

    const newNextEntryToWrite: u32 = ((queue.nextEntryToWrite.value + 1) % @as(u32, queue.entries.len));

    std.debug.assert(newNextEntryToWrite != queue.nextEntryToRead.value);

    const entry: *win32_work_queue_entry = &queue.entries[queue.nextEntryToWrite.value];
    entry.data = data;
    entry.callback = callback;

    _ = queue.completionGoal.fetchAdd(1, .Monotonic);
    queue.nextEntryToWrite.store(newNextEntryToWrite, .SeqCst);

    _ = win32.ReleaseSemaphore(queue.semaphoreHandle, 1, null);
}

fn Win32DoNextWorkQueueEntry(queue: *win32_work_queue) bool {
    var weShouldSleep = false;

    const originalNextEntryToRead = queue.nextEntryToRead.load(.SeqCst);
    const newNextEntryToRead = (originalNextEntryToRead + 1) % @as(u32, queue.entries.len);
    if (originalNextEntryToRead != queue.nextEntryToWrite.load(.SeqCst)) {
        if (queue.nextEntryToRead.compareAndSwap(originalNextEntryToRead, newNextEntryToRead, .SeqCst, .SeqCst)) |_| {} else {
            var entry = queue.entries[originalNextEntryToRead];
            entry.callback.?(queue.to(), entry.data.?);
            _ = queue.completionCount.fetchAdd(1, .SeqCst);
        }
    } else {
        weShouldSleep = true;
    }

    return weShouldSleep;
}

fn Win32CompleteAllWork(q: *platform.work_queue) void {
    const queue = win32_work_queue.from(q);
    while (queue.completionGoal.value != queue.completionCount.value) {
        _ = Win32DoNextWorkQueueEntry(queue);
    }

    queue.completionGoal.store(0, .SeqCst);
    queue.completionCount.store(0, .SeqCst);
}

fn ThreadProc(lpParameter: ?*anyopaque) callconv(WINAPI) DWORD {
    const queue: *win32_work_queue = @alignCast(@ptrCast(lpParameter.?));

    while (true) {
        if (Win32DoNextWorkQueueEntry(queue)) {
            _ = win32.WaitForSingleObjectEx(queue.semaphoreHandle, win32.x.INFINITE, win32.FALSE);
        }
    }

    return 0;
}

fn DoWorkerWork(_: ?*platform.work_queue, data: *anyopaque) void {
    var buffer = [1:0]u8{0} ** 256;

    // std.debug.print("Thread {}: {s}\n", .{ win32.GetCurrentThreadId(), @ptrCast([*:0]const u8, data) });
    _ = win32.x.wsprintfA(&buffer, "Thread %u: %s\n", win32.GetCurrentThreadId(), @as([*:0]const u8, @ptrCast(data)));
    _ = win32.OutputDebugStringA(&buffer);
}

const win32_platform_file_handle = extern struct {
    h: platform.file_handle,
    win32Handle: win32.HANDLE,
};

const win32_platform_file_group = extern struct {
    h: platform.file_group,
    fileHandle: win32.FindFileHandle,
    findData: win32.WIN32_FIND_DATAW,
};

fn Win32GetAllFilesOfTypeBegin(extension: []const u8) *platform.file_group {
    var win32FileGroup: *win32_platform_file_group = @alignCast(@ptrCast(win32.VirtualAlloc(null, @sizeOf(win32_platform_file_group), allocationReserveCommit, win32.PAGE_READWRITE).?));

    var wildcard = [2]u8{ '*', '.' } ++ [1]u8{0} ** 30;

    for (2..wildcard.len) |i| {
        if (i - 2 >= extension.len) {
            break;
        }
        wildcard[i] = extension[i - 2];
    }

    var wildcard_l = [1:0]u16{0} ** 32;
    _ = std.unicode.utf8ToUtf16Le(wildcard_l[0..], wildcard[0..]) catch |err| {
        std.debug.print("{}\n", .{err});
    };

    win32FileGroup.h.fileCount = 0;

    var findData: win32.WIN32_FIND_DATAW = undefined;
    var fileHandle = win32.FindFirstFileW(&wildcard_l, &findData);

    while (fileHandle != win32.x.INVALID_FIND_HANDLE_VALUE) {
        win32FileGroup.h.fileCount += 1;

        if (win32.FindNextFileW(fileHandle, &findData) != win32.TRUE) {
            break;
        }
    }

    _ = win32.FindClose(fileHandle);

    win32FileGroup.fileHandle = win32.FindFirstFileW(&wildcard_l, &win32FileGroup.findData);

    return @ptrCast(win32FileGroup);
}

fn Win32GetAllFilesOfTypeEnd(fileGroup: ?*platform.file_group) void {
    var win32FileGroup: ?*win32_platform_file_group = @alignCast(@ptrCast(fileGroup));
    if (win32FileGroup) |_| {
        _ = win32.FindClose(win32FileGroup.?.fileHandle);

        _ = win32.VirtualFree(win32FileGroup, 0, win32.MEM_RELEASE);
    }
}

fn Win32OpenNextFile(fileGroup: *platform.file_group) ?*platform.file_handle {
    var win32FileGroup: *win32_platform_file_group = @alignCast(@ptrCast(fileGroup));

    var result: ?*win32_platform_file_handle = null;

    if (win32FileGroup.fileHandle != win32.x.INVALID_FIND_HANDLE_VALUE) {
        result = @alignCast(@ptrCast(win32.VirtualAlloc(null, @sizeOf(win32_platform_file_handle), allocationReserveCommit, win32.PAGE_READWRITE)));

        if (result) |r| {
            // TODO (Manav): convert to unicode later
            result.?.win32Handle = win32.CreateFileW(win32FileGroup.findData.cFileName[0.. :0], win32.FILE_GENERIC_READ, win32.FILE_SHARE_READ, null, win32.OPEN_EXISTING, win32.SECURITY_ANONYMOUS, null);
            result.?.h.noErrors = r.win32Handle != win32.INVALID_HANDLE_VALUE;
        }

        if (win32.FindNextFileW(win32FileGroup.fileHandle, &win32FileGroup.findData) != win32.TRUE) {
            _ = win32.FindClose(win32FileGroup.fileHandle);
            win32FileGroup.fileHandle = win32.x.INVALID_FIND_HANDLE_VALUE;
        }
    }

    return @ptrCast(result);
}

fn Win32ReadDataFromFile(source: *platform.file_handle, offset: u64, size: u64, dest: *anyopaque) void {
    if (platform.NoFileErrors(source)) {
        var handle: *win32_platform_file_handle = @alignCast(@ptrCast(source));

        var overlapped = win32.OVERLAPPED{
            .Internal = 0,
            .InternalHigh = 0,
            .Anonymous = .{ .Anonymous = .{
                .Offset = @intCast((offset >> 0) & 0xffffffff),
                .OffsetHigh = @intCast((offset >> 32) & 0xffffffff),
            } },
            .hEvent = null,
        };

        const fileSize32: u32 = platform.SafeTruncateU64(size);

        var bytesRead: DWORD = 0;
        if (win32.ReadFile(handle.win32Handle, dest, fileSize32, &bytesRead, &overlapped) != 0 and fileSize32 == bytesRead) {} else {
            Win32FileError(&handle.h, "Read file failed");
        }
    }
}
fn Win32FileError(source: *platform.file_handle, message: []const u8) void {
    _ = message;
    if (HANDMADE_INTERNAL) {
        _ = win32.OutputDebugStringW(win32.L("Win32 File Error: "));

        // TODO (Manav): fix utf8 and utf16 stuff
        // var messageW: [256:0]u16 = [1:0]u16{ 0 } ** 256;
        // _ = std.unicode.utf8ToUtf16Le(&messageW, message) catch |err| @compileError(err);
        // _ = win32.OutputDebugStringW(&messageW);

        _ = win32.OutputDebugStringW(win32.L("\n"));
    }

    source.noErrors = false;
}

// fn Win32CloseFile(fileHandle: *platform.file_handle) void {
//     _ = win32.CloseHandle(fileHandle);
// }

pub export fn wWinMain(hInstance: ?win32.HINSTANCE, _: ?win32.HINSTANCE, _: [*:0]u16, _: u32) callconv(WINAPI) c_int {
    var win32State = win32_state{
        .gameMemoryBlock = undefined,
        .recordingHandle = undefined,
        .playBackHandle = undefined,
    };

    var highPriorityQueue = win32_work_queue{};
    highPriorityQueue.MakeQueue(3);

    var lowPriorityQueue = win32_work_queue{};
    lowPriorityQueue.MakeQueue(1);

    if (!NOT_IGNORE) {
        var a0 = "String A0".*;
        var a1 = "String A1".*;
        var a2 = "String A2".*;
        var a3 = "String A3".*;
        var a4 = "String A4".*;
        var a5 = "String A5".*;
        var a6 = "String A6".*;
        var a7 = "String A7".*;
        var a8 = "String A8".*;
        var a9 = "String A9".*;

        var b0 = "String B0".*;
        var b1 = "String B1".*;
        var b2 = "String B2".*;
        var b3 = "String B3".*;
        var b4 = "String B4".*;
        var b5 = "String B5".*;
        var b6 = "String B6".*;
        var b7 = "String B7".*;
        var b8 = "String B8".*;
        var b9 = "String B9".*;

        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a0);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a1);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a2);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a3);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a4);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a5);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a6);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a7);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a8);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &a9);

        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b0);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b1);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b2);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b3);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b4);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b5);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b6);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b7);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b8);
        Win32AddEntry(highPriorityQueue.to(), DoWorkerWork, &b9);

        Win32CompleteAllWork(highPriorityQueue.to());
    }

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
    // Win32ResizeDIBSection(&globalBackBuffer, 1920, 1080);
    // NOTE (Manav): Unaligned load on pixel in DrawRectangleQuickly allows us to use 1279 x 719

    debugGlobalShowCursor = HANDMADE_INTERNAL;

    const windowclass = win32.WNDCLASSW{
        .style = win32.WNDCLASS_STYLES{}, // WS_EX_TOPMOST|WS_EX_LAYERED
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

    if (win32.RegisterClassW(&windowclass) != 0) {
        if (win32.CreateWindowExW(
            win32.WINDOW_EX_STYLE{},
            windowclass.lpszClassName,
            win32.L("Handmade Hero in Zig"),
            win32.WINDOW_STYLE{ // win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE,
                .TABSTOP = 1,
                .GROUP = 1,
                .THICKFRAME = 1,
                .SYSMENU = 1,
                .DLGFRAME = 1,
                .BORDER = 1,
                .VISIBLE = 1,
            },
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            win32.CW_USEDEFAULT,
            null,
            null,
            hInstance,
            null,
        )) |windowHandle| {
            var monitorRefreshHz: i32 = 60;
            var win32RefreshRate: i32 = 0;

            if (win32.GetDC(windowHandle)) |refreshDC| {
                defer _ = win32.ReleaseDC(windowHandle, refreshDC);

                win32RefreshRate = win32.GetDeviceCaps(refreshDC, win32.GET_DEVICE_CAPS_INDEX.VREFRESH);
            }

            if (win32RefreshRate > 1) {
                monitorRefreshHz = win32RefreshRate;
            }

            const gameUpdateHz: f32 = @as(f32, @floatFromInt(monitorRefreshHz)) / 2.0;
            const targetSecondsPerFrame: f32 = 1.0 / gameUpdateHz;

            var soundOutput = win32_sound_output{
                .samplesPerSecond = 48000,
                .bytesPerSample = @sizeOf(i16) * 2,
            };

            soundOutput.secondaryBufferSize = soundOutput.samplesPerSecond * soundOutput.bytesPerSample;
            soundOutput.safetyBytes = @intFromFloat((@as(f32, @floatFromInt(soundOutput.samplesPerSecond)) * @as(f32, @floatFromInt(soundOutput.bytesPerSample)) / gameUpdateHz) / 3.0);

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

            const maxPossibleOverrun = 2 * 8 * @sizeOf(u16);
            const samples: ?*anyopaque = win32.VirtualAlloc(null, soundOutput.secondaryBufferSize + maxPossibleOverrun, allocationReserveCommit, win32.PAGE_READWRITE);
            // defer _ = win32.VirtualFree();

            const baseAddress: ?[*]u8 = if (HANDMADE_INTERNAL) @ptrFromInt(platform.TeraBytes(2)) else null;

            var gameMemory = platform.memory{
                .permanentStorageSize = platform.MegaBytes(256),
                .transientStorageSize = platform.GigaBytes(1),
                .permanentStorage = undefined,
                .transientStorage = undefined,
                .highPriorityQueue = highPriorityQueue.to(),
                .lowPriorityQueue = lowPriorityQueue.to(),
                .platformAPI = platform.api{
                    .AddEntry = Win32AddEntry,
                    .CompleteAllWork = Win32CompleteAllWork,

                    .DEBUGFreeFileMemory = DEBUGWin32FreeFileMemory,
                    .DEBUGReadEntireFile = DEBUGWin32ReadEntireFile,
                    .DEBUGWriteEntireFile = DEBUGWin32WriteEntireFile,

                    .GetAllFilesOfTypeBegin = Win32GetAllFilesOfTypeBegin,
                    .GetAllFilesOfTypeEnd = Win32GetAllFilesOfTypeEnd,
                    .OpenNextFile = Win32OpenNextFile,
                    .ReadDataFromFile = Win32ReadDataFromFile,
                    .FileError = Win32FileError,
                },

                .d = &globalDebug,
            };

            win32State.totalSize = gameMemory.permanentStorageSize + gameMemory.transientStorageSize;
            win32State.gameMemoryBlock = win32.VirtualAlloc(baseAddress, win32State.totalSize, allocationReserveCommit, win32.PAGE_READWRITE).?;

            gameMemory.permanentStorage = @ptrCast(win32State.gameMemoryBlock);
            gameMemory.transientStorage = gameMemory.permanentStorage + gameMemory.permanentStorageSize;

            for (1..win32State.replayBuffers.len) |replayIndex| {
                var replayBuffer = &win32State.replayBuffers[replayIndex];

                Win32GetInputFileLocation(&win32State, false, replayIndex, replayBuffer.fileName[0..WIN32_STATE_FILE_NAME_COUNT :0]);

                const fileAccessFlags = win32.FILE_ACCESS_FLAGS{ // win32.FILE_GENERIC_WRITE | win32.FILE_GENERIC_READ,
                    .FILE_READ_DATA = 1,
                    .FILE_WRITE_DATA = 1,
                    .FILE_READ_EA = 1,
                    .FILE_APPEND_DATA = 1,
                    .FILE_WRITE_EA = 1,
                    .FILE_READ_ATTRIBUTES = 1,
                    .FILE_WRITE_ATTRIBUTES = 1,
                    .READ_CONTROL = 1,
                    .SYNCHRONIZE = 1,
                };

                replayBuffer.fileHandle = win32.CreateFileW(
                    &replayBuffer.fileName,
                    fileAccessFlags,
                    win32.FILE_SHARE_NONE,
                    null,
                    win32.CREATE_ALWAYS,
                    win32.SECURITY_ANONYMOUS,
                    null,
                );

                if (replayBuffer.fileHandle == win32.INVALID_HANDLE_VALUE) {
                    std.debug.print("Failed to create File Handle: {s}\n", .{"wWinMain -> replayBuffer"});
                }

                var maxSize: win32.ULARGE_INTEGER = undefined;
                maxSize.QuadPart = win32State.totalSize;

                replayBuffer.memoryMap = win32.CreateFileMappingW(replayBuffer.fileHandle, null, win32.PAGE_READWRITE, maxSize.u.HighPart, maxSize.u.LowPart, null);

                if (win32.MapViewOfFile(replayBuffer.memoryMap, win32.FILE_MAP_ALL_ACCESS, 0, 0, win32State.totalSize)) |memoryBlock| {
                    replayBuffer.memoryBlock = memoryBlock;
                } else {
                    // TODO: diagnostic
                }
            }

            if (samples != null) {
                var inputs = [1]platform.input{platform.input{}} ** 2;

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

                var lastCycleCount = rdtsc();

                while (globalRunning) {
                    newInput.dtForFrame = targetSecondsPerFrame;

                    newInput.executableReloaded = false;
                    const newDLLWriteTime = Win32GetLastWriteTime(&sourceGameCodeDLLFullPath);
                    if (win32.CompareFileTime(&newDLLWriteTime, &gameCode.dllLastWriteTime) != 0) {
                        Win32CompleteAllWork(@ptrCast(&highPriorityQueue));
                        Win32CompleteAllWork(@ptrCast(&lowPriorityQueue));

                        Win32UnloadGameCode(&gameCode);
                        gameCode = Win32LoadGameCode(&sourceGameCodeDLLFullPath, &tempGameCodeDLLFullPath, &gameCodeLockFullPath);
                        newInput.executableReloaded = true;
                    }

                    const oldKeyboardController: *platform.controller_input = &oldInput.controllers[0];
                    const newKeyboardController: *platform.controller_input = &newInput.controllers[0];

                    newKeyboardController.* = platform.controller_input{
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
                            @as(u32, (@as(u16, @bitCast(win32.GetKeyState(@intFromEnum(win32.VK_LBUTTON)))) & (1 << 15))),
                        );
                        Win32ProcessKeyboardMessage(
                            &newInput.mouseButtons[1],
                            @as(u32, (@as(u16, @bitCast(win32.GetKeyState(@intFromEnum(win32.VK_MBUTTON)))) & (1 << 15))),
                        );
                        Win32ProcessKeyboardMessage(
                            &newInput.mouseButtons[2],
                            @as(u32, (@as(u16, @bitCast(win32.GetKeyState(@intFromEnum(win32.VK_RBUTTON)))) & (1 << 15))),
                        );
                        Win32ProcessKeyboardMessage(
                            &newInput.mouseButtons[3],
                            @as(u32, (@as(u16, @bitCast(win32.GetKeyState(@intFromEnum(win32.VK_XBUTTON1)))) & (1 << 15))),
                        );
                        Win32ProcessKeyboardMessage(
                            &newInput.mouseButtons[4],
                            @as(u32, (@as(u16, @bitCast(win32.GetKeyState(@intFromEnum(win32.VK_XBUTTON2)))) & (1 << 15))),
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
                            if (XInputGetState(controllerIndex, &controllerState) == @intFromEnum(win32.ERROR_SUCCESS)) {
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

                        var buffer = platform.offscreen_buffer{
                            .memory = globalBackBuffer.memory,
                            .width = globalBackBuffer.width,
                            .height = globalBackBuffer.height,
                            .pitch = globalBackBuffer.pitch,
                        };

                        if (win32State.inputRecordingIndex != 0) {
                            Win32RecordInput(&win32State, newInput);
                        }

                        if (win32State.inputPlayingIndex != 0) {
                            Win32PlayBackInput(&win32State, newInput);
                        }

                        if (gameCode.UpdateAndRender) |UpdateAndRender| {
                            UpdateAndRender(&gameMemory, newInput, &buffer);
                            HandleDebugCycleCounters(&gameMemory);
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

                            const expectedSoundBytesPerFrame: u32 = @intFromFloat(@as(f32, @floatFromInt(soundOutput.samplesPerSecond * soundOutput.bytesPerSample)) / gameUpdateHz);

                            const secondsLeftUntilFLip: f32 = (targetSecondsPerFrame - fromBeginToAudioSeconds);
                            const expectedBytesUntilFlip: i32 = @intFromFloat((secondsLeftUntilFLip / targetSecondsPerFrame) * @as(f32, @floatFromInt(expectedSoundBytesPerFrame)));

                            const expectedFrameBoundaryByte = playCursor +% @as(u32, @bitCast(expectedBytesUntilFlip));

                            var safeWriteCursor = writeCursor;
                            if (safeWriteCursor < playCursor) {
                                safeWriteCursor += soundOutput.secondaryBufferSize;
                            }
                            std.debug.assert(safeWriteCursor >= playCursor);
                            safeWriteCursor +%= soundOutput.safetyBytes;

                            const audioCardIsLowLatency = safeWriteCursor < expectedFrameBoundaryByte;

                            var targetCursor: DWORD = 0;
                            if (audioCardIsLowLatency) {
                                targetCursor = expectedFrameBoundaryByte +% expectedSoundBytesPerFrame;
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

                            var soundBuffer = platform.sound_output_buffer{
                                .samplesPerSecond = soundOutput.samplesPerSecond,
                                .sampleCount = @intCast(platform.Align(bytesToWrite / soundOutput.bytesPerSample, 8)),
                                .samples = @alignCast(@ptrCast(samples)),
                            };

                            bytesToWrite = soundBuffer.sampleCount * soundOutput.bytesPerSample;

                            // Win32DebugSyncDisplay(&globalBackBuffer, 30, &debugTimeMarkers, debugTimeMarkerIndex, &soundOutput, targetSecondsPerFrame);

                            if (gameCode.GetSoundSamples) |GetSoundSamples| {
                                GetSoundSamples(&gameMemory, &soundBuffer);
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
                                audioLatencySeconds = (@as(f32, @floatFromInt(audioLatencyBytes)) / @as(f32, @floatFromInt(soundOutput.bytesPerSample))) / @as(f32, @floatFromInt(soundOutput.samplesPerSecond));

                                if (!NOT_IGNORE) {
                                    var textbuffer = [1]u16{0} ** 256;
                                    _ = win32.x.wsprintfW(&textbuffer, win32.L("BTL:%u TC:%u BTW:%u - PC:%u WC:%u DELTA:%u (%fs)\n"), byteToLock, targetCursor, bytesToWrite, playCursor, writeCursor, audioLatencyBytes, audioLatencySeconds);
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
                                const sleepMS: DWORD = @intFromFloat((1000.0 * (targetSecondsPerFrame - secondsElapsedForFrame)));
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

                        if (NOT_IGNORE) {
                            var endCycleCount = rdtsc();
                            const cyclesElapsed = endCycleCount - lastCycleCount;
                            lastCycleCount = endCycleCount;

                            const mcpf = @as(f64, @floatFromInt(cyclesElapsed)) / (1000 * 1000);
                            const fps: f64 = 1000 / msPerFrame;
                            var fpsBuffer = [1:0]u16{0} ** 256;
                            _ = win32.x.wsprintfW(@as([*:0]u16, @ptrCast(&fpsBuffer)), win32.L("%.02fms/f,  %.02ff/s,  %.02fmc/f\n"), &msPerFrame, &fps, &mcpf);
                            // std.debug.print("{d:.2}ms/f, {d:.2}f/s, {d:.2}mc/f\n", .{ msPerFrame, fps, mcpf });
                            // _ = win32.OutputDebugStringW(@as([*:0]u16, @ptrCast(&fpsBuffer)));
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

    return 0;
}

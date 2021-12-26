const std = @import("std");
const win32 = struct {
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").graphics.gdi;
    usingnamespace @import("win32").media.audio;
    usingnamespace @import("win32").media.audio.direct_sound;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").system.com;
    usingnamespace @import("win32").system.library_loader;
    usingnamespace @import("win32").system.memory;
    usingnamespace @import("win32").system.performance;
    usingnamespace @import("win32").ui.input.keyboard_and_mouse;
    usingnamespace @import("win32").ui.input.xbox_controller;
    usingnamespace @import("win32").ui.windows_and_messaging;

    usingnamespace @import("win32").zig;
};

const WINAPI = std.os.windows.WINAPI;
const DWORD = std.os.windows.DWORD;

const PI32 = 3.14159265359;

const win32_offscreen_buffer = struct { info: win32.BITMAPINFO, memory: ?*anyopaque, width: i32, height: i32, pitch: usize };
const win32_window_dimension = struct { width: i32, height: i32 };

pub var globalRunning: bool = undefined;
pub var globalBackBuffer = win32_offscreen_buffer{ .info = win32.BITMAPINFO{ .bmiHeader = win32.BITMAPINFOHEADER{
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
}, .bmiColors = [1]win32.RGBQUAD{win32.RGBQUAD{
    .rgbBlue = 0,
    .rgbGreen = 0,
    .rgbRed = 0,
    .rgbReserved = 0,
}} }, .memory = undefined, .width = 0, .height = 0, .pitch = 0 };
pub var globalSecondaryBuffer: *win32.IDirectSoundBuffer = undefined;

var XInputGetState: fn (u32, ?*win32.XINPUT_STATE) callconv(WINAPI) isize = undefined;
var XInputSetState: fn (u32, ?*win32.XINPUT_VIBRATION) callconv(WINAPI) isize = undefined;

fn Win32LoadXinput() void {
    if (win32.LoadLibraryW(win32.L("xinput1_4.dll"))) |XInputLibrary| {
        // NO TYPESAFETY TO WARN YOU, BEWARE :D
        if (win32.GetProcAddress(XInputLibrary, "XInputGetState")) |funcptr| {
            XInputGetState = @ptrCast(@TypeOf(XInputGetState), funcptr);
        }

        if (win32.GetProcAddress(XInputLibrary, "XInputSetState")) |funcptr| {
            XInputSetState = @ptrCast(@TypeOf(XInputSetState), funcptr);
        }

        // TODO: diagnostic
    } else {
        // TODO: diagnostic
    }
}

var DirectSoundCreate: fn (?*const win32.Guid, ?*?*win32.IDirectSound, ?*win32.IUnknown) callconv(WINAPI) i32 = undefined;

fn Win32InitDSound(window: win32.HWND, samplesPerSecond: u32, bufferSize: u32) void {
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
                        var bufferDescription = win32.DSBUFFERDESC{ // https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ee416820(v=vs.85)#remarks
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
                    var bufferDescription = win32.DSBUFFERDESC{ // https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ee416820(v=vs.85)#remarks
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
    var result = win32_window_dimension{ .width = 0, .height = 0 };

    var clientRect: win32.RECT = undefined;
    _ = win32.GetClientRect(windowHandle, &clientRect);
    result.height = clientRect.bottom - clientRect.top;
    result.width = clientRect.right - clientRect.left;

    return result;
}

fn RenderWeirdGradient(buffer: *win32_offscreen_buffer, xOffset: i32, yOffset: i32) void {
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

fn Win32ResizeDIBSection(buffer: *win32_offscreen_buffer, width: i32, height: i32) void {
    // TODO: Bullet proof this.
    // Maybe don't free	first, free after, then free first if that failes.

    if (buffer.memory != null) {
        _ = win32.VirtualFree(buffer.memory, 0, win32.MEM_RELEASE);
    }

    buffer.width = width;
    buffer.height = height;
    const bytesPerPixel = 4;

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
    _ = win32.StretchDIBits(
        deviceContext,
        0,
        0,
        windowWidth,
        windowHeight,
        0,
        0,
        buffer.width,
        buffer.height,
        buffer.memory,
        &buffer.info,
        win32.DIB_RGB_COLORS,
        win32.SRCCOPY,
    );
}

fn Win32WindowProc(windowHandle: win32.HWND, message: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    var result: win32.LRESULT = 0;

    switch (message) {
        win32.WM_CLOSE => globalRunning = false, // TODO: handle this with a message to a user?

        win32.WM_ACTIVATEAPP => win32.OutputDebugStringW(win32.L("WM_ACTIVATEAPP\n")),

        win32.WM_DESTROY => globalRunning = false, // TODO: handle this as an error = recreate window?

        win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP => {
            const vkCode: win32.VIRTUAL_KEY = @intToEnum(win32.VIRTUAL_KEY, wParam);
            // DOCUMENTATION: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
            const wasDown: bool = ((lParam & (1 << 30)) != 0);
            const isDown: bool = ((lParam & (1 << 31)) == 0);

            if (wasDown != isDown) {
                switch (vkCode) {
                    win32.VK_W, win32.VK_A, win32.VK_S, win32.VK_D, win32.VK_Q, win32.VK_E, win32.VK_UP, win32.VK_LEFT, win32.VK_DOWN, win32.VK_RIGHT, win32.VK_ESCAPE => {},
                    win32.VK_SPACE => {
                        win32.OutputDebugStringW(win32.L("SPACE: "));
                        if (isDown) {
                            win32.OutputDebugStringW(win32.L("IsDown "));
                        }
                        if (wasDown) {
                            win32.OutputDebugStringW(win32.L("WasDown "));
                        }
                        win32.OutputDebugStringW(win32.L("\n"));
                    },
                    else => {},
                }
            }

            var altKeyWasDown = ((lParam & (1 << 29)) != 0);
            if ((vkCode == win32.VK_F4) and altKeyWasDown) {
                globalRunning = false;
            }
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

const win32_sound_output = struct { samplesPerSecond: u32, toneHz: u32, toneVolume: i16, runningSampleIndex: u32, wavePeriod: u32, bytesPerSample: u32, secondaryBufferSize: u32, tSine: f32, latencySampleCount: u32 };

fn Win32FillSoundBuffer(soundOutput: *win32_sound_output, byteToLock: DWORD, bytesToWrite: DWORD) void {
    // TODO: more strenous test :)
    // TODO: switch to a sine wave
    var region1: ?*anyopaque = undefined;
    var region1Size: DWORD = undefined;
    var region2: ?*anyopaque = undefined;
    var region2Size: DWORD = undefined;

    if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.Lock(globalSecondaryBuffer, byteToLock, bytesToWrite, &region1, &region1Size, &region2, &region2Size, 0))) {
        if (region1) |ptr| {
            var sampleOut = @ptrCast([*]i16, @alignCast(@alignOf(i16), ptr));
            const region1SampleCount = region1Size / soundOutput.bytesPerSample;
            var sampleIndex: DWORD = 0;
            while (sampleIndex < region1SampleCount) : (sampleIndex += 1) {
                const sineValue = std.math.sin(soundOutput.tSine);
                const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, soundOutput.toneVolume));
                sampleOut.* = sampleValue;
                sampleOut += 1;
                sampleOut.* = sampleValue;
                sampleOut += 1;

                soundOutput.tSine += 2.0 * PI32 * 1.0 / @intToFloat(f32, soundOutput.wavePeriod);
                soundOutput.runningSampleIndex += 1;
            }
        }

        if (region2) |ptr| {
            var sampleOut = @ptrCast([*]i16, @alignCast(@alignOf(i16), ptr));
            const region2SampleCount = region2Size / soundOutput.bytesPerSample;
            var sampleIndex: DWORD = 0;
            while (sampleIndex < region2SampleCount) : (sampleIndex += 1) {
                const sineValue = std.math.sin(soundOutput.tSine);
                const sampleValue = @floatToInt(i16, sineValue * @intToFloat(f32, soundOutput.toneVolume));
                sampleOut.* = sampleValue;
                sampleOut += 1;
                sampleOut.* = sampleValue;
                sampleOut += 1;

                soundOutput.tSine += 2.0 * PI32 * 1.0 / @intToFloat(f32, soundOutput.wavePeriod);
                soundOutput.runningSampleIndex += 1;
            }
        }

        _ = globalSecondaryBuffer.vtable.Unlock(globalSecondaryBuffer, region1, region1Size, region2, region2Size);
    }
}

pub extern "USER32" fn wsprintfW(
    param0: ?win32.PWSTR,
    param1: ?[*:0]const u16,
    ...
) callconv(WINAPI) i32;

inline fn rdtsc() u64 {
    var low: u32 = undefined;
    var high: u32 = undefined;

    low = asm ("rdtsc" : [low] "={eax}" (->u32));
    high = asm ("movl %%edx, %[high]" : [high] "=r" (->u32));

    return (@intCast(u64, (high)) << 32) | @intCast(u64, low);
}

pub export fn wWinMain(hInstance: ?win32.HINSTANCE, _: ?win32.HINSTANCE, _: [*:0]u16, _: u32) callconv(WINAPI) c_int {

    var perfCountFrequencyResult : win32.LARGE_INTEGER = undefined;
    _ = win32.QueryPerformanceCounter(&perfCountFrequencyResult);
    var perfCountFrequency = perfCountFrequencyResult.QuadPart;

    Win32LoadXinput();

    Win32ResizeDIBSection(&globalBackBuffer, 1280, 720);

    const windowclass = win32.WNDCLASS{
        .style = @intToEnum(win32.WNDCLASS_STYLES, @enumToInt(win32.CS_HREDRAW) | @enumToInt(win32.CS_VREDRAW) | @enumToInt(win32.CS_OWNDC)),
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

    if (win32.RegisterClass(&windowclass) != 0) {
        if (win32.CreateWindowEx(@intToEnum(win32.WINDOW_EX_STYLE, 0), windowclass.lpszClassName, win32.L("HandmadeHero"), @intToEnum(win32.WINDOW_STYLE, @enumToInt(win32.WS_OVERLAPPEDWINDOW) | @enumToInt(win32.WS_VISIBLE)), win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, hInstance, null)) |windowHandle| {
            if (win32.GetDC(windowHandle)) |deviceContext| {
                var xOffset: i32 = 0;
                var yOffset: i32 = 0;

                var soundOutput = win32_sound_output{ .samplesPerSecond = 48000, .toneHz = 256, .toneVolume = 1000, .runningSampleIndex = 0, .wavePeriod = undefined, .bytesPerSample = @sizeOf(i16) * 2, .secondaryBufferSize = undefined, .tSine = 0, .latencySampleCount = undefined };

                soundOutput.wavePeriod = soundOutput.samplesPerSecond / soundOutput.toneHz;
                soundOutput.secondaryBufferSize = soundOutput.samplesPerSecond * soundOutput.bytesPerSample;
                soundOutput.latencySampleCount = soundOutput.samplesPerSecond / 15; //(15 - fps)

                Win32InitDSound(windowHandle, soundOutput.samplesPerSecond, soundOutput.secondaryBufferSize);
                Win32FillSoundBuffer(&soundOutput, 0, soundOutput.latencySampleCount * soundOutput.bytesPerSample);
                _ = globalSecondaryBuffer.vtable.Play(globalSecondaryBuffer, 0, 0, win32.DSBPLAY_LOOPING);

                globalRunning = true;

                var lastCounter: win32.LARGE_INTEGER = undefined;
                _ = win32.QueryPerformanceCounter(&lastCounter);
                var lastCycleCount = rdtsc();

                while (globalRunning) {
                    var message: win32.MSG = undefined;
                    while (win32.PeekMessage(&message, null, 0, 0, win32.PM_REMOVE) != 0) {
                        if (message.message == win32.WM_QUIT) {
                            globalRunning = false;
                        }

                        _ = win32.TranslateMessage(&message);
                        _ = win32.DispatchMessage(&message);
                    }

                    // TODO: should we poll this more frequently
                    var controllerIndex: DWORD = 0;
                    while (controllerIndex < win32.XUSER_MAX_COUNT) : (controllerIndex += 1) {
                        var controllerState: win32.XINPUT_STATE = undefined;
                        if (XInputGetState(controllerIndex, &controllerState) == @enumToInt(win32.ERROR_SUCCESS)) {
                            // This controller is plugged in
                            // TODO: see if ControllerState.dwPacketNumber increments too rapidly
                            const pad = &controllerState.Gamepad;
                            // const up = (pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_UP);
                            // const down = (pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_DOWN);
                            // const left = (pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_LEFT);
                            // const right = (pad.wButtons & win32.XINPUT_GAMEPAD_DPAD_RIGHT);
                            // const start = (pad.wButtons & win32.XINPUT_GAMEPAD_START);
                            // const back = (pad.wButtons & win32.XINPUT_GAMEPAD_BACK);
                            // const leftShoulder = (pad.wButtons & win32.XINPUT_GAMEPAD_LEFT_SHOULDER);
                            // const rightShoulder = (pad.wButtons & win32.XINPUT_GAMEPAD_RIGHT_SHOULDER);
                            // const aButton = (pad.wButtons & win32.XINPUT_GAMEPAD_A);
                            // const bButton = (pad.wButtons & win32.XINPUT_GAMEPAD_B);
                            // const xButton = (pad.wButtons & win32.XINPUT_GAMEPAD_X);
                            // const yButton = (pad.wButtons & win32.XINPUT_GAMEPAD_Y);

                            const stickX = pad.sThumbLX;
                            const stickY = pad.sThumbLY;

                            xOffset += @divTrunc(stickX, 4096);
                            yOffset += @divTrunc(stickY, 4096);

                            soundOutput.toneHz = 512 * 256 * @intCast(u32, @divTrunc(stickY , 32000));
                            soundOutput.wavePeriod = soundOutput.samplesPerSecond / soundOutput.toneHz;
                        } else {
                            // This controller is not available
                        }
                    }
                    // var vibration = win32.XINPUT_VIBRATION{
                    //     .wLeftMotorSpeed = 60000,
                    //     .wRightMotorSpeed = 60000,
                    // };

                    // _ = XInputSetState(0, &vibration);

                    RenderWeirdGradient(&globalBackBuffer, xOffset, yOffset);

                    var playCursor: DWORD = undefined;
                    var writeCursor: DWORD = undefined;

                    if (win32.SUCCEEDED(globalSecondaryBuffer.vtable.GetCurrentPosition(globalSecondaryBuffer, &playCursor, &writeCursor))) {
                        const byteToLock = (soundOutput.runningSampleIndex * soundOutput.bytesPerSample) % soundOutput.secondaryBufferSize;
                        const targetCursor = (playCursor + (soundOutput.latencySampleCount * soundOutput.bytesPerSample)) % soundOutput.secondaryBufferSize;
                        var bytesToWrite: DWORD = undefined;
                        // TODO: change this to use a lower latency offset from the playcursor when we actually start using sound effects
                        if (byteToLock > targetCursor) {
                            bytesToWrite = soundOutput.secondaryBufferSize - byteToLock;
                            bytesToWrite += targetCursor;
                        } else {
                            bytesToWrite = targetCursor - byteToLock;
                        }

                        Win32FillSoundBuffer(&soundOutput, byteToLock, bytesToWrite);
                    }

                    const dimension = Win32GetWindowDimenstion(windowHandle);
                    Win32DisplayBufferInWindow(&globalBackBuffer, deviceContext, dimension.width, dimension.height);

                    var endCycleCount = rdtsc();
                    var endCounter: win32.LARGE_INTEGER = undefined;
                    _ = win32.QueryPerformanceCounter(&endCounter);

                    // TODO: display the value here
                    const cyclesElapsed = endCycleCount - lastCycleCount;
                    const counterElapsed = endCounter.QuadPart - lastCounter.QuadPart;

                    const msPerFrame = @divTrunc(1000 *counterElapsed, perfCountFrequency);
                    const fps = @divTrunc(perfCountFrequency, counterElapsed);
                    const mcpf = cyclesElapsed / (1000 * 1000); 

                    const msPerFrame_f = @intToFloat(f32, 1000 * counterElapsed)/ @intToFloat(f32, perfCountFrequency);
                    const fps_f = @intToFloat(f32, perfCountFrequency) / @intToFloat(f32, counterElapsed);
                    const mcpf_f = @intToFloat(f32, cyclesElapsed) / (1000.0 * 1000.0);

                    var buffer: [256]u16 = undefined;

                    std.debug.print("{} ms/f, {} FPS, {} Mc/f\n", .{ msPerFrame_f, fps_f, mcpf_f});
                    _ = wsprintfW(&buffer, win32.L("%dms/f, %dFPS, %dMc/f\n"), msPerFrame, fps, mcpf);
                    _ = win32.OutputDebugStringW(&buffer);

                    lastCounter = endCounter;
                    lastCycleCount = endCycleCount;

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

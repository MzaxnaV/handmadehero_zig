const platform = @import("handmade_platform");
const simd = @import("simd");

const h = struct {
    usingnamespace @import("handmade_asset.zig");
    usingnamespace @import("handmade_data.zig");
    usingnamespace @import("handmade_intrinsics.zig");
    usingnamespace @import("handmade_math.zig");
};

// build constants ------------------------------------------------------------------------------------------------------------------------

const NOT_IGNORE = platform.NOT_IGNORE;
const assert = platform.Assert;

// data types -----------------------------------------------------------------------------------------------------------------------------

pub const playing_sound = struct {
    currentVolume: h.v2,
    dCurrentVolume: h.v2,
    targetVolume: h.v2,

    dSample: f32,

    ID: h.sound_id,
    samplesPlayed: f32,
    next: ?*playing_sound,
};

pub const audio_state = struct {
    permArena: *h.memory_arena,
    firstPlayingSound: ?*playing_sound,
    firstFreePlayingSound: ?*playing_sound,

    masterVolume: h.v2,
};

// local functions ------------------------------------------------------------------------------------------------------------------------

fn OutputTestSineWave(gameState: *h.game_state, soundBuffer: *platform.sound_output_buffer, toneHz: u32) void {
    const toneVolume = 3000;
    const wavePeriod = @divTrunc(soundBuffer.samplesPerSecond, toneHz);

    var sampleOut = soundBuffer.samples;
    var sampleIndex = @as(u32, 0);
    while (sampleIndex < 2 * soundBuffer.sampleCount) : (sampleIndex += 2) {
        var sineValue: f32 = 0;
        var sampleValue: i16 = 0;
        if (NOT_IGNORE) {
            sineValue = h.Sin(gameState.tSine);
            sampleValue = @intFromFloat(sineValue * toneVolume);
        } else {
            sampleValue = 0;
        }

        sampleOut[sampleIndex] = sampleValue;
        // sampleOut += 1;
        sampleOut[sampleIndex + 1] = sampleValue;
        // sampleOut += 1;

        if (NOT_IGNORE) {
            gameState.tSine += platform.Tau32 * 1.0 / @as(f32, @floatFromInt(wavePeriod));
            if (gameState.tSine > platform.Tau32) {
                gameState.tSine -= platform.Tau32;
            }
        }
    }
}

pub fn PlaySound(audioState: *audio_state, soundID: h.sound_id) *playing_sound {
    if (audioState.firstFreePlayingSound) |_| {} else {
        audioState.firstFreePlayingSound = audioState.permArena.PushStruct(playing_sound);
        audioState.firstFreePlayingSound.?.next = null;
    }

    var playingSound = audioState.firstFreePlayingSound.?;
    audioState.firstFreePlayingSound = playingSound.next;

    playingSound.samplesPlayed = 0;
    playingSound.targetVolume = .{ 1, 1 };
    playingSound.currentVolume = playingSound.targetVolume;
    playingSound.dCurrentVolume = .{ 0, 0 };
    playingSound.ID = soundID;
    playingSound.dSample = 1;

    playingSound.next = audioState.firstPlayingSound;
    audioState.firstPlayingSound = playingSound;

    return playingSound;
}

pub fn ChangeVolume(_: *audio_state, sound: *playing_sound, fadeDurationInSeconds: f32, volume: h.v2) void {
    // _ = audioState;
    if (fadeDurationInSeconds <= 0) {
        sound.targetVolume = volume;
        sound.currentVolume = sound.targetVolume;
    } else {
        const oneOverFade = 1 / fadeDurationInSeconds;
        sound.targetVolume = volume;
        sound.dCurrentVolume = h.Scale(h.Sub(sound.targetVolume, sound.currentVolume), oneOverFade);
    }
}

pub fn ChangePitch(_: *audio_state, sound: *playing_sound, dSample: f32) void {
    // _ = audioState;
    sound.dSample = dSample;
}

pub fn OutputPlayingSounds(audioState: *audio_state, soundBuffer: *platform.sound_output_buffer, assets: *h.game_assets, tempArena: *h.memory_arena) void {
    const mixerMemory = h.BeginTemporaryMemory(tempArena);
    defer h.EndTemporaryMemory(mixerMemory);

    simd.perf_analyzer.Start(.LLVM_MCA, "OutputPlayingSound");
    defer simd.perf_analyzer.End(.LLVM_MCA, "OutputPlayingSound");

    assert((soundBuffer.sampleCount & 7) == 0);
    const sampleCount8 = soundBuffer.sampleCount / 8;
    const sampleCount4 = soundBuffer.sampleCount / 4;

    var realChannel0: []simd.f32x4 = tempArena.PushSlice(simd.f32x4, sampleCount4);
    var realChannel1: []simd.f32x4 = tempArena.PushSlice(simd.f32x4, sampleCount4);

    const secondsPerSample = 1 / @as(f32, @floatFromInt(soundBuffer.samplesPerSecond));

    // clear out mixer channel
    const zero = simd.f32x4{ 0, 0, 0, 0 };
    {
        var dest0 = realChannel0;
        var dest1 = realChannel1;

        for (0..sampleCount4) |sampleIndex| {
            dest0[sampleIndex] = zero;
            dest1[sampleIndex] = zero;
        }
    }

    // sum all sounds
    var playingSoundPtr = &audioState.firstPlayingSound;
    while (playingSoundPtr.*) |playingSound| {
        var soundFinished = false;

        var totalSamplesToMix8 = sampleCount8;
        var dest0 = realChannel0;
        var dest1 = realChannel1;

        while (totalSamplesToMix8 != 0 and !soundFinished) {
            if (assets.GetSound(playingSound.ID)) |loadedSound| {
                var info: *h.asset_sound_info = assets.GetSoundInfo(playingSound.ID);

                h.PrefetchSound(assets, info.nextIDToPlay);

                var volume = playingSound.currentVolume;
                var dVolume = h.Scale(playingSound.dCurrentVolume, secondsPerSample);
                var dVolume8 = h.Scale(dVolume, 8);
                const dSample = playingSound.dSample;
                const dSample8 = 8 * dSample;

                const masterVolume4_0: simd.f32x4 = @splat(audioState.masterVolume[0]);
                const masterVolume4_1: simd.f32x4 = @splat(audioState.masterVolume[1]);

                var volume4_0: simd.f32x4 = .{
                    volume[0] + 0 * dVolume[0],
                    volume[0] + 1 * dVolume[0],
                    volume[0] + 2 * dVolume[0],
                    volume[0] + 3 * dVolume[0],
                };
                const dVolume4_0: simd.f32x4 = @splat(dVolume[0]);
                const dVolume84_0: simd.f32x4 = @splat(dVolume8[0]);

                var volume4_1: simd.f32x4 = .{
                    volume[1] + 0 * dVolume[1],
                    volume[1] + 1 * dVolume[1],
                    volume[1] + 2 * dVolume[1],
                    volume[1] + 3 * dVolume[1],
                };
                const dVolume4_1: simd.f32x4 = @splat(dVolume[1]);
                const dVolume84_1: simd.f32x4 = @splat(dVolume8[1]);

                assert(playingSound.samplesPlayed >= 0);

                var samplesToMix8 = totalSamplesToMix8;
                const realSamplesRemainingInSound8: f32 = @as(f32, @floatFromInt(loadedSound.sampleCount - h.RoundF32ToInt(u32, playingSound.samplesPlayed))) / dSample8;
                const samplesRemainingInSound8: u32 = h.RoundF32ToInt(u32, realSamplesRemainingInSound8);
                if (samplesToMix8 > samplesRemainingInSound8) {
                    samplesToMix8 = samplesRemainingInSound8;
                }

                const audioStateOutputChannelCount = 2;
                var volumeEnded: [audioStateOutputChannelCount]bool = [1]bool{false} ** audioStateOutputChannelCount;
                for (0..volumeEnded.len) |channelIndex| {
                    if (dVolume8[channelIndex] != 0) {
                        const deltaVolume: f32 = playingSound.targetVolume[channelIndex] - volume[channelIndex];

                        const volumeSampleCount8: u32 = @intFromFloat((deltaVolume / dVolume8[channelIndex]) + 0.5);
                        if (samplesToMix8 > volumeSampleCount8) {
                            samplesToMix8 = volumeSampleCount8;
                            volumeEnded[channelIndex] = true;
                        }
                    }
                }

                var samplePosition: f32 = playingSound.samplesPlayed;
                for (0..samplesToMix8) |loopIndex| {

                    // const sampleOffset:u32 = 0;
                    // const offsetSamplePosition: f32 = samplePosition + @as(f32, @floatFromInt(sampleOffset)) * dSample;
                    // var sampleIndex: u32 = @intCast(h.FloorF32ToI32(offsetSamplePosition));
                    // const frac = offsetSamplePosition - @as(f32, @floatFromInt(sampleIndex));

                    // const sample0: f32 = @floatFromInt(loadedSound.samples[0].?[sampleIndex]);
                    // const sample1: f32 = @floatFromInt(loadedSound.samples[0].?[sampleIndex + 1]);
                    // const sampleValue = h.Lerp(sample0, frac, sample1);

                    const sampleValue_0 = simd.f32x4{
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 0 * dSample)]),
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 1 * dSample)]),
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 2 * dSample)]),
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 3 * dSample)]),
                    };

                    const sampleValue_1 = simd.f32x4{
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 4 * dSample)]),
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 5 * dSample)]),
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 6 * dSample)]),
                        @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 7 * dSample)]),
                    };

                    var d0_0 = dest0[2 * loopIndex];
                    var d0_1 = dest0[2 * loopIndex + 1];

                    var d1_0 = dest1[2 * loopIndex];
                    var d1_1 = dest1[2 * loopIndex + 1];

                    d0_0 += masterVolume4_0 * volume4_0 * sampleValue_0;
                    d0_1 += masterVolume4_0 * (volume4_0 + dVolume4_0) * sampleValue_1;

                    d1_0 += masterVolume4_1 * volume4_1 * sampleValue_1;
                    d1_1 += masterVolume4_1 * (volume4_1 + dVolume4_1) * sampleValue_1;

                    dest0[2 * loopIndex] = d0_0;
                    dest0[2 * loopIndex + 1] = d0_1;
                    dest1[2 * loopIndex] = d1_0;
                    dest1[2 * loopIndex + 1] = d1_1;

                    volume4_0 += dVolume84_0;
                    volume4_1 += dVolume84_1;

                    h.AddTo(&volume, dVolume8);
                    samplePosition += dSample8;
                }

                playingSound.currentVolume = volume;
                for (0..volumeEnded.len) |channelIndex| {
                    if (volumeEnded[channelIndex]) {
                        playingSound.currentVolume[channelIndex] = playingSound.targetVolume[channelIndex];
                        playingSound.dCurrentVolume[channelIndex] = 0;
                    }
                }

                playingSound.samplesPlayed = samplePosition;
                assert(totalSamplesToMix8 >= samplesToMix8);
                totalSamplesToMix8 -= samplesToMix8;

                if (@as(u32, @intFromFloat(playingSound.samplesPlayed)) >= loadedSound.sampleCount) {
                    if (info.nextIDToPlay.IsValid()) {
                        playingSound.ID = info.nextIDToPlay;
                        playingSound.samplesPlayed = 0;
                    } else {
                        soundFinished = true;
                    }
                }
            } else {
                h.LoadSound(assets, playingSound.ID);
                break;
            }
        }

        if (soundFinished) {
            playingSoundPtr.* = playingSound.next;
            playingSound.next = audioState.firstFreePlayingSound;
            audioState.firstFreePlayingSound = playingSound;
        } else {
            playingSoundPtr = &playingSound.next;
        }
    }

    {
        const source0 = realChannel0;
        const source1 = realChannel1;

        var sampleOut: [*]simd.i16x8 = @ptrCast(soundBuffer.samples);
        for (0..sampleCount4) |sampleIndex| {
            const l = simd.i._mm_cvtps_epi32(source0[sampleIndex]);
            const r = simd.i._mm_cvtps_epi32(source1[sampleIndex]);

            const lr0 = simd.z._mm_unpacklo_epi32(l, r);
            const lr1 = simd.z._mm_unpackhi_epi32(l, r);

            const s01 = simd.i._mm_packs_epi32(lr0, lr1);

            sampleOut[sampleIndex] = s01;
        }
    }

}

pub fn InitializeAudioState(audioState: *audio_state, arena: *h.memory_arena) void {
    audioState.permArena = arena;
    audioState.firstPlayingSound = null;
    audioState.firstFreePlayingSound = null;

    audioState.masterVolume = .{ 1, 1 };
}

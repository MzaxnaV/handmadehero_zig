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
    const wavePeriod = soundBuffer.samplesPerSecond / toneHz;

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

    assert((soundBuffer.sampleCount & 3) == 0);
    const chunkCount: u32 = (soundBuffer.sampleCount) / 4;

    var realChannel0: []simd.f32x4 = tempArena.PushSlice(simd.f32x4, chunkCount);
    var realChannel1: []simd.f32x4 = tempArena.PushSlice(simd.f32x4, chunkCount);

    const secondsPerSample = 1 / @as(f32, @floatFromInt(soundBuffer.samplesPerSecond));

    const zero: simd.f32x4 = @splat(0);
    const one: simd.f32x4 = @splat(1);

    // clear out mixer channel
    {
        simd.perf_analyzer.Start(.LLVM_MCA, "OPS_ClearingChannel");
        defer simd.perf_analyzer.End(.LLVM_MCA, "OPS_ClearingChannel");

        var dest0 = realChannel0;
        var dest1 = realChannel1;

        for (0..chunkCount) |sampleIndex| {
            dest0[sampleIndex] = zero;
            dest1[sampleIndex] = zero;
        }
    }

    simd.perf_analyzer.Start(.LLVM_MCA, "OPS_Mixing");

    // sum all sounds
    var playingSoundPtr = &audioState.firstPlayingSound;
    while (playingSoundPtr.*) |playingSound| {
        var soundFinished = false;

        var totalChunksToMix: u32 = chunkCount;
        var dest0 = realChannel0;
        var dest1 = realChannel1;

        while (totalChunksToMix != 0 and !soundFinished) {
            if (assets.GetSound(playingSound.ID)) |loadedSound| {
                var info: *h.asset_sound_info = assets.GetSoundInfo(playingSound.ID);

                h.PrefetchSound(assets, info.nextIDToPlay);

                var volume: h.v2 = playingSound.currentVolume;
                var dVolume: h.v2 = h.Scale(playingSound.dCurrentVolume, secondsPerSample);
                var dVolumeChunk: h.v2 = h.Scale(dVolume, 4);
                const dSample: f32 = playingSound.dSample;
                const dSampleChunk: f32 = 4.0 * dSample;

                // channel 0
                const masterVolume0: simd.f32x4 = @splat(audioState.masterVolume[0]);
                var volume0: simd.f32x4 = .{
                    volume[0] + 0.0 * dVolume[0],
                    volume[0] + 1.0 * dVolume[0],
                    volume[0] + 2.0 * dVolume[0],
                    volume[0] + 3.0 * dVolume[0],
                };
                const dVolume0: simd.f32x4 = @splat(dVolume[0]);
                _ = dVolume0;
                const dVolumeChunk0: simd.f32x4 = @splat(dVolumeChunk[0]);

                // channel 1
                const masterVolume1: simd.f32x4 = @splat(audioState.masterVolume[1]);
                var volume1: simd.f32x4 = .{
                    volume[1] + 0.0 * dVolume[1],
                    volume[1] + 1.0 * dVolume[1],
                    volume[1] + 2.0 * dVolume[1],
                    volume[1] + 3.0 * dVolume[1],
                };
                const dVolume1: simd.f32x4 = @splat(dVolume[1]);
                _ = dVolume1;
                const dVolumeChunk1: simd.f32x4 = @splat(dVolumeChunk[1]);

                assert(playingSound.samplesPlayed >= 0);

                var chunksToMix = totalChunksToMix;
                const realChunksRemainingInSound: f32 = @as(f32, @floatFromInt(loadedSound.sampleCount - h.RoundF32ToInt(u32, playingSound.samplesPlayed))) / dSampleChunk;
                const chunksRemainingInSound = h.RoundF32ToInt(u32, realChunksRemainingInSound);

                if (chunksToMix > chunksRemainingInSound) {
                    chunksToMix = chunksRemainingInSound;
                }

                const audioStateOutputChannelCount = 2;
                var volumeEndsAt: [audioStateOutputChannelCount]u32 = [1]u32{0} ** audioStateOutputChannelCount;
                for (0..volumeEndsAt.len) |channelIndex| {
                    if (dVolumeChunk[channelIndex] != 0) {
                        const deltaVolume: f32 = playingSound.targetVolume[channelIndex] - volume[channelIndex];

                        const volumeChunkCount: u32 = @intFromFloat((deltaVolume / dVolumeChunk[channelIndex]) + 0.5);
                        if (chunksToMix > volumeChunkCount) {
                            chunksToMix = volumeChunkCount;
                            volumeEndsAt[channelIndex] = volumeChunkCount;
                        }
                    }
                }

                const beginSamplePosition = playingSound.samplesPlayed;
                const endSamplePosition = beginSamplePosition + @as(f32, @floatFromInt(chunksToMix)) * dSampleChunk;
                const loopIndexC = (endSamplePosition - beginSamplePosition) / @as(f32, @floatFromInt(chunksToMix));
                for (0..chunksToMix) |loopIndex| {
                    var samplePosition: f32 = beginSamplePosition + loopIndexC * @as(f32, @floatFromInt(loopIndex));

                    var sampleValue: simd.f32x4 = .{ 0, 0, 0, 0 };

                    if (NOT_IGNORE) {
                        const samplePos = simd.f32x4{
                            samplePosition + 0.0 * dSample,
                            samplePosition + 1.0 * dSample,
                            samplePosition + 2.0 * dSample,
                            samplePosition + 3.0 * dSample,
                        };

                        var sampleIndex: simd.i32x4 = simd.z._mm_cvttps_epi32(samplePos);
                        var frac: simd.f32x4 = samplePos - simd.z._mm_cvtepi32_ps(sampleIndex);

                        const sampleValueF = simd.f32x4{
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0])]),
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0])]),
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0])]),
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0])]),
                        };
                        const sampleValueC = simd.f32x4{
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0] + 1)]),
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0] + 1)]),
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0] + 1)]),
                            @floatFromInt(loadedSound.samples[0].?[@intCast(sampleIndex[0] + 1)]),
                        };

                        sampleValue = (one - frac) * sampleValueF + frac * sampleValueC;
                    } else {
                        sampleValue = simd.f32x4{
                            @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 0 * dSample)]),
                            @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 1 * dSample)]),
                            @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 2 * dSample)]),
                            @floatFromInt(loadedSound.samples[0].?[h.RoundF32ToInt(u32, samplePosition + 3 * dSample)]),
                        };
                    }

                    var d0 = dest0[loopIndex];
                    var d1 = dest1[loopIndex];

                    d0 += masterVolume0 * volume0 * sampleValue;
                    d1 += masterVolume1 * volume1 * sampleValue;

                    dest0[loopIndex] = d0;
                    dest1[loopIndex] = d1;

                    volume0 += dVolumeChunk0;
                    volume1 += dVolumeChunk1;
                }

                playingSound.currentVolume[0] = volume0[0];
                playingSound.currentVolume[1] = volume1[1];
                for (0..volumeEndsAt.len) |channelIndex| {
                    if (volumeEndsAt[channelIndex] == chunksToMix) {
                        playingSound.currentVolume[channelIndex] = playingSound.targetVolume[channelIndex];
                        playingSound.dCurrentVolume[channelIndex] = 0;
                    }
                }

                playingSound.samplesPlayed = endSamplePosition;
                assert(totalChunksToMix >= chunksToMix);
                totalChunksToMix -= chunksToMix;

                if (chunksToMix == chunksRemainingInSound) {
                    if (info.nextIDToPlay.IsValid()) {
                        playingSound.ID = info.nextIDToPlay;

                        // TODO (Manav): assert still fires
                        assert(playingSound.samplesPlayed >= @as(f32, @floatFromInt(loadedSound.sampleCount)));
                        playingSound.samplesPlayed -= @floatFromInt(loadedSound.sampleCount);
                        if (playingSound.samplesPlayed < 0) {
                            playingSound.samplesPlayed = 0;
                        }
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

    simd.perf_analyzer.End(.LLVM_MCA, "OPS_Mixing");

    {
        simd.perf_analyzer.Start(.LLVM_MCA, "OPS_FillSoundBuffer");
        defer simd.perf_analyzer.End(.LLVM_MCA, "OPS_FillSoundBuffer");

        const source0 = realChannel0;
        const source1 = realChannel1;

        var sampleOut: [*]simd.i16x8 = @ptrCast(soundBuffer.samples);
        for (0..chunkCount) |sampleIndex| {
            const l = simd.i._mm_cvtps_epi32(source0[sampleIndex]);
            const r = simd.i._mm_cvtps_epi32(source1[sampleIndex]);

            const lr1 = simd.z._mm_unpackhi_epi32(l, r);
            const lr0 = simd.z._mm_unpacklo_epi32(l, r);

            const s01 = simd.z._mm_packs_epi32(lr0, lr1);

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

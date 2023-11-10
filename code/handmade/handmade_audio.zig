const platform = @import("handmade_platform");

const h = struct {
    usingnamespace @import("handmade_asset.zig");
    usingnamespace @import("handmade_data.zig");
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

    ID: h.sound_id,
    samplesPlayed: i32,
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

    playingSound.next = audioState.firstPlayingSound;
    audioState.firstPlayingSound = playingSound;

    return playingSound;
}

pub fn ChangeVolume(audioState: *audio_state, sound: *playing_sound, fadeDurationInSeconds: f32, volume: h.v2) void {
    _ = audioState;
    if (fadeDurationInSeconds <= 0) {
        sound.targetVolume = volume;
        sound.currentVolume = sound.targetVolume;
    } else {
        const oneOverFade = 1 / fadeDurationInSeconds;
        sound.targetVolume = volume;
        sound.dCurrentVolume = h.Scale(h.Sub(sound.targetVolume, sound.currentVolume), oneOverFade);
    }
}

pub fn OutputPlayingSounds(audioState: *audio_state, soundBuffer: *platform.sound_output_buffer, assets: *h.game_assets, tempArena: *h.memory_arena) void {
    const mixerMemory = h.BeginTemporaryMemory(tempArena);
    defer h.EndTemporaryMemory(mixerMemory);

    var realChannel0: []f32 = tempArena.PushSlice(f32, soundBuffer.sampleCount);
    var realChannel1: []f32 = tempArena.PushSlice(f32, soundBuffer.sampleCount);

    const secondsPerSample = 1 / @as(f32, @floatFromInt(soundBuffer.samplesPerSecond));

    // clear out mixer channel
    {
        var dest0 = realChannel0;
        var dest1 = realChannel1;

        for (0..soundBuffer.sampleCount) |sampleIndex| {
            dest0[sampleIndex] = 0;
            dest1[sampleIndex] = 0;
        }
    }

    // sum all sounds
    var playingSoundPtr = &audioState.firstPlayingSound;
    while (playingSoundPtr.*) |playingSound| {
        var soundFinished = false;

        var totalSamplesToMix = soundBuffer.sampleCount;
        var dest0 = realChannel0;
        var dest1 = realChannel1;

        while (totalSamplesToMix != 0 and !soundFinished) {
            if (assets.GetSound(playingSound.ID)) |loadedSound| {
                var info: *h.asset_sound_info = assets.GetSoundInfo(playingSound.ID);

                h.PrefetchSound(assets, info.nextIDToPlay);

                var volume = playingSound.currentVolume;
                var dVolume = h.Scale(playingSound.dCurrentVolume, secondsPerSample);

                assert(playingSound.samplesPlayed >= 0);

                var samplesToMix = totalSamplesToMix;
                const samplesRemainingInSound: u32 = loadedSound.sampleCount - @as(u32, @intCast(playingSound.samplesPlayed));
                if (samplesToMix > samplesRemainingInSound) {
                    samplesToMix = samplesRemainingInSound;
                }

                const audioStateOutputChannelCount = 2;
                var volumeEnded: [audioStateOutputChannelCount]bool = [1]bool{false} ** audioStateOutputChannelCount;
                for (0..volumeEnded.len) |channelIndex| {
                    // NOTE (Manav): floating point issues raises it's head here (._.)
                    if (dVolume[channelIndex] != 0) {
                        const deltaVolume = playingSound.targetVolume[channelIndex] - volume[channelIndex];
                        const volumeSampleCount: u32 = @intFromFloat((deltaVolume / dVolume[channelIndex]) + 0.5);

                        if (samplesToMix > volumeSampleCount) {
                            samplesToMix = volumeSampleCount;
                            volumeEnded[channelIndex] = true;
                        }
                    }
                }

                var sampleIndex: u32 = @intCast(playingSound.samplesPlayed);
                var dataIndex: u32 = 0;
                while (sampleIndex < @as(u32, @intCast(playingSound.samplesPlayed)) + samplesToMix) : ({
                    sampleIndex += 1;
                    dataIndex += 1;
                }) {
                    var sampleValue: i16 = loadedSound.samples[0].?[sampleIndex];

                    dest0[dataIndex] += audioState.masterVolume[0] * volume[0] * @as(f32, @floatFromInt(sampleValue));
                    dest1[dataIndex] += audioState.masterVolume[1] * volume[1] * @as(f32, @floatFromInt(sampleValue));

                    h.AddTo(&volume, dVolume);
                }

                playingSound.currentVolume = volume;

                for (0..volumeEnded.len) |channelIndex| {
                    if (volumeEnded[channelIndex]) {
                        playingSound.currentVolume[channelIndex] = playingSound.targetVolume[channelIndex];
                        playingSound.dCurrentVolume[channelIndex] = 0;
                    }
                }

                assert(totalSamplesToMix >= samplesToMix);
                playingSound.samplesPlayed += @intCast(samplesToMix);
                totalSamplesToMix -= samplesToMix;

                if (@as(u32, @intCast(playingSound.samplesPlayed)) == loadedSound.sampleCount) {
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

    // convert to 16 bit
    {
        var source0 = realChannel0;
        var source1 = realChannel1;

        var sampleOut = soundBuffer.samples;
        for (0..soundBuffer.sampleCount) |sampleIndex| {
            sampleOut[2 * sampleIndex] = @intFromFloat(source0[sampleIndex] + 0.5);
            sampleOut[2 * sampleIndex + 1] = @intFromFloat(source1[sampleIndex] + 0.5);
        }
    }
}

pub fn InitializeAudioState(audioState: *audio_state, arena: *h.memory_arena) void {
    audioState.permArena = arena;
    audioState.firstPlayingSound = null;
    audioState.firstFreePlayingSound = null;

    audioState.masterVolume = .{ 1, 1 };
}

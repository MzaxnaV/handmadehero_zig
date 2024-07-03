import wave

num_channels = 2
sample_width = 2  # 2 bytes per sample (16 bits)
frame_rate = 48000
duration = 1  # duration in seconds
num_samples = frame_rate * duration

left_channel_data = bytearray(num_samples * sample_width)
right_channel_data = bytearray(num_samples * sample_width)

for i in range(0, len(left_channel_data), sample_width):
    # Assign even values (0x00, 0x02, 0x04, etc.) for the left channel
    left = i % 256
    left_channel_data[i : i + sample_width] = left.to_bytes(2, byteorder="little")

    # Assign odd values (0x01, 0x03, 0x05, etc.) for the right channel
    right = (i + 1) % 256
    right_channel_data[i : i + sample_width] = right.to_bytes(2, byteorder="little")

interleaved_data = bytearray()
for i in range(0, len(left_channel_data), sample_width):
    interleaved_data.extend(left_channel_data[i : i + sample_width])
    interleaved_data.extend(right_channel_data[i : i + sample_width])

with wave.open(f"wave_stereo_test_{duration}sec.wav", "wb") as f:
    f.setnchannels(num_channels)
    f.setsampwidth(sample_width)
    f.setframerate(frame_rate)
    f.writeframes(interleaved_data)

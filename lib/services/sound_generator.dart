import 'dart:math';
import 'dart:typed_data';

class SoundGenerator {
  static const int sampleRate = 44100;

  static Uint8List generateWav(List<double> samples) {
    final numSamples = samples.length;
    final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
    final fileSize = 44 + dataSize;

    final buffer = ByteData(fileSize);

    // RIFF header
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, fileSize - 8, Endian.little);
    buffer.setUint8(8, 0x57);  // W
    buffer.setUint8(9, 0x41);  // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // fmt chunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6D); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // (space)
    buffer.setUint32(16, 16, Endian.little); // chunk size
    buffer.setUint16(20, 1, Endian.little);  // PCM format
    buffer.setUint16(22, 1, Endian.little);  // mono
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    buffer.setUint16(32, 2, Endian.little);  // block align
    buffer.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      final sample = (samples[i].clamp(-1.0, 1.0) * 32767).toInt();
      buffer.setInt16(44 + i * 2, sample, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  /// Short bright pop for correct tap
  static Uint8List tapCorrect() {
    final duration = 0.08;
    final numSamples = (sampleRate * duration).toInt();
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration); // linear decay
      final freq = 880 + 440 * (1.0 - t / duration); // descending chirp
      return sin(2 * pi * freq * t) * envelope * envelope * 0.5;
    });
    return generateWav(samples);
  }

  /// Heavy buzz for wrong tap
  static Uint8List tapWrong() {
    final duration = 0.25;
    final numSamples = (sampleRate * duration).toInt();
    final rng = Random(42);
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration);
      final tone = sin(2 * pi * 110 * t) * 0.4;
      final noise = (rng.nextDouble() - 0.5) * 0.3;
      return (tone + noise) * envelope * 0.6;
    });
    return generateWav(samples);
  }

  /// Countdown beep
  static Uint8List countdownBeep() {
    final duration = 0.12;
    final numSamples = (sampleRate * duration).toInt();
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration);
      return sin(2 * pi * 660 * t) * envelope * envelope * 0.4;
    });
    return generateWav(samples);
  }

  /// Countdown GO! - higher pitch
  static Uint8List countdownGo() {
    final duration = 0.2;
    final numSamples = (sampleRate * duration).toInt();
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration);
      final tone1 = sin(2 * pi * 880 * t) * 0.3;
      final tone2 = sin(2 * pi * 1320 * t) * 0.2;
      return (tone1 + tone2) * envelope * 0.5;
    });
    return generateWav(samples);
  }

  /// Level up - ascending two-tone
  static Uint8List levelUp() {
    final duration = 0.3;
    final numSamples = (sampleRate * duration).toInt();
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration) * (t / duration < 0.1 ? t / duration / 0.1 : 1.0);
      final freq = 440 + 880 * (t / duration); // ascending
      return sin(2 * pi * freq * t) * envelope * 0.4;
    });
    return generateWav(samples);
  }

  /// Slow-mo whoosh
  static Uint8List slowMo() {
    final duration = 0.25;
    final numSamples = (sampleRate * duration).toInt();
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration);
      final freq = 600 - 400 * (t / duration); // descending
      return sin(2 * pi * freq * t) * envelope * envelope * 0.35;
    });
    return generateWav(samples);
  }

  /// Combo lost - descending two-step
  static Uint8List comboLost() {
    final duration = 0.2;
    final numSamples = (sampleRate * duration).toInt();
    final samples = List<double>.generate(numSamples, (i) {
      final t = i / sampleRate;
      final envelope = (1.0 - t / duration);
      final freq = t < duration / 2 ? 440.0 : 330.0;
      return sin(2 * pi * freq * t) * envelope * 0.35;
    });
    return generateWav(samples);
  }
}

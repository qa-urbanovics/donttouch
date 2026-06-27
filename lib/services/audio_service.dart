// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sound_generator.dart';

enum GameSound {
  tapCorrect,
  tapWrong,
  countdownBeep,
  countdownGo,
  levelUp,
  slowMo,
  comboLost,
}

class AudioService {
  static const _keyMuted = 'sound_muted';

  late SharedPreferences _prefs;
  final Map<GameSound, String> _soundPaths = {};
  final List<AudioPlayer> _pool = [];
  int _poolIndex = 0;

  bool _muted = false;
  bool get isMuted => _muted;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _muted = _prefs.getBool(_keyMuted) ?? false;

    // Save generated WAV sounds to temp files (BytesSource unreliable on iOS)
    final dir = await getTemporaryDirectory();
    final soundDir = Directory('${dir.path}/game_sounds');
    if (!soundDir.existsSync()) {
      soundDir.createSync();
    }

    final generators = <GameSound, List<int> Function()>{
      GameSound.tapCorrect: SoundGenerator.tapCorrect,
      GameSound.tapWrong: SoundGenerator.tapWrong,
      GameSound.countdownBeep: SoundGenerator.countdownBeep,
      GameSound.countdownGo: SoundGenerator.countdownGo,
      GameSound.levelUp: SoundGenerator.levelUp,
      GameSound.slowMo: SoundGenerator.slowMo,
      GameSound.comboLost: SoundGenerator.comboLost,
    };

    for (final entry in generators.entries) {
      final path = '${soundDir.path}/${entry.key.name}.wav';
      final file = File(path);
      if (!file.existsSync()) {
        file.writeAsBytesSync(entry.value());
      }
      _soundPaths[entry.key] = path;
    }

    // Create audio player pool (allow overlapping sounds)
    for (int i = 0; i < 4; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      _pool.add(player);
    }
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    await _prefs.setBool(_keyMuted, _muted);
  }

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    await _prefs.setBool(_keyMuted, _muted);
  }

  void play(GameSound sound) {
    if (_muted) return;

    final path = _soundPaths[sound];
    if (path == null) return;

    final player = _pool[_poolIndex % _pool.length];
    _poolIndex++;

    player.stop();
    player.play(DeviceFileSource(path));
  }

  Future<void> dispose() async {
    for (final player in _pool) {
      await player.dispose();
    }
    _pool.clear();
  }
}

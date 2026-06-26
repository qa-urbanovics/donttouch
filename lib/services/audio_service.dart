// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
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
  final Map<GameSound, Uint8List> _sounds = {};
  final List<AudioPlayer> _pool = [];
  int _poolIndex = 0;

  bool _muted = false;
  bool get isMuted => _muted;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _muted = _prefs.getBool(_keyMuted) ?? false;

    // Pre-generate all sounds
    _sounds[GameSound.tapCorrect] = SoundGenerator.tapCorrect();
    _sounds[GameSound.tapWrong] = SoundGenerator.tapWrong();
    _sounds[GameSound.countdownBeep] = SoundGenerator.countdownBeep();
    _sounds[GameSound.countdownGo] = SoundGenerator.countdownGo();
    _sounds[GameSound.levelUp] = SoundGenerator.levelUp();
    _sounds[GameSound.slowMo] = SoundGenerator.slowMo();
    _sounds[GameSound.comboLost] = SoundGenerator.comboLost();

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

    final data = _sounds[sound];
    if (data == null) return;

    final player = _pool[_poolIndex % _pool.length];
    _poolIndex++;

    player.stop();
    player.play(BytesSource(data));
  }

  Future<void> dispose() async {
    for (final player in _pool) {
      await player.dispose();
    }
    _pool.clear();
  }
}

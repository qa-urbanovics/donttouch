// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const _keyHighScore = 'high_score';
  static const _keyTotalGames = 'total_games';
  static const _keyMaxCombo = 'max_combo';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get highScore => _prefs.getInt(_keyHighScore) ?? 0;
  int get totalGames => _prefs.getInt(_keyTotalGames) ?? 0;
  int get maxCombo => _prefs.getInt(_keyMaxCombo) ?? 0;

  Future<bool> submitScore(int score, int combo) async {
    await _prefs.setInt(_keyTotalGames, totalGames + 1);

    bool isNewRecord = false;

    if (score > highScore) {
      await _prefs.setInt(_keyHighScore, score);
      isNewRecord = true;
    }

    if (combo > maxCombo) {
      await _prefs.setInt(_keyMaxCombo, combo);
    }

    return isNewRecord;
  }
}

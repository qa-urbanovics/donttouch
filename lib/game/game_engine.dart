// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'dart:math';
import 'tile.dart';

enum GameEvent {
  levelUp,
  miss,
  nearMiss,
  comboLost,
  slowMoStart,
  slowMoEnd,
}

class GameEngine {
  final int gridCols;
  final int gridRows;

  static const double baseSpawnInterval = 1.2;
  static const double minSpawnInterval = 0.2;
  static const double baseTileLifetime = 2.5;
  static const double minTileLifetime = 0.6;
  static const double speedMultiplierStep = 0.12;
  static const double slowMoDuration = 2.5;
  static const double slowMoFactor = 0.4;

  // Score thresholds for each level (level 2 starts at index 0)
  static const List<int> _levelThresholds = [
    5, 12, 22, 35, 52, 73, 100, 132, 170, 215,
    268, 330, 400, 480, 570, 672, 786, 914, 1058,
  ];

  final Random _random = Random();
  final List<GameTile> tiles = [];

  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  double elapsed = 0;
  double _timeSinceLastSpawn = 0;
  int _nextId = 0;
  bool isGameOver = false;
  bool isPaused = false;

  // Slow-mo state
  double _slowMoRemaining = 0;
  bool get isSlowMo => _slowMoRemaining > 0;
  double get slowMoProgress => (_slowMoRemaining / slowMoDuration).clamp(0.0, 1.0);

  // Death state for dramatic effect
  bool isDying = false;
  double deathTimer = 0;
  int? killerTileId;

  GameEngine({required this.gridCols, required this.gridRows});

  int get level {
    for (int i = _levelThresholds.length - 1; i >= 0; i--) {
      if (score >= _levelThresholds[i]) return i + 2;
    }
    return 1;
  }

  int get _scoreForNextLevel {
    final lvl = level;
    if (lvl - 1 >= _levelThresholds.length) return score;
    return _levelThresholds[lvl - 1];
  }

  int get _scoreForCurrentLevel {
    final lvl = level;
    if (lvl <= 1) return 0;
    return _levelThresholds[lvl - 2];
  }

  double get speedMultiplier => 1.0 + (level - 1) * speedMultiplierStep;

  double get currentSpawnInterval =>
      (baseSpawnInterval / speedMultiplier).clamp(minSpawnInterval, baseSpawnInterval);

  double get currentTileLifetime =>
      (baseTileLifetime / speedMultiplier).clamp(minTileLifetime, baseTileLifetime);

  double get levelProgress {
    final current = _scoreForCurrentLevel;
    final next = _scoreForNextLevel;
    if (next <= current) return 1.0;
    return ((score - current) / (next - current)).clamp(0.0, 1.0);
  }

  double get _timeScale => isSlowMo ? slowMoFactor : 1.0;

  void reset() {
    tiles.clear();
    score = 0;
    combo = 0;
    maxCombo = 0;
    elapsed = 0;
    _timeSinceLastSpawn = 0;
    _nextId = 0;
    isGameOver = false;
    isPaused = false;
    isDying = false;
    deathTimer = 0;
    killerTileId = null;
    _slowMoRemaining = 0;
  }

  void warmUp() {
    for (int i = 0; i < 3; i++) {
      _spawnTile(forceGreen: i == 0);
    }
  }

  List<GameEvent> update(double dt) {
    if (isGameOver || isPaused) return [];

    if (isDying) {
      deathTimer += dt;
      if (deathTimer >= 0.9) {
        isGameOver = true;
      }
      return [];
    }

    final events = <GameEvent>[];
    final scaledDt = dt * _timeScale;

    elapsed += scaledDt;
    _timeSinceLastSpawn += scaledDt;

    // Slow-mo countdown
    if (_slowMoRemaining > 0) {
      _slowMoRemaining -= dt; // Real time, not scaled
      if (_slowMoRemaining <= 0) {
        _slowMoRemaining = 0;
        events.add(GameEvent.slowMoEnd);
      }
    }

    // Age tiles
    for (final tile in tiles) {
      tile.age += scaledDt;
    }

    // Check expired tiles
    final expired = tiles.where((t) => t.isExpired && !t.tapped && !t.dying).toList();
    for (final tile in expired) {
      if (tile.type == TileType.green) {
        // Near miss: tile was > 85% through its lifetime when it expired
        // and player had an active combo
        if (tile.progress >= 0.85 && combo > 0) {
          events.add(GameEvent.nearMiss);
        }
        if (combo > 2) {
          events.add(GameEvent.comboLost);
        }
        combo = 0;
        events.add(GameEvent.miss);
      }
      tile.dying = true;
    }

    // Remove fully dead tiles
    tiles.removeWhere((t) => t.dying && t.age > t.lifetime + 0.35);

    // Spawn new tiles
    if (_timeSinceLastSpawn >= currentSpawnInterval) {
      _timeSinceLastSpawn = 0;
      _spawnTile();
    }

    return events;
  }

  void _spawnTile({bool forceGreen = false}) {
    final occupied = tiles
        .where((t) => !t.dying)
        .map((t) => t.row * gridCols + t.col)
        .toSet();

    final emptyCells = <int>[];
    for (int i = 0; i < gridRows * gridCols; i++) {
      if (!occupied.contains(i)) emptyCells.add(i);
    }

    if (emptyCells.isEmpty) return;

    final cellIndex = emptyCells[_random.nextInt(emptyCells.length)];
    final row = cellIndex ~/ gridCols;
    final col = cellIndex % gridCols;

    final type = forceGreen ? TileType.green : _randomTileType();

    tiles.add(GameTile(
      id: _nextId++,
      type: type,
      row: row,
      col: col,
      lifetime: currentTileLifetime,
    ));
  }

  TileType _randomTileType() {
    final roll = _random.nextDouble();

    if (level >= 7) {
      // Level 7+: green 40%, red 42%, yellow 18%
      if (roll < 0.40) return TileType.green;
      if (roll < 0.82) return TileType.red;
      return TileType.yellow;
    } else if (level >= 5) {
      // Level 5-6: green 45%, red 40%, yellow 15%
      if (roll < 0.45) return TileType.green;
      if (roll < 0.85) return TileType.red;
      return TileType.yellow;
    } else if (level >= 3) {
      // Level 3-4: green 50%, red 40%, yellow 10%
      if (roll < 0.50) return TileType.green;
      if (roll < 0.90) return TileType.red;
      return TileType.yellow;
    } else {
      // Level 1-2: green 55%, red 45%
      if (roll < 0.55) return TileType.green;
      return TileType.red;
    }
  }

  // Set by tapTile when a level up happens
  bool _pendingLevelUp = false;
  bool get hasPendingLevelUp {
    if (_pendingLevelUp) {
      _pendingLevelUp = false;
      return true;
    }
    return false;
  }

  /// Returns: 'correct', 'wrong', 'neutral', 'slowmo'
  String tapTile(int tileId) {
    final idx = tiles.indexWhere((t) => t.id == tileId);
    if (idx == -1) return 'neutral';

    final tile = tiles[idx];
    if (tile.tapped || tile.dying) return 'neutral';

    tile.tapped = true;
    tile.dying = true;

    switch (tile.type) {
      case TileType.green:
        final prevLevel = level;
        combo++;
        if (combo > maxCombo) maxCombo = combo;
        score += 1 * combo;
        if (level > prevLevel) {
          _pendingLevelUp = true;
        }
        return 'correct';
      case TileType.red:
        isDying = true;
        deathTimer = 0;
        killerTileId = tileId;
        return 'wrong';
      case TileType.yellow:
        _slowMoRemaining = slowMoDuration;
        return 'slowmo';
    }
  }
}

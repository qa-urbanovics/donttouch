// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:dont_touch_red/game/game_engine.dart';
import 'package:dont_touch_red/game/tile.dart';

void main() {
  group('GameEngine', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine(gridCols: 4, gridRows: 5);
    });

    test('initial state is correct', () {
      expect(engine.score, 0);
      expect(engine.level, 1);
      expect(engine.combo, 0);
      expect(engine.isGameOver, false);
      expect(engine.tiles, isEmpty);
    });

    test('tapping green tile increases score', () {
      final tile = GameTile(id: 0, row: 0, col: 0, type: TileType.green, lifetime: 2.5);
      engine.tiles.add(tile);
      final result = engine.tapTile(0);
      expect(result, 'correct');
      expect(engine.score, greaterThan(0));
    });

    test('tapping red tile triggers death', () {
      final tile = GameTile(id: 0, row: 0, col: 0, type: TileType.red, lifetime: 2.5);
      engine.tiles.add(tile);
      final result = engine.tapTile(0);
      expect(result, 'wrong');
      expect(engine.isDying, true);
    });

    test('tapping yellow tile activates slow-mo', () {
      final tile = GameTile(id: 0, row: 0, col: 0, type: TileType.yellow, lifetime: 2.5);
      engine.tiles.add(tile);
      final result = engine.tapTile(0);
      expect(result, 'slowmo');
      expect(engine.isSlowMo, true);
    });

    test('combo increases on consecutive green taps', () {
      for (int i = 0; i < 3; i++) {
        engine.tiles.add(GameTile(id: i, row: 0, col: i, type: TileType.green, lifetime: 2.5));
        engine.tapTile(i);
      }
      expect(engine.combo, 3);
      expect(engine.maxCombo, 3);
    });

    test('reset clears all state', () {
      engine.tiles.add(GameTile(id: 0, row: 0, col: 0, type: TileType.green, lifetime: 2.5));
      engine.tapTile(0);
      engine.reset();
      expect(engine.score, 0);
      expect(engine.combo, 0);
      expect(engine.tiles, isEmpty);
      expect(engine.isGameOver, false);
    });
  });
}

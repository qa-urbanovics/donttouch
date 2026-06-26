// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

enum TileType { green, red, yellow }

class GameTile {
  final int id;
  final TileType type;
  final int row;
  final int col;
  final double lifetime;
  double age;
  bool tapped;
  bool dying;

  GameTile({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    required this.lifetime,
    this.age = 0,
    this.tapped = false,
    this.dying = false,
  });

  double get progress => (age / lifetime).clamp(0.0, 1.0);
  bool get isExpired => age >= lifetime;
}

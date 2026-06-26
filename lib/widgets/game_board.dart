// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_engine.dart';
import '../game/tile.dart';
import '../theme/app_theme.dart';

class GameBoard extends StatelessWidget {
  final GameEngine engine;
  final void Function(int tileId, Offset globalPosition) onTileTap;
  final double shakeOffsetX;
  final double shakeOffsetY;

  const GameBoard({
    super.key,
    required this.engine,
    required this.onTileTap,
    this.shakeOffsetX = 0,
    this.shakeOffsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(shakeOffsetX, shakeOffsetY),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / engine.gridCols;
          final cellHeight = constraints.maxHeight / engine.gridRows;
          final cellSize = min(cellWidth, cellHeight);
          final totalWidth = cellSize * engine.gridCols;
          final totalHeight = cellSize * engine.gridRows;
          final offsetX = (constraints.maxWidth - totalWidth) / 2;
          final offsetY = (constraints.maxHeight - totalHeight) / 2;

          return Stack(
            children: [
              // Grid background
              Positioned(
                left: offsetX,
                top: offsetY,
                width: totalWidth,
                height: totalHeight,
                child: CustomPaint(
                  painter: _GridPainter(
                    rows: engine.gridRows,
                    cols: engine.gridCols,
                  ),
                ),
              ),
              // Tiles
              ...engine.tiles.map((tile) {
                final tileLeft = offsetX + tile.col * cellSize;
                final tileTop = offsetY + tile.row * cellSize;
                return Positioned(
                  left: tileLeft,
                  top: tileTop,
                  width: cellSize,
                  height: cellSize,
                  child: _TileWidget(
                    key: ValueKey(tile.id),
                    tile: tile,
                    isDeath: engine.killerTileId == tile.id,
                    isSlowMo: engine.isSlowMo,
                    onTap: (globalPos) => onTileTap(tile.id, globalPos),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final GameTile tile;
  final bool isDeath;
  final bool isSlowMo;
  final void Function(Offset globalPosition) onTap;

  const _TileWidget({
    super.key,
    required this.tile,
    required this.isDeath,
    required this.isSlowMo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _tileColor;
    final glowColor = _glowColor;

    double opacity = 1.0;
    double scale = 1.0;

    if (isDeath) {
      // Death tile grows and pulses red
      scale = 1.4;
      opacity = 1.0;
    } else if (tile.dying) {
      opacity = 0.0;
      scale = 1.3;
    } else if (tile.age < 0.15) {
      final t = (tile.age / 0.15).clamp(0.0, 1.0);
      scale = 0.3 + 0.7 * Curves.elasticOut.transform(t);
      opacity = t;
    } else {
      // Pulse near expiry (last 30%)
      final remaining = 1.0 - tile.progress;
      if (remaining < 0.3 && tile.type == TileType.green) {
        final pulseT = (0.3 - remaining) / 0.3;
        final sinVal = sin(tile.age * 14);
        opacity = 0.5 + 0.5 * (1.0 - pulseT * 0.4 * (sinVal + 1));
        scale = 1.0 + pulseT * 0.03 * (sinVal + 1);
      }
    }

    final glowRadius = isDeath ? 30.0 : (isSlowMo && tile.type == TileType.yellow ? 24.0 : 16.0);
    final glowAlpha = isDeath ? 0.9 : 0.5;

    return GestureDetector(
      onTapDown: (details) => onTap(details.globalPosition),
      child: AnimatedOpacity(
        opacity: opacity.clamp(0.0, 1.0),
        duration: tile.dying
            ? const Duration(milliseconds: 200)
            : const Duration(milliseconds: 50),
        child: AnimatedScale(
          scale: scale,
          duration: isDeath
            ? const Duration(milliseconds: 300)
            : tile.dying
              ? const Duration(milliseconds: 200)
              : const Duration(milliseconds: 120),
          curve: isDeath ? Curves.easeOutBack : Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.all(3.5),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(glowAlpha),
                    blurRadius: glowRadius,
                    spreadRadius: isDeath ? 4 : 1,
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildContent() {
    if (isDeath) {
      return const Center(
        child: Icon(Icons.close, color: Colors.white, size: 32),
      );
    }
    if (tile.type == TileType.green) {
      return Center(child: _TimerRing(progress: tile.progress));
    }
    if (tile.type == TileType.yellow) {
      return Center(
        child: Icon(
          Icons.slow_motion_video,
          color: Colors.black.withOpacity(0.4),
          size: 20,
        ),
      );
    }
    return null;
  }

  Color get _tileColor {
    switch (tile.type) {
      case TileType.green:
        return AppColors.green;
      case TileType.red:
        return isDeath ? const Color(0xFFFF0020) : AppColors.red;
      case TileType.yellow:
        return AppColors.yellow;
    }
  }

  Color get _glowColor {
    switch (tile.type) {
      case TileType.green:
        return AppColors.greenGlow;
      case TileType.red:
        return AppColors.redGlow;
      case TileType.yellow:
        return AppColors.yellow;
    }
  }
}

class _TimerRing extends StatelessWidget {
  final double progress;

  const _TimerRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        value: 1.0 - progress,
        strokeWidth: 2.5,
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation<Color>(
          progress > 0.7 ? Colors.white38 : Colors.white70,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int rows;
  final int cols;

  _GridPainter({required this.rows, required this.cols});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), paint);
    }
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(Offset(0, i * cellH), Offset(size.width, i * cellH), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

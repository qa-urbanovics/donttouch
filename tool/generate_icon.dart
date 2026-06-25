// Generates app icon as PNG programmatically.
// Run: dart run tool/generate_icon.dart
// Requires: dart pub add image --dev

import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Background: dark navy (#0A0A1A)
  final bgColor = img.ColorRgba8(10, 10, 26, 255);
  img.fill(image, color: bgColor);

  // Draw rounded rectangle background with subtle gradient effect
  _drawRoundedRect(image, 0, 0, size, size, 180, img.ColorRgba8(18, 18, 42, 255));

  // Draw grid pattern (subtle)
  final gridColor = img.ColorRgba8(30, 30, 60, 255);
  const gridSize = 4;
  final cellW = size / gridSize;
  final cellH = size / gridSize;

  for (int i = 1; i < gridSize; i++) {
    final x = (i * cellW).round();
    final y = (i * cellH).round();
    for (int py = 0; py < size; py++) {
      image.setPixel(x, py, gridColor);
      if (x + 1 < size) image.setPixel(x + 1, py, gridColor);
    }
    for (int px = 0; px < size; px++) {
      image.setPixel(px, y, gridColor);
      if (y + 1 < size) image.setPixel(px, y + 1, gridColor);
    }
  }

  // Draw colored tiles in grid cells
  const padding = 24;
  final tileW = (cellW - padding * 2).round();
  final tileH = (cellH - padding * 2).round();
  const radius = 28;

  // Tile layout:
  // Row 0: green, _, red, green
  // Row 1: _, green, _, red
  // Row 2: red, _, green, _
  // Row 3: green, red, _, green
  final tiles = <List<int?>>[
    [0, null, 1, 0],    // 0=green, 1=red, 2=yellow
    [null, 0, 2, 1],
    [1, null, 0, null],
    [0, 1, null, 0],
  ];

  final green = img.ColorRgba8(0, 230, 118, 255);
  final red = img.ColorRgba8(255, 23, 68, 255);
  final yellow = img.ColorRgba8(255, 234, 0, 255);
  final greenGlow = img.ColorRgba8(0, 230, 118, 60);
  final redGlow = img.ColorRgba8(255, 23, 68, 60);
  final yellowGlow = img.ColorRgba8(255, 234, 0, 60);

  for (int row = 0; row < gridSize; row++) {
    for (int col = 0; col < gridSize; col++) {
      final type = tiles[row][col];
      if (type == null) continue;

      final x = (col * cellW + padding).round();
      final y = (row * cellH + padding).round();

      img.ColorRgba8 color;
      img.ColorRgba8 glow;
      switch (type) {
        case 0:
          color = green;
          glow = greenGlow;
          break;
        case 1:
          color = red;
          glow = redGlow;
          break;
        default:
          color = yellow;
          glow = yellowGlow;
      }

      // Draw glow (larger rect behind)
      _drawRoundedRect(image, x - 6, y - 6, tileW + 12, tileH + 12, radius + 4, glow);

      // Draw tile
      _drawRoundedRect(image, x, y, tileW, tileH, radius, color);

      // Draw X on red tiles
      if (type == 1) {
        _drawX(image, x, y, tileW, tileH, img.ColorRgba8(255, 255, 255, 180));
      }

      // Draw checkmark on green tiles
      if (type == 0) {
        _drawCheck(image, x, y, tileW, tileH, img.ColorRgba8(255, 255, 255, 180));
      }
    }
  }

  // Save all required sizes
  final basePath = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final sizes = {
    'Icon-App-1024x1024@1x.png': 1024,
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
  };

  for (final entry in sizes.entries) {
    final resized = img.copyResize(image, width: entry.value, height: entry.value, interpolation: img.Interpolation.average);
    final file = File('$basePath/${entry.key}');
    file.writeAsBytesSync(img.encodePng(resized));
    print('Generated ${entry.key} (${entry.value}x${entry.value})');
  }

  // Also save web icons
  final webSizes = {
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
    'web/favicon.png': 32,
  };

  for (final entry in webSizes.entries) {
    final resized = img.copyResize(image, width: entry.value, height: entry.value, interpolation: img.Interpolation.average);
    final file = File(entry.key);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(img.encodePng(resized));
    print('Generated ${entry.key} (${entry.value}x${entry.value})');
  }

  print('\nAll icons generated successfully!');
}

void _drawRoundedRect(img.Image image, int x, int y, int w, int h, int r, img.Color color) {
  r = min(r, min(w ~/ 2, h ~/ 2));
  for (int py = y; py < y + h; py++) {
    for (int px = x; px < x + w; px++) {
      if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;

      // Check if inside rounded rect
      bool inside = true;
      final dx = px - x;
      final dy = py - y;

      // Check corners
      if (dx < r && dy < r) {
        inside = _inCircle(dx, dy, r, r, r);
      } else if (dx > w - r - 1 && dy < r) {
        inside = _inCircle(dx, dy, w - r - 1, r, r);
      } else if (dx < r && dy > h - r - 1) {
        inside = _inCircle(dx, dy, r, h - r - 1, r);
      } else if (dx > w - r - 1 && dy > h - r - 1) {
        inside = _inCircle(dx, dy, w - r - 1, h - r - 1, r);
      }

      if (inside) {
        final existing = image.getPixel(px, py);
        final a = (color as img.ColorRgba8).a / 255.0;
        if (a >= 1.0) {
          image.setPixel(px, py, color);
        } else {
          // Alpha blend
          final nr = ((color.r * a + existing.r * (1 - a))).round().clamp(0, 255);
          final ng = ((color.g * a + existing.g * (1 - a))).round().clamp(0, 255);
          final nb = ((color.b * a + existing.b * (1 - a))).round().clamp(0, 255);
          image.setPixel(px, py, img.ColorRgba8(nr, ng, nb, 255));
        }
      }
    }
  }
}

bool _inCircle(int px, int py, int cx, int cy, int r) {
  final dx = px - cx;
  final dy = py - cy;
  return dx * dx + dy * dy <= r * r;
}

void _drawX(img.Image image, int tx, int ty, int tw, int th, img.Color color) {
  final cx = tx + tw ~/ 2;
  final cy = ty + th ~/ 2;
  final s = min(tw, th) ~/ 4;
  const thickness = 8;

  for (int i = -s; i <= s; i++) {
    for (int t = -thickness; t <= thickness; t++) {
      // Diagonal 1
      final x1 = cx + i + t ~/ 2;
      final y1 = cy + i;
      if (x1 >= 0 && y1 >= 0 && x1 < image.width && y1 < image.height) {
        image.setPixel(x1, y1, color);
      }
      // Diagonal 2
      final x2 = cx - i + t ~/ 2;
      final y2 = cy + i;
      if (x2 >= 0 && y2 >= 0 && x2 < image.width && y2 < image.height) {
        image.setPixel(x2, y2, color);
      }
    }
  }
}

void _drawCheck(img.Image image, int tx, int ty, int tw, int th, img.Color color) {
  final cx = tx + tw ~/ 2;
  final cy = ty + th ~/ 2;
  final s = min(tw, th) ~/ 5;
  const thickness = 6;

  // Draw a simple checkmark: down-right then up-right
  for (int i = 0; i <= s; i++) {
    for (int t = -thickness; t <= thickness; t++) {
      final x = cx - s ~/ 2 + i;
      final y = cy + i ~/ 2 + t;
      if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
        image.setPixel(x, y, color);
      }
    }
  }
  for (int i = 0; i <= s * 2; i++) {
    for (int t = -thickness; t <= thickness; t++) {
      final x = cx + s ~/ 2 + i;
      final y = cy + s ~/ 2 - i ~/ 2 + t;
      if (x >= 0 && y >= 0 && x < image.width && y < image.height) {
        image.setPixel(x, y, color);
      }
    }
  }
}

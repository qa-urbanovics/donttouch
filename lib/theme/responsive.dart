import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late final Size _size;
  late final double _shortestSide;

  Responsive(this.context) {
    _size = MediaQuery.sizeOf(context);
    _shortestSide = _size.shortestSide;
  }

  bool get isTablet => _shortestSide >= 600;
  bool get isSmallPhone => _shortestSide < 380;

  double get scale {
    if (_shortestSide >= 800) return 1.5; // iPad Pro
    if (_shortestSide >= 600) return 1.3; // iPad
    if (_shortestSide >= 400) return 1.0; // Normal phone
    return 0.85; // iPhone SE
  }

  int get gridCols {
    if (_shortestSide >= 800) return 6; // iPad Pro
    if (_shortestSide >= 600) return 5; // iPad
    return 4; // iPhone
  }

  int get gridRows {
    if (_shortestSide >= 800) return 8; // iPad Pro
    if (_shortestSide >= 600) return 7; // iPad
    return 5; // iPhone
  }

  double sp(double size) => size * scale;
}

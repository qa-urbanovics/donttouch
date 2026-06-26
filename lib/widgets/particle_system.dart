// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x, y;
  double vx, vy;
  double life;
  double maxLife;
  double size;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
    required this.color,
  }) : maxLife = life;

  double get progress => (life / maxLife).clamp(0.0, 1.0);
  bool get isDead => life <= 0;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 200 * dt; // gravity
    life -= dt;
    size *= 0.995;
  }
}

class ParticleSystem {
  final List<Particle> _particles = [];
  final Random _random = Random();

  List<Particle> get particles => _particles;
  bool get isEmpty => _particles.isEmpty;

  void emit({
    required double x,
    required double y,
    required Color color,
    int count = 12,
    double speed = 250,
    double sizeMin = 3,
    double sizeMax = 8,
    double lifeMin = 0.4,
    double lifeMax = 0.8,
  }) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final v = speed * (0.4 + _random.nextDouble() * 0.6);
      _particles.add(Particle(
        x: x,
        y: y,
        vx: cos(angle) * v,
        vy: sin(angle) * v - 80, // bias upward
        life: lifeMin + _random.nextDouble() * (lifeMax - lifeMin),
        size: sizeMin + _random.nextDouble() * (sizeMax - sizeMin),
        color: color,
      ));
    }
  }

  void emitExplosion({
    required double x,
    required double y,
    required Color color,
  }) {
    emit(
      x: x,
      y: y,
      color: color,
      count: 30,
      speed: 400,
      sizeMin: 4,
      sizeMax: 12,
      lifeMin: 0.5,
      lifeMax: 1.2,
    );
  }

  void update(double dt) {
    for (final p in _particles) {
      p.update(dt);
    }
    _particles.removeWhere((p) => p.isDead);
  }

  void clear() => _particles.clear();
}

class ParticlePainter extends CustomPainter {
  final ParticleSystem system;

  ParticlePainter(this.system);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in system.particles) {
      final opacity = (p.progress * p.progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.progress, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

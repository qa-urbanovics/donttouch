// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../services/score_service.dart';
import '../services/audio_service.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  final ScoreService scoreService;
  final AudioService audioService;

  const MenuScreen({
    super.key,
    required this.scoreService,
    required this.audioService,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          scoreService: widget.scoreService,
          audioService: widget.audioService,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final highScore = widget.scoreService.highScore;
    final totalGames = widget.scoreService.totalGames;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Mute button top-right
            Positioned(
              top: r.sp(8),
              right: r.sp(8),
              child: IconButton(
                onPressed: () {
                  widget.audioService.toggleMute();
                  setState(() {});
                },
                icon: Icon(
                  widget.audioService.isMuted
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: AppColors.textSecondary,
                  size: r.sp(24),
                ),
              ),
            ),
            Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.sp(420)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.sp(32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.red, Color(0xFFFF6B6B)],
                    ).createShader(bounds),
                    child: Text(
                      'RED',
                      style: TextStyle(
                        fontSize: r.sp(70),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  SizedBox(height: r.sp(2)),
                  Text(
                    'TRAP',
                    style: TextStyle(
                      fontSize: r.sp(50),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -2,
                    ),
                  ),

                  SizedBox(height: r.sp(40)),

                  // Stats
                  if (totalGames > 0) ...[
                    _StatRow(
                        label: 'BEST SCORE',
                        value: '$highScore',
                        scale: r.scale),
                    SizedBox(height: r.sp(6)),
                    _StatRow(
                        label: 'GAMES PLAYED',
                        value: '$totalGames',
                        scale: r.scale),
                    SizedBox(height: r.sp(6)),
                    _StatRow(
                        label: 'BEST COMBO',
                        value: 'x${widget.scoreService.maxCombo}',
                        scale: r.scale),
                    SizedBox(height: r.sp(40)),
                  ],

                  const Spacer(flex: 1),

                  // Play button
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + _pulseController.value * 0.04;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: r.sp(60),
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.greenGlow.withOpacity(0.5),
                        ),
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: r.sp(26),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Hints
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HintDot(color: AppColors.green, scale: r.scale),
                      SizedBox(width: r.sp(6)),
                      Text('Tap', style: TextStyle(
                        color: AppColors.textSecondary, fontSize: r.sp(12))),
                      SizedBox(width: r.sp(20)),
                      _HintDot(color: AppColors.red, scale: r.scale),
                      SizedBox(width: r.sp(6)),
                      Text('Avoid', style: TextStyle(
                        color: AppColors.textSecondary, fontSize: r.sp(12))),
                      SizedBox(width: r.sp(20)),
                      _HintDot(color: AppColors.yellow, scale: r.scale),
                      SizedBox(width: r.sp(6)),
                      Text('Slow-mo', style: TextStyle(
                        color: AppColors.textSecondary, fontSize: r.sp(12))),
                    ],
                  ),

                  SizedBox(height: r.sp(20)),
                ],
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

class _HintDot extends StatelessWidget {
  final Color color;
  final double scale;

  const _HintDot({required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14 * scale,
      height: 14 * scale,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final double scale;

  const _StatRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12 * scale,
            letterSpacing: 2,
          ),
        ),
        SizedBox(width: 12 * scale),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../services/score_service.dart';
import '../services/audio_service.dart';
import 'game_screen.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final int maxCombo;
  final int level;
  final double elapsed;
  final ScoreService scoreService;
  final AudioService audioService;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.maxCombo,
    required this.level,
    required this.elapsed,
    required this.scoreService,
    required this.audioService,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  bool _isNewRecord = false;
  late AnimationController _entryController;
  late AnimationController _countUpController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _scoreCountUp;

  final GlobalKey _shareKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _countUpController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (400 + widget.score * 8).clamp(400, 2000)),
    );

    _slideAnimation = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _scoreCountUp = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _countUpController, curve: Curves.easeOutCubic),
    );

    _saveScore();
    _entryController.forward();

    // Delay count-up for drama
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _countUpController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _countUpController.dispose();
    super.dispose();
  }

  Future<void> _saveScore() async {
    final isNew = await widget.scoreService.submitScore(
      widget.score,
      widget.maxCombo,
    );
    if (mounted) {
      setState(() => _isNewRecord = isNew);
    }
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            GameScreen(
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

  void _goToMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _shareScore() async {
    try {
      final boundary = _shareKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/dont_touch_red_score.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "I scored ${widget.score} points in Don't Touch Red! Can you beat me?",
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share not available: $e')),
        );
      }
    }
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    if (mins > 0) return '${mins}m ${secs}s';
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            );
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.sp(32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Shareable card
                  RepaintBoundary(
                    key: _shareKey,
                    child: Container(
                      color: AppColors.background,
                      padding: EdgeInsets.all(r.sp(24)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Game Over title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.red, Color(0xFFFF6B6B)],
                            ).createShader(bounds),
                            child: Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: r.sp(38),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          if (_isNewRecord) ...[
                            SizedBox(height: r.sp(12)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: r.sp(16),
                                vertical: r.sp(6),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.accent),
                              ),
                              child: Text(
                                'NEW RECORD!',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: r.sp(14),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: r.sp(36)),

                          // Animated score
                          AnimatedBuilder(
                            animation: _scoreCountUp,
                            builder: (context, _) {
                              return Text(
                                '${_scoreCountUp.value}',
                                style: TextStyle(
                                  fontSize: r.sp(68),
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.white,
                                ),
                              );
                            },
                          ),
                          Text(
                            'POINTS',
                            style: TextStyle(
                              fontSize: r.sp(12),
                              color: AppColors.textSecondary,
                              letterSpacing: 4,
                            ),
                          ),

                          SizedBox(height: r.sp(28)),

                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatColumn(
                                  label: 'LEVEL',
                                  value: '${widget.level}',
                                  scale: r.scale),
                              _StatColumn(
                                  label: 'COMBO',
                                  value: 'x${widget.maxCombo}',
                                  scale: r.scale),
                              _StatColumn(
                                  label: 'TIME',
                                  value: _formatTime(widget.elapsed),
                                  scale: r.scale),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  SizedBox(
                    width: r.sp(300),
                    height: r.sp(56),
                    child: ElevatedButton(
                      onPressed: _playAgain,
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
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: r.sp(20),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: r.sp(12)),

                  // Share + Menu row
                  SizedBox(
                    width: r.sp(300),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: r.sp(48),
                            child: TextButton(
                              onPressed: _goToMenu,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: AppColors.grey.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              child: Text(
                                'MENU',
                                style: TextStyle(
                                  fontSize: r.sp(14),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: r.sp(12)),
                        Expanded(
                          child: SizedBox(
                            height: r.sp(48),
                            child: TextButton.icon(
                              onPressed: _shareScore,
                              icon: Icon(Icons.share, size: r.sp(16)),
                              label: Text(
                                'SHARE',
                                style: TextStyle(
                                  fontSize: r.sp(14),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: AppColors.accent.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final double scale;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10 * scale,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

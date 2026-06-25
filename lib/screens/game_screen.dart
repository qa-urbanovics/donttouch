import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game/game_engine.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/game_board.dart';
import '../widgets/particle_system.dart';
import '../services/score_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final ScoreService scoreService;
  final AudioService audioService;

  const GameScreen({
    super.key,
    required this.scoreService,
    required this.audioService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late GameEngine _engine;
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _engineInitialized = false;

  final ParticleSystem _particles = ParticleSystem();

  // Shake
  double _shakeX = 0;
  double _shakeY = 0;
  double _shakeIntensity = 0;
  final Random _random = Random();

  // Score pop
  int _lastScore = 0;
  String _popText = '';
  double _popOpacity = 0;
  double _popY = 0;

  // Level up flash
  double _flashOpacity = 0;
  Color _flashColor = AppColors.accent;

  // Death red overlay
  double _deathOverlay = 0;

  // Feedback texts
  String _feedbackText = '';
  double _feedbackOpacity = 0;
  Color _feedbackColor = AppColors.white;

  // Slow-mo visual
  double _slowMoVisual = 0;

  // Background pulse
  double _bgPulse = 0;

  // Countdown
  int _countdown = 3;
  bool _gameStarted = false;

  // Pause
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_engineInitialized) {
      final r = Responsive(context);
      _engine = GameEngine(gridCols: r.gridCols, gridRows: r.gridRows);
      _engine.reset();
      _engine.warmUp();
      _engineInitialized = true;
      _startCountdown();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_gameStarted && !_engine.isGameOver && !_isPaused) {
        _pause();
      }
    }
  }

  void _startCountdown() async {
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      HapticService.light();
      widget.audioService.play(GameSound.countdownBeep);
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (!mounted) return;
    widget.audioService.play(GameSound.countdownGo);
    setState(() {
      _countdown = 0;
      _gameStarted = true;
    });
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _pause() {
    if (_engine.isGameOver || _engine.isDying) return;
    _ticker.stop();
    _engine.isPaused = true;
    setState(() => _isPaused = true);
  }

  void _resume() {
    _engine.isPaused = false;
    _lastTick = Duration.zero;
    _ticker.start();
    setState(() => _isPaused = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_engine.isGameOver) {
      _ticker.stop();
      Future.delayed(const Duration(milliseconds: 100), _goToGameOver);
      return;
    }

    final dt = _lastTick == Duration.zero
        ? 0.016
        : (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    final clampedDt = dt.clamp(0.0, 0.05);

    final events = _engine.update(clampedDt);
    _particles.update(clampedDt);

    // Shake decay
    if (_shakeIntensity > 0) {
      _shakeIntensity *= 0.82;
      _shakeX = (_random.nextDouble() - 0.5) * 2 * _shakeIntensity;
      _shakeY = (_random.nextDouble() - 0.5) * 1.2 * _shakeIntensity;
      if (_shakeIntensity < 0.3) {
        _shakeIntensity = 0;
        _shakeX = 0;
        _shakeY = 0;
      }
    }

    // Pop decay
    if (_popOpacity > 0) {
      _popOpacity -= clampedDt * 2.5;
      _popY -= clampedDt * 40;
    }

    // Flash decay
    if (_flashOpacity > 0) {
      _flashOpacity -= clampedDt * 3;
    }

    // Death overlay
    if (_engine.isDying) {
      _deathOverlay = (_deathOverlay + clampedDt * 2.5).clamp(0.0, 0.6);
    }

    // Feedback decay
    if (_feedbackOpacity > 0) {
      _feedbackOpacity -= clampedDt * 2.0;
    }

    // Slow-mo visual
    if (_engine.isSlowMo) {
      _slowMoVisual = (_slowMoVisual + clampedDt * 4).clamp(0.0, 1.0);
    } else {
      _slowMoVisual = (_slowMoVisual - clampedDt * 3).clamp(0.0, 1.0);
    }

    // Background pulse based on level
    _bgPulse = 0.3 + 0.7 * sin(elapsed.inMicroseconds / 1000000.0 * (1.0 + _engine.level * 0.15) * 2);

    // Process events
    for (final event in events) {
      switch (event) {
        case GameEvent.levelUp:
          // Level ups now triggered by score in _onTileTap
          break;
        case GameEvent.miss:
          _shakeIntensity = 3;
          break;
        case GameEvent.nearMiss:
          _showFeedback('CLOSE!', AppColors.yellow);
          HapticService.light();
          break;
        case GameEvent.comboLost:
          _showFeedback('COMBO LOST', AppColors.red);
          _shakeIntensity = 5;
          HapticService.medium();
          widget.audioService.play(GameSound.comboLost);
          break;
        case GameEvent.slowMoStart:
          break;
        case GameEvent.slowMoEnd:
          _showFeedback('SPEED UP!', AppColors.white);
          break;
      }
    }

    setState(() {});
  }

  void _showFeedback(String text, Color color) {
    _feedbackText = text;
    _feedbackOpacity = 1.0;
    _feedbackColor = color;
  }

  void _onTileTap(int tileId, Offset globalPos) {
    if (_engine.isGameOver || _engine.isDying || !_gameStarted || _isPaused) {
      return;
    }

    final result = _engine.tapTile(tileId);

    // Convert global position to local for particles
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final localPos = box?.globalToLocal(globalPos) ?? globalPos;

    switch (result) {
      case 'correct':
        HapticService.light();
        widget.audioService.play(GameSound.tapCorrect);
        _particles.emit(
          x: localPos.dx,
          y: localPos.dy,
          color: AppColors.green,
          count: 8,
          speed: 200,
        );
        final gained = _engine.score - _lastScore;
        _lastScore = _engine.score;
        _popText = _engine.combo > 1 ? '+$gained  x${_engine.combo}' : '+$gained';
        _popOpacity = 1.0;
        _popY = 0;
        // Check for level up triggered by score
        if (_engine.hasPendingLevelUp) {
          _flashOpacity = 0.5;
          _flashColor = AppColors.accent;
          _showFeedback('LEVEL ${_engine.level}', AppColors.accent);
          HapticService.medium();
          widget.audioService.play(GameSound.levelUp);
        }
        break;
      case 'wrong':
        HapticService.error();
        widget.audioService.play(GameSound.tapWrong);
        _particles.emitExplosion(
          x: localPos.dx,
          y: localPos.dy,
          color: AppColors.red,
        );
        _shakeIntensity = 25;
        _flashOpacity = 0.8;
        _flashColor = AppColors.red;
        break;
      case 'slowmo':
        HapticService.medium();
        widget.audioService.play(GameSound.slowMo);
        _particles.emit(
          x: localPos.dx,
          y: localPos.dy,
          color: AppColors.yellow,
          count: 10,
          speed: 180,
        );
        _showFeedback('SLOW MOTION!', AppColors.yellow);
        break;
      case 'neutral':
        break;
    }

    setState(() {});
  }

  void _goToGameOver() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameOverScreen(
          score: _engine.score,
          maxCombo: _engine.maxCombo,
          level: _engine.level,
          elapsed: _engine.elapsed,
          scoreService: widget.scoreService,
          audioService: widget.audioService,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    // Background color pulse
    final bgLerp = (_bgPulse * 0.08 * (_engine.level / 15.0)).clamp(0.0, 0.15);
    final bgColor = Color.lerp(AppColors.background, AppColors.surface, bgLerp)!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main game
            Column(
              children: [
                _buildHUD(r),
                // Level progress bar
                _buildProgressBar(),
                // Slow-mo indicator
                if (_engine.isSlowMo) _buildSlowMoBar(),
                // Game board
                Expanded(
                  child: GameBoard(
                    engine: _engine,
                    onTileTap: _onTileTap,
                    shakeOffsetX: _shakeX,
                    shakeOffsetY: _shakeY,
                  ),
                ),
              ],
            ),

            // Particles overlay
            if (!_particles.isEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ParticlePainter(_particles),
                  ),
                ),
              ),

            // Score pop
            if (_popOpacity > 0)
              Positioned(
                top: r.sp(75) + _popY,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: _popOpacity.clamp(0.0, 1.0),
                    child: Center(
                      child: Text(
                        _popText,
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: r.sp(26),
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: AppColors.greenGlow.withOpacity(0.8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Feedback text (COMBO LOST, CLOSE!, LEVEL UP, SLOW MOTION)
            if (_feedbackOpacity > 0)
              Positioned(
                bottom: r.sp(100),
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: _feedbackOpacity.clamp(0.0, 1.0),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.sp(20),
                          vertical: r.sp(8),
                        ),
                        decoration: BoxDecoration(
                          color: _feedbackColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _feedbackColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _feedbackText,
                          style: TextStyle(
                            color: _feedbackColor,
                            fontSize: r.sp(18),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Level up / death flash
            if (_flashOpacity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: _flashColor.withOpacity(_flashOpacity.clamp(0.0, 1.0)),
                  ),
                ),
              ),

            // Death red overlay
            if (_deathOverlay > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AppColors.red.withOpacity(_deathOverlay.clamp(0.0, 0.6)),
                  ),
                ),
              ),

            // Slow-mo vignette
            if (_slowMoVisual > 0.1)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.yellow.withOpacity(0.08 * _slowMoVisual),
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

            // Countdown overlay
            if (!_gameStarted)
              Positioned.fill(
                child: Container(
                  color: AppColors.background.withOpacity(0.85),
                  child: Center(
                    child: Text(
                      _countdown > 0 ? '$_countdown' : 'GO!',
                      style: TextStyle(
                        fontSize: r.sp(96),
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),

            // Pause overlay
            if (_isPaused)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _resume,
                  child: Container(
                    color: AppColors.background.withOpacity(0.9),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pause_circle_outline,
                              color: AppColors.white, size: r.sp(64)),
                          SizedBox(height: r.sp(16)),
                          Text(
                            'PAUSED',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: r.sp(32),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                          SizedBox(height: r.sp(24)),
                          Text(
                            'Tap to resume',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: r.sp(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }

  Widget _buildHUD(Responsive r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.sp(20), vertical: r.sp(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: r.sp(10),
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_engine.score}',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: r.sp(30),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          // Center: combo badge + controls
          Column(
            children: [
              // Combo badge
              if (_engine.combo > 1)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(bottom: r.sp(4)),
                  padding: EdgeInsets.symmetric(
                    horizontal: r.sp(12),
                    vertical: r.sp(3),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    'x${_engine.combo}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: r.sp(16),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              // Mute + Pause buttons
              if (_gameStarted && !_engine.isGameOver && !_engine.isDying)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HudIconButton(
                      icon: widget.audioService.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      size: r.sp(16),
                      onTap: () {
                        widget.audioService.toggleMute();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: r.sp(12)),
                    _HudIconButton(
                      icon: Icons.pause_rounded,
                      size: r.sp(16),
                      onTap: _pause,
                    ),
                  ],
                ),
            ],
          ),

          // Level
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LEVEL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: r.sp(10),
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_engine.level}',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: r.sp(30),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: _engine.levelProgress,
          minHeight: 3,
          backgroundColor: AppColors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.accent.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildSlowMoBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: _engine.slowMoProgress,
          minHeight: 3,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.yellow.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _HudIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size * 2.2,
        height: size * 2.2,
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(size * 0.5),
          border: Border.all(
            color: AppColors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: size),
      ),
    );
  }
}

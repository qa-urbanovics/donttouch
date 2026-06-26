// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'services/score_service.dart';
import 'services/audio_service.dart';
import 'screens/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  final scoreService = ScoreService();
  await scoreService.init();

  final audioService = AudioService();
  await audioService.init(prefs);

  runApp(DontTouchRedApp(
    scoreService: scoreService,
    audioService: audioService,
  ));
}

class DontTouchRedApp extends StatelessWidget {
  final ScoreService scoreService;
  final AudioService audioService;

  const DontTouchRedApp({
    super.key,
    required this.scoreService,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Don't Touch Red",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: MenuScreen(
        scoreService: scoreService,
        audioService: audioService,
      ),
    );
  }
}

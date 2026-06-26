// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A1A);
  static const surface = Color(0xFF12122A);
  static const green = Color(0xFF00E676);
  static const greenGlow = Color(0xFF00E676);
  static const red = Color(0xFFFF1744);
  static const redGlow = Color(0xFFFF1744);
  static const yellow = Color(0xFFFFEA00);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF424260);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8888AA);
  static const accent = Color(0xFF7C4DFF);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -2,
          ),
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
}

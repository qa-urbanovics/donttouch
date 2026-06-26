// Copyright (c) 2026 Aleksejs Urbanovics. All rights reserved.

import 'package:flutter/services.dart';

class HapticService {
  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  static void error() {
    HapticFeedback.vibrate();
  }
}

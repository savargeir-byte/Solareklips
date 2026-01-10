// lib/core/services/shadow_engine.dart
import 'dart:math';

class ShadowEngine {
  /// VERY GOOD approximation for UX (not NASA-grade, but good)
  static Duration totalityDuration({
    required double userLat,
    required double centerLat,
  }) {
    final distance = (userLat - centerLat).abs();
    final seconds = max(0, 160 - (distance * 40));
    return Duration(seconds: seconds.round());
  }
}

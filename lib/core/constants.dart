import 'package:flutter/material.dart';

/// Solar Eclipse Minimal color palette
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF1a1a1a);
  static const Color gold = Color(0xFFe4b85f);
  static const Color goldDim = Color(0xFF8a7344);

  // Additional semantic colors
  static const Color solarOrange = Color(0xFFFF6B35);
  static const Color lunarIndigo = Color(0xFF5B4B8A);
}

/// App configuration constants
class AppConfig {
  static const String appName = 'EclipseMap';
  static const String appVersion = '0.3.1';

  // Asset paths
  static const String eclipsesDataPath = 'assets/mock/eclipse_events.json';
  static const String geoJsonBasePath = 'assets/geojson/';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration coronaAnimationDuration = Duration(seconds: 3);

  // Cache settings
  static const Duration cacheDuration = Duration(hours: 24);
}

/// Supported locales
class AppLocales {
  static const english = Locale('en');
  static const icelandic = Locale('is');

  static const List<Locale> supported = [english, icelandic];
}

class EclipseTimingEngine {
  /// seconds before / after peak where diamond ring happens
  static const int diamondRingWindowSeconds = 12;

  static bool isDiamondRing({
    required DateTime now,
    required DateTime peak,
  }) {
    final diff = now.difference(peak).inSeconds.abs();
    return diff <= diamondRingWindowSeconds;
  }

  static bool isTotality({
    required DateTime now,
    required DateTime start,
    required DateTime end,
  }) {
    return now.isAfter(start) && now.isBefore(end);
  }
}

import 'dart:async';

/// Service for live countdown to eclipse events
/// Emits Duration updates every second until event occurs
class EclipseCountdown {
  final DateTime targetTime;

  EclipseCountdown(this.targetTime);

  /// Stream that emits remaining time every second
  /// Returns Duration.zero when event has passed
  Stream<Duration> stream() async* {
    while (true) {
      final now = DateTime.now().toUtc();
      final remaining = targetTime.difference(now);

      // Emit zero if event has passed, otherwise emit remaining duration
      if (remaining.isNegative) {
        yield Duration.zero;
      } else {
        yield remaining;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Get current remaining time (one-time calculation)
  Duration get remaining {
    final now = DateTime.now().toUtc();
    final diff = targetTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Check if event has already occurred
  bool get hasOccurred {
    return DateTime.now().toUtc().isAfter(targetTime);
  }

  /// Format duration as "X days Y hrs Z min"
  static String formatDuration(Duration duration) {
    if (duration == Duration.zero) return 'Event has occurred';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days days  $hours hrs  $minutes min';
    } else if (hours > 0) {
      return '$hours hrs  $minutes min';
    } else {
      return '$minutes min';
    }
  }

  /// Format as compact countdown "DDd HHh MMm"
  static String formatCompact(Duration duration) {
    if (duration == Duration.zero) return 'Now';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    return '${days}d ${hours}h ${minutes}m';
  }

  /// Format for display in countdown widget with separate units
  static Map<String, int> toUnits(Duration duration) {
    return {
      'days': duration.inDays,
      'hours': duration.inHours % 24,
      'minutes': duration.inMinutes % 60,
      'seconds': duration.inSeconds % 60,
    };
  }
}

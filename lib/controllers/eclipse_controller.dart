import 'dart:ui';

import 'package:flutter/material.dart';

/// Controller for managing eclipse shadow animation state and real-time sync
class EclipseController extends ChangeNotifier {
  final DateTime start;
  final DateTime peak;
  final DateTime end;

  EclipseController({
    required this.start,
    required this.peak,
    required this.end,
  });

  /// Calculate current progress (0.0 to 1.0) based on real time
  double get progress {
    final now = DateTime.now().toUtc();
    if (now.isBefore(start)) return 0;
    if (now.isAfter(end)) return 1;
    return (now.difference(start).inMilliseconds /
            end.difference(start).inMilliseconds)
        .clamp(0.0, 1.0);
  }

  /// Get umbra position on map (normalized 0-1 coordinates)
  Offset get umbraPosition {
    // Smooth movement across Iceland from west to east
    return Offset(
      lerpDouble(0.15, 0.85, progress)!,
      lerpDouble(0.35, 0.45, progress)!,
    );
  }

  /// Get shadow scale factor (grows slightly during eclipse)
  double get shadowScale {
    // Scale from 0.8 to 1.3 with peak at middle
    final peakFactor = 1.0 - (0.5 - progress).abs() * 2;
    return 0.8 + (peakFactor * 0.5);
  }

  /// Get shadow rotation in degrees
  double get shadowRotation {
    return progress * 360;
  }

  /// Format time remaining until peak
  String get timeRemaining {
    final now = DateTime.now().toUtc();
    if (now.isAfter(end)) return 'Eclipse ended';
    if (now.isBefore(start)) {
      final diff = start.difference(now);
      return 'Starts in ${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    if (now.isBefore(peak)) {
      final diff = peak.difference(now);
      return 'Peak in ${diff.inMinutes}m ${diff.inSeconds % 60}s';
    }
    final diff = end.difference(now);
    return 'Ends in ${diff.inMinutes}m ${diff.inSeconds % 60}s';
  }

  /// Get eclipse phase name
  String get phaseName {
    if (progress < 0.1) return 'First Contact';
    if (progress < 0.4) return 'Partial Phase';
    if (progress < 0.6) return 'Totality';
    if (progress < 0.9) return 'Partial Phase';
    return 'Fourth Contact';
  }
}

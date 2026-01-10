// lib/core/services/eclipse_engine.dart
import '../models/eclipse_event_simple.dart';

class EclipseEngine {
  static EclipseEventSimple getNextBigEvent(List<EclipseEventSimple> events) {
    events.sort((a, b) => a.peak.compareTo(b.peak));
    return events.firstWhere((e) => e.peak.isAfter(DateTime.now()));
  }

  static double progress(EclipseEventSimple e) {
    final now = DateTime.now();
    if (now.isBefore(e.start)) return 0;
    if (now.isAfter(e.end)) return 1;
    return now.difference(e.start).inSeconds /
        e.end.difference(e.start).inSeconds;
  }
}

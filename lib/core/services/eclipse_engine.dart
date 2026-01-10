// lib/core/services/eclipse_engine.dart
import '../models/eclipse_event_simple.dart';

class EclipseEngine {
  static List<EclipseEventSimple> allEvents = [
    _iceland2026(),
    _spain2027(),
    _egypt2028(),
  ];

  static EclipseEventSimple getNextEvent(DateTime now) {
    final upcoming = allEvents
        .where((e) => e.peakTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.peakTime.compareTo(b.peakTime));
    return upcoming.first;
  }

  static List<EclipseEventSimple> timeline({int years = 5}) {
    final limit = DateTime.now().add(Duration(days: 365 * years));
    return allEvents
        .where((e) => e.peakTime.isBefore(limit))
        .toList();
  }

  static Duration countdown(EclipseEventSimple e) =>
      e.peakTime.difference(DateTime.now());

  static double progress(EclipseEventSimple e) {
    final now = DateTime.now();
    if (now.isBefore(e.startTime)) return 0;
    if (now.isAfter(e.endTime)) return 1;
    return now.difference(e.startTime).inSeconds /
        e.endTime.difference(e.startTime).inSeconds;
  }

  static EclipseEventSimple _iceland2026() {
    return EclipseEventSimple(
      id: 'iceland_2026',
      title: 'Iceland 2026 – Total Solar Eclipse',
      type: EclipseType.solarTotal,
      startTime: DateTime.utc(2026, 8, 12, 16, 48),
      peakTime: DateTime.utc(2026, 8, 12, 17, 48),
      endTime: DateTime.utc(2026, 8, 12, 18, 42),
      visibility: 'Iceland, Greenland, Arctic',
      description:
          'A rare total solar eclipse crossing Iceland. Prime photography event.',
      pathGeoJson: [
        [63.9, -22.5],
        [64.3, -20.0],
        [65.1, -17.0],
      ],
    );
  }

  static EclipseEventSimple _spain2027() {
    return EclipseEventSimple(
      id: 'spain_2027',
      title: 'Spain 2027 – Total Solar Eclipse',
      type: EclipseType.solarTotal,
      startTime: DateTime.utc(2027, 8, 2, 8, 0),
      peakTime: DateTime.utc(2027, 8, 2, 10, 7),
      endTime: DateTime.utc(2027, 8, 2, 12, 0),
      visibility: 'Spain, Morocco, Algeria, Egypt',
      description:
          'Total solar eclipse with over 6 minutes of totality over Southern Spain.',
      pathGeoJson: [
        [36.7, -6.3],
        [37.2, -4.4],
        [38.0, -2.0],
      ],
    );
  }

  static EclipseEventSimple _egypt2028() {
    return EclipseEventSimple(
      id: 'egypt_2028',
      title: 'Egypt 2028 – Total Solar Eclipse',
      type: EclipseType.solarTotal,
      startTime: DateTime.utc(2028, 7, 22, 9, 0),
      peakTime: DateTime.utc(2028, 7, 22, 10, 27),
      endTime: DateTime.utc(2028, 7, 22, 12, 0),
      visibility: 'Egypt, Saudi Arabia, Australia',
      description:
          'The longest total solar eclipse until 2114 - over 6 minutes of totality.',
      pathGeoJson: [
        [25.7, 32.6],
        [26.2, 34.0],
        [27.0, 36.0],
      ],
    );
  }
}

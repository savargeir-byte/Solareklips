// lib/core/models/eclipse_event_simple.dart
class EclipseEventSimple {
  final String id;
  final DateTime start;
  final DateTime peak;
  final DateTime end;
  final String type; // solar | lunar
  final String subtype; // total | partial | annular
  final String title;
  final List<String> visibleFrom;
  final bool isMajor;

  EclipseEventSimple({
    required this.id,
    required this.start,
    required this.peak,
    required this.end,
    required this.type,
    required this.subtype,
    required this.title,
    required this.visibleFrom,
    this.isMajor = false,
  });

  Duration get duration => end.difference(start);

  Duration timeUntilPeak() => peak.difference(DateTime.now());
}

// lib/core/models/eclipse_event_simple.dart

enum EclipseType { solarTotal, solarPartial, lunarTotal, lunarPartial }

class EclipseEventSimple {
  final String id;
  final String title;
  final EclipseType type;
  final DateTime peakTime;
  final DateTime startTime;
  final DateTime endTime;
  final List<List<double>> pathGeoJson; // lat,lng
  final String visibility;
  final String description;

  EclipseEventSimple({
    required this.id,
    required this.title,
    required this.type,
    required this.peakTime,
    required this.startTime,
    required this.endTime,
    required this.pathGeoJson,
    required this.visibility,
    required this.description,
  });

  Duration get duration => endTime.difference(startTime);

  Duration timeUntilPeak() => peakTime.difference(DateTime.now());
}

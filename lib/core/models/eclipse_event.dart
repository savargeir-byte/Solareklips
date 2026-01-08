enum EclipseType { solar, lunar }

class EclipseEvent {
  final String id;
  final EclipseType type;
  final DateTime start;
  final DateTime peak;
  final DateTime end;
  final String visibility;
  final String geoJsonPath;

  EclipseEvent({
    required this.id,
    required this.type,
    required this.start,
    required this.peak,
    required this.end,
    required this.visibility,
    required this.geoJsonPath,
  });

  factory EclipseEvent.fromJson(Map<String, dynamic> json) {
    return EclipseEvent(
      id: json['id'],
      type: json['type'] == 'solar' ? EclipseType.solar : EclipseType.lunar,
      start: DateTime.parse(json['start']),
      peak: DateTime.parse(json['peak']),
      end: DateTime.parse(json['end']),
      visibility: json['visibility'],
      geoJsonPath: json['geoJsonPath'],
    );
  }
}

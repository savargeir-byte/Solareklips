enum EclipseType { solar, lunar }

class EclipseEvent {
  final String id;
  final EclipseType type;
  final DateTime start;
  final DateTime peak;
  final DateTime end;
  final String visibility;
  final String geoJsonPath;
  final String? pathGeoJsonFile;
  final double? shadowWidthKm;
  final int? maxDurationSeconds;
  final double? magnitude;
  final String? title;
  final String? description;
  final List<double>? centerlineCoords;

  EclipseEvent({
    required this.id,
    required this.type,
    required this.start,
    required this.peak,
    required this.end,
    required this.visibility,
    required this.geoJsonPath,
    this.pathGeoJsonFile,
    this.shadowWidthKm,
    this.maxDurationSeconds,
    this.magnitude,
    this.title,
    this.description,
    this.centerlineCoords,
  });

  String get dateDisplay {
    final month = peak.month.toString().padLeft(2, '0');
    final day = peak.day.toString().padLeft(2, '0');
    return '${peak.year}-$month-$day';
  }

  factory EclipseEvent.fromJson(Map<String, dynamic> json) {
    // Handle both old and new JSON formats
    final visibilityRegions = json['visibilityRegions'];
    final visibilityString = visibilityRegions is List 
        ? visibilityRegions.join(', ') 
        : (json['visibility'] ?? 'Unknown');
    
    return EclipseEvent(
      id: json['id'],
      type: json['type'] == 'solar' ? EclipseType.solar : EclipseType.lunar,
      start: DateTime.parse(json['startUtc'] ?? json['start']),
      peak: DateTime.parse(json['peakUtc'] ?? json['peak']),
      end: DateTime.parse(json['endUtc'] ?? json['end']),
      visibility: visibilityString,
      geoJsonPath: json['pathGeoJson'] ?? json['geoJsonPath'] ?? '',
      pathGeoJsonFile: json['pathGeoJson'] ?? json['pathGeoJsonFile'],
      shadowWidthKm: json['shadowWidthKm']?.toDouble(),
      maxDurationSeconds: json['maxDurationSeconds']?.toInt(),
      magnitude: json['magnitude']?.toDouble(),
      title: json['title'],
      description: json['description'],
      centerlineCoords: json['centerlineCoords'] != null 
        ? List<double>.from(json['centerlineCoords']) 
        : null,
    );
  }
}

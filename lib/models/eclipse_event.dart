/// Model representing a solar or lunar eclipse event with enhanced scientific data
class EclipseEvent {
  final String id;
  final EclipseType type; // solar or lunar
  final EclipseSubtype subtype; // total, partial, annular, penumbral
  final DateTime startUtc;
  final DateTime peakUtc;
  final DateTime endUtc;
  final String pathGeoJson; // GeoJSON string for map overlay
  final List<String> visibilityRegions;
  final String description;

  // Enhanced fields for scientific accuracy
  final double? magnitude; // Eclipse magnitude (0.0 to 1.0+)
  final int?
      maxDurationSeconds; // Maximum duration of totality/annularity in seconds
  final List<double>? centerlineCoords; // [lat, lon] of greatest eclipse point
  final double? gamma; // Gamma value (axis distance) from Besselian elements
  final int? sarosNumber; // Saros series number
  final String? catalog; // Source catalog reference (e.g., "NASA-SE-5MCAT")

  // Visibility & weather scoring
  final double? visibilityScore; // 0.0-1.0, computed from weather + magnitude
  final Map<String, dynamic>? weatherData; // Cached weather forecast data
  final double? kpIndex; // Geomagnetic K-index for aurora potential

  // New enhanced fields for global offline app
  final Map<String, Map<String, String>>?
      localContactTimes; // Contact times per city {"Reykjavik": {"start": "...", "peak": "...", "end": "..."}}
  final String?
      pathGeoJsonFile; // Separate GeoJSON file path (e.g., "assets/geo/2026_iceland_path.json")
  final double? shadowWidthKm; // Shadow width in kilometers
  final double? centerLineSpeedKph; // Shadow speed along centerline in km/h
  final String?
      illustration; // Illustration image path (e.g., "assets/img/solar2026.png")

  EclipseEvent({
    required this.id,
    required this.type,
    required this.subtype,
    required this.startUtc,
    required this.peakUtc,
    required this.endUtc,
    required this.pathGeoJson,
    required this.visibilityRegions,
    required this.description,
    this.magnitude,
    this.maxDurationSeconds,
    this.centerlineCoords,
    this.gamma,
    this.sarosNumber,
    this.catalog,
    this.visibilityScore,
    this.weatherData,
    this.kpIndex,
    this.localContactTimes,
    this.pathGeoJsonFile,
    this.shadowWidthKm,
    this.centerLineSpeedKph,
    this.illustration,
  });

  /// Parse from JSON
  factory EclipseEvent.fromJson(Map<String, dynamic> json) {
    return EclipseEvent(
      id: json['id'] as String,
      type: EclipseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EclipseType.solar,
      ),
      subtype: EclipseSubtype.values.firstWhere(
        (e) => e.name == json['subtype'],
        orElse: () => EclipseSubtype.total,
      ),
      startUtc: DateTime.parse(json['startUtc'] as String),
      peakUtc: DateTime.parse(json['peakUtc'] as String),
      endUtc: DateTime.parse(json['endUtc'] as String),
      pathGeoJson: json['pathGeoJson'] as String? ??
          '', // Legacy field for backwards compatibility
      visibilityRegions: List<String>.from(json['visibilityRegions'] as List),
      description: json['description'] as String,
      magnitude: json['magnitude'] != null
          ? (json['magnitude'] as num).toDouble()
          : null,
      maxDurationSeconds: json['maxDurationSeconds'] as int?,
      centerlineCoords: json['centerlineCoords'] != null
          ? List<double>.from((json['centerlineCoords'] as List)
              .map((e) => (e as num).toDouble()))
          : null,
      gamma: json['gamma'] != null ? (json['gamma'] as num).toDouble() : null,
      sarosNumber: json['sarosNumber'] as int?,
      catalog: json['catalog'] as String?,
      visibilityScore: json['visibilityScore'] != null
          ? (json['visibilityScore'] as num).toDouble()
          : null,
      weatherData: json['weatherData'] as Map<String, dynamic>?,
      kpIndex:
          json['kpIndex'] != null ? (json['kpIndex'] as num).toDouble() : null,
      localContactTimes: json['localContactTimes'] != null
          ? Map<String, Map<String, String>>.from(
              (json['localContactTimes'] as Map).map(
                (k, v) => MapEntry(
                  k.toString(),
                  Map<String, String>.from(v as Map),
                ),
              ),
            )
          : null,
      pathGeoJsonFile: json['pathGeoJson'] as String?,
      shadowWidthKm: json['shadowWidthKm'] != null
          ? (json['shadowWidthKm'] as num).toDouble()
          : null,
      centerLineSpeedKph: json['centerLineSpeedKph'] != null
          ? (json['centerLineSpeedKph'] as num).toDouble()
          : null,
      illustration: json['illustration'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'subtype': subtype.name,
      'startUtc': startUtc.toIso8601String(),
      'peakUtc': peakUtc.toIso8601String(),
      'endUtc': endUtc.toIso8601String(),
      'pathGeoJson': pathGeoJson,
      'visibilityRegions': visibilityRegions,
      'description': description,
      if (magnitude != null) 'magnitude': magnitude,
      if (maxDurationSeconds != null) 'maxDurationSeconds': maxDurationSeconds,
      if (centerlineCoords != null) 'centerlineCoords': centerlineCoords,
      if (gamma != null) 'gamma': gamma,
      if (sarosNumber != null) 'sarosNumber': sarosNumber,
      if (catalog != null) 'catalog': catalog,
      if (visibilityScore != null) 'visibilityScore': visibilityScore,
      if (weatherData != null) 'weatherData': weatherData,
      if (kpIndex != null) 'kpIndex': kpIndex,
      if (localContactTimes != null) 'localContactTimes': localContactTimes,
      if (pathGeoJsonFile != null) 'pathGeoJson': pathGeoJsonFile,
      if (shadowWidthKm != null) 'shadowWidthKm': shadowWidthKm,
      if (centerLineSpeedKph != null) 'centerLineSpeedKph': centerLineSpeedKph,
      if (illustration != null) 'illustration': illustration,
    };
  }

  /// User-friendly title for list/card display
  String get title {
    final subtypeStr = subtype.displayName;
    final typeStr = type == EclipseType.solar ? 'Solar' : 'Lunar';
    return '$subtypeStr $typeStr Eclipse';
  }

  /// Short date string for display
  String get dateDisplay {
    return '${peakUtc.year}-${peakUtc.month.toString().padLeft(2, '0')}-${peakUtc.day.toString().padLeft(2, '0')}';
  }

  /// Duration string for totality/maximum eclipse
  String get durationDisplay {
    if (maxDurationSeconds == null) return 'Duration unknown';
    final minutes = maxDurationSeconds! ~/ 60;
    final seconds = maxDurationSeconds! % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Visibility quality label based on score
  String get visibilityLabel {
    if (visibilityScore == null) return 'Unknown';
    if (visibilityScore! >= 0.8) return 'Excellent';
    if (visibilityScore! >= 0.6) return 'Good';
    if (visibilityScore! >= 0.4) return 'Marginal';
    return 'Poor';
  }
}

enum EclipseType {
  solar,
  lunar,
}

enum EclipseSubtype {
  total,
  partial,
  annular,
  penumbral;

  String get displayName {
    switch (this) {
      case EclipseSubtype.total:
        return 'Total';
      case EclipseSubtype.partial:
        return 'Partial';
      case EclipseSubtype.annular:
        return 'Annular';
      case EclipseSubtype.penumbral:
        return 'Penumbral';
    }
  }
}

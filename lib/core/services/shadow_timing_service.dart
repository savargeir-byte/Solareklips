import 'dart:math';

/// Service for calculating GPS-based shadow timing and local eclipse duration
class ShadowTimingService {
  /// Calculate the haversine distance between two points in meters
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1Rad) * cos(lat2Rad);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c * 1000; // Return in meters
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  /// Calculate local totality duration based on distance from centerline
  ///
  /// Parameters:
  /// - [userLat], [userLon]: User's GPS coordinates
  /// - [centerlineLat], [centerlineLon]: Closest point on path centerline
  /// - [maxShadowWidthMeters]: Total width of umbra shadow
  /// - [maxTotalitySeconds]: Maximum duration at centerline
  ///
  /// Returns: Estimated totality duration in seconds at user location
  static double calculateLocalTotality({
    required double userLat,
    required double userLon,
    required double centerlineLat,
    required double centerlineLon,
    required double maxShadowWidthMeters,
    required int maxTotalitySeconds,
  }) {
    // Distance from user to centerline
    final distanceToCenterline = haversineDistance(
      userLat,
      userLon,
      centerlineLat,
      centerlineLon,
    );

    // If outside shadow path, no totality
    final shadowRadius = maxShadowWidthMeters / 2;
    if (distanceToCenterline > shadowRadius) {
      return 0.0;
    }

    // Calculate ratio: how far off-axis (0 = centerline, 1 = edge)
    final offAxisRatio = distanceToCenterline / shadowRadius;

    // Duration decreases as you move away from centerline
    // Using parabolic falloff for more realistic estimation
    final durationFactor = 1 - (offAxisRatio * offAxisRatio);

    return maxTotalitySeconds * durationFactor;
  }

  ///
  /// Returns: [lat, lon] of closest centerline point
  static List<double> findClosestCenterlinePoint({
    required double userLat,
    required double userLon,
    required List<List<double>> centerlinePath,
  }) {
    if (centerlinePath.isEmpty) {
      return [userLat, userLon];
    }

    double minDistance = double.infinity;
    List<double> closestPoint = centerlinePath.first;

    for (final point in centerlinePath) {
      final distance = haversineDistance(
        userLat,
        userLon,
        point[0],
        point[1],
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    return closestPoint;
  }

  /// Calculate shadow speed at a given point
  ///
  /// Returns: Shadow speed in km/h
  static double calculateShadowSpeed({
    required double latitude,
    double baseSpeedKph = 2000.0, // Approximate shadow speed
  }) {
    // Shadow speed varies with latitude
    // Faster near poles, slower near equator
    final latRad = _toRadians(latitude);
    final speedFactor = 1.0 + (0.5 * cos(latRad).abs());

    return baseSpeedKph * speedFactor;
  }

  /// Format duration in a human-readable format
  static String formatDuration(double seconds) {
    if (seconds <= 0) {
      return 'No totality at this location';
    }

    final minutes = seconds ~/ 60;
    final secs = (seconds % 60).round();

    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Calculate contact times based on user location and eclipse timing
  ///
  /// Returns map with 'c1', 'c2', 'c3', 'c4' keys (first through fourth contact)
  static Map<String, DateTime> calculateContactTimes({
    required double userLat,
    required double userLon,
    required List<List<double>> centerlinePath,
    required DateTime peak,
    required double maxShadowWidthMeters,
    required int maxTotalitySeconds,
  }) {
    final closestPoint = findClosestCenterlinePoint(
      userLat: userLat,
      userLon: userLon,
      centerlinePath: centerlinePath,
    );

    final localTotality = calculateLocalTotality(
      userLat: userLat,
      userLon: userLon,
      centerlineLat: closestPoint[0],
      centerlineLon: closestPoint[1],
      maxShadowWidthMeters: maxShadowWidthMeters,
      maxTotalitySeconds: maxTotalitySeconds,
    );

    final halfTotality = localTotality / 2;

    // Estimate partial phase duration (typically ~1 hour before/after)
    const partialPhaseDuration = 3600; // seconds

    return {
      'c1': peak.subtract(
          Duration(seconds: (partialPhaseDuration + halfTotality).round())),
      'c2': peak.subtract(Duration(seconds: halfTotality.round())),
      'c3': peak.add(Duration(seconds: halfTotality.round())),
      'c4': peak.add(
          Duration(seconds: (partialPhaseDuration + halfTotality).round())),
    };
  }
}

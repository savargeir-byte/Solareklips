import 'package:geolocator/geolocator.dart';

import 'package:eclipse_map/core/models/eclipse_event.dart';
import 'geojson_loader.dart';
import 'shadow_timing_service.dart';

/// Service for calculating location-aware eclipse timing and visibility
/// Combines GPS positioning with shadow timing calculations
class LocationEclipseCalculator {
  final GeoJsonLoader _geoJsonLoader = GeoJsonLoader();

  /// Calculate user-specific eclipse details based on GPS location
  ///
  /// Returns a map containing:
  /// - 'inPath': bool - whether user is in eclipse path
  /// - 'totalityDuration': double - seconds of totality (0 if partial)
  /// - 'distanceToCenterline': double - meters from centerline
  /// - 'contactTimes': Map<String, DateTime> - C1, C2, Max, C3, C4
  /// - 'magnitude': double - eclipse magnitude at location
  Future<Map<String, dynamic>> calculateForLocation({
    required EclipseEvent event,
    required Position userPosition,
  }) async {
    final results = <String, dynamic>{
      'inPath': false,
      'totalityDuration': 0.0,
      'distanceToCenterline': double.infinity,
      'contactTimes': <String, DateTime>{},
      'magnitude': 0.0,
    };

    // Load centerline path if available
    if (event.pathGeoJsonFile == null) {
      return results;
    }

    try {
      final centerlinePoints =
          await _geoJsonLoader.loadPathFromAsset(event.pathGeoJsonFile!);

      if (centerlinePoints.isEmpty) {
        return results;
      }

      // Convert to coordinate list for calculations
      final centerlinePath = centerlinePoints
          .map((point) => [point.latitude, point.longitude])
          .toList();

      // Find closest point on centerline
      final closestPoint = ShadowTimingService.findClosestCenterlinePoint(
        userLat: userPosition.latitude,
        userLon: userPosition.longitude,
        centerlinePath: centerlinePath,
      );

      // Calculate distance to centerline
      final distanceToCenterline = ShadowTimingService.haversineDistance(
        userPosition.latitude,
        userPosition.longitude,
        closestPoint[0],
        closestPoint[1],
      );

      results['distanceToCenterline'] = distanceToCenterline;

      // Get shadow width (convert km to meters)
      final shadowWidthMeters = (event.shadowWidthKm ?? 180.0) * 1000;

      // Check if user is in path
      final inPath = distanceToCenterline <= (shadowWidthMeters / 2);
      results['inPath'] = inPath;

      if (inPath && event.subtype == EclipseType.total) {
        // Calculate local totality duration
        final totalityDuration = ShadowTimingService.calculateLocalTotality(
          userLat: userPosition.latitude,
          userLon: userPosition.longitude,
          centerlineLat: closestPoint[0],
          centerlineLon: closestPoint[1],
          maxShadowWidthMeters: shadowWidthMeters,
          maxTotalitySeconds: event.maxDurationSeconds ?? 120,
        );

        results['totalityDuration'] = totalityDuration;

        // Calculate contact times
        final contactTimes = ShadowTimingService.calculateContactTimes(
          userLat: userPosition.latitude,
          userLon: userPosition.longitude,
          centerlinePath: centerlinePath,
          peak: event.peak,
          maxShadowWidthMeters: shadowWidthMeters,
          maxTotalitySeconds: event.maxDurationSeconds ?? 120,
        );

        results['contactTimes'] = contactTimes;

        // Magnitude at location (simplified)
        results['magnitude'] = _calculateMagnitudeAtLocation(
          distanceToCenterline: distanceToCenterline,
          shadowRadius: shadowWidthMeters / 2,
          maxMagnitude: event.magnitude ?? 1.0,
        );
      }
    } catch (e) {
      print('Error calculating eclipse for location: $e');
    }

    return results;
  }

  /// Get user's current location with permission handling
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate eclipse magnitude at a specific location
  /// Simplified model based on distance from centerline
  double _calculateMagnitudeAtLocation({
    required double distanceToCenterline,
    required double shadowRadius,
    required double maxMagnitude,
  }) {
    if (distanceToCenterline >= shadowRadius) {
      return 0.0;
    }

    // Linear falloff from centerline to edge
    final ratio = 1.0 - (distanceToCenterline / shadowRadius);
    return maxMagnitude * ratio;
  }

  /// Check if a location is within viewing region
  bool isLocationInViewingRegion({
    required double latitude,
    required double longitude,
    required List<String> visibility,
  }) {
    // Simplified region checking
    // In production, use more sophisticated geocoding

    // Iceland bounds
    if (visibility.any((r) => r.toLowerCase().contains('iceland'))) {
      if (latitude >= 63.0 &&
          latitude <= 67.0 &&
          longitude >= -25.0 &&
          longitude <= -13.0) {
        return true;
      }
    }

    // Northern Europe
    if (visibility
        .any((r) => r.toLowerCase().contains('northern europe'))) {
      if (latitude >= 45.0 && latitude <= 71.0) {
        return true;
      }
    }

    // Global fallback for lunar eclipses
    if (visibility.any((r) => r.toLowerCase().contains('global'))) {
      return true;
    }

    return false;
  }

  /// Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Format totality duration for display
  String formatTotalityDuration(double seconds) {
    return ShadowTimingService.formatDuration(seconds);
  }
}

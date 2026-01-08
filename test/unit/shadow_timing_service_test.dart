import 'package:flutter_test/flutter_test.dart';
import 'package:eclipse_map/core/services/shadow_timing_service.dart';

void main() {
  group('ShadowTimingService', () {
    test('haversineDistance calculates correct distance', () {
      // Distance between Reykjavik and Akureyri (approximately 250km)
      const reykjavikLat = 64.1466;
      const reykjavikLon = -21.9426;
      const akureyriLat = 65.6885;
      const akureyriLon = -18.1262;

      final distance = ShadowTimingService.haversineDistance(
        reykjavikLat,
        reykjavikLon,
        akureyriLat,
        akureyriLon,
      );

      // Expected distance is approximately 248km (248,000 meters)
      expect(distance, greaterThan(240000));
      expect(distance, lessThan(260000));
    });

    test('haversineDistance returns 0 for same location', () {
      const lat = 64.1466;
      const lon = -21.9426;

      final distance = ShadowTimingService.haversineDistance(
        lat,
        lon,
        lat,
        lon,
      );

      expect(distance, equals(0.0));
    });

    test('calculateLocalTotality returns 0 outside shadow path', () {
      final duration = ShadowTimingService.calculateLocalTotality(
        userLat: 64.0,
        userLon: -19.0,
        centerlineLat: 64.5,
        centerlineLon: -19.0,
        maxShadowWidthMeters: 100000, // 100km width
        maxTotalitySeconds: 120,
      );

      // User is ~55km from centerline, so outside 50km shadow radius
      expect(duration, equals(0.0));
    });

    test('calculateLocalTotality returns max duration at centerline', () {
      final duration = ShadowTimingService.calculateLocalTotality(
        userLat: 64.5,
        userLon: -19.0,
        centerlineLat: 64.5,
        centerlineLon: -19.0,
        maxShadowWidthMeters: 100000,
        maxTotalitySeconds: 120,
      );

      // At centerline, duration should equal max duration
      expect(duration, equals(120.0));
    });

    test('calculateLocalTotality returns reduced duration off centerline', () {
      // Place user at half-radius from centerline
      final duration = ShadowTimingService.calculateLocalTotality(
        userLat: 64.3,
        userLon: -19.0,
        centerlineLat: 64.5,
        centerlineLon: -19.0,
        maxShadowWidthMeters: 100000, // 100km width, 50km radius
        maxTotalitySeconds: 120,
      );

      // Duration should be reduced but not zero
      expect(duration, greaterThan(0));
      expect(duration, lessThan(120));
    });

    test('findClosestCenterlinePoint finds nearest point', () {
      final centerlinePath = [
        [64.0, -20.0],
        [64.5, -19.5],
        [65.0, -19.0],
      ];

      final closestPoint = ShadowTimingService.findClosestCenterlinePoint(
        userLat: 64.6,
        userLon: -19.4,
        centerlinePath: centerlinePath,
      );

      // Closest point should be [64.5, -19.5]
      expect(closestPoint[0], equals(64.5));
      expect(closestPoint[1], equals(-19.5));
    });

    test('findClosestCenterlinePoint handles empty path', () {
      final closestPoint = ShadowTimingService.findClosestCenterlinePoint(
        userLat: 64.6,
        userLon: -19.4,
        centerlinePath: [],
      );

      // Should return user location when path is empty
      expect(closestPoint[0], equals(64.6));
      expect(closestPoint[1], equals(-19.4));
    });

    test('formatDuration formats seconds correctly', () {
      expect(ShadowTimingService.formatDuration(45), equals('45s'));
      expect(ShadowTimingService.formatDuration(90), equals('1m 30s'));
      expect(ShadowTimingService.formatDuration(125), equals('2m 5s'));
      expect(ShadowTimingService.formatDuration(0), contains('No totality'));
    });

    test('calculateContactTimes returns all contact times', () {
      final centerlinePath = [
        [64.5, -19.0],
      ];
      final peakUtc = DateTime.utc(2026, 4, 12, 15, 0, 0);

      final contactTimes = ShadowTimingService.calculateContactTimes(
        userLat: 64.5,
        userLon: -19.0,
        centerlinePath: centerlinePath,
        peakUtc: peakUtc,
        maxShadowWidthMeters: 100000,
        maxTotalitySeconds: 120,
      );

      expect(contactTimes.keys, containsAll(['c1', 'c2', 'c3', 'c4']));
      expect(contactTimes['c1']!.isBefore(contactTimes['c2']!), isTrue);
      expect(contactTimes['c2']!.isBefore(peakUtc), isTrue);
      expect(contactTimes['c3']!.isAfter(peakUtc), isTrue);
      expect(contactTimes['c4']!.isAfter(contactTimes['c3']!), isTrue);
    });

    test('calculateShadowSpeed varies with latitude', () {
      final equatorSpeed = ShadowTimingService.calculateShadowSpeed(
        latitude: 0.0,
        baseSpeedKph: 2000.0,
      );

      final midLatSpeed = ShadowTimingService.calculateShadowSpeed(
        latitude: 45.0,
        baseSpeedKph: 2000.0,
      );

      final poleSpeed = ShadowTimingService.calculateShadowSpeed(
        latitude: 80.0,
        baseSpeedKph: 2000.0,
      );

      // At equator: cos(0) = 1, factor = 1.5, speed = 3000
      expect(equatorSpeed, closeTo(3000.0, 10));

      // At mid latitude: speed should be between equator and poles
      expect(midLatSpeed, greaterThan(2000.0));
      expect(midLatSpeed, lessThan(equatorSpeed));

      // At poles: cos(80) ≈ 0.17, factor ≈ 1.085, speed ≈ 2170
      expect(poleSpeed, greaterThan(2100.0));
      expect(poleSpeed, lessThan(equatorSpeed));
    });
  });
}

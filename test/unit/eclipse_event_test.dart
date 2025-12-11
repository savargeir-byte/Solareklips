import 'dart:convert';

import 'package:eclipse_map/models/eclipse_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EclipseEvent JSON Parsing', () {
    test('Parse Iceland 2026 total solar eclipse from JSON', () {
      const jsonString = '''
      {
        "id": "iceland-2026-solar-total",
        "type": "solar",
        "subtype": "total",
        "startUtc": "2026-04-12T14:30:00Z",
        "peakUtc": "2026-04-12T15:00:00Z",
        "endUtc": "2026-04-12T15:30:00Z",
        "pathGeoJson": "{\\"type\\":\\"FeatureCollection\\"}",
        "visibilityRegions": ["Iceland", "Greenland (partial)"],
        "description": "Total solar eclipse crossing Iceland",
        "magnitude": 1.045,
        "maxDurationSeconds": 138,
        "centerlineCoords": [64.5, -19.0],
        "gamma": 0.32,
        "sarosNumber": 120,
        "catalog": "NASA-SE-5MCAT",
        "visibilityScore": 0.78,
        "kpIndex": 3.2
      }
      ''';

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final event = EclipseEvent.fromJson(json);

      expect(event.id, 'iceland-2026-solar-total');
      expect(event.type, EclipseType.solar);
      expect(event.subtype, EclipseSubtype.total);
      expect(event.magnitude, 1.045);
      expect(event.maxDurationSeconds, 138);
      expect(event.centerlineCoords, [64.5, -19.0]);
      expect(event.sarosNumber, 120);
      expect(event.visibilityScore, 0.78);
      expect(event.title, 'Total Solar Eclipse');
      expect(event.durationDisplay, '2m 18s');
      expect(event.visibilityLabel, 'Good');
    });

    test('Parse lunar eclipse from JSON', () {
      const jsonString = '''
      {
        "id": "global-2025-lunar-partial",
        "type": "lunar",
        "subtype": "partial",
        "startUtc": "2025-09-07T22:00:00Z",
        "peakUtc": "2025-09-07T23:30:00Z",
        "endUtc": "2025-09-08T01:00:00Z",
        "pathGeoJson": "{\\"type\\":\\"FeatureCollection\\"}",
        "visibilityRegions": ["Europe", "Africa", "Asia"],
        "description": "Partial lunar eclipse",
        "magnitude": 0.35,
        "visibilityScore": 0.92
      }
      ''';

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final event = EclipseEvent.fromJson(json);

      expect(event.type, EclipseType.lunar);
      expect(event.subtype, EclipseSubtype.partial);
      expect(event.magnitude, 0.35);
      expect(event.visibilityScore, 0.92);
      expect(event.title, 'Partial Lunar Eclipse');
      expect(event.visibilityLabel, 'Excellent');
    });

    test('Parse event without optional fields', () {
      const jsonString = '''
      {
        "id": "test-event",
        "type": "solar",
        "subtype": "annular",
        "startUtc": "2028-01-01T12:00:00Z",
        "peakUtc": "2028-01-01T13:00:00Z",
        "endUtc": "2028-01-01T14:00:00Z",
        "pathGeoJson": "{}",
        "visibilityRegions": ["Global"],
        "description": "Test event"
      }
      ''';

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final event = EclipseEvent.fromJson(json);

      expect(event.magnitude, null);
      expect(event.maxDurationSeconds, null);
      expect(event.visibilityScore, null);
      expect(event.durationDisplay, 'Duration unknown');
      expect(event.visibilityLabel, 'Unknown');
    });

    test('Serialize event to JSON and back', () {
      final original = EclipseEvent(
        id: 'test-eclipse',
        type: EclipseType.solar,
        subtype: EclipseSubtype.total,
        startUtc: DateTime.parse('2026-04-12T14:30:00Z'),
        peakUtc: DateTime.parse('2026-04-12T15:00:00Z'),
        endUtc: DateTime.parse('2026-04-12T15:30:00Z'),
        pathGeoJson: '{"type":"FeatureCollection"}',
        visibilityRegions: ['Iceland'],
        description: 'Test eclipse',
        magnitude: 1.0,
        maxDurationSeconds: 120,
      );

      final json = original.toJson();
      final reconstructed = EclipseEvent.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.type, original.type);
      expect(reconstructed.magnitude, original.magnitude);
      expect(reconstructed.maxDurationSeconds, original.maxDurationSeconds);
    });
  });
}

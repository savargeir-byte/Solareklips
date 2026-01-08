import 'package:eclipse_map/core/models/eclipse_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EclipseEvent Model', () {
    test('creates event with required fields', () {
      final event = EclipseEvent(
        id: 'test-1',
        type: EclipseType.solar,
        start: DateTime.utc(2026, 4, 12, 14, 30),
        peak: DateTime.utc(2026, 4, 12, 15, 0),
        end: DateTime.utc(2026, 4, 12, 15, 30),
        visibility: 'Iceland',
        geoJsonPath: 'assets/geo/test.json',
      );

      expect(event.id, equals('test-1'));
      expect(event.type, equals(EclipseType.solar));
      expect(event.visibility, equals('Iceland'));
    });

    test('parses from JSON', () {
      final json = {
        'id': 'test-2',
        'type': 'lunar',
        'start': '2026-04-12T14:30:00Z',
        'peak': '2026-04-12T15:00:00Z',
        'end': '2026-04-12T15:30:00Z',
        'visibility': 'Global',
        'geoJsonPath': 'assets/geo/lunar.json',
      };

      final event = EclipseEvent.fromJson(json);

      expect(event.id, equals('test-2'));
      expect(event.type, equals(EclipseType.lunar));
      expect(event.visibility, equals('Global'));
    });
  });
}

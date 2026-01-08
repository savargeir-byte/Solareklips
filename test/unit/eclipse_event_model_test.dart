import 'package:flutter_test/flutter_test.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';

void main() {
  group('EclipseEvent', () {
    test('fromJson parses JSON correctly', () {
      final json = {
        ''id'': ''test-2026'',
        ''type'': ''solar'',
        ''start'': ''2026-04-12T14:30:00Z'',
        ''peak'': ''2026-04-12T15:00:00Z'',
        ''end'': ''2026-04-12T15:30:00Z'',
        ''visibility'': ''Iceland, Greenland'',
        ''geoJsonPath'': ''assets/geo/2026_iceland.json'',
      };

      final event = EclipseEvent.fromJson(json);

      expect(event.id, equals(''test-2026''));
      expect(event.type, equals(EclipseType.solar));
      expect(event.visibility, equals(''Iceland, Greenland''));
      expect(event.geoJsonPath, equals(''assets/geo/2026_iceland.json''));
    });

    test(''creates event with all required fields'', () {
      final event = EclipseEvent(
        id: ''test-1'',
        type: EclipseType.lunar,
        start: DateTime.utc(2026, 4, 12, 14, 30),
        peak: DateTime.utc(2026, 4, 12, 15, 0),
        end: DateTime.utc(2026, 4, 12, 15, 30),
        visibility: ''Global'',
        geoJsonPath: ''assets/geo/lunar.json'',
      );

      expect(event.id, equals(''test-1''));
      expect(event.type, equals(EclipseType.lunar));
      expect(event.start, equals(DateTime.utc(2026, 4, 12, 14, 30)));
      expect(event.peak, equals(DateTime.utc(2026, 4, 12, 15, 0)));
      expect(event.end, equals(DateTime.utc(2026, 4, 12, 15, 30)));
      expect(event.visibility, equals(''Global''));
      expect(event.geoJsonPath, equals(''assets/geo/lunar.json''));
    });

    test(''EclipseType enum has solar and lunar'', () {
      expect(EclipseType.values.length, equals(2));
      expect(EclipseType.values, contains(EclipseType.solar));
      expect(EclipseType.values, contains(EclipseType.lunar));
    });
  });
}

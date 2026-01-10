import '../../core/models/eclipse_event_simple.dart';

class EducationContent {
  static String explainEvent(EclipseEventSimple event) {
    switch (event.type) {
      case EclipseType.solarTotal:
        return '''
A total solar eclipse happens when the Moon moves exactly between the Earth and the Sun.

For a short moment, the Moon completely blocks the Sun's bright surface.
This allows us to see the Sun's outer atmosphere, called the corona.

Total solar eclipses are rare in any one location.
That is why this event is so special.
''';

      case EclipseType.lunarTotal:
        return '''
A total lunar eclipse happens when the Earth moves between the Sun and the Moon.

Earth's shadow slowly covers the Moon.
The Moon often turns red because sunlight bends through Earth's atmosphere.
''';

      default:
        return '''
An eclipse happens when the Sun, Earth, and Moon line up in space.
''';
    }
  }

  static String whyHere(EclipseEventSimple event) {
    return '''
This eclipse is visible here because of the Moon's tilted orbit
and the rotation of the Earth.

The Moon's shadow follows a narrow path across the planet.
Only locations inside this path experience totality.
''';
  }

  static String history() {
    return '''
Eclipses have been observed for thousands of years.

Ancient civilizations used eclipses to track time and seasons.
Today, scientists use eclipses to study the Sun's atmosphere,
gravity, and the structure of space itself.
''';
  }
}

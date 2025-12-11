# EclipseMap

**Offline-First Flutter App** með "Iceland Total Solar Eclipse 2026" sem hero event.

## Lýsing

EclipseMap er algjörlega client-side app - engin nettenging nauðsynleg. Öll eclipse gögn eru innbyggð sem JSON assets með GeoJSON paths fyrir path visualization á korti.

## Hönnun: Solar Eclipse Minimal

- **Premium Black & Gold Theme**: Inspired by Apple minimal design
- **Custom Eclipse Illustration**: Hand-painted corona með CustomPainter
- **Countdown Widget**: Days/Hours/Minutes til Iceland 2026
- **Icon Grid Navigation**: Solar/Lunar/Map/Favorites

## Helstu eiginleikar

- ✅ Heimaskjár með niðurtalningu og custom eclipse illustration
- ✅ Event listi með 3+ curated eclipse events
- ✅ Detail skjár með animated timeline og scientific metadata
- ✅ Interactive kort með GeoJSON path overlay
- ✅ Zero backend - virkar alveg án internets

## Tæknimál

- **Framework**: Flutter 3.x með web support
- **State Management**: Riverpod 2.6.1
- **Kort**: flutter_map 4.0.0 með OpenStreetMap tiles
- **Data Model**: Enhanced með magnitude, Saros number, gamma, duration
- **Architecture**: Repository pattern með 24h in-memory cache

## VS Code viðbætur

- Flutter & Dart (official)
- Riverpod Snippets
- GitLens
- GitHub Copilot

## Setup

```powershell
# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Run tests
flutter test
```

## Project Structure

```
lib/
├── main.dart                    # App entry, HomeScreen, EclipseIllustration
├── models/
│   └── eclipse_event.dart       # Enhanced data model
├── services/
│   └── eclipse_service.dart     # JSON asset loader
├── repositories/
│   └── eclipse_repository.dart  # Caching & filtering layer
└── screens/
    ├── event_list_screen.dart   # ListView með event cards
    ├── event_detail_screen.dart # Detail view með timeline
    └── map_screen.dart          # FlutterMap með path overlay

assets/
├── mock/
│   └── eclipse_events.json      # 3 embedded events með GeoJSON
└── data/
    └── api_sources.json         # Reference docs (ekki notað runtime)

test/
└── unit/
    └── eclipse_event_test.dart  # Model parsing tests
```

## Data Model

Hver EclipseEvent inniheldur:

- Basic info: title, type, subtype, peakUtc, visibilityRegions
- Scientific metadata: magnitude, maxDurationSeconds, gamma, sarosNumber
- Map data: geoJsonPath (embedded polygon), centerlineCoords
- Future: visibilityScore, weatherData, kpIndex

## Future Roadmap

### v2.0: Local Astronomy Calculations

- On-device eclipse path computation (Dart port of NOVAS)
- Calculate local circumstances fyrir user's GPS position

### v3.0: Optional Online Features

- Weather forecasts (OpenWeather API)
- Space weather (NOAA Kp index)
- Community photo sharing

---

**Last Updated**: 2025-01-24  
**Version**: 1.0 (Client-Side Only)

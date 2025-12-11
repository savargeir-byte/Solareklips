# EclipseMap Architecture

**Client-Side Only** • **Offline-First** • **Embedded Data**

## Overview

EclipseMap er algjörlega client-side Flutter app án bakenda. Öll gögn eru innbyggð í appið sem JSON assets. Engin nettenging nauðsynleg.

## Design Philosophy

- **Offline-First**: Virkar án internet tengingar
- **Embedded Data**: Eclipse catalog innbyggður í APK/IPA/Web bundle
- **Zero Backend**: Engin API keys, engin server-side kóði
- **Precomputed Paths**: GeoJSON polygon paths með hverju eclipse eventi

## Data Architecture

### Local Data Sources

```
assets/
├── mock/
│   └── eclipse_events.json    # 3+ curated events með fullum metadata
└── data/
    └── api_sources.json       # Reference documentation (ekki notað í runtime)
```

### Eclipse Event Model

```dart
class EclipseEvent {
  String id;                      // Unique identifier
  String title;                   // "Iceland Total Solar Eclipse 2026"
  EclipseType type;               // solar/lunar
  EclipseSubtype subtype;         // total/partial/annular/penumbral
  DateTime peakUtc;               // Peak time
  List<String> visibilityRegions; // ["Iceland", "Greenland"]
  String? geoJsonPath;            // Embedded GeoJSON polygon

  // Scientific metadata
  double? magnitude;              // Eclipse magnitude (0.0-2.0)
  int? maxDurationSeconds;        // Max totality/annularity duration
  List<double>? centerlineCoords; // [lat, lng] of maximum eclipse
  double? gamma;                  // Distance from Earth center (-2 to +2)
  int? sarosNumber;               // Saros cycle number
  String? catalog;                // "NASA Five Millennium Catalog"

  // Future: weather/space weather (precomputed)
  int? visibilityScore;           // 0-100 weather-adjusted score
  Map<String, dynamic>? weatherData; // Cached historical cloud cover
  double? kpIndex;                // Geomagnetic activity (0-9)
}
```

### Repository Pattern

```
UI (Riverpod Consumers)
         ↓
EclipseRepository (caching, filtering)
         ↓
EclipseService (JSON asset loader)
         ↓
assets/mock/eclipse_events.json
```

**No Network Layer**: HttpService, NasaService, JplService, WeatherService **removed**.

## Screen Architecture

### 1. HomeScreen (`lib/main.dart`)

- **Custom Eclipse Illustration**: CustomPainter með gullnum corona og svörtum tungli
- **Countdown Widget**: Dagar/Klukkustundir/Mínútur til Iceland 2026
- **Icon Navigation Grid**: Solar/Lunar/Map/Favorites (4 aðal flokkar)
- **CTA Button**: "See Full Path →" (navigates til EventListScreen)

### 2. EventListScreen (`lib/screens/event_list_screen.dart`)

- ListView of EventListItem cards
- Data from `eclipseEventsProvider` (async Riverpod provider)
- Tap navigation → EventDetailScreen

### 3. EventDetailScreen (`lib/screens/event_detail_screen.dart`)

- Hero image area (TODO: custom illustration)
- Animated timeline með contact times (C1/C2/Max/C3/C4)
- Visibility regions as chips
- Scientific metadata display (magnitude, Saros, duration)
- "View on Map" button → MapScreen

### 4. MapScreen (`lib/screens/map_screen.dart`)

- FlutterMap með OpenStreetMap tiles
- PolygonLayer fyrir eclipse path (parsed frá GeoJSON string)
- Floating re-center button
- Colored overlay (orange fyrir solar, indigo fyrir lunar)

## State Management

**Riverpod Providers:**

```dart
// Service layer
final eclipseServiceProvider = Provider<EclipseService>(...);

// Repository layer (with caching)
final eclipseRepositoryProvider = Provider<EclipseRepository>(...);

// Data providers (FutureProvider for async loading)
final eclipseEventsProvider = FutureProvider<List<EclipseEvent>>(...);
final heroEventProvider = FutureProvider<EclipseEvent?>(...);
```

**Cache Strategy**: 24-hour in-memory cache í repository layer. Engin persistent storage (Hive ekki notað í MVP).

## UI Theme

**"Solar Eclipse Minimal"** - Premium black & gold palette inspired by Apple design:

```dart
const kBlack = Color(0xFF000000);
const kDarkGray = Color(0xFF1A1A1A);
const kGold = Color(0xFFE4B85F);
const kGoldDim = Color(0xFF8A7344);
```

- **Typography**: System fonts (SF Pro á iOS/macOS, Roboto á Android/Web)
- **Spacing**: 8px grid system (8, 16, 24, 32, 48, 64)
- **Elevation**: Minimal - flat cards með subtle borders
- **Animations**: Smooth 300-500ms curves (easeInOut)

## Data Update Strategy (Future)

Þar sem appið er offline-first, data updates koma með app updates:

1. **Compile Time**: Curator (þú) updates `assets/mock/eclipse_events.json` manually
2. **Build Time**: Flutter bundles JSON í APK/IPA/Web
3. **Runtime**: App reads embedded asset með `rootBundle.loadString()`
4. **Updates**: Notendur download new app version til að fá ný events

**Future Enhancement**: Optional online sync fyrir real-time weather/Kp updates (kemur í version 2.0).

## Testing Strategy

### Unit Tests

- Model parsing (`test/unit/eclipse_event_test.dart`)
- Repository caching logic
- GeoJSON parsing utilities

### Widget Tests

- EclipseIllustration painter
- CountdownWidget formatting
- EventListItem display

### Integration Tests

- Full navigation flows (Home → List → Detail → Map)
- Asset loading
- Error handling

## Performance Considerations

- **Bundle Size**: ~50KB fyrir 3 events með GeoJSON paths (acceptable)
- **JSON Parsing**: Synchronous decode á JSON asset (~5ms fyrir 3 events)
- **Map Rendering**: PolygonLayer með ~100-500 coordinates (smooth á 60fps)
- **Memory**: ~2MB heap fyrir cached events + map tiles (~20MB)

## Security & Privacy

- **Zero Network Calls**: Engin data leakage
- **No Analytics**: Engin user tracking (future: optional Firebase Analytics)
- **No Permissions**: Engin location/notification permissions í MVP
- **Local Storage**: Einungis in-memory cache (no persistent data)

## Deployment Targets

- **Web**: Chrome/Firefox/Safari með WebAssembly (canvaskit renderer)
- **Android**: API 21+ (5.0 Lollipop)
- **iOS**: iOS 12+ (future - ekki í MVP)
- **Desktop**: Windows/macOS/Linux (future - ekki í MVP)

## Future Roadmap

### v2.0: Local Astronomy Calculations

- **Computation Library**: Dart port of NOVAS (Naval Observatory Vector Astrometry)
- **Dynamic Path Generation**: Compute eclipse paths on-device
- **Custom Location**: Calculate local circumstances fyrir user's GPS position

### v3.0: Optional Online Enhancements

- **Weather Forecast Integration**: OpenWeather API fyrir 7-day forecasts
- **Space Weather**: NOAA Kp index fyrir aurora visibility
- **Community Features**: Share observation photos/reports

---

**Last Updated**: 2025-01-24  
**Architecture Version**: 2.0 (Client-Side Only)  
**Author**: Þróunarteymið

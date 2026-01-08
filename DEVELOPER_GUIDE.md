# EclipseMap - Complete Developer Guide

## 🎯 Project Overview

EclipseMap is a **production-grade astronomy application** built with Flutter 3.x, featuring GPS-based eclipse calculations, interactive maps, and stunning CustomPainter animations. The app follows clean architecture principles with an offline-first approach.

### Core Principles
1. **Offline-First**: All data embedded in app - works without internet
2. **Clean Architecture**: Clear separation of concerns
3. **GPS-Powered**: Real-time calculations based on user location
4. **Apple App Store Ready**: iOS Human Interface Guidelines compliant
5. **Tested**: Unit tests for critical business logic

---

## 📐 Architecture Overview

### Layer Structure

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Screens, Widgets, Providers)     │
├─────────────────────────────────────┤
│         Business Logic Layer        │
│    (Services, Controllers)          │
├─────────────────────────────────────┤
│          Data Layer                 │
│   (Repositories, Models, Assets)    │
└─────────────────────────────────────┘
```

### Key Components

#### 1. Models (`lib/models/`)
- **EclipseEvent**: Core data model with scientific metadata
  - Types: Solar/Lunar
  - Subtypes: Total/Partial/Annular/Penumbral
  - Scientific data: magnitude, Saros number, gamma, duration
  - Location data: centerline coords, GeoJSON paths

#### 2. Services (`lib/services/`)

**EclipseService**
- Loads eclipse data from local JSON assets
- No network dependencies
- Provides filtering by date range and region

**ShadowTimingService** ⭐
- Haversine distance calculations
- Local totality duration based on distance from centerline
- Contact times (C1, C2, C3, C4) calculation
- Shadow speed calculations

**LocationEclipseCalculator** ⭐
- GPS-based eclipse calculations
- Determines if user is in totality path
- Calculates personalized eclipse timing
- Distance to centerline computation

**GeoJsonLoader**
- Parses GeoJSON from assets
- Supports all geometry types (Polygon, LineString, etc.)
- Bounds calculation for map centering

**ThemeService**
- Dark/Light theme management
- Astronomy-optimized color palette
- Material Design 3 theming

#### 3. Repositories (`lib/repositories/`)

**EclipseRepository**
- 24-hour in-memory cache
- Event filtering and searching
- Hero event determination (next major eclipse)

#### 4. Providers (`lib/providers/`)

**LocationProviders**
- User GPS position management
- Permission state tracking
- Eclipse calculation for specific events

#### 5. Screens (`lib/screens/`)

- **HomeScreen**: Countdown, illustration, navigation
- **EventListScreen**: Solar/Lunar tabs with filtered lists
- **EventDetailScreen**: Full details with location-aware timing ⭐
- **MapScreen**: Interactive FlutterMap with GeoJSON overlays

#### 6. Widgets (`lib/widgets/`)

- **CoronaPainter**: HDR corona with chromosphere red flash
- **EclipseShadowPainter**: Dynamic shadow with penumbra/umbra
- **EclipseProgressSimulation**: Real-time eclipse animation
- **GeoJsonMapWidget**: Map with polygon overlays

---

## 🗺️ Data Architecture

### Asset Structure

```
assets/
├── mock/
│   └── eclipse_events.json          # 3 curated events
├── geojson/
│   ├── 2026_total_solar_centerline.json
│   ├── 2026_total_solar_umbra.json
│   └── 2026_total_solar_penumbra.json
└── images/
    └── appicon.png
```

### Eclipse Event JSON Schema

```json
{
  "id": "iceland-2026-solar-total",
  "title": "Iceland Total Solar Eclipse 2026",
  "type": "solar",
  "subtype": "total",
  "startUtc": "2026-04-12T14:30:00Z",
  "peakUtc": "2026-04-12T15:00:00Z",
  "endUtc": "2026-04-12T15:30:00Z",
  "pathGeoJson": "assets/geojson/2026_total_solar_umbra.json",
  "visibilityRegions": ["Iceland", "Greenland (partial)"],
  "description": "...",
  "magnitude": 1.045,
  "maxDurationSeconds": 138,
  "centerlineCoords": [64.5, -19.0],
  "gamma": 0.32,
  "sarosNumber": 120,
  "shadowWidthKm": 180
}
```

---

## 🧮 GPS Calculations

### How Location-Aware Timing Works

1. **Get User Location**
   - Request GPS permission
   - Obtain latitude/longitude via Geolocator

2. **Load Eclipse Path**
   - Parse GeoJSON centerline from assets
   - Extract coordinate array

3. **Find Closest Point**
   - Calculate haversine distance to each centerline point
   - Identify minimum distance point

4. **Calculate Totality Duration**
   ```dart
   distanceRatio = distanceFromCenterline / shadowRadius
   durationFactor = 1 - (distanceRatio²)  // Parabolic falloff
   localDuration = maxDuration * durationFactor
   ```

5. **Compute Contact Times**
   - C1: First contact (partial begins)
   - C2: Second contact (totality begins)
   - C3: Third contact (totality ends)
   - C4: Fourth contact (partial ends)

### Example Usage

```dart
final calculator = LocationEclipseCalculator();
final position = await calculator.getCurrentLocation();

final results = await calculator.calculateForLocation(
  event: icelandEvent,
  userPosition: position,
);

print('In path: ${results['inPath']}');
print('Duration: ${results['totalityDuration']}s');
print('Distance: ${results['distanceToCenterline']}m');
```

---

## 🎨 CustomPainter Animations

### Corona Painter

**Features:**
- Radial gradient with HDR effect (screen blend mode)
- Chromosphere red flash simulation
- Animated intensity pulsing
- 12 corona spikes

**Usage:**
```dart
AnimatedCorona(
  size: 280,
  showChromosphere: true,
)
```

### Eclipse Shadow Painter

**Features:**
- Penumbra (soft outer shadow)
- Umbra (solid totality zone)
- Corona glow at peak totality
- Rotation and scale transformations

---

## 🧪 Testing Strategy

### Unit Tests

**ShadowTimingService Tests** (`test/unit/shadow_timing_service_test.dart`)
- ✅ Haversine distance calculation
- ✅ Local totality duration
- ✅ Closest centerline point finding
- ✅ Contact times calculation
- ✅ Duration formatting

**EclipseEvent Tests** (`test/unit/eclipse_event_model_test.dart`)
- ✅ JSON serialization/deserialization
- ✅ Title generation
- ✅ Date formatting
- ✅ Visibility scoring

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/shadow_timing_service_test.dart

# Run with coverage
flutter test --coverage
```

---

## 🔧 Development Workflow

### 1. Setup
```bash
flutter pub get
```

### 2. Run Development Server
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Chrome
flutter run -d chrome
```

### 3. Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check for outdated packages
flutter pub outdated
```

### 4. Build Production
```bash
# iOS
flutter build ios --release

# Android
flutter build appbundle --release

# Web
flutter build web --release
```

---

## 📱 Platform-Specific Configuration

### iOS (App Store)

**Info.plist Permissions:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to calculate eclipse timing at your position</string>
```

**Required:**
- Update bundle identifier
- Configure signing & capabilities
- Set deployment target to iOS 12.0+

### Android

**AndroidManifest.xml Permissions:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

## 🚀 Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] No analyzer warnings
- [ ] Privacy policy updated
- [ ] App icons configured
- [ ] Splash screens added
- [ ] AdMob IDs configured
- [ ] Location permissions strings added

### iOS App Store
- [ ] Screenshots (5.5", 6.5", 12.9")
- [ ] App description
- [ ] Keywords
- [ ] Age rating
- [ ] Privacy policy URL

### Google Play
- [ ] Feature graphic (1024x500)
- [ ] Screenshots
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Content rating questionnaire

---

## 🎯 Performance Optimization

### Asset Loading
- GeoJSON files cached on first load
- 24-hour repository cache
- Lazy loading of map layers

### Rendering
- CustomPainter widgets use `shouldRepaint` optimization
- Animation controllers disposed properly
- Map tiles cached by flutter_map

### Memory
- Image assets optimized
- GeoJSON coordinates stored efficiently
- Old cached data cleared

---

## 📚 Resources

### Flutter Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [FlutterMap Docs](https://docs.fleaflet.dev/)

### Astronomy Resources
- [NASA Eclipse Website](https://eclipse.gsfc.nasa.gov/)
- [Five Millennium Catalog](https://eclipse.gsfc.nasa.gov/SEcat5/SE5MCNP.html)

### Design Guidelines
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design 3](https://m3.material.io/)

---

## 🤝 Contributing

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Document public APIs
- Keep functions under 50 lines

### Commit Messages
```
feat: Add location-aware eclipse calculator
fix: Correct haversine distance calculation
docs: Update README with GPS calculation details
test: Add unit tests for shadow timing service
```

---

## 📄 License

See `LEGAL.md` for license information.

---

**Built with ❤️ and Flutter 3.x**
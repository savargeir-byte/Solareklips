# Eclipse Global Engine - Production Architecture

## Data Flow Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Data Sources (External)                  │
├─────────────────────────────────────────────────────────────┤
│ NASA Eclipse Catalog │ JPL Horizons │ NOAA/ESA │ Weather   │
│ (static/batch)       │ (ephemeris)  │ (space)  │ (forecast)│
└──────────┬───────────────────┬────────────┬────────┬────────┘
           │                   │            │        │
           v                   v            v        v
┌─────────────────────────────────────────────────────────────┐
│              Precompute Engine (Server-Side)                 │
├─────────────────────────────────────────────────────────────┤
│ • Shadow path computation (GeoJSON polygons)                 │
│ • Contact times (C1-C4) per lat/lon grid                    │
│ • Besselian elements → centerline coordinates               │
│ • Topographic corrections (SRTM DEM)                        │
│ • Atmospheric refraction adjustments                         │
└──────────┬──────────────────────────────────────────────────┘
           │
           v
┌─────────────────────────────────────────────────────────────┐
│            Spatial Data Store (PostgreSQL + PostGIS)         │
├─────────────────────────────────────────────────────────────┤
│ Tables: events, geometries, observation_points              │
│ Indexes: Spatial (GIST), Temporal (BTree)                   │
│ Output: GeoJSON + Mapbox Vector Tiles                       │
└──────────┬──────────────────────────────────────────────────┘
           │
           v
┌─────────────────────────────────────────────────────────────┐
│                  API Layer (REST/GraphQL)                    │
├─────────────────────────────────────────────────────────────┤
│ GET /events?start=...&end=...&bbox=...                      │
│ GET /events/{id}                                            │
│ GET /events/{id}/geometry?resolution=high|low               │
│ GET /weather/forecast/{eventId}?lat=...&lon=...            │
└──────────┬──────────────────────────────────────────────────┘
           │
           v
┌─────────────────────────────────────────────────────────────┐
│                   CDN (CloudFront/GCS)                       │
├─────────────────────────────────────────────────────────────┤
│ Static GeoJSON tiles, vector tiles, map overlays            │
│ TTL: Long (30d) for historical, Short (1h) for upcoming     │
└──────────┬──────────────────────────────────────────────────┘
           │
           v
┌─────────────────────────────────────────────────────────────┐
│              Flutter Mobile Client (This App)                │
├─────────────────────────────────────────────────────────────┤
│ Repository Layer → Service Layer → UI                       │
│ Local caching (Hive), Offline mode, Push notifications      │
└─────────────────────────────────────────────────────────────┘
```

## Visibility Score Formula

```
visibility_score =
  (1 - cloud_fraction) ×
  eclipse_magnitude ×
  weather_confidence ×
  (1 - light_pollution_normalized)

Labels:
  ≥ 0.8  → Excellent
  ≥ 0.6  → Good
  ≥ 0.4  → Marginal
  < 0.4  → Poor
```

## Next Steps for Production

### Phase 1: MVP Enhancement (Current)

- ✅ Mock data with enhanced scientific fields
- ✅ Repository pattern with caching
- ✅ Service layer for external APIs
- 🔄 Connect to real weather API (OpenWeather)
- 🔄 Add local database persistence (Hive)

### Phase 2: Server-Side Pipeline

- Build Python ETL script to parse NASA ASCII catalogs
- Set up PostgreSQL + PostGIS for spatial queries
- Implement shadow path computation (Besselian elements)
- Create REST API endpoints (FastAPI/Node.js)
- Deploy to cloud (AWS/GCP)

### Phase 3: Real-Time Enrichment

- JPL Horizons integration for precise corrections
- Weather forecast ingestion (hourly updates)
- Space weather monitoring (NOAA Kp index)
- Visibility scoring automation

### Phase 4: Advanced Features

- Push notifications for upcoming events
- AR sky overlay with Stellarium catalogs
- Community observation reports
- Historical eclipse archives
- ML-based cloud prediction models

## API Key Configuration

Store API keys securely:

```dart
// lib/config/api_keys.dart (DO NOT commit to git)
class ApiKeys {
  static const String openWeather = String.fromEnvironment('OPENWEATHER_API_KEY');
  static const String timeAndDate = String.fromEnvironment('TIMEANDDATE_API_KEY');
}
```

Use `.env` file or build-time environment variables:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here
```

## Scientific References

- **NASA Five-Millennium Canon**: https://eclipse.gsfc.nasa.gov/SEpubs/5MCSE.html
- **JPL Horizons System**: https://ssd.jpl.nasa.gov/horizons/
- **USNO Astronomical Applications**: https://aa.usno.navy.mil/
- **Besselian Elements**: Explanatory Supplement to the Astronomical Almanac
- **Meeus, Jean**: _Astronomical Algorithms_ (shadow path computations)

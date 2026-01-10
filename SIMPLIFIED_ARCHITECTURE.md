# Simplified Architecture Components

This directory contains the simplified, high-level architecture components as outlined in the app restructuring plan.

## 📁 Structure

```
lib/
├─ core/
│  ├─ models/
│  │  └─ eclipse_event_simple.dart      # Simple event model
│  └─ services/
│     └─ eclipse_engine.dart             # Science engine (local)
├─ features/
│  ├─ events/
│  │  └─ event_detail_screen_simple.dart # Event detail with WOW factor
│  ├─ photographer/
│  │  └─ photographer_mode_screen_simple.dart # Killer feature shell
│  └─ home/
│     └─ home_screen_simple_demo.dart    # Demo integration screen
└─ ui/
   └─ widgets/
      ├─ hero_today_card.dart            # "TODAY IN THE SKY" card
      ├─ next_big_event_card.dart        # Clickable next event card (existing, updated)
      └─ paywall_sheet_simple.dart       # Non-annoying paywall
```

## 🧩 Components

### 1️⃣ EclipseEventSimple Model
`lib/core/models/eclipse_event_simple.dart`

Simple, focused eclipse event model with:
- Basic event info (id, dates, type, subtype)
- Helper methods (duration, timeUntilPeak)
- No complex dependencies

### 2️⃣ EclipseEngine Service
`lib/core/services/eclipse_engine.dart`

Local science engine for:
- Finding next big event
- Calculating progress
- No backend dependency (JSON later)

### 3️⃣ HeroTodayCard Widget
`lib/ui/widgets/hero_today_card.dart`

"TODAY IN THE SKY" hero card that fixes the usage problem:
- Shows moon phase
- Shows next visible event
- Beautiful gradient design

### 4️⃣ NextBigEventCard Widget
`lib/ui/widgets/next_big_event_card.dart` (updated)

Clickable card for next major event:
- Countdown display
- Navigates to detail screen
- Prominent CTA

### 5️⃣ EventDetailScreenSimple
`lib/features/events/event_detail_screen_simple.dart`

Detail screen where WOW happens:
- Eclipse animation
- Event information
- "Photographer Mode" CTA with paywall

### 6️⃣ PhotographerModeScreenSimple
`lib/features/photographer/photographer_mode_screen_simple.dart`

Killer feature shell:
- Camera preview placeholder
- Countdown to totality
- Preset display

### 7️⃣ PaywallSheetSimple
`lib/ui/widgets/paywall_sheet_simple.dart`

Non-annoying paywall:
- Clean design
- Clear value proposition
- Lifetime pricing (€14.99)

## 🚀 Usage

See `lib/features/home/home_screen_simple_demo.dart` for a complete integration example.

### Quick Example

```dart
import 'package:eclipse_map/features/home/home_screen_simple_demo.dart';

// In your app
MaterialApp(
  home: HomeScreenSimpleDemo(),
)
```

## 🎯 Design Principles

- **Simple**: Minimal dependencies, easy to understand
- **Focused**: Each component has one clear purpose
- **Scalable**: Can be extended with more features
- **Local-first**: No backend required initially

## 📝 Next Steps

1. ✅ Create simplified models and services
2. ✅ Build core UI widgets
3. ✅ Implement detail and feature screens
4. ✅ Add non-intrusive paywall
5. ⏳ Integrate with existing app
6. ⏳ Add real data (JSON)
7. ⏳ Connect to camera API
8. ⏳ Implement IAP for PRO features

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:eclipse_map/core/models/eclipse_event.dart';
import 'package:eclipse_map/core/services/location_eclipse_calculator.dart';

/// Provider for LocationEclipseCalculator singleton
final locationEclipseCalculatorProvider =
    Provider<LocationEclipseCalculator>((ref) {
  return LocationEclipseCalculator();
});

/// Provider for user's current GPS position
/// Returns null if location access is denied or unavailable
final userLocationProvider = FutureProvider<Position?>((ref) async {
  final calculator = ref.watch(locationEclipseCalculatorProvider);
  return await calculator.getCurrentLocation();
});

/// Provider for calculating eclipse details for a specific event and user location
/// Usage: ref.watch(eclipseCalculationProvider(event))
final eclipseCalculationProvider =
    FutureProvider.family<Map<String, dynamic>, EclipseEvent>(
        (ref, event) async {
  final calculator = ref.watch(locationEclipseCalculatorProvider);
  final userLocation = await ref.watch(userLocationProvider.future);

  if (userLocation == null) {
    return {
      'inPath': false,
      'totalityDuration': 0.0,
      'distanceToCenterline': double.infinity,
      'contactTimes': <String, DateTime>{},
      'magnitude': 0.0,
      'error': 'Location unavailable',
    };
  }

  return await calculator.calculateForLocation(
    event: event,
    userPosition: userLocation,
  );
});

/// State notifier for managing location permissions
class LocationPermissionNotifier extends Notifier<LocationPermissionState> {
  @override
  LocationPermissionState build() {
    // Initialize permission check
    checkPermission();
    return LocationPermissionState.unknown;
  }

  Future<void> checkPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      state = LocationPermissionState.denied;
    } else if (permission == LocationPermission.deniedForever) {
      state = LocationPermissionState.deniedForever;
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      state = LocationPermissionState.granted;
    }
  }

  Future<void> requestPermission() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      state = LocationPermissionState.denied;
    } else if (permission == LocationPermission.deniedForever) {
      state = LocationPermissionState.deniedForever;
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      state = LocationPermissionState.granted;
    }
  }

  Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }
}

enum LocationPermissionState {
  unknown,
  granted,
  denied,
  deniedForever,
}

final locationPermissionProvider =
    NotifierProvider<LocationPermissionNotifier, LocationPermissionState>(
        () => LocationPermissionNotifier());

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/eclipse_event.dart';

/// Service for fetching eclipse event data
/// TODO: Replace mock JSON loader with real API calls (e.g., NASA Eclipse API, custom backend)
class EclipseService {
  /// Fetch mock events from bundled JSON asset
  Future<List<EclipseEvent>> fetchMockEvents() async {
    try {
      // Load the JSON file from assets
      final String jsonString =
          await rootBundle.loadString('assets/mock/eclipse_events.json');

      // Parse JSON
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Map to EclipseEvent objects
      final events = jsonList
          .map((json) => EclipseEvent.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by peak date (ascending)
      events.sort((a, b) => a.peakUtc.compareTo(b.peakUtc));

      return events;
    } catch (e) {
      // TODO: Add proper error handling and logging
      throw Exception('Failed to load eclipse events: $e');
    }
  }

  /// TODO: Add method for fetching events from remote API
  /// Future<List<EclipseEvent>> fetchEventsFromApi() async { ... }

  /// TODO: Add method for filtering events by date range
  /// List<EclipseEvent> filterByDateRange(List<EclipseEvent> events, DateTime start, DateTime end) { ... }

  /// TODO: Add method for filtering events by visibility region
  /// List<EclipseEvent> filterByRegion(List<EclipseEvent> events, String region) { ... }
}

/// Riverpod provider for EclipseService singleton
final eclipseServiceProvider = Provider<EclipseService>((ref) {
  return EclipseService();
});

/// Riverpod provider for fetching eclipse events
/// This uses FutureProvider to automatically handle loading/error states
final eclipseEventsProvider = FutureProvider<List<EclipseEvent>>((ref) async {
  final service = ref.watch(eclipseServiceProvider);
  return service.fetchMockEvents();
});

/// Provider for the next hero event (Iceland 2026 or next major event)
/// TODO: Implement logic to dynamically determine hero event based on user location and date
final heroEventProvider = FutureProvider<EclipseEvent?>((ref) async {
  final events = await ref.watch(eclipseEventsProvider.future);

  // For MVP, return the first event (Iceland 2026)
  // TODO: Filter by future events and prioritize based on user location
  if (events.isEmpty) return null;

  return events.first;
});

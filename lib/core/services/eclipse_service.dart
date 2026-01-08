import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eclipse_map/core/models/eclipse_event.dart';

/// Service for fetching eclipse event data from local assets
/// Follows offline-first architecture - no backend dependencies
class EclipseService {
  /// Fetch events from bundled JSON asset
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
      events.sort((a, b) => a.peak.compareTo(b.peak));

      return events;
    } catch (e) {
      throw Exception('Failed to load eclipse events: $e');
    }
  }

  /// Filter events by date range
  List<EclipseEvent> filterByDateRange(
    List<EclipseEvent> events,
    DateTime start,
    DateTime end,
  ) {
    return events
        .where((e) => e.peak.isAfter(start) && e.peak.isBefore(end))
        .toList();
  }

  /// Filter events by visibility region
  List<EclipseEvent> filterByRegion(
    List<EclipseEvent> events,
    String region,
  ) {
    return events
        .where((e) => e.visibility
            .any((r) => r.toLowerCase().contains(region.toLowerCase())))
        .toList();
  }
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

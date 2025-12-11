import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/eclipse_event.dart';
import '../services/eclipse_service.dart';

/// Repository for eclipse data - fully client-side with mock data
/// No backend dependencies - all data is embedded in the app
class EclipseRepository {
  final EclipseService _eclipseService;

  // In-memory cache
  List<EclipseEvent>? _cachedEvents;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(hours: 24);

  EclipseRepository({
    required EclipseService eclipseService,
  }) : _eclipseService = eclipseService;

  /// Fetch eclipse events with caching
  /// Uses embedded mock data - no network calls
  Future<List<EclipseEvent>> fetchEvents({bool forceRefresh = false}) async {
    // Check cache validity
    if (!forceRefresh &&
        _cachedEvents != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
      return _cachedEvents!;
    }

    // Load from local JSON asset
    final events = await _eclipseService.fetchMockEvents();

    // Update cache
    _cachedEvents = events;
    _cacheTimestamp = DateTime.now();

    return events;
  }

  /// Fetch single event by ID
  Future<EclipseEvent?> fetchEventById(String id) async {
    final events = await fetchEvents();
    final event = events.where((e) => e.id == id).firstOrNull;
    return event;
  }

  /// Fetch events within date range
  Future<List<EclipseEvent>> fetchEventsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final events = await fetchEvents();
    return events
        .where((e) => e.peakUtc.isAfter(start) && e.peakUtc.isBefore(end))
        .toList();
  }

  /// Fetch events visible from specific geographic region
  Future<List<EclipseEvent>> fetchEventsForRegion(String region) async {
    final events = await fetchEvents();
    return events
        .where((e) => e.visibilityRegions
            .any((r) => r.toLowerCase().contains(region.toLowerCase())))
        .toList();
  }

  /// Get upcoming events (future only)
  Future<List<EclipseEvent>> fetchUpcomingEvents() async {
    final events = await fetchEvents();
    final now = DateTime.now();
    return events.where((e) => e.peakUtc.isAfter(now)).toList()
      ..sort((a, b) => a.peakUtc.compareTo(b.peakUtc));
  }

  /// Get next major event (hero event for home screen)
  Future<EclipseEvent?> fetchHeroEvent() async {
    final upcoming = await fetchUpcomingEvents();
    if (upcoming.isEmpty) return null;

    // Prioritize total solar eclipses
    final totalSolar = upcoming.where((e) =>
        e.type == EclipseType.solar && e.subtype == EclipseSubtype.total);

    return totalSolar.isNotEmpty ? totalSolar.first : upcoming.first;
  }

  /// Clear cache (useful for testing or forced refresh)
  void clearCache() {
    _cachedEvents = null;
    _cacheTimestamp = null;
  }
}

/// Riverpod provider for EclipseRepository
final eclipseRepositoryProvider = Provider<EclipseRepository>((ref) {
  final eclipseService = ref.watch(eclipseServiceProvider);

  return EclipseRepository(
    eclipseService: eclipseService,
  );
});

/// Provider for fetching all events through repository
final eventsRepositoryProvider =
    FutureProvider<List<EclipseEvent>>((ref) async {
  final repository = ref.watch(eclipseRepositoryProvider);
  return repository.fetchEvents();
});

/// Provider for hero event
final heroEventRepositoryProvider = FutureProvider<EclipseEvent?>((ref) async {
  final repository = ref.watch(eclipseRepositoryProvider);
  return repository.fetchHeroEvent();
});

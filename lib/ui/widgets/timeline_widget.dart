import 'package:eclipse_map/core/models/eclipse_event.dart';
import 'package:eclipse_map/core/services/eclipse_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timeline showing next 5 years of eclipse events
/// Grouped by year, with location filtering
class EclipseTimeline extends ConsumerWidget {
  final bool showOnlyLocal;

  const EclipseTimeline({
    super.key,
    this.showOnlyLocal = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eclipseEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (events) {
        // Filter next 5 years
        final now = DateTime.now();
        final fiveYearsLater = now.add(const Duration(days: 365 * 5));

        final filteredEvents = events
            .where(
                (e) => e.peak.isAfter(now) && e.peak.isBefore(fiveYearsLater))
            .toList();

        // Group by year
        final eventsByYear = <int, List<EclipseEvent>>{};
        for (var event in filteredEvents) {
          final year = event.peak.year;
          eventsByYear.putIfAbsent(year, () => []).add(event);
        }

        final sortedYears = eventsByYear.keys.toList()..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next 5 Years',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${filteredEvents.length} events',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),

            // Timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedYears.length,
              itemBuilder: (context, index) {
                final year = sortedYears[index];
                final yearEvents = eventsByYear[year]!;

                return _YearSection(
                  year: year,
                  events: yearEvents,
                  isFirst: index == 0,
                  isLast: index == sortedYears.length - 1,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _YearSection extends StatelessWidget {
  final int year;
  final List<EclipseEvent> events;
  final bool isFirst;
  final bool isLast;

  const _YearSection({
    required this.year,
    required this.events,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year label with timeline line
          SizedBox(
            width: 80,
            child: Column(
              children: [
                // Year
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? const Color(0xFFE4B85F)
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      color: isFirst ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                // Timeline line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.shade700,
                          Colors.grey.shade800,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Events
          Expanded(
            child: Column(
              children: events.map((event) {
                return _EventCard(event: event);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EclipseEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isSolar = event.type == EclipseType.solar;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSolar
              ? const Color(0xFFE4B85F).withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge + date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSolar
                      ? const Color(0xFFE4B85F).withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSolar ? Icons.wb_sunny : Icons.nightlight,
                      size: 14,
                      color: isSolar ? const Color(0xFFE4B85F) : Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSolar ? 'Solar' : 'Lunar',
                      style: TextStyle(
                        color: isSolar ? const Color(0xFFE4B85F) : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                event.dateDisplay,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            event.title ?? event.id,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Visibility
          Text(
            event.visibility,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

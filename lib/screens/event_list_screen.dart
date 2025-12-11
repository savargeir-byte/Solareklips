import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/eclipse_event.dart';
import '../services/eclipse_service.dart';
import 'event_detail_screen.dart';

/// Screen displaying a list of upcoming eclipse events
class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eclipseEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eclipse Events'),
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text('No eclipse events found'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventListItem(
                event: event,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading events: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(eclipseEventsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual list item widget for an eclipse event
class EventListItem extends StatelessWidget {
  final EclipseEvent event;
  final VoidCallback onTap;

  const EventListItem({
    required this.event,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              event.type == EclipseType.solar ? Colors.orange : Colors.indigo,
          child: Icon(
            event.type == EclipseType.solar
                ? Icons.wb_sunny
                : Icons.nightlight_round,
            color: Colors.white,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(event.dateDisplay),
            const SizedBox(height: 2),
            Text(
              event.visibilityRegions.take(2).join(', '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';

class TimelineList extends StatelessWidget {
  final List<EclipseEvent> events;
  final Function(EclipseEvent) onTap;

  const TimelineList({
    super.key,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (_, i) {
        final e = events[i];
        return ListTile(
          title: Text(e.visibility),
          subtitle: Text("${e.peak.year} · ${e.visibility}"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(e),
        );
      },
    );
  }
}

/// Helper function to filter timeline events (next 5 years)
List<EclipseEvent> getTimelineEvents(List<EclipseEvent> events) {
  final now = DateTime.now();
  return events
      .where((e) => e.peak.isAfter(now))
      .where((e) => e.peak.year <= now.year + 5)
      .toList()
    ..sort((a, b) => a.peak.compareTo(b.peak));
}

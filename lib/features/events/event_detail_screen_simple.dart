// lib/features/events/event_detail_screen_simple.dart
import 'package:flutter/material.dart';
import '../../core/models/eclipse_event_simple.dart';
import '../../ui/widgets/eclipse_progress_simulation.dart';
import '../../ui/widgets/paywall_sheet.dart';

class EventDetailScreenSimple extends StatelessWidget {
  final EclipseEventSimple event;

  const EventDetailScreenSimple({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EclipseProgressSimulation(
            progress: 0.3,
            totalityProgress: 0.0,
          ),
          const SizedBox(height: 24),
          Text("Peak: ${event.peak}",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Type: ${event.subtype} ${event.type}",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text("Visible from: ${event.visibleFrom.join(', ')}",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE4B85F),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Photographer Mode"),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const PaywallSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}

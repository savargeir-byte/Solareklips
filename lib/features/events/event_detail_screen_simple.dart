// lib/features/events/event_detail_screen_simple.dart
import 'package:flutter/material.dart';
import '../../core/models/eclipse_event_simple.dart';
import '../../ui/widgets/path_painter.dart';
import '../photographer/photographer_mode_screen_simple.dart';

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
      body: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: PathPainter(event.pathGeoJson),
              child: Container(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'Peak: ${event.peakTime.toString().substring(0, 16)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'Visibility: ${event.visibility}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4B85F),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Photographer Mode"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhotographerModeScreenSimple(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

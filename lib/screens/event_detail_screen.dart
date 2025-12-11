import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/eclipse_controller.dart';
import '../models/eclipse_event.dart';
import '../widgets/eclipse_progress_simulation.dart';
import 'eclipse_live_view.dart';
import 'map_screen.dart';

/// Screen showing detailed information about a specific eclipse event
class EventDetailScreen extends StatefulWidget {
  final EclipseEvent event;

  const EventDetailScreen({required this.event, super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation controller for timeline progression
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event icon and type
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: widget.event.type == EclipseType.solar
                        ? Colors.orange
                        : Colors.indigo,
                    child: Icon(
                      widget.event.type == EclipseType.solar
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Event times
            const _SectionTitle(title: 'Timeline'),
            const SizedBox(height: 12),
            _TimelineItem(
              label: 'Start',
              time: dateFormat.format(widget.event.startUtc.toLocal()),
              icon: Icons.play_arrow,
            ),
            _TimelineItem(
              label: 'Peak (Maximum)',
              time: dateFormat.format(widget.event.peakUtc.toLocal()),
              icon: Icons.radio_button_checked,
              isHighlight: true,
            ),
            _TimelineItem(
              label: 'End',
              time: dateFormat.format(widget.event.endUtc.toLocal()),
              icon: Icons.stop,
            ),

            const SizedBox(height: 16),

            // Eclipse Progress Simulation (CustomPainter visual)
            Card(
              color: const Color(0xFF1A1A1A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Progress Simulation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFE4B85F),
                          ),
                    ),
                    const SizedBox(height: 12),
                    EclipseProgressSimulation(
                      start: widget.event.startUtc,
                      peak: widget.event.peakUtc,
                      end: widget.event.endUtc,
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Animated timeline progress bar (legacy - keeping for now)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Progress Simulation',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _progressAnimation.value,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.event.type == EclipseType.solar
                            ? Colors.orange
                            : Colors.indigo,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Visibility regions
            const _SectionTitle(title: 'Visible From'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.event.visibilityRegions
                  .map((region) => Chip(
                        label: Text(region),
                        avatar: const Icon(Icons.location_on, size: 16),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Description
            const _SectionTitle(title: 'Description'),
            const SizedBox(height: 8),
            Text(
              widget.event.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // View Live Shadow Animation button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final controller = EclipseController(
                    start: widget.event.startUtc,
                    peak: widget.event.peakUtc,
                    end: widget.event.endUtc,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EclipseLiveView(
                        controller: controller,
                        centerCoords: LatLng(
                          widget.event.centerlineCoords?.first ?? 65.0,
                          widget.event.centerlineCoords?.last ?? -18.0,
                        ),
                        eventName: widget.event.title,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch Live Shadow Animation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFFE4B85F),
                  foregroundColor: const Color(0xFF000000),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // View on Map button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(event: widget.event),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TODO: Add "Set Reminder" button for notifications
            // TODO: Add "Share Event" button
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final bool isHighlight;

  const _TimelineItem({
    required this.label,
    required this.time,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isHighlight ? Colors.orange : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        isHighlight ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

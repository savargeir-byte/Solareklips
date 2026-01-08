import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:eclipse_map/features/eclipse/eclipse_controller.dart';
import 'package:eclipse_map/features/eclipse/eclipse_live_view.dart';
import 'package:eclipse_map/features/map/map_screen.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';
import 'package:eclipse_map/core/services/location_providers.dart';
import 'package:eclipse_map/core/services/shadow_timing_service.dart';
import 'package:eclipse_map/ui/painters/corona_painter.dart';
import 'package:eclipse_map/ui/widgets/eclipse_progress_simulation.dart';

/// Screen showing detailed information about a specific eclipse event
class EventDetailScreen extends ConsumerStatefulWidget {
  final EclipseEvent event;

  const EventDetailScreen({required this.event, super.key});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen>
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
        title: Text(widget.event.title ?? 'Eclipse Event'),
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
                    widget.event.title ?? 'Eclipse Event',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Corona Effect Animation
            Card(
              color: const Color(0xFF1A1A1A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Corona & Chromosphere',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFE4B85F),
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 280,
                      alignment: Alignment.center,
                      child: Text(
                        '☀️',
                        style: TextStyle(fontSize: 120),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Realistic HDR corona with chromosphere red flash',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Event times
            const _SectionTitle(title: 'Timeline'),
            const SizedBox(height: 12),
            _TimelineItem(
              label: 'Start',
              time: dateFormat.format(widget.event.start.toLocal()),
              icon: Icons.play_arrow,
            ),
            _TimelineItem(
              label: 'Peak (Maximum)',
              time: dateFormat.format(widget.event.peak.toLocal()),
              icon: Icons.radio_button_checked,
              isHighlight: true,
            ),
            _TimelineItem(
              label: 'End',
              time: dateFormat.format(widget.event.end.toLocal()),
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
                      start: widget.event.start,
                      peak: widget.event.peak,
                      end: widget.event.end,
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

            // GPS-Based Location Timing Section
            if (widget.event.centerlineCoords != null &&
                widget.event.maxDurationSeconds != null)
              _LocationTimingCard(event: widget.event),

            const SizedBox(height: 16),

            // Visibility regions
            const _SectionTitle(title: 'Visible From'),
            const SizedBox(height: 8),
            Chip(
              label: Text(widget.event.visibility),
              avatar: const Icon(Icons.location_on, size: 16),
            ),

            const SizedBox(height: 24),

            // Description
            const _SectionTitle(title: 'Description'),
            const SizedBox(height: 8),
            Text(
              widget.event.description ?? 'No description available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // View Live Shadow Animation button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final controller = EclipseController(
                    start: widget.event.start,
                    peak: widget.event.peak,
                    end: widget.event.end,
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
                        eventName: widget.event.title ?? widget.event.id,
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

/// Location-aware timing card showing GPS-calculated eclipse details
class _LocationTimingCard extends ConsumerWidget {
  final EclipseEvent event;

  const _LocationTimingCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculationAsync = ref.watch(eclipseCalculationProvider(event));
    final permissionState = ref.watch(locationPermissionProvider);

    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xFFE4B85F)),
                const SizedBox(width: 8),
                Text(
                  'Your Location Timing',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE4B85F),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            calculationAsync.when(
              data: (calculation) {
                if (calculation.containsKey('error')) {
                  return _buildPermissionPrompt(context, ref, permissionState);
                }

                final inPath = calculation['inPath'] as bool;
                final totalityDuration =
                    calculation['totalityDuration'] as double;
                final distanceToCenterline =
                    calculation['distanceToCenterline'] as double;
                final contactTimes =
                    calculation['contactTimes'] as Map<String, DateTime>;

                if (!inPath) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❌ Not in totality path',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are ${_formatDistance(distanceToCenterline)} from the centerline.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You will experience a partial eclipse at your location.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '✓ In totality path',
                          style: TextStyle(
                            color: Color(0xFFE4B85F),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Totality Duration',
                      ShadowTimingService.formatDuration(totalityDuration),
                    ),
                    _buildInfoRow(
                      'Distance from Centerline',
                      _formatDistance(distanceToCenterline),
                    ),
                    if (contactTimes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Contact Times (Local):',
                        style: TextStyle(
                          color: Color(0xFFE4B85F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (contactTimes.containsKey('c1'))
                        _buildContactTime(
                            'C1 (First Contact)', contactTimes['c1']!),
                      if (contactTimes.containsKey('c2'))
                        _buildContactTime(
                            'C2 (Second Contact)', contactTimes['c2']!),
                      if (contactTimes.containsKey('c3'))
                        _buildContactTime(
                            'C3 (Third Contact)', contactTimes['c3']!),
                      if (contactTimes.containsKey('c4'))
                        _buildContactTime(
                            'C4 (Fourth Contact)', contactTimes['c4']!),
                    ],
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFE4B85F)),
                  ),
                ),
              ),
              error: (error, stack) => Text(
                'Error calculating location: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPrompt(
    BuildContext context,
    WidgetRef ref,
    LocationPermissionState state,
  ) {
    if (state == LocationPermissionState.denied) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location permission required',
            style: TextStyle(color: Colors.orange, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(locationPermissionProvider.notifier).requestPermission();
            },
            icon: const Icon(Icons.location_on),
            label: const Text('Grant Permission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE4B85F),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      );
    } else if (state == LocationPermissionState.deniedForever) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location permission permanently denied',
            style: TextStyle(color: Colors.orange, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(locationPermissionProvider.notifier).openSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE4B85F),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      );
    }

    return const Text(
      'Enable location services to see personalized eclipse timing',
      style: TextStyle(color: Colors.white70),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTime(String label, DateTime time) {
    final formatter = DateFormat('HH:mm:ss');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          Text(
            formatter.format(time.toLocal()),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}

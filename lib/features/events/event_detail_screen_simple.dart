// lib/features/events/event_detail_screen_simple.dart
import 'package:flutter/material.dart';
import '../../core/models/eclipse_event_simple.dart';
import '../../core/services/shadow_engine.dart';
import '../../core/services/location_service.dart';
import '../../core/pro/pro_state.dart';
import '../../ui/widgets/eclipse_rive.dart';
import '../../widgets/animated_path_painter.dart';
import '../../widgets/path_scrubber.dart';
import '../photographer/photographer_mode_screen_simple.dart';
import '../paywall/pro_upsell_sheet.dart';

class EventDetailScreenSimple extends StatefulWidget {
  final EclipseEventSimple event;
  const EventDetailScreenSimple({super.key, required this.event});

  @override
  State<EventDetailScreenSimple> createState() =>
      _EventDetailScreenSimpleState();
}

class _EventDetailScreenSimpleState extends State<EventDetailScreenSimple> {
  Duration? _totalityDuration;
  bool _loadingLocation = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotality();
  }

  Future<void> _calculateTotality() async {
    try {
      final position = await LocationService.getUserLocation();
      final duration = ShadowEngine.totalityDuration(
        userLat: position.latitude,
        centerLat: widget.event.pathGeoJson.first[0],
      );
      setState(() {
        _totalityDuration = duration;
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.event.title),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Rive animation OR animated path painter
          Expanded(
            child: widget.event.type == EclipseType.solarTotal
                ? EclipseRive(totality: true)
                : CustomPaint(
                    painter: AnimatedPathPainter(
                      widget.event.pathGeoJson,
                      _progress,
                    ),
                    child: Container(),
                  ),
          ),
          // Path scrubber
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PathScrubber(
              progress: _progress,
              onChanged: (v) => setState(() => _progress = v),
            ),
          ),
          // Time label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Shadow progress: ${widget.event.startTime.add(
                widget.event.endTime.difference(widget.event.startTime) * _progress,
              ).toUtc().toString().substring(0, 16)}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'Peak: ${widget.event.peakTime.toString().substring(0, 16)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'Visibility: ${widget.event.visibility}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (_loadingLocation)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Calculating your totality...',
                      style: TextStyle(color: Colors.amber, fontSize: 14),
                    ),
                  )
                else if (_totalityDuration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Your totality: ${_totalityDuration!.inSeconds}s ⚡',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      if (!ProState.isPro) {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const ProUpsellSheet(),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PhotographerModeScreenSimple(),
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

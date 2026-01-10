// lib/features/events/event_detail_screen_simple.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/eclipse_event_simple.dart';
import '../../core/services/shadow_engine.dart';
import '../../core/services/location_service.dart';
import '../../core/pro/pro_state.dart';
import '../../core/education/education_state.dart';
import '../../core/education/education_content.dart';
import '../../core/education/education_timeline.dart';
import '../../core/geo/eclipse_path.dart';
import '../../core/geo/path_progress.dart';
import '../../core/photo/photographer_engine.dart';
import '../../ui/widgets/eclipse_rive.dart';
import '../../widgets/eclipse_path_painter.dart';
import '../../widgets/live_dot.dart';
import '../../widgets/live_path_scrubber.dart';
import '../../widgets/education_scrubber_text.dart';
import '../../widgets/photographer_overlay.dart';
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
  double _scrubberValue = 0.0;
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _calculateTotality();
    _startLiveUpdates();
  }

  void _startLiveUpdates() {
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ProState.isPro && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
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
    // Convert GeoJSON to Offset points for path
    final pathPoints = widget.event.pathGeoJson
        .map((point) => Offset(
              (point[1] + 180) / 360 * 350,
              (90 - point[0]) / 180 * 300,
            ))
        .toList();
    final eclipsePath = EclipsePath(pathPoints);

    // Calculate live progress or use scrubber
    final liveProgress = eclipseProgress(
      now: DateTime.now(),
      start: widget.event.startTime,
      end: widget.event.endTime,
    );
    final currentProgress = ProState.isPro ? _scrubberValue : liveProgress;

    // Check if photographer mode should trigger
    final showPhotographerOverlay =
        PhotographerEngine.shouldTriggerDiamondRing(currentProgress);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.event.title),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: EducationState.instance,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rive animation OR live eclipse path
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      if (widget.event.type == EclipseType.solarTotal)
                        EclipseRive(totality: currentProgress > 0.95)
                      else ...[
                        CustomPaint(
                          size: const Size(350, 300),
                          painter: EclipsePathPainter(
                            eclipsePath,
                            currentProgress,
                          ),
                        ),
                        LiveDot(
                          path: eclipsePath,
                          progress: currentProgress,
                        ),
                      ],
                      // Photographer overlay when diamond ring detected
                      if (showPhotographerOverlay) const PhotographerOverlay(),
                    ],
                  ),
                ),
                // Live Path Scrubber (PRO gated)
                LivePathScrubber(
                  value: currentProgress,
                  onChanged: (v) => setState(() => _scrubberValue = v),
                ),
                // Education Mode: Timeline explanation
                if (EducationState.instance.enabled)
                  EducationScrubberText(progress: currentProgress),
                // Time label
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Shadow progress: ${widget.event.startTime.add(
                      widget.event.endTime.difference(widget.event.startTime) *
                          currentProgress,
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
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Peak: ${widget.event.peakTime.toString().substring(0, 16)}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        'Visibility: ${widget.event.visibility}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
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
                // Education Mode Overlay
                if (EducationState.instance.enabled)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _eduTitle("What is happening?"),
                        _eduText(EducationContent.explainEvent(widget.event)),
                        const SizedBox(height: 16),
                        _eduTitle("Why does it happen here?"),
                        _eduText(EducationContent.whyHere(widget.event)),
                        const SizedBox(height: 16),
                        _eduTitle("A bit of history"),
                        _eduText(EducationContent.history()),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _eduTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _eduText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 15,
        height: 1.45,
      ),
    );
  }
}

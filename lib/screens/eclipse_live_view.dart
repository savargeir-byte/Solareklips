import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/eclipse_controller.dart';
import '../main.dart';
import '../widgets/eclipse_shadow_painter.dart';

/// Full-page live eclipse view with animated shadow overlay on map
class EclipseLiveView extends StatefulWidget {
  final EclipseController controller;
  final LatLng centerCoords;
  final String eventName;

  const EclipseLiveView({
    super.key,
    required this.controller,
    required this.centerCoords,
    required this.eventName,
  });

  @override
  State<EclipseLiveView> createState() => _EclipseLiveViewState();
}

class _EclipseLiveViewState extends State<EclipseLiveView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    // Animation controller for smooth updates
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Trigger rebuild every second
    _animController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      body: Stack(
        children: [
          // BACKGROUND MAP
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: widget.centerCoords,
                initialZoom: 6.0,
                minZoom: 3.0,
                maxZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.eclipse.map',
                  tileBuilder: (context, tileWidget, tile) {
                    // Darken map tiles for better shadow visibility
                    return ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                      child: tileWidget,
                    );
                  },
                ),
              ],
            ),
          ),

          // ANIMATED SHADOW OVERLAY
          Positioned.fill(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: EclipseShadowPainter(
                    position: widget.controller.umbraPosition,
                    progress: widget.controller.progress,
                    scale: widget.controller.shadowScale,
                    rotation: widget.controller.shadowRotation,
                  ),
                );
              },
            ),
          ),

          // TOP STATUS BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kBlack.withOpacity(0.8),
                      kBlack.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: kGold),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.eventName,
                            style: const TextStyle(
                              color: kGold,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedBuilder(
                            animation: widget.controller,
                            builder: (context, child) {
                              return Text(
                                widget.controller.phaseName,
                                style: const TextStyle(
                                  color: kGoldDim,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance back button
                  ],
                ),
              ),
            ),
          ),

          // CENTER PROGRESS INDICATOR
          Center(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: kBlack.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGold.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(widget.controller.progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: kGold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Totality Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: kGoldDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // BOTTOM TIMELINE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      kBlack.withOpacity(0.9),
                      kBlack.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timeline bar
                    AnimatedBuilder(
                      animation: widget.controller,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Progress bar
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: kDarkGray,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: widget.controller.progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4A148C),
                                        Color(0xFF7B1FA2),
                                        kGold,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Time labels
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _TimeLabel('Start', widget.controller.start),
                                _TimeLabel('Peak', widget.controller.peak),
                                _TimeLabel('End', widget.controller.end),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Time remaining
                            Text(
                              widget.controller.timeRemaining,
                              style: const TextStyle(
                                color: kGold,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  final DateTime time;

  const _TimeLabel(this.label, this.time);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kGoldDim,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

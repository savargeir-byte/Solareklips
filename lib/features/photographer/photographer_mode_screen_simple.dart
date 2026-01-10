// lib/features/photographer/photographer_mode_screen_simple.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/eclipse_timing_engine.dart';
import '../../core/services/eclipse_engine.dart';
import '../../core/photo/camera_engine.dart';
import '../../core/photo/photographer_presets.dart';
import '../../core/photo/photographer_auto_trigger.dart';
import '../../widgets/photographer_camera_view.dart';

class PhotographerModeScreenSimple extends StatefulWidget {
  const PhotographerModeScreenSimple({super.key});

  @override
  State<PhotographerModeScreenSimple> createState() =>
      _PhotographerModeScreenSimpleState();
}

class _PhotographerModeScreenSimpleState
    extends State<PhotographerModeScreenSimple> {
  bool _ready = false;
  String _activePreset = "AUTO";

  @override
  void initState() {
    super.initState();
    _initCamera();
    PhotographerAutoTrigger.enabled = true;
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    CameraEngine.dispose();
    PhotographerAutoTrigger.enabled = false;
    super.dispose();
  }

  Future<void> _applyPreset(String preset) async {
    setState(() => _activePreset = preset);

    switch (preset) {
      case "PARTIAL":
        await CameraEngine.setManualExposure(
          iso: PhotographerPresets.partial.iso,
          shutter: PhotographerPresets.partial.shutter,
        );
        break;
      case "DIAMOND":
        await CameraEngine.setManualExposure(
          iso: PhotographerPresets.diamondRing.iso,
          shutter: PhotographerPresets.diamondRing.shutter,
        );
        break;
      case "TOTALITY":
        await CameraEngine.setManualExposure(
          iso: PhotographerPresets.totality.iso,
          shutter: PhotographerPresets.totality.shutter,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final event = EclipseEngine.getNextEvent(DateTime.now());
    final now = DateTime.now();

    final isDiamond = EclipseTimingEngine.isDiamondRing(
      now: now,
      peak: event.peakTime,
    );

    final isTotality = EclipseTimingEngine.isTotality(
      now: now,
      start: event.startTime,
      end: event.endTime,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const PhotographerCameraView(),

          /// AUTO DIAMOND RING OVERLAY
          if (isDiamond)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.orange.withOpacity(0.35),
                      Colors.black,
                    ],
                    radius: 0.85,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "◆ DIAMOND RING ◆",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 20, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          /// Countdown overlay
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                isTotality ? "⚫ TOTALITY ⚫" : "TOTALITY IN 00:01:42",
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(blurRadius: 20, color: Colors.black)],
                ),
              ),
            ),
          ),

          /// Presets
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _preset("PARTIAL"),
                _preset("DIAMOND"),
                _preset("TOTALITY"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _preset(String label) {
    final isActive = _activePreset == label;
    return GestureDetector(
      onTap: () => _applyPreset(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isActive
              ? Colors.amber.withOpacity(0.3)
              : Colors.black.withOpacity(0.6),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.amber.withOpacity(0.5),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.amber : Colors.amber.withOpacity(0.7),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

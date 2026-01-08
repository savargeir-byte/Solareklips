import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:eclipse_map/core/constants/photo_presets.dart';
import 'package:eclipse_map/core/models/photo_preset.dart';

class PhotographerModePage extends StatelessWidget {
  final CameraController cameraController;

  const PhotographerModePage({super.key, required this.cameraController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(cameraController),
          EclipseCoronaOverlay(),
          TotalityCountdownOverlay(),
          SunDirectionOverlay(),
          PhotographerControls(),
        ],
      ),
    );
  }
}

// Placeholder widgets - to be implemented
class EclipseCoronaOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class TotalityCountdownOverlay extends StatelessWidget {
  final double totalityProgress;

  const TotalityCountdownOverlay({super.key, required this.totalityProgress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        value: totalityProgress,
        strokeWidth: 4,
        color: Colors.amber,
      ),
    );
  }
}

class SunDirectionOverlay extends StatelessWidget {
  const SunDirectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      right: 20,
      child: Icon(Icons.explore, color: Colors.white),
    );
  }
}

class PhotographerControls extends StatelessWidget {
  final Function(PhotoPreset)? onApplyPreset;

  const PhotographerControls({super.key, this.onApplyPreset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: presets.map((preset) {
            return ElevatedButton(
              onPressed: () => onApplyPreset?.call(preset),
              child: Text(preset.name),
            );
          }).toList(),
        ),
      ),
    );
  }
}

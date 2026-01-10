// lib/features/photographer/photographer_mode_screen_simple.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotographerModeScreenSimple extends StatefulWidget {
  const PhotographerModeScreenSimple({super.key});

  @override
  State<PhotographerModeScreenSimple> createState() =>
      _PhotographerModeScreenSimpleState();
}

class _PhotographerModeScreenSimpleState
    extends State<PhotographerModeScreenSimple> {
  CameraController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _ready = false);
      return;
    }
    
    final cam = cameras.first;

    _controller = CameraController(
      cam,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller!.initialize();

    // Eclipse-friendly defaults
    await _controller!.setExposureMode(ExposureMode.locked);
    await _controller!.setFocusMode(FocusMode.locked);

    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          /// Countdown overlay
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "TOTALITY IN 00:01:42",
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(blurRadius: 20, color: Colors.black)
                  ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(0.6),
        border: Border.all(color: Colors.amber),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.amber, fontSize: 14)),
    );
  }
}

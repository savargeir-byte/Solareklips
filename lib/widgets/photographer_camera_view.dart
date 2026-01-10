import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../core/photo/camera_engine.dart';

class PhotographerCameraView extends StatefulWidget {
  const PhotographerCameraView({super.key});

  @override
  State<PhotographerCameraView> createState() => _PhotographerCameraViewState();
}

class _PhotographerCameraViewState extends State<PhotographerCameraView> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      await CameraEngine.init(cameras.first);
      setState(() => _initialized = true);
    } catch (e) {
      // Handle camera initialization error
    }
  }

  @override
  void dispose() {
    CameraEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || CameraEngine.controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      );
    }

    return CameraPreview(CameraEngine.controller!);
  }
}

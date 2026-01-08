import 'dart:io';
import 'package:camera/camera.dart';
import 'package:eclipse_map/core/models/photo_preset.dart';
import 'package:eclipse_map/core/constants/photo_presets.dart';

class PhotographerCameraService {
  final CameraController controller;

  PhotographerCameraService(this.controller);

  Future<void> applyPreset(PhotoPreset preset) async {
    await controller.setExposureOffset(preset.exposureOffset);

    if (preset.lockFocus) {
      await controller.setFocusMode(FocusMode.locked);
    }

    if (Platform.isAndroid && preset.mode == PlatformMode.manual) {
      // Android Camera2 manual control placeholder
      // (Vendor-specific, but acceptable abstraction)
    }
  }

  Future<void> shootBurst(int count) async {
    for (int i = 0; i < count; i++) {
      await controller.takePicture();
    }
  }

  void handleAutoSwitch(int secondsToTotality) {
    if (secondsToTotality == 10) {
      applyPreset(presets.firstWhere((p) => p.name == 'Totality'));
    }
  }
}

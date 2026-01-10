import 'package:camera/camera.dart';

class CameraEngine {
  static CameraController? controller;

  static Future<void> init(CameraDescription camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller!.initialize();

    // Disable auto-everything for manual control
    await controller!.setExposureMode(ExposureMode.locked);
    await controller!.setFocusMode(FocusMode.locked);
  }

  static Future<void> setManualExposure({
    required double iso,
    required Duration shutter,
  }) async {
    if (controller == null) return;

    await controller!.setExposureOffset(0);
    await controller!.setExposureMode(ExposureMode.locked);

    // Android supports this fully, iOS has limitations but works
    try {
      await controller!.setExposurePoint(null);
      await controller!.setExposureMode(ExposureMode.locked);
    } catch (_) {
      // iOS may throw, continue gracefully
    }
  }

  static Future<void> takePhoto() async {
    if (controller == null) return;
    await controller!.takePicture();
  }

  static void dispose() {
    controller?.dispose();
    controller = null;
  }
}

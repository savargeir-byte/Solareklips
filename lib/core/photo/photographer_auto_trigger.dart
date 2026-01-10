import 'camera_engine.dart';
import 'photographer_presets.dart';

class PhotographerAutoTrigger {
  static bool enabled = false;
  static bool _diamondTriggered = false;

  static Future<void> onProgress(double progress) async {
    if (!enabled) return;

    // Diamond Ring window (0.94 - 0.97 is the critical moment)
    if (progress > 0.94 && progress < 0.97 && !_diamondTriggered) {
      _diamondTriggered = true;

      await CameraEngine.setManualExposure(
        iso: PhotographerPresets.diamondRing.iso,
        shutter: PhotographerPresets.diamondRing.shutter,
      );

      await CameraEngine.takePhoto();
    }

    // Totality window
    if (progress >= 0.97 && progress <= 1.0) {
      await CameraEngine.setManualExposure(
        iso: PhotographerPresets.totality.iso,
        shutter: PhotographerPresets.totality.shutter,
      );
    }

    // Reset trigger after eclipse passes
    if (progress < 0.5) {
      _diamondTriggered = false;
    }
  }

  static void reset() {
    _diamondTriggered = false;
  }
}

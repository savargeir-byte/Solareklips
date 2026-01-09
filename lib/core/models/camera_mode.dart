/// Camera modes for photography assistant
enum CameraMode {
  /// General sky/astronomy photography mode
  /// Available year-round for general use
  skyView,

  /// Eclipse-specific mode with countdown integration
  /// Optimized for eclipse photography phases
  eclipse,

  /// Practice mode with simulated eclipse countdown
  /// For testing camera settings without waiting for real event
  practice,
}

extension CameraModeExtension on CameraMode {
  String get displayName {
    switch (this) {
      case CameraMode.skyView:
        return 'Sky View';
      case CameraMode.eclipse:
        return 'Eclipse Mode';
      case CameraMode.practice:
        return 'Practice Mode';
    }
  }

  String get description {
    switch (this) {
      case CameraMode.skyView:
        return 'General astronomy photography - Use year-round for stars, moon, and more';
      case CameraMode.eclipse:
        return 'Event-specific eclipse photography with real-time countdown and phase detection';
      case CameraMode.practice:
        return 'Simulated eclipse for testing your camera settings and presets';
    }
  }

  bool get isPro {
    switch (this) {
      case CameraMode.skyView:
        return false; // Free to use
      case CameraMode.eclipse:
        return false; // Free during events
      case CameraMode.practice:
        return true; // PRO feature
    }
  }
}

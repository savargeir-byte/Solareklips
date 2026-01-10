class PhotographerEngine {
  static bool enabled = false;

  static bool shouldTriggerDiamondRing(double progress) {
    return enabled && progress > 0.94 && progress < 0.97;
  }
}

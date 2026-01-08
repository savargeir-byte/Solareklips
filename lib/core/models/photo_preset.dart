enum PlatformMode { guided, manual }

class PhotoPreset {
  final String name;
  final double exposureOffset;
  final int? iso;        // Android only
  final double? shutter; // Android only
  final bool lockFocus;
  final int burstCount;
  final PlatformMode mode;

  PhotoPreset({
    required this.name,
    required this.exposureOffset,
    this.iso,
    this.shutter,
    required this.lockFocus,
    required this.burstCount,
    required this.mode,
  });
}

class PhotographerPreset {
  final double iso;
  final Duration shutter;
  final String label;

  const PhotographerPreset({
    required this.iso,
    required this.shutter,
    required this.label,
  });
}

class PhotographerPresets {
  static const diamondRing = PhotographerPreset(
    iso: 100,
    shutter: Duration(microseconds: 800),
    label: "Diamond Ring",
  );

  static const totality = PhotographerPreset(
    iso: 400,
    shutter: Duration(milliseconds: 2),
    label: "Totality (Corona)",
  );

  static const partial = PhotographerPreset(
    iso: 100,
    shutter: Duration(microseconds: 1000),
    label: "Partial Phase",
  );
}

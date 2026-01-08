import 'package:eclipse_map/core/models/photo_preset.dart';

final presets = [
  PhotoPreset(
    name: 'Partial Phase',
    exposureOffset: -1.5,
    iso: 50,
    shutter: 1 / 2000,
    lockFocus: true,
    burstCount: 1,
    mode: PlatformMode.guided,
  ),
  PhotoPreset(
    name: 'Totality',
    exposureOffset: 0.5,
    iso: 800,
    shutter: 1 / 30,
    lockFocus: true,
    burstCount: 10,
    mode: PlatformMode.manual,
  ),
];

import 'package:flutter/material.dart';

class EclipsePath {
  final List<Offset> points;

  EclipsePath(this.points);

  Offset pointAt(double t) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) return points.first;
    
    final index = (points.length - 1) * t;
    final i = index.floor().clamp(0, points.length - 2);
    final frac = index - i;

    return Offset.lerp(points[i], points[i + 1], frac)!;
  }
}

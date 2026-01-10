import 'package:flutter/material.dart';
import '../core/geo/eclipse_path.dart';

class EclipsePathPainter extends CustomPainter {
  final EclipsePath path;
  final double progress;

  EclipsePathPainter(this.path, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.points.isEmpty) return;

    final shadowPaint = Paint()
      ..color = const Color(0x3DFFFFFF)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final mainPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final shadowPath = Path();
    final mainPath = Path();

    for (int i = 0; i < path.points.length; i++) {
      final p = path.points[i];
      if (i == 0) {
        shadowPath.moveTo(p.dx, p.dy);
        mainPath.moveTo(p.dx, p.dy);
      } else {
        shadowPath.lineTo(p.dx, p.dy);
        mainPath.lineTo(p.dx, p.dy);
      }
    }

    canvas.drawPath(shadowPath, shadowPaint);

    final metrics = mainPath.computeMetrics().first;
    final partial = metrics.extractPath(0, metrics.length * progress);

    canvas.drawPath(partial, mainPaint);
  }

  @override
  bool shouldRepaint(covariant EclipsePathPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

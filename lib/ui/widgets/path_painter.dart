// lib/ui/widgets/path_painter.dart
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<List<double>> points;
  PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.plus;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (points[i][1] + 180) / 360 * size.width;
      final y = (90 - points[i][0]) / 180 * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class AnimatedPathPainter extends CustomPainter {
  final List<List<double>> points;
  final double progress;

  AnimatedPathPainter(this.points, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [Colors.amber, Colors.orange],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final maxIndex = (points.length * progress).clamp(1, points.length).toInt();

    for (int i = 0; i < maxIndex; i++) {
      final x = (points[i][1] + 180) / 360 * size.width;
      final y = (90 - points[i][0]) / 180 * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    /// Shadow head
    if (maxIndex > 0) {
      final last = points[maxIndex - 1];
      final dx = (last[1] + 180) / 360 * size.width;
      final dy = (90 - last[0]) / 180 * size.height;

      canvas.drawCircle(
        Offset(dx, dy),
        12,
        Paint()
          ..color = Colors.black
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedPathPainter old) =>
      old.progress != progress;
}

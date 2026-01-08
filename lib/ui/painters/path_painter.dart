import 'package:flutter/material.dart';

class EclipsePathPainter extends CustomPainter {
  final List<Offset> path;
  final double progress;

  EclipsePathPainter(this.path, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final p = Path();
    final end = (path.length * progress).floor();

    for (int i = 0; i < end; i++) {
      if (i == 0) {
        p.moveTo(path[i].dx, path[i].dy);
      } else {
        p.lineTo(path[i].dx, path[i].dy);
      }
    }

    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}

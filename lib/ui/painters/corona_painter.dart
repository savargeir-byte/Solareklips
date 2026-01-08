import 'package:flutter/material.dart';

class CoronaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    final corona = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.6));

    canvas.drawCircle(c, size.width * 0.6, corona);
  }

  @override
  bool shouldRepaint(_) => true;
}

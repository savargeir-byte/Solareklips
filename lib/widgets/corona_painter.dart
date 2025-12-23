import 'dart:math';

import 'package:flutter/material.dart';

/// Realistic corona effect with HDR glow and chromosphere red flash
class CoronaPainter extends CustomPainter {
  final double intensity; // 0..1 animation value
  final bool showChromosphere;

  CoronaPainter({
    this.intensity = 1.0,
    this.showChromosphere = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Corona glow with HDR effect using screen blend mode
    final coronaPaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withOpacity(0.25 * intensity),
          Colors.amber.withOpacity(0.06 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.6));

    canvas.drawCircle(center, size.width * 0.6, coronaPaint);

    // Chromosphere red flash (dynamic)
    if (showChromosphere) {
      final chromoPaint = Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.red.withOpacity(0.45 * intensity),
            Colors.red.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.3));

      canvas.drawCircle(center, size.width * 0.3, chromoPaint);
    }

    // Inner corona spikes (subtle)
    const spikeCount = 12;
    final spikePaint = Paint()
      ..color = Colors.amber.withOpacity(0.15 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < spikeCount; i++) {
      final angle = (i * 2 * 3.14159) / spikeCount;
      final startRadius = size.width * 0.15;
      final endRadius = size.width * 0.4;

      final start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );

      final end = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(start, end, spikePaint);
    }
  }

  @override
  bool shouldRepaint(CoronaPainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
        oldDelegate.showChromosphere != showChromosphere;
  }
}

/// Animated corona widget with pulsing effect
class AnimatedCorona extends StatefulWidget {
  final double size;
  final bool showChromosphere;

  const AnimatedCorona({
    super.key,
    this.size = 300,
    this.showChromosphere = true,
  });

  @override
  State<AnimatedCorona> createState() => _AnimatedCoronaState();
}

class _AnimatedCoronaState extends State<AnimatedCorona>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CoronaPainter(
            intensity: 0.7 + 0.3 * _controller.value,
            showChromosphere: widget.showChromosphere,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
          ),
        );
      },
    );
  }
}

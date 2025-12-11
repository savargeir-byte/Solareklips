import 'dart:ui';

import 'package:flutter/material.dart';

/// Interactive eclipse progress simulation using CustomPainter
/// Shows sun/moon alignment with smooth blend effects
class EclipseProgressSimulation extends StatefulWidget {
  final DateTime start;
  final DateTime peak;
  final DateTime end;
  final double height;

  const EclipseProgressSimulation({
    super.key,
    required this.start,
    required this.peak,
    required this.end,
    this.height = 220,
  });

  @override
  State<EclipseProgressSimulation> createState() =>
      _EclipseProgressSimulationState();
}

class _EclipseProgressSimulationState extends State<EclipseProgressSimulation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    // Subtle pulsing animation
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Update progress every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() {});
      return mounted;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _progress() {
    final now = DateTime.now().toUtc();
    final start = widget.start.toUtc();
    final end = widget.end.toUtc();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    final total = end.difference(start).inSeconds.toDouble();
    final elapsed = now.difference(start).inSeconds.toDouble().clamp(0, total);
    return elapsed / total;
  }

  double _peakProgress() {
    final start = widget.start.toUtc();
    final end = widget.end.toUtc();
    final peak = widget.peak.toUtc();
    final total = end.difference(start).inSeconds.toDouble();
    final peakElapsed = peak.difference(start).inSeconds.toDouble();
    return peakElapsed / total;
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress();
    final peakP = _peakProgress();

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ticker,
        builder: (context, _) {
          return CustomPaint(
            painter: _EclipsePainter(
              progress: p,
              peakProgress: peakP,
              pulse: _ticker.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _EclipsePainter extends CustomPainter {
  final double progress; // 0..1 (current event progress)
  final double peakProgress; // 0..1 (where peak occurs)
  final double pulse; // 0..1 (animation pulse)

  // Solar Eclipse Minimal colors
  static const kBlack = Color(0xFF000000);
  static const kGold = Color(0xFFE4B85F);
  static const kGoldDim = Color(0xFF8A7344);

  _EclipsePainter({
    required this.progress,
    required this.peakProgress,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);
    final sunR = size.height * 0.22 < 100.0 ? size.height * 0.22 : 100.0;
    final moonR = sunR * 0.98;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = kBlack,
    );

    // Sun glow (pulsing slightly)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          kGold.withOpacity(0.15 + 0.10 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: sunR * 2.5));
    canvas.drawCircle(center, sunR * 2.2, glowPaint);

    // Sun core with soft blur
    final sunPaint = Paint()
      ..color = kGold
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawCircle(center, sunR, sunPaint);

    // Moon sliding horizontally based on progress
    final startX = center.dx - sunR * 2.2;
    final endX = center.dx + sunR * 2.2;
    final moonX = lerpDouble(startX, endX, progress)!;
    final moonCenter = Offset(moonX, center.dy);

    // Moon (dark disc with slight blur)
    final moonPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(moonCenter, moonR, moonPaint);

    // Corona effect at maximum eclipse (near peak)
    final distanceFromPeak = (progress - peakProgress).abs();
    final coronaAlpha = (1.0 - distanceFromPeak * 2.5).clamp(0.0, 1.0);
    if (coronaAlpha > 0) {
      final coronaPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = kGold.withOpacity(0.8 * coronaAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(center, sunR + 8, coronaPaint);
    }

    // Timeline bar
    _drawTimeline(canvas, size, center, sunR);
  }

  void _drawTimeline(Canvas canvas, Size size, Offset center, double sunR) {
    final barTop = center.dy + sunR + 32;
    const barHeight = 10.0;
    const barPadding = 32.0;
    final barRect = Rect.fromLTWH(
      barPadding,
      barTop,
      size.width - barPadding * 2,
      barHeight,
    );

    // Background track
    final trackPaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(8)),
      trackPaint,
    );

    // Gradient progress fill
    final filledWidth = barRect.width * progress;
    final fillRect = Rect.fromLTWH(
      barRect.left,
      barRect.top,
      filledWidth,
      barRect.height,
    );

    if (filledWidth > 0) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            kGoldDim,
            kGold,
            kGold.withOpacity(0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(fillRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(8)),
        fillPaint,
      );
    }

    // Peak marker (gold dot)
    final peakX = barRect.left + barRect.width * peakProgress;
    final peakMarkerPaint = Paint()
      ..color = kGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(peakX, barRect.top - 6),
      5,
      peakMarkerPaint,
    );

    // Labels
    _drawLabel(canvas, 'Start', Offset(barRect.left, barRect.bottom + 12));
    _drawLabel(
      canvas,
      'Peak',
      Offset(peakX, barRect.bottom + 12),
      centered: true,
      bold: true,
    );
    _drawLabel(
      canvas,
      'End',
      Offset(barRect.right, barRect.bottom + 12),
      rightAlign: true,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position, {
    bool centered = false,
    bool rightAlign = false,
    bool bold = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(bold ? 0.95 : 0.7),
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    Offset paintOffset = position;
    if (centered) {
      paintOffset = Offset(position.dx - textPainter.width / 2, position.dy);
    } else if (rightAlign) {
      paintOffset = Offset(position.dx - textPainter.width, position.dy);
    }

    textPainter.paint(canvas, paintOffset);
  }

  @override
  bool shouldRepaint(covariant _EclipsePainter old) =>
      old.progress != progress || old.pulse != pulse;
}

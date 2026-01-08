import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// CustomPainter for rendering dynamic eclipse shadow on map
/// Renders penumbra (soft outer shadow) and umbra (solid center)
class EclipseShadowPainter extends CustomPainter {
  final Offset position; // Normalized position (0-1, 0-1)
  final double progress; // Eclipse progress 0-1
  final double scale; // Shadow size multiplier
  final double rotation; // Rotation in degrees

  EclipseShadowPainter({
    required this.position,
    required this.progress,
    required this.scale,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(
      position.dx * size.width,
      position.dy * size.height,
    );

    // SHADOW SIZE (scales with progress)
    final baseUmbraRadius = 80.0 * scale;
    final basePenumbraRadius = 200.0 * scale;

    final umbraRadius = baseUmbraRadius * (0.5 + progress * 0.5);
    final penumbraRadius = basePenumbraRadius * (0.7 + progress * 0.3);

    // Save canvas state
    canvas.save();

    // Apply rotation around center
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 3.14159 / 180);
    canvas.translate(-center.dx, -center.dy);

    // PENUMBRA (soft outer shadow)
    final penumbraPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        penumbraRadius,
        [
          Colors.black.withOpacity(0.45 * progress),
          Colors.black.withOpacity(0.25 * progress),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      )
      ..blendMode = BlendMode.darken;

    canvas.drawCircle(center, penumbraRadius, penumbraPaint);

    // UMBRA (solid center shadow - totality zone)
    final umbraPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        umbraRadius,
        [
          Colors.black.withOpacity(0.92 * progress),
          Colors.black.withOpacity(0.75 * progress),
        ],
        [0.0, 1.0],
      )
      ..blendMode = BlendMode.srcOver;

    canvas.drawCircle(center, umbraRadius, umbraPaint);

    // CORONA GLOW (subtle gold ring at totality peak)
    if (progress > 0.4 && progress < 0.6) {
      final coronaAlpha = 1.0 - (0.5 - progress).abs() * 5;
      final coronaPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          umbraRadius + 15,
          [
            const Color(0xFFe4b85f).withOpacity(0.4 * coronaAlpha),
            const Color(0xFFe4b85f).withOpacity(0.2 * coronaAlpha),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        )
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(center, umbraRadius + 15, coronaPaint);
    }

    // Restore canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(EclipseShadowPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.progress != progress ||
        oldDelegate.scale != scale ||
        oldDelegate.rotation != rotation;
  }
}

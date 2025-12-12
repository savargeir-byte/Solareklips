import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'dart:ui' as ui;

/// Painter for animated path-of-totality tracing
class PathTracingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final List<geo.LatLng> path;
  final Color pathColor;
  final double strokeWidth;

  PathTracingPainter({
    required this.progress,
    required this.path,
    this.pathColor = Colors.orangeAccent,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    // Calculate how many points to draw based on progress
    final pointCount = (path.length * progress).ceil().clamp(0, path.length);
    if (pointCount < 2) return;

    final paint = Paint()
      ..color = pathColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Glow effect
    final glowPaint = Paint()
      ..color = pathColor.withOpacity(0.3)
      ..strokeWidth = strokeWidth * 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final pathPoints = path.take(pointCount).toList();

    // Convert LatLng to screen coordinates
    final screenPath = ui.Path();
    
    for (int i = 0; i < pathPoints.length; i++) {
      final point = _latLngToOffset(pathPoints[i], size);
      
      if (i == 0) {
        screenPath.moveTo(point.dx, point.dy);
      } else {
        screenPath.lineTo(point.dx, point.dy);
      }
    }

    // Draw glow
    canvas.drawPath(screenPath, glowPaint);
    
    // Draw main path
    canvas.drawPath(screenPath, paint);

    // Draw animated head marker
    if (pathPoints.isNotEmpty) {
      final headPoint = _latLngToOffset(pathPoints.last, size);
      
      final headPaint = Paint()
        ..color = pathColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(headPoint, strokeWidth * 2, headPaint);
      
      // Pulsing effect on head
      final pulsePaint = Paint()
        ..color = pathColor.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(headPoint, strokeWidth * 4, pulsePaint);
    }
  }

  Offset _latLngToOffset(geo.LatLng latLng, Size size) {
    // Simple equirectangular projection
    // Map latitude/longitude to canvas coordinates
    // This is a simplified version - for real maps use proper projection
    
    final x = ((latLng.longitude + 180) / 360) * size.width;
    final y = ((90 - latLng.latitude) / 180) * size.height;
    
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(PathTracingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.path != path;
  }
}

/// Animated widget for path-of-totality tracing
class AnimatedPathTracing extends StatefulWidget {
  final List<geo.LatLng> path;
  final Duration duration;
  final Color pathColor;
  final double strokeWidth;
  final bool repeat;

  const AnimatedPathTracing({
    super.key,
    required this.path,
    this.duration = const Duration(seconds: 10),
    this.pathColor = Colors.orangeAccent,
    this.strokeWidth = 3.0,
    this.repeat = true,
  });

  @override
  State<AnimatedPathTracing> createState() => _AnimatedPathTracingState();
}

class _AnimatedPathTracingState extends State<AnimatedPathTracing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
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
          painter: PathTracingPainter(
            progress: _controller.value,
            path: widget.path,
            pathColor: widget.pathColor,
            strokeWidth: widget.strokeWidth,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Advanced path painter with umbra/penumbra visualization
class ShadowPathPainter extends CustomPainter {
  final double progress;
  final List<geo.LatLng> centerline;
  final List<geo.LatLng> umbraPath;
  final List<geo.LatLng> penumbraPath;

  ShadowPathPainter({
    required this.progress,
    required this.centerline,
    this.umbraPath = const [],
    this.penumbraPath = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw penumbra (outer shadow)
    if (penumbraPath.isNotEmpty) {
      final penumbraPoints = _convertPath(penumbraPath, size, progress);
      if (penumbraPoints.length > 2) {
        final penumbraPathObj = ui.Path();
        penumbraPathObj.moveTo(penumbraPoints.first.dx, penumbraPoints.first.dy);
        for (int i = 1; i < penumbraPoints.length; i++) {
          penumbraPathObj.lineTo(penumbraPoints[i].dx, penumbraPoints[i].dy);
        }
        penumbraPathObj.close();
        
        final penumbraPaint = Paint()
          ..color = Colors.amber.withOpacity(0.15)
          ..style = PaintingStyle.fill;
        
        canvas.drawPath(penumbraPathObj, penumbraPaint);
      }
    }

    // Draw umbra (inner shadow)
    if (umbraPath.isNotEmpty) {
      final umbraPoints = _convertPath(umbraPath, size, progress);
      if (umbraPoints.length > 2) {
        final umbraPathObj = ui.Path();
        umbraPathObj.moveTo(umbraPoints.first.dx, umbraPoints.first.dy);
        for (int i = 1; i < umbraPoints.length; i++) {
          umbraPathObj.lineTo(umbraPoints[i].dx, umbraPoints[i].dy);
        }
        umbraPathObj.close();
        
        final umbraPaint = Paint()
          ..color = const Color(0xFFE4B85F).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawPath(umbraPathObj, umbraPaint);
      }
    }

    // Draw centerline
    final centerPoints = _convertPath(centerline, size, progress);
    if (centerPoints.length > 1) {
      final pathObj = ui.Path();
      pathObj.moveTo(centerPoints.first.dx, centerPoints.first.dy);
      for (int i = 1; i < centerPoints.length; i++) {
        pathObj.lineTo(centerPoints[i].dx, centerPoints[i].dy);
      }

      final centerPaint = Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(pathObj, centerPaint);
    }
  }

  List<Offset> _convertPath(List<geo.LatLng> path, Size size, double progress) {
    final pointCount = (path.length * progress).ceil().clamp(0, path.length);
    return path
        .take(pointCount)
        .map((latLng) => _latLngToOffset(latLng, size))
        .toList();
  }

  Offset _latLngToOffset(geo.LatLng latLng, Size size) {
    final x = ((latLng.longitude + 180) / 360) * size.width;
    final y = ((90 - latLng.latitude) / 180) * size.height;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(ShadowPathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

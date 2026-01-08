import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

/// Widget that distorts eclipse shadow based on device tilt using accelerometer
class TiltableShadowWidget extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;

  const TiltableShadowWidget({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.3, // Maximum tilt effect in radians (~17 degrees)
  });

  @override
  State<TiltableShadowWidget> createState() => _TiltableShadowWidgetState();
}

class _TiltableShadowWidgetState extends State<TiltableShadowWidget> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (mounted) {
        setState(() {
          // Normalize accelerometer values (-10 to 10 typical) to tilt angle
          _tiltX = (event.x / 10.0).clamp(-1.0, 1.0) * widget.maxTiltAngle;
          _tiltY = (event.y / 10.0).clamp(-1.0, 1.0) * widget.maxTiltAngle;
        });
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(_tiltY)
        ..rotateY(-_tiltX),
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}

/// CustomPainter for eclipse shadow with tilt distortion support
class TiltedShadowPainter extends CustomPainter {
  final Offset position;
  final double progress;
  final double scale;
  final double rotation;
  final double tiltX;
  final double tiltY;

  TiltedShadowPainter({
    required this.position,
    required this.progress,
    required this.scale,
    required this.rotation,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shadowRadius = 150.0 * scale;

    // Apply tilt transformation
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Apply perspective-like skew based on tilt
    final skewMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(tiltY)
      ..rotateY(-tiltX);

    canvas.transform(skewMatrix.storage);
    canvas.translate(-center.dx, -center.dy);

    // Draw umbra (total shadow)
    final umbraPaint = Paint()
      ..color = Colors.black.withOpacity(0.7 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

    canvas.drawCircle(
      position,
      shadowRadius * 0.6,
      umbraPaint,
    );

    // Draw penumbra (partial shadow)
    final penumbraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withOpacity(0.3 * progress),
          Colors.transparent,
        ],
        stops: const [0.6, 1.0],
      ).createShader(
        Rect.fromCircle(center: position, radius: shadowRadius),
      );

    canvas.drawCircle(
      position,
      shadowRadius,
      penumbraPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(TiltedShadowPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.progress != progress ||
        oldDelegate.scale != scale ||
        oldDelegate.rotation != rotation ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY;
  }
}

/// Example usage widget combining tilt detection with shadow painting
class TiltShadowDemo extends StatefulWidget {
  const TiltShadowDemo({super.key});

  @override
  State<TiltShadowDemo> createState() => _TiltShadowDemoState();
}

class _TiltShadowDemoState extends State<TiltShadowDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Listen to accelerometer
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (mounted) {
        setState(() {
          _tiltX = (event.x / 10.0).clamp(-1.0, 1.0);
          _tiltY = (event.y / 10.0).clamp(-1.0, 1.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tilt your device',
              style: TextStyle(color: Colors.amber[200], fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'X: ${_tiltX.toStringAsFixed(2)} Y: ${_tiltY.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 300,
              height: 300,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: TiltedShadowPainter(
                      position: const Offset(150, 150),
                      progress: _controller.value,
                      scale: 1.0,
                      rotation: 0.0,
                      tiltX: _tiltX * 0.3,
                      tiltY: _tiltY * 0.3,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

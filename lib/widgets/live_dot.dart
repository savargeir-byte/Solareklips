import 'package:flutter/material.dart';

import '../core/geo/eclipse_path.dart';

class LiveDot extends StatelessWidget {
  final EclipsePath path;
  final double progress;

  const LiveDot({super.key, required this.path, required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = path.pointAt(progress);

    return Positioned(
      left: p.dx - 6,
      top: p.dy - 6,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withOpacity(0.6),
              blurRadius: 12,
            )
          ],
        ),
      ),
    );
  }
}

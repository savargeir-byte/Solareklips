// lib/ui/widgets/eclipse_rive.dart
import 'package:flutter/material.dart';

class EclipseRive extends StatelessWidget {
  final bool totality;
  const EclipseRive({super.key, required this.totality});

  @override
  Widget build(BuildContext context) {
    // Placeholder until eclipse.riv is created
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: totality
              ? [
                  Colors.black,
                  Colors.amber.withOpacity(0.3),
                  Colors.black,
                ]
              : [
                  Colors.amber,
                  Colors.orange,
                  Colors.black,
                ],
          radius: 0.8,
        ),
      ),
      child: Center(
        child: Icon(
          totality ? Icons.brightness_1 : Icons.brightness_2,
          size: 120,
          color: totality ? Colors.white : Colors.amber,
        ),
      ),
    );
  }
}

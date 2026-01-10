import 'package:flutter/material.dart';
import '../core/education/education_timeline.dart';

class EducationScrubberText extends StatelessWidget {
  final double progress;

  const EducationScrubberText({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        EducationTimeline.explain(progress),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }
}

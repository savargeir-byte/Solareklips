import 'package:flutter/material.dart';

class PathScrubber extends StatelessWidget {
  final double progress;
  final ValueChanged<double> onChanged;

  const PathScrubber({
    super.key,
    required this.progress,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.amber,
        inactiveTrackColor: Colors.white24,
        thumbColor: Colors.amber,
      ),
      child: Slider(
        value: progress,
        min: 0,
        max: 1,
        onChanged: onChanged,
      ),
    );
  }
}

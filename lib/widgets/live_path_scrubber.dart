import 'package:flutter/material.dart';

import '../core/pro/pro_state.dart';

class LivePathScrubber extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const LivePathScrubber({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!ProState.isPro) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "🔒 Unlock PRO to explore the eclipse timeline",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0x61FFFFFF),
            fontSize: 14,
          ),
        ),
      );
    }

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: const Color(0xFFFFC107),
        inactiveTrackColor: const Color(0x3DFFFFFF),
        thumbColor: const Color(0xFFFFC107),
        overlayColor: const Color(0x33FFC107),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: 0,
        max: 1,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';

class EclipseCountdown extends StatelessWidget {
  final EclipseEvent event;
  final VoidCallback onTap;

  const EclipseCountdown({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final remaining = event.peak.difference(DateTime.now().toUtc());

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text("Next Eclipse"),
          Text(
            "${remaining.inDays}d ${remaining.inHours % 24}h",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}

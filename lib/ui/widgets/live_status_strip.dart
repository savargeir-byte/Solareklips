import 'package:flutter/material.dart';
import '../../core/models/eclipse_event_simple.dart';

class LiveStatusStrip extends StatelessWidget {
  final EclipseEventSimple event;
  const LiveStatusStrip({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (now.isBefore(event.startTime)) {
      final daysUntil = event.startTime.difference(now).inDays;
      statusText = daysUntil > 1 
          ? "Moon approaching Sun — $daysUntil days until first contact"
          : "Eclipse begins tomorrow!";
      statusColor = Colors.white54;
      statusIcon = Icons.schedule;
    } else if (now.isBefore(event.peakTime)) {
      statusText = "Partial eclipse in progress";
      statusColor = Colors.orangeAccent;
      statusIcon = Icons.brightness_5;
    } else if (now.isBefore(event.endTime)) {
      final minsRemaining = event.endTime.difference(now).inMinutes;
      if (minsRemaining < 5) {
        statusText = "TOTALITY — look up now!";
        statusColor = Colors.redAccent;
        statusIcon = Icons.brightness_1;
      } else {
        statusText = "Eclipse ending phase";
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.brightness_6;
      }
    } else {
      statusText = "Eclipse ended — see you next time";
      statusColor = Colors.white38;
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/ui/widgets/hero_today_card.dart
import 'package:flutter/material.dart';
import '../../core/services/eclipse_engine.dart';
import '../../features/events/event_detail_screen_simple.dart';
import 'live_countdown_text.dart';

class HeroTodayCard extends StatelessWidget {
  const HeroTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EclipseEngine.getNextEvent(DateTime.now());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreenSimple(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Colors.amber, Colors.black],
            radius: 1.2,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NEXT BIG EVENT",
                style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Text(event.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 16),
            LiveCountdownText(target: event.peakTime),
          ],
        ),
      ),
    );
  }
}

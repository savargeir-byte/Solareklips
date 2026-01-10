// lib/ui/widgets/hero_today_card.dart
import 'package:flutter/material.dart';

class HeroTodayCard extends StatelessWidget {
  final String moonPhase;
  final String nextEvent;

  const HeroTodayCard({
    super.key,
    required this.moonPhase,
    required this.nextEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2417), Color(0xFF000000)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TODAY IN THE SKY",
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("Moon phase: $moonPhase",
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          Text("Next visible event: $nextEvent",
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

// lib/features/home/home_screen_simple_demo.dart
import 'package:flutter/material.dart';
import '../../core/models/eclipse_event_simple.dart';
import '../../core/services/eclipse_engine.dart';
import '../../ui/widgets/hero_today_card.dart';
import '../../ui/widgets/next_big_event_card.dart';
import '../events/event_detail_screen_simple.dart';

/// Demo screen showing the simplified architecture components
class HomeScreenSimpleDemo extends StatelessWidget {
  const HomeScreenSimpleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final events = [
      EclipseEventSimple(
        id: '2026-iceland',
        title: '2026 Total Solar Eclipse',
        type: 'solar',
        subtype: 'total',
        start: DateTime(2026, 8, 12, 16, 30),
        peak: DateTime(2026, 8, 12, 17, 45),
        end: DateTime(2026, 8, 12, 19, 0),
        visibleFrom: ['Iceland', 'Greenland', 'Spain'],
        isMajor: true,
      ),
      EclipseEventSimple(
        id: '2027-spain',
        title: '2027 Total Solar Eclipse',
        type: 'solar',
        subtype: 'total',
        start: DateTime(2027, 8, 2, 8, 30),
        peak: DateTime(2027, 8, 2, 10, 15),
        end: DateTime(2027, 8, 2, 12, 0),
        visibleFrom: ['Spain', 'Morocco', 'Algeria'],
        isMajor: true,
      ),
    ];

    final nextEvent = EclipseEngine.getNextBigEvent(events);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Simplified Architecture Demo'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Hero Today Card
          const HeroTodayCard(
            moonPhase: 'Waxing Crescent 🌒',
            nextEvent: 'Aug 12, 2026',
          ),

          // Next Big Event Card
          NextBigEventCard(
            event: nextEvent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreenSimple(event: nextEvent),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Architecture Info',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '✅ EclipseEventSimple model\n'
                  '✅ EclipseEngine service\n'
                  '✅ HeroTodayCard widget\n'
                  '✅ NextBigEventCard widget\n'
                  '✅ EventDetailScreenSimple\n'
                  '✅ PhotographerModeScreenSimple\n'
                  '✅ PaywallSheetSimple',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

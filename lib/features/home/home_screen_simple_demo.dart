// lib/features/home/home_screen_simple_demo.dart
import 'package:flutter/material.dart';
import '../../core/services/eclipse_engine.dart';
import '../../core/education/education_state.dart';
import '../../ui/widgets/hero_today_card.dart';

/// Demo screen showing the simplified architecture components
class HomeScreenSimpleDemo extends StatelessWidget {
  const HomeScreenSimpleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = EclipseEngine.timeline(years: 5);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Eclipse Countdown'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Hero Today Card (tappable countdown)
          const HeroTodayCard(),

          const SizedBox(height: 16),

          // Education Mode Toggle
          AnimatedBuilder(
            animation: EducationState.instance,
            builder: (context, _) {
              return SwitchListTile(
                title: const Text(
                  "Education Mode",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "Learn what is happening and why",
                  style: TextStyle(color: Colors.white54),
                ),
                value: EducationState.instance.enabled,
                onChanged: (v) => EducationState.instance.toggle(v),
              );
            },
          ),

          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPCOMING EVENTS',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ...timeline.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${event.peakTime.year} • ${event.title}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ FEATURES',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '✅ Countdown → tappable → detail\n'
                  '✅ Next Big Event logic\n'
                  '✅ Timeline-ready engine\n'
                  '✅ GeoJSON path drawing\n'
                  '✅ Photographer Mode foundation\n'
                  '✅ No backend\n'
                  '✅ No paywall',
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

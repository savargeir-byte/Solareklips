// lib/features/home/home_screen_simple_demo.dart
import 'package:flutter/material.dart';
import '../../core/services/eclipse_engine.dart';
import '../../core/education/education_state.dart';
import '../../core/photo/photographer_engine.dart';
import '../../ui/widgets/hero_today_card.dart';
import '../../ui/widgets/live_status_strip.dart';
import '../events/event_detail_screen_simple.dart';

/// Demo screen showing the simplified architecture components
class HomeScreenSimpleDemo extends StatelessWidget {
  const HomeScreenSimpleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = EclipseEngine.timeline(years: 5);
    final nextEvent = EclipseEngine.getNextEvent(DateTime.now());

    return AnimatedBuilder(
      animation: EducationState.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Eclipse Countdown'),
            backgroundColor: Colors.transparent,
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: EducationState.instance.enabled
                  ? LinearGradient(
                      colors: [Colors.black, Colors.blueGrey.shade900],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Colors.black, Colors.black],
                    ),
            ),
            child: ListView(
              children: [
                const SizedBox(height: 16),

                // Hero Today Card (tappable countdown)
                const HeroTodayCard(),

                // Live Status Strip
                LiveStatusStrip(event: nextEvent),

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

                // Photographer Mode Toggle
                SwitchListTile(
                  title: const Text(
                    "Photographer Mode Auto-Trigger",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Alert when Diamond Ring appears",
                    style: TextStyle(color: Colors.white54),
                  ),
                  value: PhotographerEngine.enabled,
                  onChanged: (v) {
                    PhotographerEngine.enabled = v;
                    (context as Element).markNeedsBuild();
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
                      ...timeline.map((event) => _eventRow(
                            context,
                            '${event.peakTime.year} • ${event.title}',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailScreenSimple(event: event),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _eventRow(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.public, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

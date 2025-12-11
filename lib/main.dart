import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/event_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'widgets/eclipse_progress_simulation.dart';

void main() {
  runApp(const ProviderScope(child: EclipseMapApp()));
}

// Solar Eclipse Minimal color palette
const Color kBlack = Color(0xFF000000);
const Color kDarkGray = Color(0xFF1a1a1a);
const Color kGold = Color(0xFFe4b85f);
const Color kGoldDim = Color(0xFF8a7344);

class EclipseMapApp extends StatelessWidget {
  const EclipseMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EclipseMap',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('is')],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBlack,
        primaryColor: kGold,
        colorScheme: const ColorScheme.dark(
          primary: kGold,
          secondary: kGold,
          surface: kDarkGray,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              color: kGold, fontWeight: FontWeight.w300, fontSize: 32),
          headlineMedium: TextStyle(
              color: kGold, fontWeight: FontWeight.w400, fontSize: 24),
          bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: kGold,
            side: const BorderSide(color: kGold, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              kDarkGray.withOpacity(0.3),
              kBlack,
              kBlack,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // Live Eclipse Progress Simulation
                  SizedBox(
                    height: 240,
                    child: EclipseProgressSimulation(
                      start: DateTime(2026, 4, 12, 14, 30),
                      peak: DateTime(2026, 4, 12, 15, 0),
                      end: DateTime(2026, 4, 12, 15, 30),
                      height: 240,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event title
                  Text(
                    'Iceland 2026',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Solar Eclipse',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Countdown
                  const CountdownWidget(),

                  const SizedBox(height: 48),

                  // Icon grid
                  const IconGrid(),

                  const SizedBox(height: 40),

                  // Full path button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventListScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See Full Path →',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Eclipse illustration widget with gold corona and black moon
class EclipseIllustration extends StatelessWidget {
  const EclipseIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: EclipsePainter(),
    );
  }
}

class EclipsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Gold corona (outer glow)
    final coronaPaint = Paint()
      ..color = kGold.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        center,
        radius + (i * 15),
        coronaPaint..color = kGold.withOpacity(0.1 * i),
      );
    }

    // Gold ring (sun)
    final sunPaint = Paint()
      ..color = kGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, sunPaint);

    // Black moon (covering sun)
    final moonPaint = Paint()
      ..color = kBlack
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center.translate(5, -5), radius - 8, moonPaint);

    // Moon outline
    final moonOutlinePaint = Paint()
      ..color = kGoldDim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center.translate(5, -5), radius - 8, moonOutlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Countdown widget
class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real countdown calculation
    final targetDate = DateTime(2026, 4, 12, 15, 0);
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    return Column(
      children: [
        Text(
          'Countdown',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                color: kGoldDim,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CountdownUnit(value: days, label: 'DAYS'),
            const SizedBox(width: 24),
            _CountdownUnit(value: hours, label: 'HRS'),
            const SizedBox(width: 24),
            _CountdownUnit(value: minutes, label: 'MIN'),
          ],
        ),
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: kGold,
            fontSize: 48,
            fontWeight: FontWeight.w300,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: kGoldDim,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// Icon grid for navigation
class IconGrid extends StatelessWidget {
  const IconGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _IconButton(
          icon: Icons.wb_sunny_outlined,
          label: 'Solar',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventListScreen(),
              ),
            );
          },
        ),
        _IconButton(
          icon: Icons.nightlight_outlined,
          label: 'Lunar',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventListScreen(),
              ),
            );
          },
        ),
        _IconButton(
          icon: Icons.map_outlined,
          label: 'Map',
          onTap: () {
            // TODO: Navigate to map with Iceland event
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventListScreen(),
              ),
            );
          },
        ),
        _IconButton(
          icon: Icons.star_outline,
          label: 'Favorites',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _IconButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: kGold.withOpacity(0.3), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: kGold,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: kGoldDim,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

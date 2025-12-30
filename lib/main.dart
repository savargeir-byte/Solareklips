import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'models/eclipse_event.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_list_screen.dart';
import 'screens/map_screen.dart';
import 'services/admob_service.dart';
import 'services/theme_service.dart';
import 'widgets/eclipse_progress_simulation.dart';
import 'widgets/photography_assistant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Handle GDPR/CCPA consent before initializing AdMob
  await AdMobService.requestConsent();
  
  await AdMobService.initialize();
  print('📱 AdMob initialized');
  
  runApp(const ProviderScope(child: EclipseMapApp()));
}

// Solar Eclipse Minimal color palette
const Color kBlack = Color(0xFF000000);
const Color kDarkGray = Color(0xFF1a1a1a);
const Color kGold = Color(0xFFe4b85f);
const Color kGoldDim = Color(0xFF8a7344);

class EclipseMapApp extends ConsumerWidget {
  const EclipseMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'EclipseMap',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: EclipseTheme.lightTheme,
      darkTheme: EclipseTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('is')],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (ad) {
        setState(() {
          _isBannerLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _bannerAd = null;
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: kGold,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: kGold),
            onPressed: () {
              _showSettingsSheet(context);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
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

                  // Countdown (tappable)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(
                            event: EclipseEvent(
                              id: 'iceland-2026',
                              type: EclipseType.solar,
                              subtype: EclipseSubtype.total,
                              startUtc: DateTime(2026, 4, 12, 14, 30).toUtc(),
                              peakUtc: DateTime(2026, 4, 12, 15, 0).toUtc(),
                              endUtc: DateTime(2026, 4, 12, 15, 30).toUtc(),
                              pathGeoJson: '',
                              visibilityRegions: ['Iceland'],
                              description:
                                  'Total Solar Eclipse visible from Iceland',
                              magnitude: 1.00,
                              maxDurationSeconds: 180,
                              centerlineCoords: [64.9631, -19.0208],
                            ),
                          ),
                        ),
                      );
                    },
                    child: const CountdownWidget(),
                  ),

                  const SizedBox(height: 48),

                  // Icon grid
                  const IconGrid(),

                  const SizedBox(height: 40),

                  // Time Travel Mode button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailScreen(
                              event: EclipseEvent(
                                id: 'iceland-2026',
                                type: EclipseType.solar,
                                subtype: EclipseSubtype.total,
                                startUtc: DateTime(2026, 4, 12, 14, 30),
                                peakUtc: DateTime(2026, 4, 12, 15, 0),
                                endUtc: DateTime(2026, 4, 12, 15, 30),
                                pathGeoJson: 'iceland_2026',
                                visibilityRegions: ['Iceland', 'Greenland'],
                                description: 'Total Solar Eclipse over Iceland',
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Full path button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventListScreen(initialTab: 0),
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

                  // AdMob Banner
                  if (_isBannerLoaded && _bannerAd != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        height: 50,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      },
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
class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late DateTime targetDate;
  late Duration difference;
  
  @override
  void initState() {
    super.initState();
    targetDate = DateTime(2026, 4, 12, 15, 0);
    _updateCountdown();
    // Update every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateCountdown();
        return true;
      }
      return false;
    });
  }

  void _updateCountdown() {
    if (mounted) {
      setState(() {
        difference = targetDate.difference(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

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
            const SizedBox(width: 24),
            _CountdownUnit(value: seconds, label: 'SEC'),
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
                builder: (context) => const EventListScreen(initialTab: 0),
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
                builder: (context) => const EventListScreen(initialTab: 1),
              ),
            );
          },
        ),
        _IconButton(
          icon: Icons.map_outlined,
          label: 'Map',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  event: EclipseEvent(
                    id: 'iceland-2026',
                    type: EclipseType.solar,
                    subtype: EclipseSubtype.total,
                    startUtc: DateTime(2026, 4, 12, 14, 30),
                    peakUtc: DateTime(2026, 4, 12, 15, 0),
                    endUtc: DateTime(2026, 4, 12, 15, 30),
                    pathGeoJson: 'iceland_2026',
                    visibilityRegions: ['Iceland'],
                    description: 'Total Solar Eclipse',
                  ),
                ),
              ),
            );
          },
        ),
        _IconButton(
          icon: Icons.camera_alt_outlined,
          label: 'Camera',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PhotographyAssistant(
                event: EclipseEvent(
                  id: 'iceland-2026',
                  type: EclipseType.solar,
                  subtype: EclipseSubtype.total,
                  startUtc: DateTime(2026, 4, 12, 14, 30),
                  peakUtc: DateTime(2026, 4, 12, 15, 0),
                  endUtc: DateTime(2026, 4, 12, 15, 30),
                  pathGeoJson: 'iceland_2026',
                  visibilityRegions: ['Iceland'],
                  description: 'Total Solar Eclipse',
                ),
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

void _showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: kGold),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: kGold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: kGold),
            title: const Text('Notifications'),
            subtitle: const Text('Eclipse countdown alerts'),
            trailing: const Icon(Icons.chevron_right, color: kGoldDim),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: kGold),
            title: const Text('About'),
            subtitle: const Text('App version and info'),
            trailing: const Icon(Icons.chevron_right, color: kGoldDim),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'EclipseMap',
                applicationVersion: '2.0.0',
                applicationLegalese: '© 2025 Premium Eclipse Features',
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

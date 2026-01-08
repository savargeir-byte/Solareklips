import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:eclipse_map/core/constants.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';
import 'package:eclipse_map/core/services/admob_service.dart';
import 'package:eclipse_map/core/services/eclipse_repository.dart';
import 'package:eclipse_map/features/events/event_detail_screen.dart';
import 'package:eclipse_map/ui/theme/theme_service.dart';
import 'package:eclipse_map/ui/widgets/next_big_event_card.dart';
import 'package:eclipse_map/ui/widgets/timeline_list.dart';

// Provider for loading events
final eventsProvider = FutureProvider<List<EclipseEvent>>((ref) async {
  final repository = EclipseRepository();
  return repository.loadEvents();
});

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
        final eventsAsync = ref.watch(eventsProvider);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Eclipse Timeline',
              style: TextStyle(color: AppColors.gold),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: AppColors.gold,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  AppColors.darkGray.withOpacity(0.3),
                  AppColors.black,
                  AppColors.black,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: eventsAsync.when(
                data: (events) {
                  final timelineEvents = getTimelineEvents(events);
                  final nextBigEvent =
                      timelineEvents.isNotEmpty ? timelineEvents.first : null;

                  return CustomScrollView(
                    slivers: [
                      // Hero card - Next Big Event
                      if (nextBigEvent != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: NextBigEventCard(
                              event: nextBigEvent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                      event: nextBigEvent,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Section header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'UPCOMING ECLIPSES (5 YEARS)',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.gold),
                          ),
                        ),
                      ),

                      // Timeline list (excluding first event shown in hero card)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Skip first event (shown in hero card)
                            final event = timelineEvents[index + 1];
                            return ListTile(
                              title: Text(event.visibility),
                              subtitle: Text(
                                '${event.peak.year} · ${_formatDate(event.peak)}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                      event: event,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: timelineEvents.length > 1
                              ? timelineEvents.length - 1
                              : 0,
                        ),
                      ),

                      // Banner ad at bottom
                      if (_isBannerLoaded && _bannerAd != null)
                        SliverToBoxAdapter(
                          child: Container(
                            alignment: Alignment.center,
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading events: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

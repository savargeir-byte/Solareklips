import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:latlong2/latlong.dart';

import '../models/eclipse_event.dart';
import '../services/admob_service.dart';
import '../widgets/geojson_map_widget.dart';

/// Interactive map screen showing eclipse path overlay
/// Uses GeoJsonMapWidget for rendering centerline, umbra, and penumbra
class MapScreen extends StatefulWidget {
  final EclipseEvent event;

  const MapScreen({required this.event, super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
    // Use pathGeoJsonFile if available, otherwise fallback to default Iceland path
    final assetPath =
        widget.event.pathGeoJsonFile ?? 'assets/geo/2026_iceland_path.json';

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          '${widget.event.title} - Map',
          style: const TextStyle(color: Color(0xFFE4B85F)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE4B85F)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GeoJsonMapWidget(
              assetPath: assetPath,
              fallbackCenter: widget.event.centerlineCoords != null
                  ? LatLng(
                      widget.event.centerlineCoords![0],
                      widget.event.centerlineCoords![1],
                    )
                  : LatLng(64.1466, -21.9426), // Default to Reykjavik
              zoom: 5.5,
            ),
          ),
          if (_isBannerLoaded && _bannerAd != null)
            Container(
              height: 50,
              color: Colors.black12,
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

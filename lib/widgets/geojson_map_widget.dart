import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget for rendering GeoJSON eclipse paths on flutter_map
/// Supports centerline (polyline), umbra (totality polygon), and penumbra (partial polygon)
class GeoJsonMapWidget extends StatefulWidget {
  final String assetPath;
  final LatLng fallbackCenter;
  final double zoom;

  GeoJsonMapWidget({
    required this.assetPath,
    LatLng? fallbackCenter,
    this.zoom = 5.5,
    super.key,
  }) : fallbackCenter = fallbackCenter ?? LatLng(64.1466, -21.9426);

  @override
  State<GeoJsonMapWidget> createState() => _GeoJsonMapWidgetState();
}

class _GeoJsonMapWidgetState extends State<GeoJsonMapWidget> {
  List<LatLng> centerline = [];
  List<LatLng> umbra = [];
  List<LatLng> penumbra = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle.loadString(widget.assetPath);
      final map = json.decode(raw) as Map<String, dynamic>;
      final features = (map['features'] as List<dynamic>);

      for (var f in features) {
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final geom = f['geometry'] as Map<String, dynamic>;
        final type = geom['type'] as String;

        if (type == 'LineString' && props['feature_type'] == 'centerline') {
          final coords = geom['coordinates'] as List<dynamic>;
          centerline = coords
              .map((c) => LatLng(
                    (c[1] as num).toDouble(), // lat
                    (c[0] as num).toDouble(), // lon
                  ))
              .toList();
        } else if (type == 'Polygon' && props['feature_type'] == 'umbra') {
          final rings = geom['coordinates'] as List<dynamic>;
          final outer = rings[0] as List<dynamic>;
          umbra = outer
              .map((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();
        } else if (type == 'Polygon' && props['feature_type'] == 'penumbra') {
          final rings = geom['coordinates'] as List<dynamic>;
          final outer = rings[0] as List<dynamic>;
          penumbra = outer
              .map((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load GeoJSON: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE4B85F)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final center = centerline.isNotEmpty
        ? centerline[(centerline.length / 2).floor()]
        : widget.fallbackCenter;

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: widget.zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.eclipse_map',
        ),

        // Penumbra (partial) - light amber fill
        if (penumbra.isNotEmpty)
          PolygonLayer(
            polygons: [
              Polygon(
                points: penumbra,
                color: Colors.amber.withOpacity(0.12),
                borderColor: Colors.amber.withOpacity(0.45),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),

        // Umbra (totality) - stronger fill with gold color
        if (umbra.isNotEmpty)
          PolygonLayer(
            polygons: [
              Polygon(
                points: umbra,
                color: const Color(0xFFE4B85F).withOpacity(0.28),
                borderColor: const Color(0xFFE4B85F),
                borderStrokeWidth: 2.0,
              ),
            ],
          ),

        // Centerline - orange accent line
        if (centerline.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: centerline,
                color: Colors.orangeAccent,
                strokeWidth: 3.0,
              ),
            ],
          ),

        // Optional: Markers on start/end points
        if (centerline.isNotEmpty)
          MarkerLayer(
            markers: [
              Marker(
                point: centerline.first,
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Marker(
                point: centerline.last,
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

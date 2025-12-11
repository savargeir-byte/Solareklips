import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/eclipse_event.dart';
import '../widgets/geojson_map_widget.dart';

/// Interactive map screen showing eclipse path overlay
/// Uses GeoJsonMapWidget for rendering centerline, umbra, and penumbra
class MapScreen extends StatelessWidget {
  final EclipseEvent event;

  const MapScreen({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    // Use pathGeoJsonFile if available, otherwise fallback to default Iceland path
    final assetPath =
        event.pathGeoJsonFile ?? 'assets/geo/2026_iceland_path.json';

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          '${event.title} - Map',
          style: const TextStyle(color: Color(0xFFE4B85F)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE4B85F)),
      ),
      body: GeoJsonMapWidget(
        assetPath: assetPath,
        fallbackCenter: event.centerlineCoords != null
            ? LatLng(
                event.centerlineCoords![0],
                event.centerlineCoords![1],
              )
            : LatLng(64.1466, -21.9426), // Default to Reykjavik
        zoom: 5.5,
      ),
    );
  }
}

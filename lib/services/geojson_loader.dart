import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// Service for loading and parsing GeoJSON data for eclipse paths
class GeoJsonLoader {
  /// Load GeoJSON from asset file and parse coordinates
  /// Returns list of LatLng points for polygon/line rendering
  Future<List<LatLng>> loadPathFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      return _extractCoordinates(data);
    } catch (e) {
      print('Error loading GeoJSON from $assetPath: $e');
      return [];
    }
  }

  /// Parse GeoJSON string and extract coordinates
  List<LatLng> parseGeoJsonString(String geoJsonString) {
    try {
      final data = json.decode(geoJsonString) as Map<String, dynamic>;
      return _extractCoordinates(data);
    } catch (e) {
      print('Error parsing GeoJSON string: $e');
      return [];
    }
  }

  /// Extract coordinates from GeoJSON structure
  /// Supports Polygon, MultiPolygon, LineString, MultiLineString
  List<LatLng> _extractCoordinates(Map<String, dynamic> geoJson) {
    final List<LatLng> coords = [];

    // Check if it's a Feature or FeatureCollection
    if (geoJson.containsKey('type')) {
      final type = geoJson['type'] as String;

      if (type == 'FeatureCollection') {
        final features = geoJson['features'] as List;
        for (final feature in features) {
          coords.addAll(_extractFromGeometry(
              feature['geometry'] as Map<String, dynamic>));
        }
      } else if (type == 'Feature') {
        coords.addAll(
            _extractFromGeometry(geoJson['geometry'] as Map<String, dynamic>));
      } else {
        // Direct geometry
        coords.addAll(_extractFromGeometry(geoJson));
      }
    }

    return coords;
  }

  /// Extract coordinates from a geometry object
  List<LatLng> _extractFromGeometry(Map<String, dynamic> geometry) {
    final List<LatLng> coords = [];
    final type = geometry['type'] as String;
    final coordinates = geometry['coordinates'];

    switch (type) {
      case 'Polygon':
        // Polygon: [ [[lon, lat], [lon, lat], ...] ]
        final rings = coordinates as List;
        if (rings.isNotEmpty) {
          final outerRing = rings[0] as List;
          coords.addAll(_parseCoordinateList(outerRing));
        }
        break;

      case 'MultiPolygon':
        // MultiPolygon: [ [[[lon, lat]...]], [[[lon, lat]...]] ]
        final polygons = coordinates as List;
        for (final polygon in polygons) {
          final rings = polygon as List;
          if (rings.isNotEmpty) {
            final outerRing = rings[0] as List;
            coords.addAll(_parseCoordinateList(outerRing));
          }
        }
        break;

      case 'LineString':
        // LineString: [[lon, lat], [lon, lat], ...]
        coords.addAll(_parseCoordinateList(coordinates as List));
        break;

      case 'MultiLineString':
        // MultiLineString: [ [[lon, lat]...], [[lon, lat]...] ]
        final lines = coordinates as List;
        for (final line in lines) {
          coords.addAll(_parseCoordinateList(line as List));
        }
        break;

      case 'Point':
        // Point: [lon, lat]
        final point = coordinates as List;
        coords.add(LatLng(
          (point[1] as num).toDouble(),
          (point[0] as num).toDouble(),
        ));
        break;

      case 'MultiPoint':
        // MultiPoint: [[lon, lat], [lon, lat], ...]
        coords.addAll(_parseCoordinateList(coordinates as List));
        break;
    }

    return coords;
  }

  /// Parse list of coordinate pairs [lon, lat] to LatLng
  List<LatLng> _parseCoordinateList(List coordinates) {
    return coordinates.map((coord) {
      final c = coord as List;
      return LatLng(
        (c[1] as num).toDouble(), // latitude
        (c[0] as num).toDouble(), // longitude
      );
    }).toList();
  }

  /// Calculate bounding box from list of points
  /// Returns [minLat, minLng, maxLat, maxLng]
  List<double> calculateBounds(List<LatLng> points) {
    if (points.isEmpty) return [0, 0, 0, 0];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return [minLat, minLng, maxLat, maxLng];
  }

  /// Calculate center point from bounds
  LatLng calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return LatLng(0, 0);

    final bounds = calculateBounds(points);
    return LatLng(
      (bounds[0] + bounds[2]) / 2, // avg lat
      (bounds[1] + bounds[3]) / 2, // avg lng
    );
  }
}

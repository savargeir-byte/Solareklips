import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';

class EclipseRepository {
  Future<List<EclipseEvent>> loadEvents() async {
    final raw = await rootBundle.loadString(''assets/data/eclipses.json'');
    final list = json.decode(raw) as List;
    return list.map((e) => EclipseEvent.fromJson(e)).toList();
  }
}

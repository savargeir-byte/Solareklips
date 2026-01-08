import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eclipse_map/app.dart';
import 'package:eclipse_map/core/services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Handle GDPR/CCPA consent before initializing AdMob
  await AdMobService.requestConsent();
  
  await AdMobService.initialize();
  print('📱 AdMob initialized');
  
  runApp(const ProviderScope(child: EclipseMapApp()));
}

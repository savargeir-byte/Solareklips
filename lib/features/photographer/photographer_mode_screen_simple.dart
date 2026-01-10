// lib/features/photographer/photographer_mode_screen_simple.dart
import 'package:flutter/material.dart';

class PhotographerModeScreenSimple extends StatelessWidget {
  const PhotographerModeScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Photographer Mode"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              "Auto eclipse presets\nISO • Shutter • WB\nComing alive next",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/photographer/photographer_mode_screen_simple.dart
import 'package:flutter/material.dart';

class PhotographerModeScreenSimple extends StatelessWidget {
  const PhotographerModeScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Center(
            child: Text("Camera Preview",
                style: TextStyle(color: Colors.white24, fontSize: 18)),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text("TOTALITY IN 00:01:12",
                    style: TextStyle(color: Color(0xFFE4B85F), fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text("Preset: Diamond Ring",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

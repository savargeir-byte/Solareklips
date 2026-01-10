import 'dart:async';

import 'package:flutter/material.dart';

class LiveCountdownText extends StatefulWidget {
  final DateTime target;
  const LiveCountdownText({super.key, required this.target});

  @override
  State<LiveCountdownText> createState() => _LiveCountdownTextState();
}

class _LiveCountdownTextState extends State<LiveCountdownText> {
  late Timer _timer;
  late Duration remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.target.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          remaining = widget.target.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final mins = remaining.inMinutes % 60;
    final secs = remaining.inSeconds % 60;

    return Text(
      "$days d  $hours h  $mins m  $secs s",
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.amber,
        letterSpacing: 2,
      ),
    );
  }
}

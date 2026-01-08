import 'package:flutter/material.dart';
import 'package:eclipse_map/core/models/eclipse_event.dart';

class NextBigEventCard extends StatelessWidget {
  final EclipseEvent event;
  final VoidCallback onTap;

  const NextBigEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = event.peak.difference(DateTime.now().toUtc());

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "NEXT BIG EVENT 🔥",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              event.visibility,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "${remaining.inDays} days to go",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTap,
              child: const Text("View event"),
            )
          ],
        ),
      ),
    );
  }
}

double eclipseProgress({
  required DateTime now,
  required DateTime start,
  required DateTime end,
}) {
  if (now.isBefore(start)) return 0;
  if (now.isAfter(end)) return 1;

  final total = end.difference(start).inSeconds;
  final current = now.difference(start).inSeconds;

  return (current / total).clamp(0.0, 1.0);
}

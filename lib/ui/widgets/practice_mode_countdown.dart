import 'dart:async';
import 'package:flutter/material.dart';

/// Eclipse phases for simulation
enum EclipsePhase {
  beforeC1,
  partialC1C2,
  diamondRing,
  bailysBeads,
  totality,
  chromosphere,
  afterC4,
}

extension EclipsePhaseExtension on EclipsePhase {
  String get displayName {
    switch (this) {
      case EclipsePhase.beforeC1:
        return 'Before C1';
      case EclipsePhase.partialC1C2:
        return 'Partial (C1-C2)';
      case EclipsePhase.diamondRing:
        return 'Diamond Ring';
      case EclipsePhase.bailysBeads:
        return 'Baily\'s Beads';
      case EclipsePhase.totality:
        return 'Totality';
      case EclipsePhase.chromosphere:
        return 'Chromosphere';
      case EclipsePhase.afterC4:
        return 'After C4';
    }
  }

  Color get color {
    switch (this) {
      case EclipsePhase.beforeC1:
        return Colors.blue;
      case EclipsePhase.partialC1C2:
        return Colors.orange;
      case EclipsePhase.diamondRing:
        return const Color(0xFFE4B85F);
      case EclipsePhase.bailysBeads:
        return const Color(0xFFE4B85F);
      case EclipsePhase.totality:
        return Colors.purple;
      case EclipsePhase.chromosphere:
        return Colors.red;
      case EclipsePhase.afterC4:
        return Colors.grey;
    }
  }
}

/// Practice mode countdown with simulated eclipse phases
/// Used to test camera settings without waiting for real event
class PracticeModeCountdown extends StatefulWidget {
  final VoidCallback? onPhaseChange;

  const PracticeModeCountdown({
    super.key,
    this.onPhaseChange,
  });

  @override
  State<PracticeModeCountdown> createState() => _PracticeModeCountdownState();
}

class _PracticeModeCountdownState extends State<PracticeModeCountdown> {
  late DateTime _simulatedEventTime;
  Duration _timeRemaining = const Duration(minutes: 5);
  Timer? _timer;
  EclipsePhase _currentPhase = EclipsePhase.beforeC1;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Start 5 minutes before C1
    _simulatedEventTime = DateTime.now().add(const Duration(minutes: 5));
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _simulatedEventTime = DateTime.now().add(const Duration(minutes: 5));
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeRemaining = _simulatedEventTime.difference(DateTime.now());

        // Update phase based on time remaining
        final secondsRemaining = _timeRemaining.inSeconds;
        final oldPhase = _currentPhase;

        if (secondsRemaining > 240) {
          // > 4 min: Before C1
          _currentPhase = EclipsePhase.beforeC1;
        } else if (secondsRemaining > 180) {
          // 4-3 min: Partial (C1-C2)
          _currentPhase = EclipsePhase.partialC1C2;
        } else if (secondsRemaining > 120) {
          // 3-2 min: Diamond Ring
          _currentPhase = EclipsePhase.diamondRing;
        } else if (secondsRemaining > 60) {
          // 2-1 min: Baily's Beads
          _currentPhase = EclipsePhase.bailysBeads;
        } else if (secondsRemaining > 30) {
          // 1-0.5 min: Totality
          _currentPhase = EclipsePhase.totality;
        } else if (secondsRemaining > 0) {
          // 0.5-0 min: Chromosphere
          _currentPhase = EclipsePhase.chromosphere;
        } else {
          // Finished
          _currentPhase = EclipsePhase.afterC4;
          timer.cancel();
          _isRunning = false;
        }

        // Notify on phase change
        if (oldPhase != _currentPhase) {
          widget.onPhaseChange?.call();
        }
      });
    });
  }

  void _stopSimulation() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentPhase = EclipsePhase.beforeC1;
      _timeRemaining = const Duration(minutes: 5);
    });
  }

  void _resetSimulation() {
    _stopSimulation();
    setState(() {
      _simulatedEventTime = DateTime.now().add(const Duration(minutes: 5));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _timeRemaining.inMinutes;
    final seconds = _timeRemaining.inSeconds % 60;

    return Card(
      color: const Color(0xFFE4B85F).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title
            Row(
              children: [
                const Icon(
                  Icons.science,
                  color: Color(0xFFE4B85F),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Practice Mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isRunning)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Current phase indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentPhase.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentPhase.color,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Phase',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentPhase.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _currentPhase.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeUnit(
                  value: minutes,
                  label: 'MIN',
                ),
                const SizedBox(width: 16),
                const Text(
                  ':',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFE4B85F),
                  ),
                ),
                const SizedBox(width: 16),
                _TimeUnit(
                  value: seconds,
                  label: 'SEC',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Controls
            if (!_isRunning) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _startSimulation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4B85F),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Start Simulation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _stopSimulation,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.stop, color: Colors.red),
                        label: const Text(
                          'Stop',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _resetSimulation,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.restart_alt,
                            color: Colors.grey.shade300),
                        label: Text(
                          'Reset',
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Info
            Text(
              'Simulated eclipse with 5-minute countdown through all phases',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE4B85F),
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

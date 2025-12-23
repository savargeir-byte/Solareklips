import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/eclipse_event.dart';

/// Professional photography assistant for eclipse photography
class PhotographyAssistant extends StatefulWidget {
  final EclipseEvent event;

  const PhotographyAssistant({
    super.key,
    required this.event,
  });

  @override
  State<PhotographyAssistant> createState() => _PhotographyAssistantState();
}

class _PhotographyAssistantState extends State<PhotographyAssistant> {
  Timer? _intervalTimer;
  int _shotsRemaining = 0;
  bool _isRunning = false;

  // Camera settings recommendations
  final Map<String, CameraSettings> _phaseSettings = {
    'Partial (C1-C2)': CameraSettings(
      iso: 100,
      shutter: '1/1000',
      aperture: 'f/8',
      filter: 'Solar filter required',
    ),
    'Diamond Ring': CameraSettings(
      iso: 400,
      shutter: '1/1000',
      aperture: 'f/5.6',
      filter: 'Remove solar filter NOW',
    ),
    'Baily\'s Beads': CameraSettings(
      iso: 400,
      shutter: '1/500',
      aperture: 'f/5.6',
      filter: 'No filter',
    ),
    'Totality - Inner Corona': CameraSettings(
      iso: 400,
      shutter: '1/250',
      aperture: 'f/4',
      filter: 'No filter',
    ),
    'Totality - Outer Corona': CameraSettings(
      iso: 1600,
      shutter: '1/15',
      aperture: 'f/2.8',
      filter: 'No filter',
    ),
    'Chromosphere': CameraSettings(
      iso: 800,
      shutter: '1/500',
      aperture: 'f/5.6',
      filter: 'No filter',
    ),
  };

  void _startIntervalTimer({
    required int shots,
    required Duration interval,
  }) {
    setState(() {
      _shotsRemaining = shots;
      _isRunning = true;
    });

    _intervalTimer = Timer.periodic(interval, (timer) {
      if (_shotsRemaining <= 0) {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        HapticFeedback.heavyImpact();
        return;
      }

      HapticFeedback.lightImpact();
      setState(() {
        _shotsRemaining--;
      });
    });
  }

  void _stopTimer() {
    _intervalTimer?.cancel();
    setState(() {
      _isRunning = false;
      _shotsRemaining = 0;
    });
  }

  @override
  void dispose() {
    _intervalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photography Assistant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              '📸 Eclipse Photography Guide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Recommended camera settings for each phase',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Interval Timer
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⏱️ Interval Timer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isRunning) ...[
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '$_shotsRemaining',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFFE4B85F),
                              ),
                            ),
                            const Text(
                              'shots remaining',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _stopTimer,
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text('Quick Bracket Modes:'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _IntervalButton(
                            label: 'Baily\'s Beads\n15 shots / 0.5s',
                            onPressed: () => _startIntervalTimer(
                              shots: 15,
                              interval: const Duration(milliseconds: 500),
                            ),
                          ),
                          _IntervalButton(
                            label: 'Corona HDR\n7 shots / 1s',
                            onPressed: () => _startIntervalTimer(
                              shots: 7,
                              interval: const Duration(seconds: 1),
                            ),
                          ),
                          _IntervalButton(
                            label: 'Diamond Ring\n5 shots / 0.3s',
                            onPressed: () => _startIntervalTimer(
                              shots: 5,
                              interval: const Duration(milliseconds: 300),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Settings by phase
            const Text(
              '⚙️ Settings by Phase',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._phaseSettings.entries.map((entry) {
              return _SettingsCard(
                phase: entry.key,
                settings: entry.value,
              );
            }).toList(),

            const SizedBox(height: 24),

            // Quick tips
            Card(
              color: Colors.amber[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Pro Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _TipItem('Use manual focus set to infinity'),
                    _TipItem('Shoot in RAW format for post-processing'),
                    _TipItem('Use mirror lock-up or electronic shutter'),
                    _TipItem('Bracket exposures during totality'),
                    _TipItem('Remove solar filter 2s before totality'),
                    _TipItem('Put filter back immediately after C3'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Equipment checklist
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Equipment Checklist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _ChecklistItem('Camera with manual controls'),
                    _ChecklistItem('Telephoto lens (400mm+ recommended)'),
                    _ChecklistItem('Sturdy tripod'),
                    _ChecklistItem('Solar filter (Baader film or glass)'),
                    _ChecklistItem('Intervalometer or remote shutter'),
                    _ChecklistItem('Extra batteries (cold drains them fast)'),
                    _ChecklistItem('Memory cards (32GB+ recommended)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraSettings {
  final int iso;
  final String shutter;
  final String aperture;
  final String filter;

  CameraSettings({
    required this.iso,
    required this.shutter,
    required this.aperture,
    required this.filter,
  });
}

class _SettingsCard extends StatelessWidget {
  final String phase;
  final CameraSettings settings;

  const _SettingsCard({
    required this.phase,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phase,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE4B85F),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SettingItem(label: 'ISO', value: settings.iso.toString()),
                _SettingItem(label: 'Shutter', value: settings.shutter),
                _SettingItem(label: 'Aperture', value: settings.aperture),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: settings.filter.contains('Remove') ||
                        settings.filter.contains('NOW')
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    settings.filter.contains('required')
                        ? Icons.block
                        : Icons.check_circle,
                    size: 16,
                    color: settings.filter.contains('Remove') ||
                            settings.filter.contains('NOW')
                        ? Colors.red
                        : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      settings.filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: settings.filter.contains('Remove') ||
                                settings.filter.contains('NOW')
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;

  const _SettingItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _IntervalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _IntervalButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;

  const _ChecklistItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

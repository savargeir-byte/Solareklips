import 'package:flutter/material.dart';
import '../models/eclipse_event.dart';
import '../widgets/eclipse_shadow_painter.dart';

/// Time travel widget for eclipse preview at any time
class TimeTravelMode extends StatefulWidget {
  final EclipseEvent event;

  const TimeTravelMode({
    super.key,
    required this.event,
  });

  @override
  State<TimeTravelMode> createState() => _TimeTravelModeState();
}

class _TimeTravelModeState extends State<TimeTravelMode>
    with SingleTickerProviderStateMixin {
  late AnimationController _playbackController;
  double _sliderValue = 0.0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _playbackController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _playbackController.addListener(() {
      setState(() {
        _sliderValue = _playbackController.value;
      });
    });
  }

  @override
  void dispose() {
    _playbackController.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _playbackController.repeat();
      } else {
        _playbackController.stop();
      }
    });
  }

  void _rewind() {
    setState(() {
      _sliderValue = (_sliderValue - 0.1).clamp(0.0, 1.0);
      _playbackController.value = _sliderValue;
    });
  }

  void _fastForward() {
    setState(() {
      _sliderValue = (_sliderValue + 0.1).clamp(0.0, 1.0);
      _playbackController.value = _sliderValue;
    });
  }

  String _getTimeAtProgress(double progress) {
    final duration = widget.event.endUtc.difference(widget.event.startUtc);
    final elapsed = duration * progress;
    final targetTime = widget.event.startUtc.add(elapsed);
    
    return '${targetTime.toLocal().hour.toString().padLeft(2, '0')}:'
        '${targetTime.toLocal().minute.toString().padLeft(2, '0')}:'
        '${targetTime.toLocal().second.toString().padLeft(2, '0')}';
  }

  String _getPhaseAtProgress(double progress) {
    if (progress < 0.1) return 'Before Eclipse';
    if (progress < 0.3) return 'Partial Phase (C1)';
    if (progress < 0.45) return 'Approaching Totality';
    if (progress >= 0.45 && progress <= 0.55) return 'TOTALITY (C2-C3)';
    if (progress < 0.7) return 'Partial Phase (C3)';
    if (progress < 0.9) return 'Ending Phase';
    return 'Eclipse Complete (C4)';
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = _getTimeAtProgress(_sliderValue);
    final currentPhase = _getPhaseAtProgress(_sliderValue);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Time Travel Mode',
          style: TextStyle(color: Color(0xFFE4B85F)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE4B85F)),
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[900],
              child: CustomPaint(
                painter: EclipseShadowPainter(
                  position: Offset(
                    200 + (100 * _sliderValue),
                    200,
                  ),
                  progress: _sliderValue,
                  scale: 1.0 + (0.5 * _sliderValue),
                  rotation: 0.0,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // Info section
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Time display
                Text(
                  currentTime,
                  style: const TextStyle(
                    color: Color(0xFFE4B85F),
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Phase display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _sliderValue >= 0.45 && _sliderValue <= 0.55
                        ? Colors.red.withOpacity(0.3)
                        : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentPhase,
                    style: TextStyle(
                      color: _sliderValue >= 0.45 && _sliderValue <= 0.55
                          ? Colors.red[200]
                          : const Color(0xFFE4B85F),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Controls section
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Timeline slider
                Row(
                  children: [
                    const Icon(Icons.wb_twilight, color: Color(0xFFE4B85F), size: 20),
                    Expanded(
                      child: Slider(
                        value: _sliderValue,
                        onChanged: (value) {
                          setState(() {
                            _sliderValue = value;
                            _playbackController.value = value;
                          });
                        },
                        activeColor: const Color(0xFFE4B85F),
                        inactiveColor: Colors.grey[800],
                      ),
                    ),
                    const Icon(Icons.nightlight, color: Color(0xFFE4B85F), size: 20),
                  ],
                ),

                const SizedBox(height: 16),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rewind
                    IconButton(
                      onPressed: _rewind,
                      icon: const Icon(Icons.fast_rewind),
                      color: const Color(0xFFE4B85F),
                      iconSize: 32,
                    ),

                    // Play/Pause
                    IconButton(
                      onPressed: _togglePlayback,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      color: const Color(0xFFE4B85F),
                      iconSize: 48,
                    ),

                    // Fast forward
                    IconButton(
                      onPressed: _fastForward,
                      icon: const Icon(Icons.fast_forward),
                      color: const Color(0xFFE4B85F),
                      iconSize: 32,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Speed control
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Speed:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    ...['0.5x', '1x', '2x', '5x'].map((speed) {
                      final speedValue = double.parse(speed.replaceAll('x', ''));
                      final isSelected = _playbackSpeed == speedValue;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _playbackSpeed = speedValue;
                              _playbackController.duration = Duration(
                                milliseconds: (10000 / speedValue).round(),
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFFE4B85F)
                                : Colors.transparent,
                            foregroundColor: isSelected
                                ? Colors.black
                                : const Color(0xFFE4B85F),
                            side: const BorderSide(
                              color: Color(0xFFE4B85F),
                            ),
                          ),
                          child: Text(speed),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

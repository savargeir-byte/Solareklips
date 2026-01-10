// lib/ui/widgets/eclipse_rive.dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class EclipseRive extends StatefulWidget {
  final bool totality;
  const EclipseRive({super.key, required this.totality});

  @override
  State<EclipseRive> createState() => _EclipseRiveState();
}

class _EclipseRiveState extends State<EclipseRive> {
  SMIBool? _totality;

  void _onInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'ECLIPSE');
    if (controller != null) {
      artboard.addController(controller);
      _totality = controller.findInput<bool>('totality') as SMIBool?;
      _totality?.value = widget.totality;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/eclipse.riv',
      fit: BoxFit.cover,
      onInit: _onInit,
    );
  }
}

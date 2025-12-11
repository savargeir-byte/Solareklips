# Rive Eclipse Shadow Animation

This directory contains Rive animation files for the eclipse shadow effects.

## eclipse_shadow.riv

### Artboard: EclipseShadow

**State Machine:** EclipseController

### Inputs:

- `progress` (Number, 0.0-1.0): Overall eclipse progression
- `umbra_x` (Number, 0.0-1.0): Umbra shadow X position
- `umbra_y` (Number, 0.0-1.0): Umbra shadow Y position
- `shadow_scale` (Number, 0.8-1.3): Shadow size multiplier
- `shadow_rotation` (Number, 0-360): Shadow rotation in degrees

### Layers:

1. **PenumbraGradient**: Soft radial gradient (60% opacity)

   - Color: Black with radial falloff
   - Blend mode: Darken
   - Size: 200px base radius

2. **UmbraCore**: Solid circle (100% opacity)

   - Color: Black
   - Size: 80px base radius
   - Position: Animated by umbra_x, umbra_y

3. **GlowRing**: Solar corona effect
   - Color: Gold (#E4B85F)
   - Opacity: Peaks at 50% progress
   - Animation: 2-3 second loop
   - Blend mode: Screen

### Animation:

- **glow_loop**: Continuous 2.5s shimmer effect on GlowRing
- **fade_in**: Smooth opacity transition when progress > 0.15
- **scale_pulse**: Subtle scale variation tied to progress

### Usage in Flutter:

```dart
RiveAnimation.asset(
  'assets/rive/eclipse_shadow.riv',
  artboard: 'EclipseShadow',
  stateMachines: ['EclipseController'],
  onInit: (artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'EclipseController',
    );
    controller?.findInput<double>('progress')?.value = 0.5;
    controller?.findInput<double>('umbra_x')?.value = 0.5;
    controller?.findInput<double>('umbra_y')?.value = 0.5;
  },
)
```

## Creating the Rive File

To create `eclipse_shadow.riv`:

1. Open Rive Editor (https://rive.app)
2. Create new artboard named "EclipseShadow" (1000x1000px)
3. Add three layers:
   - Rectangle → Convert to Ellipse → Name "PenumbraGradient"
   - Rectangle → Convert to Ellipse → Name "UmbraCore"
   - Rectangle → Convert to Ellipse with stroke → Name "GlowRing"
4. Apply radial gradients and colors as specified above
5. Create State Machine named "EclipseController"
6. Add Number inputs: progress, umbra_x, umbra_y, shadow_scale, shadow_rotation
7. Bind inputs to layer properties (position, scale, opacity)
8. Export as `eclipse_shadow.riv`

**Note:** This is a placeholder. The actual .riv file needs to be created in Rive Editor.
For production use, either:

- Create the animation in Rive following this spec
- Use the CustomPainter fallback (already implemented)
- Request a pre-made .riv file from a Rive animator

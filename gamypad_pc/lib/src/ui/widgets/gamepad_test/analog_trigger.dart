import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/gamepad_test_palette.dart';
import 'package:protocol/protocol.dart';

/// An analog trigger: hold to fill, release to empty, reporting every
/// intermediate value.
///
/// gamypad_controller has no equivalent — its `GamepadButton` treats LT/RT as
/// digital and sends 0 or 1, which loses the whole 0..255 range the native side
/// is configured for. This ramps instead, so partial pulls are observable and
/// can be checked against a real game.
class AnalogTrigger extends StatefulWidget {
  const AnalogTrigger({
    super.key,
    required this.label,
    required this.onChanged,
    this.width = 160,
    this.height = 40,
    this.rampDuration = const Duration(milliseconds: 450),
  });

  final String label;

  /// Receives `triggerMin..triggerMax`, matching [TriggerMessage.value].
  final ValueChanged<int> onChanged;

  final double width;
  final double height;

  /// How long a full pull takes. Long enough to stop at an interesting value.
  final Duration rampDuration;

  /// Real triggers spring back faster than they travel.
  static const releaseDuration = Duration(milliseconds: 140);

  @override
  State<AnalogTrigger> createState() => _AnalogTriggerState();
}

class _AnalogTriggerState extends State<AnalogTrigger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ramp = AnimationController(
    vsync: this,
    duration: widget.rampDuration,
    reverseDuration: AnalogTrigger.releaseDuration,
  )..addListener(_emit);

  int _value = triggerMin;

  void _emit() {
    // Fraction of travel becomes the reported value, so the fill on screen and
    // the number on the wire are the same quantity.
    final next = (_ramp.value * triggerMax).round().clamp(
      triggerMin,
      triggerMax,
    );
    if (next == _value) return;
    setState(() => _value = next);
    widget.onChanged(next);
  }

  /// From rest, so a re-press always visibly travels the full range rather than
  /// jumping to wherever the last release left off.
  void _press() => _ramp.forward(from: 0);

  void _release() => _ramp.reverse(from: _ramp.value);

  @override
  void dispose() {
    _ramp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fill = _value / triggerMax;

    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: GamepadTestPalette.analogTrack,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GamepadTestPalette.border),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fill,
              child: Container(
                decoration: BoxDecoration(
                  color: GamepadTestPalette.analogFill,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Center(
              child: Text(
                // The raw value is shown so the number reaching the device can
                // be read directly, not inferred from the bar.
                '${widget.label}  $_value',
                style: TextStyle(
                  color: fill > 0.5 ? Colors.black : GamepadTestPalette.label,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
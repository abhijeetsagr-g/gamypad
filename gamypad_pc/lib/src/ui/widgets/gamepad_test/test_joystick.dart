import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/gamepad_test_palette.dart';
import 'package:protocol/protocol.dart';

/// A draggable stick reporting signed 16-bit axes.
///
/// The feel — travel distance, deadzone, quadratic response — is copied from
/// gamypad_controller so a value tuned there behaves the same here. The
/// difference is the payload: this emits protocol-range integers directly,
/// where the controller rounds a float at the JSON layer.
class TestJoystick extends StatefulWidget {
  const TestJoystick({
    super.key,
    required this.stick,
    required this.onChanged,
    this.radius = 60,
  });

  final GamepadStick stick;
  final void Function(int x, int y) onChanged;
  final double radius;

  /// Fraction of travel below which the stick reads as centred.
  static const deadzone = 0.1;

  @override
  State<TestJoystick> createState() => _TestJoystickState();
}

class _TestJoystickState extends State<TestJoystick> {
  Offset _offset = Offset.zero;

  double get _thumbRadius => widget.radius * 0.42;

  /// Travel exceeds the visible radius, so the thumb reaches the ring edge
  /// before it saturates.
  double get _maxDis => widget.radius * 1.3;

  void _update(Offset localPosition) {
    final offset = localPosition - Offset(widget.radius, widget.radius);
    final target = offset.distance < _maxDis
        ? offset
        : Offset.fromDirection(offset.direction, _maxDis);

    setState(() => _offset = target);

    var normalized = Offset(
      (target.dx / _maxDis).clamp(-1.0, 1.0),
      (target.dy / _maxDis).clamp(-1.0, 1.0),
    );

    if (normalized.distance < TestJoystick.deadzone) {
      normalized = Offset.zero;
    }

    // Quadratic: fine control near centre, full range at the edge.
    normalized = Offset(
      normalized.dx.abs() * normalized.dx,
      normalized.dy.abs() * normalized.dy,
    );

    widget.onChanged(
      (normalized.dx * stickMax).round(),
      (normalized.dy * stickMax).round(),
    );
  }

  void _reset() {
    setState(() => _offset = Offset.zero);
    widget.onChanged(stickCenter, stickCenter);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => _update(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: GamepadTestPalette.stickRing,
                  width: 2,
                ),
                color: GamepadTestPalette.stickWell,
              ),
            ),
            Transform.translate(
              offset: _offset,
              child: Container(
                width: _thumbRadius * 2,
                height: _thumbRadius * 2,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: GamepadTestPalette.stickRing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
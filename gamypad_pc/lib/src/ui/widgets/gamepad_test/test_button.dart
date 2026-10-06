import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/widgets/gamepad_test/gamepad_test_palette.dart';

/// A digital button for the testing ground. Styling copied from
/// gamypad_controller's `GamepadButton`, but it reports a boolean instead of
/// encoding a wire message, so nothing here knows about the transport.
class TestButton extends StatefulWidget {
  const TestButton({
    super.key,
    required this.label,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  final String label;
  final double width;
  final double height;

  /// Emits true on press, false on release.
  final ValueChanged<bool> onChanged;

  @override
  State<TestButton> createState() => _TestButtonState();
}

class _TestButtonState extends State<TestButton> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
    widget.onChanged(pressed);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      // Listener rather than GestureDetector: fires on pointer down without
      // waiting on the gesture arena, so there is no perceptible input lag.
      child: Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          decoration: BoxDecoration(
            color: _pressed
                ? GamepadTestPalette.surfacePressed
                : GamepadTestPalette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pressed
                  ? GamepadTestPalette.borderPressed
                  : GamepadTestPalette.border,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: _pressed
                    ? GamepadTestPalette.labelPressed
                    : GamepadTestPalette.label,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
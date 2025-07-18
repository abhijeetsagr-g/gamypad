import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  const Joystick({
    super.key,
    required this.joystickRadius,
    required this.label,
  });
  final double joystickRadius;
  final String label;

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _joystickOffset = Offset.zero;
  double get _joystickRadius => widget.joystickRadius;

  void _updateOffset(Offset localPos) {
    final Offset center = Offset(_joystickRadius, _joystickRadius);
    Offset delta = localPos - center;

    // Clamp within circle
    if (delta.distance > _joystickRadius) {
      delta = Offset.fromDirection(delta.direction, _joystickRadius);
    }

    setState(() => _joystickOffset = delta);
  }

  void _resetOffset() {
    setState(() => _joystickOffset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updateOffset(details.localPosition),
      onPanUpdate: (details) => _updateOffset(details.localPosition),
      onPanEnd: (_) => _resetOffset(),

      child: Container(
        width: _joystickRadius * 2,
        height: _joystickRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[700],
        ),
        child: Stack(
          children: [
            Positioned(
              left: _joystickOffset.dx + _joystickRadius - 20,
              top: _joystickOffset.dy + _joystickRadius - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gamypad_apk/models/client.dart';
import 'package:provider/provider.dart';

class Joystick extends StatefulWidget {
  const Joystick({super.key, required this.isLeftStick});

  final bool isLeftStick;
  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _stickOffset = Offset.zero;
  final double _radius = 60; // Outer Circle Radius
  final double _thumbRadius = 25; // Inner Circle Radius

  void _onChanged({int? xValue, int? yValue}) {
    String name = widget.isLeftStick ? "leftStick" : "rightStick";
    final clientProvider = Provider.of<Client>(context, listen: false);
    clientProvider.sendJson({
      'action': name,
      'btn': {'x': xValue.toString(), 'y': yValue.toString()},
    });
    // print("$name, $xValue : $yValue");
  }

  void _updateStick(Offset details) {
    final Offset offset = details - Offset(_radius, _radius);
    final double distance = offset.distance;

    // Allow stick to go beyond outer circle
    final double limitFactor = 1.3; // 30% beyond outer circle
    final double maxDis = _radius * limitFactor;

    Offset target;
    if (distance < maxDis) {
      target = offset;
    } else {
      target = Offset.fromDirection(offset.direction, maxDis);
    }

    // Smooth interpolation
    _stickOffset = Offset.lerp(_stickOffset, target, 0.2)!;

    // Normalize based on maxDis
    Offset normalized = Offset(
      _stickOffset.dx / maxDis,
      _stickOffset.dy / maxDis,
    );

    // Clamp to [-1, 1]
    normalized = Offset(
      normalized.dx.clamp(-1.0, 1.0),
      normalized.dy.clamp(-1.0, 1.0),
    );

    // Deadzone
    const double deadzone = 0.1;
    if (normalized.distance < deadzone) {
      normalized = Offset.zero;
    }

    // Curved sensitivity (quadratic scaling for precision near center)
    normalized = Offset(
      normalized.dx.abs() * normalized.dx,
      normalized.dy.abs() * normalized.dy,
    );

    // Scale to joystick int range
    const int maxRange = 32767;
    final int xValue = (normalized.dx * maxRange).toInt();
    final int yValue = (normalized.dy * maxRange).toInt();

    _onChanged(xValue: xValue, yValue: yValue);
    setState(() {});
  }

  void _resetStick() {
    setState(() {
      _stickOffset = Offset.zero;
      _onChanged(xValue: 0, yValue: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => _updateStick(details.localPosition),
      onPanEnd: (details) => _resetStick(),
      child: SizedBox(
        width: _radius * 2,
        height: _radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Circle
            Container(
              width: _radius * 2,
              height: _radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade300, width: 2),
              ),
            ),
            // Inner thumb
            Transform.translate(
              offset: _stickOffset,
              child: Container(
                width: _thumbRadius * 2,
                height: _thumbRadius * 2,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

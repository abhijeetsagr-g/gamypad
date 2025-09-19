import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  const Joystick({super.key, required this.isLeftStick});

  final bool isLeftStick;
  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _stickOffset = Offset.zero;
  final double _radius = 60; // Outer Cricle Radius
  final double _thumbRadius = 25; // Inner Circle radius

  void _onChanged({int? xValue, int? yValue}) {
    String name = widget.isLeftStick ? "Left" : "Right";
    print("$name : $xValue, $yValue");
  }

  void _updateStick(Offset details) {
    final Offset offset = details - Offset(_radius, _radius);
    final double distance = offset.distance;

    if (distance < _radius - _thumbRadius) {
      _stickOffset = offset;
    } else {
      // Clamp thumb inside Circle
      _stickOffset = Offset.fromDirection(
        offset.direction,
        _radius - _thumbRadius,
      );
    }

    // normalize values (-1 to 1)
    final double maxDis = _radius - _thumbRadius;
    final Offset normalized = Offset(
      _stickOffset.dx / maxDis,
      _stickOffset.dy / maxDis,
    );

    // normalized = Offset(-1..1, -1..1)
    final int maxRange = 32767;
    final int xValue = (normalized.dx * maxRange).toInt();
    final int yValue = (-normalized.dy * maxRange).toInt();

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
            // inner circle
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

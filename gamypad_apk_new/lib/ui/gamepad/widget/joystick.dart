import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';

class Joystick extends ConsumerStatefulWidget {
  const Joystick({super.key, required this.isLeftStick, required this.radius});
  final bool isLeftStick;
  final double radius;

  @override
  ConsumerState<Joystick> createState() => _JoystickState();
}

class _JoystickState extends ConsumerState<Joystick> {
  Offset _stickOffset = Offset.zero;

  double get _thumbRadius => widget.radius * 0.42;
  double get _maxDis => widget.radius * 1.3;
  String get _action => widget.isLeftStick ? 'leftStick' : 'rightStick';

  void _send(int x, int y) {
    ref.read(clientProvider.notifier).sendJson({
      'action': _action,
      'btn': {'x': x.toString(), 'y': y.toString()},
    });
  }

  void _updateStick(Offset localPosition) {
    final Offset offset = localPosition - Offset(widget.radius, widget.radius);
    final double distance = offset.distance;

    // clamp to maxDis
    final Offset target = distance < _maxDis
        ? offset
        : Offset.fromDirection(offset.direction, _maxDis);

    _stickOffset = target;

    // normalize to [-1, 1]
    Offset normalized = Offset(
      (target.dx / _maxDis).clamp(-1.0, 1.0),
      (target.dy / _maxDis).clamp(-1.0, 1.0),
    );

    // deadzone
    if (normalized.distance < 0.1) normalized = Offset.zero;

    // quadratic sensitivity
    normalized = Offset(
      normalized.dx.abs() * normalized.dx,
      normalized.dy.abs() * normalized.dy,
    );

    const int maxRange = 32767;
    _send(
      (normalized.dx * maxRange).toInt(),
      (normalized.dy * maxRange).toInt(),
    );

    setState(() {});
  }

  void _resetStick() {
    _stickOffset = Offset.zero;
    _send(0, 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => _updateStick(details.localPosition),
      onPanEnd: (_) => _resetStick(),
      onPanCancel: _resetStick,
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // outer ring
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4DA6FF), width: 2),
                color: const Color(0xFF111111),
              ),
            ),
            // thumb
            Transform.translate(
              offset: _stickOffset,
              child: Container(
                width: _thumbRadius * 2,
                height: _thumbRadius * 2,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4DA6FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

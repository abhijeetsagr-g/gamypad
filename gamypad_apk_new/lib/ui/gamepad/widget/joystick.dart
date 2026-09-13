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
  bool _dragging = false;

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
    final Offset target = distance < _maxDis
        ? offset
        : Offset.fromDirection(offset.direction, _maxDis);
    _stickOffset = target;
    Offset normalized = Offset(
      (target.dx / _maxDis).clamp(-1.0, 1.0),
      (target.dy / _maxDis).clamp(-1.0, 1.0),
    );
    if (normalized.distance < 0.1) normalized = Offset.zero;
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

  void _onPanStart(_) {
    _dragging = true;
    if (widget.isLeftStick) {
      ref.read(tiltProvider.notifier).setSuppressed(true);
    }
  }

  void _onPanEnd([_]) {
    _dragging = false;
    if (widget.isLeftStick) {
      ref.read(tiltProvider.notifier).setSuppressed(false);
    }
    _resetStick();
  }

  @override
  Widget build(BuildContext context) {
    // Tilt drives left-stick visuals when not dragging.
    if (widget.isLeftStick) {
      ref.listen(tiltProvider, (prev, next) {
        if (_dragging) return;
        if (!next.enabled) {
          if (_stickOffset != Offset.zero) {
            setState(() => _stickOffset = Offset.zero);
          }
          return;
        }
        final double nx = (next.stickX / 32767).clamp(-1.0, 1.0);
        final double ny = (next.stickY / 32767).clamp(-1.0, 1.0);
        final Offset off = Offset(nx * _maxDis, ny * _maxDis);
        if ((off - _stickOffset).distance > 0.5) {
          setState(() => _stickOffset = off);
        }
      });
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: (details) => _updateStick(details.localPosition),
      onPanEnd: _onPanEnd,
      onPanCancel: () => _onPanEnd(),
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
                border: Border.all(color: const Color(0xFF4DA6FF), width: 2),
                color: const Color(0xFF111111),
              ),
            ),
            Transform.translate(
              offset: _stickOffset,
              child: Container(
                width: _thumbRadius * 2,
                height: _thumbRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isLeftStick && ref.watch(tiltProvider).enabled && !_dragging
                      ? const Color(0xFF00FF88)
                      : const Color(0xFF4DA6FF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

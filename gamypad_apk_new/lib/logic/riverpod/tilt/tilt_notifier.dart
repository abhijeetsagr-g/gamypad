import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:gamypad_apk_new/logic/riverpod/my_providers.dart';
import 'package:gamypad_apk_new/logic/riverpod/tilt/tilt_state.dart';

class TiltNotifier extends Notifier<TiltState> {
  StreamSubscription<AccelerometerEvent>? _sub;

  // low-pass filtered gravity projection
  double _fX = 0;
  double _fY = 0;
  bool _hasFilter = false;

  // throttle: send at most every ~32ms (~30Hz)
  DateTime? _lastSend;
  int _lastSx = 0, _lastSy = 0;

  // suppress tilt while left stick is being dragged
  bool _suppress = false;

  @override
  TiltState build() {
    ref.onDispose(() => _sub?.cancel());
    // auto-pause when disconnected — keep enabled flag but stop sending
    ref.listen(clientProvider, (prev, next) {
      if (!(next.isConnected)) {
        _sendStick(0, 0, force: true);
      }
    });
    return const TiltState();
  }

  bool get isSuppressed => _suppress;
  void setSuppressed(bool v) => _suppress = v;

  void toggle() {
    if (state.enabled) {
      disable();
    } else {
      enable();
    }
  }

  void enable() {
    if (state.enabled) return;
    state = state.copyWith(enabled: true);
    _hasFilter = false;
    _fX = 0;
    _fY = 0;
    _sub?.cancel();
    _sub = accelerometerEventStream().listen(
      _onAccel,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  void disable() {
    if (!state.enabled) return;
    _sub?.cancel();
    _sub = null;
    state = state.copyWith(enabled: false, rawX: 0, rawY: 0, stickX: 0, stickY: 0);
    _sendStick(0, 0, force: true);
  }

  void calibrate() {
    // capture current filtered tilt as neutral
    state = state.copyWith(calibX: _fX, calibY: _fY);
  }

  void setSensitivity(double v) {
    state = state.copyWith(sensitivity: v.clamp(0.6, 3.0));
  }

  void setDeadzone(double v) {
    state = state.copyWith(deadzone: v.clamp(0.0, 0.4));
  }

  void _onAccel(AccelerometerEvent e) {
    if (!state.enabled) return;

    const double g = 9.81;

    // LandscapeLeft mapping (gamepad is landscape).
    // Physical axes (portrait natural): X→right, Y→top, Z→out.
    // In landscapeLeft, gravity projects onto -Y for roll (left/right)
    // and +X for pitch (forward/back). Empirically this matches "lean right → right".
    final double rawX = (-e.y / g);
    final double rawY = (e.x / g);

    // low-pass ~15% new, 85% old to kill hand tremor
    if (!_hasFilter) {
      _fX = rawX;
      _fY = rawY;
      _hasFilter = true;
    } else {
      _fX = _fX * 0.85 + rawX * 0.15;
      _fY = _fY * 0.85 + rawY * 0.15;
    }

    double dx = (_fX - state.calibX);
    double dy = (_fY - state.calibY);

    dx *= state.sensitivity;
    dy *= state.sensitivity;

    dx = dx.clamp(-1.0, 1.0);
    dy = dy.clamp(-1.0, 1.0);

    // radial deadzone with rescale
    final double dist = math.sqrt(dx * dx + dy * dy);
    if (dist < state.deadzone) {
      dx = 0;
      dy = 0;
    } else if (dist > 0) {
      final double scale = (dist - state.deadzone) / (1 - state.deadzone);
      dx = dx / dist * scale;
      dy = dy / dist * scale;
      // clamp after rescale
      dx = dx.clamp(-1.0, 1.0);
      dy = dy.clamp(-1.0, 1.0);
    }

    // quadratic sensitivity to match Joystick widget feel
    dx = dx.abs() * dx;
    dy = dy.abs() * dy;

    // invert Y: tilting top away (forward) → stick up (negative Y in many games)
    // Keep consistent with physical Joystick which sends +Y down.
    // For tilt, "lean forward" should feel like pushing stick forward (up = -Y).
    dy = -dy;

    final int sx = (dx * 32767).toInt();
    final int sy = (dy * 32767).toInt();

    state = state.copyWith(rawX: _fX, rawY: _fY, stickX: sx, stickY: sy);

    if (_suppress) return;
    final connected = ref.read(clientProvider).isConnected;
    if (!connected) return;

    final now = DateTime.now();
    if (_lastSend != null && now.difference(_lastSend!).inMilliseconds < 32) {
      return;
    }
    _lastSend = now;

    // avoid spamming identical values
    if (sx == _lastSx && sy == _lastSy) return;

    _sendStick(sx, sy);
  }

  void _sendStick(int x, int y, {bool force = false}) {
    if (!force && x == _lastSx && y == _lastSy) return;
    _lastSx = x;
    _lastSy = y;
    // reuse the same wire format as the physical joystick: leftStick
    try {
      ref.read(clientProvider.notifier).sendJson({
        'action': 'leftStick',
        'btn': {'x': x.toString(), 'y': y.toString()},
      });
    } catch (_) {}
  }
}

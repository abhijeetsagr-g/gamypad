import 'dart:async';

import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:protocol/protocol.dart';

class GamepadInput {
  GamepadInput({
    required GamepadTransport transport,
    required SettingModel settings,
  }) : _settings = settings,
       _transport = transport {
    _subscription = _transport.status.listen((status) {
      if (status == ConnectionStatus.connected) _replay();
    });
  }

  final GamepadTransport _transport;
  final SettingModel _settings;
  StreamSubscription<ConnectionStatus>? _subscription;
  final Set<GamepadButton> _held = {};

  @override
  String toString() =>
      'GamepadInput(held: ${_held.isEmpty ? 'none' : _held.join(', ')})';

  void press(GamepadButton button) {
    _held.add(button);
    if (_settings.vibrate) _vibrate();
    _send(ButtonMessage(button: button, pressed: true));
  }

  void release(GamepadButton button) {
    _held.remove(button);
    _send(ButtonMessage(button: button, pressed: false));
  }

  void setStick(GamepadStick stick, int x, int y) {
    _send(StickMessage(stick: stick, x: x, y: y));
  }

  void setTrigger(GamepadTrigger trigger, int value) {
    // Digital mode is full-or-nothing — but only while pressed. The release
    // must go out as triggerMin; forcing it to triggerMax here is what used to
    // leave the PC holding the trigger down forever.
    final pressed = value > triggerMin;
    final sent = _settings.digitalTriggers && pressed ? triggerMax : value;

    if (_settings.vibrate && _settings.digitalTriggers && pressed) _vibrate();

    _send(TriggerMessage(trigger: trigger, value: sent));
  }

  void releaseAll() {
    for (final button in _held) {
      _send(ButtonMessage(button: button, pressed: false));
    }
    _held.clear();

    for (final stick in GamepadStick.values) {
      _send(StickMessage(stick: stick, x: stickCenter, y: stickCenter));
    }
    for (final trigger in GamepadTrigger.values) {
      _send(TriggerMessage(trigger: trigger, value: triggerMin));
    }
  }

  void dispose() {
    releaseAll();
    _subscription?.cancel();
    _subscription = null;
  }

  void _replay() {
    for (final button in _held) {
      _send(ButtonMessage(button: button, pressed: true));
    }
  }

  void _vibrate() {
    unawaited(Haptics.vibrate(HapticsType.success));
  }

  void _send(Message message) => unawaited(_transport.send(message));
}

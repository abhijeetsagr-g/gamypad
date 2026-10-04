import 'dart:async';

import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:protocol/protocol.dart';

class GamepadInput {
  GamepadInput({required GamepadTransport transport}) : _transport = transport {
    _subscription = _transport.status.listen((status) {
      if (status == ConnectionStatus.connected) _replay();
    });
  }

  final GamepadTransport _transport;
  StreamSubscription<ConnectionStatus>? _subscription;

  /// Buttons currently held down.
  final Set<GamepadButton> _held = {};

  @override
  String toString() =>
      'GamepadInput(held: ${_held.isEmpty ? 'none' : _held.join(', ')})';

  /// Holds [button] down.
  void press(GamepadButton button) {
    _held.add(button);
    _send(ButtonMessage(button: button, pressed: true));
  }

  void release(GamepadButton button) {
    _held.remove(button);
    _send(ButtonMessage(button: button, pressed: false));
  }

  /// Reports a stick position in protocol units — [stickMin]..[stickMax] per axis.
  void setStick(GamepadStick stick, int x, int y) {
    _send(StickMessage(stick: stick, x: x, y: y));
  }

  /// Reports analog trigger travel, [triggerMin]..[triggerMax].
  void setTrigger(GamepadTrigger trigger, int value) {
    _send(TriggerMessage(trigger: trigger, value: value));
  }

  /// Returns the pad to rest:
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

  /// Releases everything and stops listening.
  void dispose() {
    releaseAll();
    _subscription?.cancel();
    _subscription = null;
  }

  /// Restates the current truth after a reconnect.
  void _replay() {
    for (final button in _held) {
      _send(ButtonMessage(button: button, pressed: true));
    }
  }

  /// Sends without waiting, because input must never block a gesture.
  void _send(Message message) => unawaited(_transport.send(message));
}

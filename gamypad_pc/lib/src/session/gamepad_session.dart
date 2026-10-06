import 'dart:async';
import 'dart:io';

import 'package:gamypad_pc/src/device/gamepad_device.dart';
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:protocol/protocol.dart';

void _trace(String message) {
  stderr.writeln('[session] $message');
}

class GamepadSession {
  final MessageSocket socket;
  final GamepadDevice device;

  GamepadSession({required this.socket, required this.device});

  StreamSubscription<Message>? _subscription;

  Stream<ConnectionState> get state => socket.state;
  int get port => socket.port;

  Future<void> start() async {
    _trace('start() called');
    _subscription = socket.messages.listen(
      apply,
      onError: (Object error, StackTrace stack) {
        _trace('stream error: $error');
        Error.throwWithStackTrace(error, stack);
      },
    );
    _trace('subscribed to ${socket.runtimeType}.messages');
    try {
      await socket.start();
      _trace('socket.start() returned, port=${socket.port}');
    } catch (e, st) {
      _trace('socket.start() THREW ${e.runtimeType}: $e');
      _trace('stack: $st');
      rethrow;
    }
  }

  Future<void> stop() async {
    _trace('stop() called');
    await _subscription?.cancel();
    _subscription = null;
    _trace('subscription cancelled');
    await socket.stop();
    _trace('socket stopped');
  }

  void dispose() {
    _trace('dispose() -> device.dispose()');
    device.dispose();
  }

  void apply(Message message) {
    switch (message) {
      case ButtonMessage(:final button, :final pressed):
        device.setButton(button, pressed);
      case TriggerMessage(:final trigger, :final value):
        device.setTrigger(trigger, value);
      case StickMessage(:final stick, :final x, :final y):
        device.setStick(stick, x, y);
      case Ping():
        socket.send(const Pong());
      case Pong():
        break;
    }
  }
}

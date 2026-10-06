import 'dart:async';
import 'dart:io';

import 'package:gamypad_pc/src/device/gamepad_device.dart';
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:protocol/protocol.dart';

/// Temporary tracing. Uses stderr rather than debugPrint so this layer stays
/// free of Flutter and `dart test` keeps working on it. Strip before release.
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
        // Rethrow so it surfaces as an uncaught async error. Without this the
        // first exception (e.g. /dev/uinput going away mid-session) cancels the
        // subscription permanently and leaves a live-looking server that
        // silently applies nothing.
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

  /// Stops listening and closes the socket. Reversible: calling [start] again
  /// resumes with the same device.
  Future<void> stop() async {
    _trace('stop() called');
    await _subscription?.cancel();
    _subscription = null;
    _trace('subscription cancelled');
    await socket.stop();
    _trace('socket stopped');
  }

  /// Permanent teardown. Separate from [stop] because the gamepad must survive
  /// a stop/start cycle — disposing here would free the native handle and leave
  /// every later write going nowhere, with no error to notice it by.
  void dispose() {
    _trace('dispose() -> device.dispose()');
    device.dispose();
  }

  /// Feeds one message to the device.
  ///
  /// Public because the in-app testing ground drives the session directly,
  /// with no socket in the way. It is the same path an incoming packet takes,
  /// so anything this exercises is genuinely covered.
  void apply(Message message) {
    switch (message) {
      case ButtonMessage(:final button, :final pressed):
        _trace('apply button ${button.name} -> ${pressed ? 1 : 0}');
        device.setButton(button, pressed);
      case TriggerMessage(:final trigger, :final value):
        _trace('apply trigger ${trigger.name} -> $value');
        device.setTrigger(trigger, value);
      case StickMessage(:final stick, :final x, :final y):
        _trace('apply stick ${stick.name} -> $x,$y');
        device.setStick(stick, x, y);
      case Ping():
        _trace('apply ping -> replying pong');
        socket.send(const Pong());
      case Pong():
        _trace('apply pong (ignored)');
        break;
    }
  }
}

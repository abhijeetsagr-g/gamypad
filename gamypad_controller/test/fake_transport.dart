import 'dart:async';

import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:protocol/protocol.dart';

/// Stands in for `UdpTransport` so the layers above it can be exercised with no
/// sockets, no network and instant timers.
///
/// Not a subclass: [GamepadTransport] is an `abstract interface class`, so
/// implementing it *is* the only option — which is the point of it being one.
/// A hand-written fake can only implement an interface, so the interface has to
/// survive contact with a test double.
///
/// Shared rather than per-file because both the state layer and the input layer
/// need it, and a second copy would drift the moment either grew a field.
///
/// [sent] records messages instead of putting them on a wire, which is what lets
/// the input layer's behaviour be asserted as *order and content* rather than as
/// datagrams that would have to be decoded back to be checked.
class FakeTransport implements GamepadTransport {
  final sent = <Message>[];

  final _status = StreamController<ConnectionStatus>.broadcast();
  final _incoming = StreamController<Message>.broadcast();

  /// Hosts the caller asked for, in order.
  final connectCalls = <ConnectionTarget>[];

  var disconnectCalls = 0;

  /// Thrown by the next [connect], if set. Cleared after being thrown.
  Object? failWith;

  /// When true, [connect] reports `connected` the way a real socket does. Off
  /// by default so a test that does not care about status sees only what it
  /// asked for.
  bool reportConnectedOnConnect = true;

  @override
  Future<void> connect(ConnectionTarget target) async {
    connectCalls.add(target);
    final failure = failWith;
    if (failure != null) {
      failWith = null;
      throw failure;
    }
    if (reportConnectedOnConnect) {
      _status.add(ConnectionStatus.connecting);
      _status.add(ConnectionStatus.connected);
    }
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    _status.add(ConnectionStatus.disconnected);
  }

  @override
  Future<void> send(Message message) async => sent.add(message);

  @override
  Stream<ConnectionStatus> get status => _status.stream;

  @override
  Stream<Message> get incoming => _incoming.stream;

  /// Simulates the transport reporting something on its own — how the watchdog
  /// reaches the state layer, and how a reconnect reaches the input layer.
  void emit(ConnectionStatus status) => _status.add(status);

  Future<void> close() async {
    await _status.close();
    await _incoming.close();
  }
}

/// Broadcast delivery is async; give queued events a turn to land.
///
/// Reading [FakeTransport.sent] straight after an [emit] without this sees a
/// stale list, which reads as a real failure and is not one.
Future<void> settle() => Future<void>.delayed(Duration.zero);

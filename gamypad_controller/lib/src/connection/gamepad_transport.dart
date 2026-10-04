import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:protocol/protocol.dart';

abstract interface class GamepadTransport {
  Future<void> connect(ConnectionTarget target);

  /// Stops the timers, closes the socket, and returns status to
  /// [ConnectionStatus.disconnected].
  Future<void> disconnect();

  /// Encodes and sends one message.
  Future<void> send(Message message);

  /// The connection's state over time.
  Stream<ConnectionStatus> get status;

  /// Messages the server sent us.
  Stream<Message> get incoming;
}

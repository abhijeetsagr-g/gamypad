import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:protocol/protocol.dart';

abstract interface class GamepadTransport {
  Future<void> connect(ConnectionTarget target);
  Future<void> disconnect();
  Future<void> send(Message message);
  Stream<ConnectionStatus> get status;
  Stream<Message> get incoming;
}

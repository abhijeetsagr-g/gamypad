import 'package:protocol/protocol.dart';

enum ConnectionState { idle, listening, connected }

abstract interface class MessageSocket {
  Stream<Message> get messages;
  Stream<ConnectionState> get state;
  int get port;
  void send(Message message);
  Future<void> start();
  Future<void> stop();
}

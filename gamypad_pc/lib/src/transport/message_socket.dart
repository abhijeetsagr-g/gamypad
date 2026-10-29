import 'package:protocol/protocol.dart';

enum ConnectionState { idle, listening, connected }

abstract interface class MessageSocket {
  Stream<Message> get messages;
  Stream<ConnectionState> get state;
  int get port;
  void send(Message message);

  /// Binds to [port]; 0 lets the OS pick a free one.
  Future<void> start({int port = 0});
  Future<void> stop();
}

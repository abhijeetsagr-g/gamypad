import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:protocol/protocol.dart';

/// Temporary tracing, stderr so this layer stays Flutter-free. Strip later.
void _trace(String message) {
  stderr.writeln('[udp] $message');
}

class UdpSocket implements MessageSocket {
  RawDatagramSocket? _socket;
  Timer? _watchdog;

  /// Seconds without a packet before the client is considered gone.
  static const interval = 5;

  // Broadcast so start/stop is reversible: a single-subscription controller
  // cannot be listened to twice, and the UI's toggle stops then starts the
  // server. Messages that arrive while stopped are dropped, which is correct
  // — nothing should be applying input then.
  final _messages = StreamController<Message>.broadcast();
  final _state = StreamController<ConnectionState>.broadcast();

  InternetAddress? _clientAddress;
  int? _clientPort;

  // Keep a track on when the last Packet was spent
  DateTime? _lastPacket;

  @override
  int get port => _socket?.port ?? 0;

  @override
  Stream<Message> get messages => _messages.stream;

  @override
  Future<void> start() async {
    _trace('start() binding to anyIPv4:0');
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (e) {
      _trace('bind FAILED: ${e.runtimeType}: $e');
      rethrow;
    }
    _trace('bound, ephemeral port = ${_socket!.port}');
    _socket!.listen(_onEvent);
    _state.add(ConnectionState.listening);
    _trace('emitted ConnectionState.listening');
    _startWatchdog();
  }

  @override
  void send(Message message) {
    // Must target the client's port, not our own bound port.
    final address = _clientAddress;
    final clientPort = _clientPort;
    if (_socket == null || address == null || clientPort == null) return;
    _socket!.send(utf8.encode(message.encode()), address, clientPort);
  }

  @override
  Stream<ConnectionState> get state => _state.stream;

  @override
  Future<void> stop() async {
    _trace('stop()');
    _watchdog?.cancel();
    _watchdog = null;
    _socket?.close();
    _socket = null;
    _clientPort = null;
    _clientAddress = null;
    _state.add(ConnectionState.idle);
    _trace('emitted ConnectionState.idle');
  }

  void _startWatchdog() {
    _watchdog = Timer.periodic(Duration(seconds: interval), (_) {
      if (_lastPacket == null) return;
      final elapsed = DateTime.now().difference(_lastPacket!);
      if (elapsed.inSeconds > interval) {
        _trace(
          'watchdog: no traffic for ${elapsed.inSeconds}s, dropping client',
        );
        _lastPacket = null;
        _clientAddress = null;
        _clientPort = null;
        _state.add(ConnectionState.listening);
      }
    });
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    _trace('socket event: read');
    Datagram? dg;
    while ((dg = _socket?.receive()) != null) {
      _handle(dg!);
    }
  }

  void _handle(Datagram dg) {
    Message message;
    try {
      final json = jsonDecode(utf8.decode(dg.data));
      if (json is! Map<String, dynamic>) {
        _trace(
          'packet from ${dg.address.address}:${dg.port} is not a JSON object',
        );
        return;
      }
      message = Message.fromJson(json);
    } on FormatException catch (e) {
      _trace(
        'packet from ${dg.address.address}:${dg.port} rejected: ${e.message}',
      );
      return; // malformed: not a client, do not touch state
    }

    final wasConnected = _clientAddress != null;
    _lastPacket = DateTime.now();
    _clientAddress = dg.address;
    _clientPort = dg.port;
    if (!wasConnected) {
      _trace('first packet from ${dg.address.address}:${dg.port}');
      _state.add(ConnectionState.connected);
    }
    _trace(
      'parsed ${message.runtimeType} from ${dg.address.address}:${dg.port}',
    );
    _messages.add(message);
  }
}

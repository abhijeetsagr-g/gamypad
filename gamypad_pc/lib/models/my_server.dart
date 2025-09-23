import 'dart:convert';
import 'dart:io';

import 'package:gamypad_pc/models/gamepad.dart';

class MyServer {
  final Gamepad _gamepad = Gamepad();
  RawDatagramSocket? _server;
  String _error = "";
  bool _running = false;

  void Function(bool connected)? onClientStatusChanged;

  Future<void> start() async {
    // Try connecting the UDP connection
    try {
      _server = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _running = true;
      _server!.listen(_handleEvent);
    } on SocketException catch (e) {
      _error = e.message;
      return;
    }
  }

  /// Handle socket events
  void _handleEvent(RawSocketEvent event) {
    if (!_running) return;

    if (event == RawSocketEvent.read) {
      Datagram? dg;
      while ((dg = _server!.receive()) != null) {
        onClientStatusChanged?.call(true);
        try {
          final data = utf8.decode(dg!.data);
          _gamepad.handleClient(data);
        } catch (e) {
          _error = "Failed to decode packet: $e";
        }
      }
    }
  }

  /// Stop the UDP server safely
  Future<void> stop() async {
    if (!_running) return;

    _running = false;
    try {
      _server?.close();
    } catch (e) {
      _error = "Error closing server: $e";
    }

    _server = null;
    onClientStatusChanged?.call(false);
  }

  void deleteGamepad() {
    _gamepad.dispose();
  }

  int get runningPort => _server?.port ?? -1;
  String get errorMessage => _error;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Client with ChangeNotifier {
  Socket? _socket;
  bool _isConnected = false;

  // Callbacks that can be assigned from the UI/Provider
  void Function()? onDisconnected;
  void Function(Object error)? onError;

  bool get isConnected => _isConnected;
  Socket? get client => _socket;

  Future<void> connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _isConnected = _socket != null;
    notifyListeners();

    // Listen for incoming data from the server
    _socket!.listen(
      (data) {
        final msg = utf8.decode(data).trim();
        print("Server: $msg");
      },
      onError: (error) {
        _isConnected = false;
        onError?.call(error);
        notifyListeners();
        disconnect();
      },
      onDone: () {
        _isConnected = false;
        onDisconnected?.call();
        notifyListeners();
        disconnect();
      },
    );
  }

  /// Send a Dart map as JSON
  void sendJson(Map<String, dynamic> message) {
    if (_socket != null) {
      final jsonString = "${jsonEncode(message)}\n"; // delimiter
      _socket!.write(jsonString);
      // print('Sent: $jsonString');
    } else {
      // print('Not connected to the server.');
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class Client with ChangeNotifier {
  RawDatagramSocket? _client;
  InternetAddress? _address;
  int _port = 0;
  bool get isConnected => _client != null;

  void Function(String error)? onError;
  void Function()? onDisconnected;

  // Initialize the UDP Client
  Future<void> connect(String host, int port) async {
    _address = InternetAddress(host);
    _port = port;

    _client = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    notifyListeners();
  }

  // Send a Map as json over UDP
  void sendJson(Map<String, dynamic> message) {
    if (_client != null && _address != null) {
      final jsonString = jsonEncode(message);
      _client!.send(utf8.encode(jsonString), _address!, _port);
    }
  }

  // Disconnect
  void disconnect() {
    _client?.close();
    _client = null;
    notifyListeners();
  }

  String? get address => _address?.address;
  int? get port => _port;
}

import 'dart:convert';
import 'dart:io';

import 'package:gamypad_pc/models/gamepad.dart';

class MyServer {
  Gamepad? _gamepad = Gamepad();
  final int port;
  ServerSocket? _server;
  String _error = "";
  Socket? _client; // only one client at a time
  MyServer({this.port = 8080});

  // Callback for client status
  void Function(bool connected)? onClientStatusChanged;

  Future<void> start() async {
    _gamepad = Gamepad();
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    } on SocketException catch (e) {
      _error = e.message;
      return;
    }

    _server?.listen((client) {
      if (_client != null) {
        // Already connected, reject new client
        client.write("Server busy, only one client allowed.\n");
        client.close();
        return;
      }

      _client = client;
      onClientStatusChanged?.call(true);
      client
          .cast<List<int>>() // ensure the stream is List<int>
          .transform(utf8.decoder) // decode bytes → string
          .transform(const LineSplitter()) // split by \n
          .listen(
            (line) => handleClient(line),
            onDone: () {
              _client = null;
              onClientStatusChanged?.call(false);
            },
            onError: (err) {
              _error = err.toString();
              _client = null;
              onClientStatusChanged?.call(false);
            },
          );
    });
  }

  Future<void> stop() async {
    _gamepad?.dispose();
    _gamepad = null;
    await _client?.close();
    _client = null;
    await _server?.close();
    _server = null;
    onClientStatusChanged?.call(false);
  }

  void handleClient(String data) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(data);

      switch (decoded['action']) {
        case 'press':
          _gamepad?.pressKey(decoded['btn']);
          break;
        case 'release':
          _gamepad?.releaseKey(decoded['btn']);
          break;
        case 'leftStick':
          // btn for example will be : {'x' : '1230', 'y' : '1230'}
          int valueX = int.parse(decoded['btn']['x']);
          int valueY = int.parse(decoded['btn']['y']);
          _gamepad?.setAxis(1, valueX, valueY);
          break;
        case 'rightStick':
          // btn for example will be : {'x' : '1230', 'y' : '1230'}
          int valueX = int.parse(decoded['btn']['x']);
          int valueY = int.parse(decoded['btn']['y']);
          _gamepad?.setAxis(0, valueX, valueY);
          break;
        case 'RT':
          int value = int.parse(decoded['btn']);
          _gamepad?.setTrigger(0, value);
          break;
        case 'LT':
          int value = int.parse(decoded['btn']);
          _gamepad?.setTrigger(1, value);
          break;
      }
    } catch (e) {
      print("Invalid JSON: $data ,error : $e");
    }
  }

  String get address => _server?.address.host ?? "";
  int get runningPort => _server?.port ?? -1;
  bool get hasClient => _client != null;
  String get errorMessage => _error;
}

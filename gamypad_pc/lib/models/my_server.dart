import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gamypad_pc/models/gamepad.dart';

class MyServer {
  final Gamepad _gamepad = Gamepad();
  RawDatagramSocket? _server;
  Timer? _watchdog;
  DateTime? _lastPacket;
  String _error = "";
  bool _running = false;
  InternetAddress? _clientAddress;
  int? _clientPort;

  void Function(bool connected)? onClientStatusChanged;

  void _onPacket(Datagram dg) {
    _lastPacket = DateTime.now();
    _clientAddress = dg.address;
    _clientPort = dg.port;
    onClientStatusChanged?.call(true);

    try {
      final data = utf8.decode(dg.data);
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) return;
      if (json['type'] == 'ping') {
        // reply pong back to client
        _server!.send(
          utf8.encode(jsonEncode({"type": "pong"})),
          _clientAddress!,
          _clientPort!,
        );
        return;
      }
      _gamepad.handleClient(data);
    } catch (e) {
      _error = "Failed to decode packet: $e";
    }
  }

  Future<void> start() async {
    try {
      _server = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _running = true;
      _server!.listen(_handleEvent);
      _startWatchdog();
    } on SocketException catch (e) {
      _error = e.message;
    }
  }

  void _handleEvent(RawSocketEvent event) {
    if (!_running) return;
    if (event != RawSocketEvent.read) return;

    Datagram? dg;
    while ((dg = _server!.receive()) != null) {
      _onPacket(dg!);
    }
  }

  void _startWatchdog() {
    _watchdog = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastPacket == null) return;
      final elapsed = DateTime.now().difference(_lastPacket!);
      if (elapsed.inSeconds > 5) {
        _lastPacket = null;
        onClientStatusChanged?.call(false);
      }
    });
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _watchdog?.cancel();
    _watchdog = null;
    _lastPacket = null;
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

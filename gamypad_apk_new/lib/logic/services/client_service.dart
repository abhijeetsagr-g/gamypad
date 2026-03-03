import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ClientService {
  RawDatagramSocket? _socket;
  InternetAddress? _address;
  int? _port;
  Timer? _pingTimer;
  DateTime? _lastPong;
  Timer? _watchdog;

  void Function()? onDisconnected;

  // send ping to the server
  void _startPing() {
    _pingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      sendJson({"type": "ping"});
    });
  }

  void _startWatchdog() {
    // give server 6s grace on first connect
    _lastPong = DateTime.now();
    _watchdog = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastPong == null) return;
      final elapsed = DateTime.now().difference(_lastPong!);

      // if server don't ping back, it is disconnected
      if (elapsed.inSeconds > 5) {
        disconnect();
      }
    });
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _socket?.receive();
    if (dg == null) return;
    try {
      // update last ping time
      final json = jsonDecode(utf8.decode(dg.data));
      if (json is Map<String, dynamic> && json['type'] == 'pong') {
        _lastPong = DateTime.now();
      }
    } catch (_) {}
  }

  Future<void> connect(String host, int port) async {
    try {
      _address = (await InternetAddress.lookup(host)).first;
      _port = port;
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.listen(
        _onEvent,
        onError: (e) => disconnect(),
        onDone: () => disconnect(),
      );

      // Start pining logic
      _startPing();
      _startWatchdog();
    } catch (e) {
      disconnect();
      rethrow;
    }
  }

  // Run for Gamepad
  void sendJson(Map<String, dynamic> message) {
    if (_socket == null || _address == null || _port == null) return;
    try {
      final bytes = utf8.encode(jsonEncode(message));
      final sent = _socket!.send(bytes, _address!, _port!);
      print('sent $sent bytes to $_address:$_port'); // add this
    } catch (e) {
      print('send error: $e'); // and this
    }
  }

  // run on exit
  void disconnect() {
    onDisconnected?.call();
    _pingTimer?.cancel();
    _watchdog?.cancel();
    _socket?.close();

    _pingTimer = null;
    _watchdog = null;
    _lastPong = null;
    _socket = null;
    _address = null;
    _port = null;
  }

  // getters
  bool get isConnected => _socket != null;
  String? get address => _address?.address;
  int? get port => _port;
}

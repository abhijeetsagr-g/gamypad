import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gamypad_pc/models/gamepad.dart';

class ConnectedClient {
  ConnectedClient(this.gamepad);

  final Gamepad gamepad;
  DateTime lastSeen = DateTime.now();
}

class ClientInfo {
  ClientInfo(this.playerIndex, this.endpoint, this.lastSeen);

  final int playerIndex;
  final String endpoint;
  final DateTime lastSeen;
}

class MyServer {
  final Map<String, ConnectedClient> _clients = {};
  RawDatagramSocket? _server;
  Timer? _watchdog;
  String _error = "";
  bool _running = false;
  int _nextPlayerIndex = 1;

  void Function(List<ClientInfo> clients)? onClientsChanged;

  List<ClientInfo> get clients => _clients.entries
      .map((e) => ClientInfo(
          e.value.gamepad.playerIndex, e.key, e.value.lastSeen))
      .toList()
    ..sort((a, b) => a.playerIndex.compareTo(b.playerIndex));

  void _notifyClientsChanged() => onClientsChanged?.call(clients);

  String _keyFor(Datagram dg) => '${dg.address.address}:${dg.port}';

  void _onPacket(Datagram dg) {
    try {
      final data = utf8.decode(dg.data);
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) return;

      final key = _keyFor(dg);
      final isPing = json['type'] == 'ping';

      final existing = _clients[key];
      if (existing != null) {
        existing.lastSeen = DateTime.now();
      } else if (isPing) {
        // First contact from a new phone -> it becomes its own controller.
        final client = ConnectedClient(Gamepad(_nextPlayerIndex++));
        _clients[key] = client;
        print('🎮 Player ${client.gamepad.playerIndex} connected: $key');
        _notifyClientsChanged();
      } else {
        // Input before any ping (or unknown packet type) — ignore.
        return;
      }

      if (isPing) {
        // reply pong back to client
        _server!.send(
          utf8.encode(jsonEncode({"type": "pong"})),
          dg.address,
          dg.port,
        );
        return;
      }

      existing!.gamepad.handleClient(data);
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
      final now = DateTime.now();
      final stale = _clients.entries
          .where((e) => now.difference(e.value.lastSeen).inSeconds > 5)
          .map((e) => e.key)
          .toList();

      for (final key in stale) {
        final client = _clients.remove(key)!;
        print('📴 Player ${client.gamepad.playerIndex} disconnected: $key');
        client.gamepad.dispose();
      }

      if (stale.isNotEmpty) {
        _notifyClientsChanged();
      }
    });
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _watchdog?.cancel();
    _watchdog = null;
    try {
      _server?.close();
    } catch (e) {
      _error = "Error closing server: $e";
    }
    _server = null;
    _disposeAll();
  }

  /// Kick a single device by its "ip:port" endpoint. Returns true if found.
  bool kickClient(String endpoint) {
    final client = _clients.remove(endpoint);
    if (client == null) return false;
    print('🦶 Kicked Player ${client.gamepad.playerIndex}: $endpoint');
    client.gamepad.dispose();
    _notifyClientsChanged();
    return true;
  }

  void _disposeAll() {
    for (final client in _clients.values) {
      client.gamepad.dispose();
    }
    _clients.clear();
    _nextPlayerIndex = 1;
    _notifyClientsChanged();
  }

  void deleteGamepad() {}

  int get runningPort => _server?.port ?? -1;
  String get errorMessage => _error;
  int get connectedCount => _clients.length;
}
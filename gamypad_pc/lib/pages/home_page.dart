import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gamypad_pc/models/my_server.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MyServer _server;
  String _ip = "";
  bool _serverOn = false;
  List<ClientInfo> _clients = [];
  String _error = "";

  @override
  void initState() {
    super.initState();
    _server = MyServer();
    _server.onClientsChanged = (clients) {
      setState(() => _clients = clients);
    };
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return '127.0.0.1';
  }

  Future<void> _startServer() async {
    setState(() => _error = "");
    await _server.start();
    if (_server.errorMessage.isNotEmpty) {
      setState(() => _error = _server.errorMessage);
      return;
    }
    final ip = await _getLocalIp();
    setState(() {
      _ip = ip;
      _serverOn = true;
    });
  }

  Future<void> _stopServer() async {
    await _server.stop();
    setState(() {
      _serverOn = false;
      _clients = [];
      _ip = "";
    });
  }

  Future<void> _confirmKick(ClientInfo c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Text(
          'Kick Player ${c.playerIndex}?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        content: Text(
          '${c.endpoint} will be disconnected and its virtual gamepad removed. The phone can reconnect by tapping Connect again.',
          style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('KICK',
                style: TextStyle(
                    fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 11)),
          ),
        ],
      ),
    );
    if (confirmed == true) _server.kickClient(c.endpoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'GAMYPAD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _clients.isNotEmpty
                      ? '${_clients.length} CONNECTED'
                      : _serverOn
                      ? 'WAITING'
                      : 'OFF',
                  style: TextStyle(
                    color: _clients.isNotEmpty
                        ? const Color(0xFF00FF88)
                        : _serverOn
                        ? Colors.orange
                        : Colors.white24,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _clients.isNotEmpty
                        ? const Color(0xFF00FF88)
                        : _serverOn
                        ? Colors.orange
                        : Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status display
              if (_serverOn) ...[
                // QR always visible — every phone can scan the same code
                QrImageView(
                  data: '$_ip:${_server.runningPort}',
                  version: QrVersions.auto,
                  size: 150,
                  backgroundColor: Colors.white,
                ),

                Text(
                  _clients.isNotEmpty
                      ? '${_clients.length} DEVICE${_clients.length == 1 ? '' : 'S'} CONNECTED'
                      : 'WAITING FOR DEVICE',
                  style: TextStyle(
                    color: _clients.isNotEmpty
                        ? const Color(0xFF00FF88)
                        : Colors.white38,
                    fontSize: 12,
                    letterSpacing: 4,
                  ),
                ),
                if (_clients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final c in _clients)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.only(
                          left: 16, right: 6, top: 6, bottom: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF00FF88).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gamepad,
                              color: Color(0xFF00FF88), size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'PLAYER ${c.playerIndex}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            c.endpoint,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '● LIVE',
                            style: TextStyle(
                              color: Color(0xFF00FF88),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            color: Colors.white38,
                            hoverColor: Colors.red.withValues(alpha: 0.15),
                            tooltip: 'Kick',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 28, minHeight: 28),
                            onPressed: () => _confirmKick(c),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                Text(
                  _ip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PORT  ${_server.runningPort}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    letterSpacing: 4,
                  ),
                ),
              ] else ...[
                const Text(
                  'SERVER OFF',
                  style: TextStyle(
                    color: Colors.white12,
                    fontSize: 18,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // Error
              if (_error.isNotEmpty) ...[
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Button
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: _serverOn ? _stopServer : _startServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _serverOn
                        ? Colors.red[900]
                        : const Color(0xFF00FF88),
                    foregroundColor: _serverOn ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _serverOn ? 'STOP SERVER' : 'START SERVER',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
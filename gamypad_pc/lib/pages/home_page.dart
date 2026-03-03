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
  bool _clientConnected = false;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _server = MyServer();
    _server.onClientStatusChanged = (connected) {
      setState(() => _clientConnected = connected);
    };
  }

  @override
  void dispose() {
    _server.stop();
    _server.deleteGamepad();
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
      _clientConnected = false;
      _ip = "";
    });
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
                  _clientConnected
                      ? 'CONNECTED'
                      : _serverOn
                      ? 'WAITING'
                      : 'OFF',
                  style: TextStyle(
                    color: _clientConnected
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
                    color: _clientConnected
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
                // show this in HomePage when server is running
                if (!_clientConnected)
                  QrImageView(
                    data: '$_ip:${_server.runningPort}',
                    version: QrVersions.auto,
                    size: 150,
                    backgroundColor: Colors.white,
                  ),

                Text(
                  _clientConnected ? 'DEVICE CONNECTED' : 'WAITING FOR DEVICE',
                  style: TextStyle(
                    color: _clientConnected
                        ? const Color(0xFF00FF88)
                        : Colors.white38,
                    fontSize: 12,
                    letterSpacing: 4,
                  ),
                ),
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

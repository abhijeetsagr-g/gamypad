import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gamypad_pc/models/my_server.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MyServer server;
  String ip = "";

  bool isServerOn = false;
  String errorMessage = "";
  bool isDeviceConnected = false;

  Future<String> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) {
          return addr.address; // first non-loopback IPv4
        }
      }
    }
    return '127.0.0.1';
  }

  Future<void> turnServerOn() async {
    try {
      await server.start();
      if (server.errorMessage.isNotEmpty) {
        setState(() {
          errorMessage = server.errorMessage;
        });
        return;
      }

      ip = await getLocalIpAddress();
      setState(() {
        isServerOn = true;
      });
      server.onClientStatusChanged = (connected) {
        setState(() {
          isDeviceConnected = connected;
        });
      };
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> turnServerOff() async {
    await server.stop();
    setState(() {
      isServerOn = false;
      isDeviceConnected = false;
    });
  }

  @override
  void initState() {
    super.initState();
    server = MyServer();
  }

  @override
  void dispose() {
    super.dispose();
    server.stop();
    server.deleteGamepad();
  }

  List<Widget> onServerOff() {
    return [
      Text(
        "Press the following button to run the server",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(),
          foregroundColor: Colors.white,
        ),
        onPressed: turnServerOn,
        child: Text("Start Server"),
      ),
      if (errorMessage.isNotEmpty) Text(errorMessage),
    ];
  }

  List<Widget> onServerOn() {
    return [
      Text(
        "Server running on $ip:${server.runningPort}, Use your phone to connect",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),

      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(),
          foregroundColor: Colors.red,
        ),
        onPressed: turnServerOff,
        child: Text("Stop Server"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamypad Control Center'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDeviceConnected ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isServerOn ? onServerOn() : onServerOff(),
        ),
      ),
    );
  }
}

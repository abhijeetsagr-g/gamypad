import 'dart:io';
import 'dart:convert';

bool isConnected = false;
bool isError = false;

Socket? socket;
final int headerSize = 64;

Object? error;

void connectServer(serverIP, port) async {
  isError = false;
  try {
    socket = await Socket.connect(serverIP, port);
  } catch (e) {
    isError = true;
    error = e;
  }
}

void sendJson(String btn, String action) {
  if (socket != null) {
    final data = jsonEncode({"btn": btn, "action": action});
    final length = utf8.encode(data).length;
    final header = utf8.encode(length.toString().padRight(headerSize));
    socket!.add(header + utf8.encode(data));
  }
}

void disconnectServer() {
  if (socket != null) {
    final data = jsonEncode({"exit": true});
    final length = utf8.encode(data).length;
    final header = utf8.encode(length.toString().padRight(headerSize));
    socket!.add(header + utf8.encode(data));
    socket!.destroy();
  }
}

import 'dart:io';
import 'dart:convert';

bool isConnected = false;
bool isError = false;

Socket? socket;
final int headerSize = 64;
Object? error;

Future<Object?> connectServer(String serverIP, int port) async {
  isError = false;
  try {
    socket = await Socket.connect(serverIP, port);
    isConnected = true;
    return null;
  } catch (e) {
    isError = true;
    error = e;
    return e;
  }
}

void checkConnection() {
  if (socket != null) {}
}

void sendJson(String btn, String action) {
  if (socket != null && isConnected) {
    try {
      final data = jsonEncode({"btn": btn, "action": action});
      final bodyBytes = utf8.encode(data);
      final length = bodyBytes.length;
      final header = utf8.encode(length.toString().padLeft(headerSize, '0'));

      socket!.add(header + bodyBytes);
    } catch (e) {
      error = e;
    }
  }
}

Future<void> disconnectServer() async {
  if (socket != null && isConnected) {
    try {
      final data = jsonEncode({"exit": true});
      final length = utf8.encode(data).length;
      final header = utf8.encode(length.toString().padRight(headerSize));
      socket!.add(header + utf8.encode(data));
      await socket!.flush();
      await socket!.close();
      isConnected = false;
    } catch (e) {
      error = e;
    }
  }
}

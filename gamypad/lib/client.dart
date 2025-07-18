import 'dart:async';
import 'dart:convert';
import 'dart:io';

Socket? client;
final int headerSize = 64;
final String exitCode = "EXIT";

bool socketConnection = false;

Future<String?> connectServer(String addr, int port) async {
  final ipRegex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
    r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );

  if (addr.isEmpty) {
    return "IP address and port must not be empty.";
  }

  if (!ipRegex.hasMatch(addr)) {
    return "Invalid IP address format.";
  }

  if (port < 0 || port > 65535) {
    return "Port must be a number between 0 and 65535.";
  }

  try {
    client = await Socket.connect(addr, port);
    socketConnection = true;
  } catch (e) {
    return e.toString();
  }

  return "";
}

String? sendJson(String btnName, String action) {
  if (client != null && socketConnection) {
    try {
      // Send the btn and it's action
      final data = jsonEncode({"btn": btnName, "action": action});
      final bodyBytes = utf8.encode(data);
      final length = bodyBytes.length;
      final header = utf8.encode(length.toString().padLeft(headerSize, " "));

      client!.add(header + bodyBytes);
    } catch (e) {
      return e.toString();
    }
  }
  return "";
}

void sendThumbstick(pos, String dir) {}

Future<String> disconnectServer() async {
  if (client != null && socketConnection) {
    try {
      final data = jsonEncode({exitCode: true});
      final length = utf8.encode(data).length;
      final header = utf8.encode(length.toString().padRight(headerSize));

      client!.add(header + utf8.encode(data));

      await client!.flush();
      await client!.close();

      socketConnection = false;
    } catch (e) {
      return e.toString();
    }
  }
  return "";
}

import 'dart:io';

class MyServer {
  final int port;
  ServerSocket? _server;
  String _error = "";
  Socket? _client; // only one client at a time
  MyServer({this.port = 8080});

  // Callback for client status
  void Function(bool connected)? onClientStatusChanged;

  Future<void> start() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    _server?.listen((client) {
      if (_client != null) {
        // Already connected, reject new client
        client.write("Server busy, only one client allowed.\n");
        client.close();
        return;
      }

      _client = client;
      onClientStatusChanged?.call(true);
      client.listen(
        (event) {
          final data = String.fromCharCodes(event).trim();
          handleClient(data);
        },
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
    await _client?.close();
    _client = null;
    await _server?.close();
    onClientStatusChanged?.call(false);
  }

  void handleClient(String data) {
    print("Received: $data");
  }

  String get address => _server?.address.host ?? "";
  int get runningPort => _server?.port ?? -1;
  bool get hasClient => _client != null;
  String get errorMessage => _error;
}

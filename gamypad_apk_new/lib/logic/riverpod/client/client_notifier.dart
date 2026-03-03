import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/client/client_state.dart';
import 'package:gamypad_apk_new/logic/services/client_service.dart';

class ClientNotifier extends Notifier<ClientState> {
  late final ClientService _service;

  @override
  ClientState build() {
    _service = ClientService();
    _service.onDisconnected = () {
      state = const ClientState(); // reset to default
    };
    return const ClientState();
  }

  Future<void> connect(String host, int port) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.connect(host, port);
      state = ClientState(
        isConnected: true,
        address: _service.address,
        port: _service.port,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void disconnect() {
    _service.disconnect();
    state = const ClientState();
  }

  void sendJson(Map<String, dynamic> message) => _service.sendJson(message);
}

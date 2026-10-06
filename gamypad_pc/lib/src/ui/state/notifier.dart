import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:gamypad_pc/src/ui/state/providers.dart';

class ServerState {
  final ConnectionState connection;
  final int port;
  final String ip;
  final bool busy;
  final String? error;

  const ServerState({
    this.connection = ConnectionState.idle,
    this.port = 0,
    this.ip = '',
    this.busy = false,
    this.error,
  });

  bool get isRunning => connection != ConnectionState.idle;
  bool get isConnected => connection == ConnectionState.connected;

  static const _unset = Object();

  ServerState copyWith({
    ConnectionState? connection,
    int? port,
    String? ip,
    bool? busy,
    Object? error = _unset,
  }) => ServerState(
    connection: connection ?? this.connection,
    port: port ?? this.port,
    ip: ip ?? this.ip,
    busy: busy ?? this.busy,
    error: identical(error, _unset) ? this.error : error as String?,
  );
}

class ServerController extends Notifier<ServerState> {
  @override
  ServerState build() {
    final session = ref.watch(sessionProvider);

    final sub = session.state.listen((next) {
      state = state.copyWith(connection: next, error: null);
    });
    ref.onDispose(sub.cancel);

    return const ServerState();
  }

  Future<void> start() async {
    final session = ref.read(sessionProvider);
    state = state.copyWith(busy: true, error: null);

    try {
      await session.start();

      final ip = await ref.read(localIpProvider.future);
      state = state.copyWith(port: session.port, ip: ip);
    } on SocketException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: '$e');
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> stop() async {
    await ref.read(sessionProvider).stop();
  }
}

final serverControllerProvider =
    NotifierProvider<ServerController, ServerState>(ServerController.new);

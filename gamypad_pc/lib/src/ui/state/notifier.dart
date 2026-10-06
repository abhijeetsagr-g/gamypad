import 'dart:io';

import 'package:flutter/foundation.dart';
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

  /// Sentinel distinguishing "not passed" from "passed null". Without it as the
  /// default, an omitted `error` reads as null and the ternary always clears.
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

    // UdpSocket owns ConnectionState; mirror it in so widgets rebuild.
    final sub = session.state.listen((next) {
      debugPrint('[state] socket says $next -> copying into ServerState');
      state = state.copyWith(connection: next, error: null);
    });
    ref.onDispose(sub.cancel);

    debugPrint('[state] build() ran, watching ${session.runtimeType}');
    return const ServerState();
  }

  Future<void> start() async {
    final session = ref.read(sessionProvider);
    debugPrint('[state] start() entered');

    state = state.copyWith(busy: true, error: null);
    debugPrint('[state] busy=true, error cleared');
    try {
      await session.start();
      debugPrint('[state] session.start() ok, port=${session.port}');

      final ip = await ref.read(localIpProvider.future);
      debugPrint('[state] ip resolved to $ip');

      state = state.copyWith(port: session.port, ip: ip);
      debugPrint('[state] committed port+ip');
    } on SocketException catch (e) {
      debugPrint('[state] SocketException: ${e.message}');
      state = state.copyWith(error: e.message);
    } catch (e, st) {
      // Previously uncaught: anything that was not a SocketException vanished
      // and left busy stuck or the UI showing nothing.
      debugPrint('[state] UNEXPECTED ${e.runtimeType}: $e\n$st');
      state = state.copyWith(error: '$e');
    } finally {
      state = state.copyWith(busy: false);
      debugPrint('[state] busy=false');
    }
    debugPrint('[state] start() finished with $state');
  }

  Future<void> stop() async {
    debugPrint('[state] stop() entered');
    await ref.read(sessionProvider).stop();
    debugPrint('[state] stop() done');
  }
}

/// Declared next to the notifier it constructs, so consumers need one import
/// for the type and its provider instead of two.
final serverControllerProvider =
    NotifierProvider<ServerController, ServerState>(ServerController.new);

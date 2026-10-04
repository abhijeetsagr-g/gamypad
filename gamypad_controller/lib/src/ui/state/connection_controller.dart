import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:gamypad_controller/src/connection/transport_provider.dart';

class ConnectionState {
  final ConnectionStatus status;
  final bool busy;
  final String? error;

  /// The server we are connected to, or were last connected to.
  final ConnectionTarget? target;

  const ConnectionState({
    this.status = ConnectionStatus.disconnected,
    this.busy = false,
    this.error,
    this.target,
  });

  bool get isActive => status != ConnectionStatus.disconnected;
  bool get isConnected => status == ConnectionStatus.connected;

  /// Was connected and lost the server.
  bool get isLost => status == ConnectionStatus.lost;

  /// Sentinel telling "argument omitted" from "argument was null".
  static const _unset = Object();

  ConnectionState copyWith({
    ConnectionStatus? status,
    bool? busy,
    Object? error = _unset,
    Object? target = _unset,
  }) => ConnectionState(
    status: status ?? this.status,
    busy: busy ?? this.busy,
    error: identical(error, _unset) ? this.error : error as String?,
    target: identical(target, _unset)
        ? this.target
        : target as ConnectionTarget?,
  );

  @override
  String toString() =>
      'ConnectionState(${status.name}, busy: $busy, error: $error, '
      'target: $target)';
}

/// Drives [GamepadTransport] and mirrors its status into [ConnectionState].
class ConnectionController extends Notifier<ConnectionState> {
  @override
  ConnectionState build() {
    final transport = ref.watch(transportProvider);

    final subscription = transport.status.listen((next) {
      state = state.copyWith(status: next, error: null, busy: false);
    });
    ref.onDispose(subscription.cancel);

    return const ConnectionState();
  }

  GamepadTransport get _transport => ref.read(transportProvider);

  /// Connects to [target], reporting failure through [ConnectionState.error]
  /// rather than by throwing.
  Future<void> connect(ConnectionTarget target) async {
    if (state.busy) return;

    // Cleared up front: an error from a previous attempt must not sit next to a
    // spinner for the duration of this one.
    state = state.copyWith(busy: true, error: null, target: target);

    try {
      await _transport.connect(target);
    } on SocketException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    } catch (error) {
      state = state.copyWith(busy: false, error: '$error');
    }
  }

  Future<void> disconnect() => _transport.disconnect();

  /// Retries the remembered target after a [ConnectionStatus.lost].
  Future<void> reconnect() async {
    final target = state.target;
    if (target == null) return;
    await connect(target);
  }
}

final connectionControllerProvider =
    NotifierProvider<ConnectionController, ConnectionState>(
      ConnectionController.new,
    );

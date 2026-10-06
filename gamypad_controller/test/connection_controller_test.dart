import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/transport_provider.dart';
import 'package:gamypad_controller/src/ui/state/connection_controller.dart';

import 'fake_transport.dart';

void main() {
  late FakeTransport transport;
  late ProviderContainer container;

  ConnectionState read() => container.read(connectionControllerProvider);
  ConnectionController controller() =>
      container.read(connectionControllerProvider.notifier);

  setUp(() {
    transport = FakeTransport();
    container = ProviderContainer(
      overrides: [transportProvider.overrideWithValue(transport)],
    );
  });

  tearDown(() async {
    container.dispose();
    await transport.close();
  });

  group('copyWith', () {
    const withError = ConnectionState(error: 'connection refused');

    test('preserves error when the argument is omitted', () {
      expect(withError.copyWith(busy: true).error, 'connection refused');
    });

    test('preserves error when unrelated fields change', () {
      expect(
        withError.copyWith(status: ConnectionStatus.connected).error,
        'connection refused',
      );
    });

    test('clears error only when null is passed explicitly', () {
      expect(withError.copyWith(error: null).error, isNull);
    });

    test('survives the set-then-clear sequence connect() performs', () {
      // Mirrors ConnectionController.connect(): clear error, then report a
      // failure, then release busy. The message must survive to the last copy.
      final state = const ConnectionState()
          .copyWith(busy: true, error: null)
          .copyWith(error: 'bind failed')
          .copyWith(busy: false);

      expect(state.busy, isFalse);
      expect(state.error, 'bind failed');
    });

    test('preserves target when omitted, clears it when explicit', () {
      // Both nullable, so both directions have to be pinned — the `?? this`
      // shortcut cannot express "set it to null".
      final withTarget = ConnectionState(
        target: UdpTarget(host: '10.0.0.5', port: 41234),
      );
      expect(withTarget.copyWith(busy: true).target, isNotNull);
      expect(withTarget.copyWith(target: null).target, isNull);
    });
  });

  group('defaults', () {
    test('starts disconnected with nothing to show', () {
      final state = read();
      expect(state.status, ConnectionStatus.disconnected);
      expect(state.busy, isFalse);
      expect(state.error, isNull);
      expect(state.target, isNull);
      expect(state.isActive, isFalse);
      expect(state.isConnected, isFalse);
      expect(state.isLost, isFalse);
    });

    test('isActive covers connecting, connected and lost', () {
      // Once the user has asked to pair, "not connected" is a lie.
      for (final status in [
        ConnectionStatus.connecting,
        ConnectionStatus.connected,
        ConnectionStatus.lost,
      ]) {
        expect(ConnectionState(status: status).isActive, isTrue);
      }
    });

    test('isConnected is true only when actually talking', () {
      // A connect in flight is not yet connected, and `lost` no longer is.
      expect(
        ConnectionState(status: ConnectionStatus.connected).isConnected,
        isTrue,
      );
      for (final status in [
        ConnectionStatus.disconnected,
        ConnectionStatus.connecting,
        ConnectionStatus.lost,
      ]) {
        expect(ConnectionState(status: status).isConnected, isFalse);
      }
    });

    test('a busy attempt is not a connection', () {
      expect(
        ConnectionState(
          status: ConnectionStatus.connecting,
          busy: true,
        ).isConnected,
        isFalse,
      );
    });
  });

  group('mirroring the transport', () {
    test('connect drives the transport and lands on connected', () async {
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();

      expect(transport.connectCalls, hasLength(1));
      expect(transport.connectCalls.single.host, '10.0.0.5');
      expect(read().status, ConnectionStatus.connected);
      expect(read().busy, isFalse);
      expect(read().error, isNull);
    });

    test('connecting is visible before it finishes', () async {
      transport.reportConnectedOnConnect = false;
      final pending = controller().connect(
        UdpTarget(host: '10.0.0.5', port: 41234),
      );
      await settle();

      // The status the transport has not reported yet is not the status the
      // user should see: they asked for something and it has not arrived.
      expect(read().busy, isTrue);
      expect(read().target?.host, '10.0.0.5');

      await pending;
    });

    test('the target is remembered for a later retry', () async {
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();
      expect(read().target.toString(), '10.0.0.5:41234');
    });

    test('a status the transport reports on its own reaches the UI', () async {
      // This is the watchdog's only route to the screen. Without the mirror in
      // build(), a lost connection would be invisible.
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();

      transport.emit(ConnectionStatus.lost);
      await settle();

      expect(read().status, ConnectionStatus.lost);
      expect(read().isLost, isTrue);
      expect(read().isConnected, isFalse);
    });

    test('a status change clears a stale error', () async {
      transport.failWith = SocketException('refused');
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();
      expect(read().error, isNotNull);

      transport.emit(ConnectionStatus.connected);
      await settle();

      // Otherwise the user reads a failure message while the status says
      // connected.
      expect(read().error, isNull);
    });

    test('disconnect is passed straight through', () async {
      await controller().disconnect();
      await settle();
      expect(transport.disconnectCalls, 1);
      expect(read().status, ConnectionStatus.disconnected);
    });
  });

  group('failure', () {
    test('a SocketException reports its message and does not throw', () async {
      transport.failWith = SocketException('connection refused');
      // The caller is a widget that wants to show a snackbar, so the reason
      // belongs in state rather than in an exception it has to catch.
      await expectLater(
        controller().connect(UdpTarget(host: '10.0.0.5', port: 41234)),
        completes,
      );
      await settle();

      expect(read().error, 'connection refused');
      expect(read().busy, isFalse);
      expect(read().isConnected, isFalse);
    });

    test('anything else is stringified rather than swallowed', () async {
      transport.failWith = StateError('boom');
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();
      expect(read().error, contains('boom'));
    });

    test('busy is always released, even on failure', () async {
      transport.failWith = SocketException('nope');
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();

      // A stuck spinner is the classic symptom of a missing `finally`.
      expect(read().busy, isFalse);
    });

    test('the failed target is still remembered, so retry can work', () async {
      transport.failWith = SocketException('nope');
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();
      expect(read().target?.host, '10.0.0.5');
    });

    test('a second connect while busy is ignored', () async {
      transport.reportConnectedOnConnect = false;
      final pending = controller().connect(
        UdpTarget(host: '10.0.0.5', port: 41234),
      );
      await settle();
      await controller().connect(UdpTarget(host: '10.0.0.6', port: 41234));
      await pending;
      await settle();

      // Two overlapping binds would leave one socket orphaned.
      expect(transport.connectCalls, hasLength(1));
    });
  });

  group('reconnect', () {
    test('retries the remembered target', () async {
      await controller().connect(UdpTarget(host: '10.0.0.5', port: 41234));
      await settle();
      transport.emit(ConnectionStatus.lost);
      await settle();

      await controller().reconnect();
      await settle();

      expect(transport.connectCalls, hasLength(2));
      expect(transport.connectCalls.last.toString(), '10.0.0.5:41234');
      expect(read().status, ConnectionStatus.connected);
    });

    test('does nothing when there is no target to retry', () async {
      // Nothing was ever connected, so there is no address to fall back on.
      await controller().reconnect();
      expect(transport.connectCalls, isEmpty);
    });
  });
}

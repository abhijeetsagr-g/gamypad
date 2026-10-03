import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:gamypad_pc/src/ui/state/notifier.dart';

/// `copyWith` on a nullable field is easy to get silently wrong: an omitted
/// argument and an explicit null both read as null, and the error path that
/// sets the message can be erased by the next copy that means to leave it
/// alone. Nothing about that is visible to the analyzer.
void main() {
  const withError = ServerState(error: 'bind failed');

  group('copyWith', () {
    test('preserves error when the argument is omitted', () {
      expect(withError.copyWith(busy: true).error, 'bind failed');
    });

    test('preserves error when unrelated fields change', () {
      expect(
        withError.copyWith(port: 41234, ip: '10.0.0.5').error,
        'bind failed',
      );
    });

    test('clears error when null is passed explicitly', () {
      expect(withError.copyWith(error: null).error, isNull);
    });

    test('sets error from a value', () {
      expect(const ServerState().copyWith(error: 'boom').error, 'boom');
    });

    test('survives the set-then-clear sequence start() actually performs', () {
      // Mirrors ServerController.start(): set busy and clear error, then report
      // a failure, then release busy. The message must survive to the last copy.
      var state = const ServerState()
          .copyWith(busy: true, error: null)
          .copyWith(error: 'bind failed')
          .copyWith(busy: false);

      expect(state.busy, isFalse);
      expect(state.error, 'bind failed');
    });
  });

  group('defaults', () {
    test('starts idle with nothing to show', () {
      const state = ServerState();
      expect(state.connection, ConnectionState.idle);
      expect(state.port, 0);
      expect(state.ip, '');
      expect(state.busy, isFalse);
      expect(state.error, isNull);
      expect(state.isRunning, isFalse);
    });

    test('isRunning tracks the connection, not busy', () {
      expect(
        const ServerState(connection: ConnectionState.listening).isRunning,
        isTrue,
      );
      expect(
        const ServerState(connection: ConnectionState.connected).isRunning,
        isTrue,
      );
      expect(
        const ServerState(busy: true).isRunning,
        isFalse,
        reason: 'busy is about the transition, not the socket',
      );
    });

    test('isConnected is true only when a controller is attached', () {
      // listening means the socket is bound but nobody has sent a packet yet.
      expect(
        const ServerState(connection: ConnectionState.connected).isConnected,
        isTrue,
      );
      expect(
        const ServerState(connection: ConnectionState.listening).isConnected,
        isFalse,
      );
      expect(const ServerState().isConnected, isFalse);
      // A busy start is not a connection.
      expect(const ServerState(busy: true).isConnected, isFalse);
    });
  });
}

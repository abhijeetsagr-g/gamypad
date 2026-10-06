import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/udp_transport.dart';
import 'package:protocol/protocol.dart';
import 'package:test/test.dart';

/// Stands in for gamypad_pc: binds a port, answers [Ping] with [Pong], and
/// records everything else it receives.
///
/// A real socket rather than a fake, on purpose. What is worth testing here —
/// binding, the read/drain loop, the source filter, timer cadence — only exists
/// once there is a real socket behind it. A hand-written fake would assert that
/// the fake behaves as the test expects, which proves nothing about
/// [UdpTransport]. `gamypad_pc`'s `FakeSocket` is the right tool for testing the
/// layer *above* the transport; this file is the layer that owns the socket.
class FakePc {
  RawDatagramSocket? _socket;

  /// Non-ping messages the server received, in order.
  final input = <Message>[];

  /// How many [Ping]s arrived. The cadence assertion reads this.
  var pings = 0;

  /// Where the client lives, learned from its first packet — exactly as the
  /// real server does.
  InternetAddress? clientAddress;
  int clientPort = 0;

  /// Set false to "die": stop answering, so the client's watchdog should
  /// notice.
  bool answerPings = true;

  int get port => _socket!.port;

  Future<void> start() async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    _socket = socket;
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      // Drain, not a single receive — mirrors what the real server does.
      while (true) {
        final datagram = socket.receive();
        if (datagram == null) break;
        _handle(datagram);
      }
    });
  }

  void _handle(Datagram datagram) {
    final Message message;
    try {
      message = Message.fromJson(
        jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>,
      );
    } on FormatException {
      return; // Not a message we understand, not our problem.
    }

    clientAddress = datagram.address;
    clientPort = datagram.port;

    if (message is Ping) {
      pings++;
      if (answerPings) {
        _socket!.send(
          utf8.encode(const Pong().encode()),
          datagram.address,
          datagram.port,
        );
      }
    } else {
      input.add(message);
    }
  }

  /// Sends arbitrary bytes to the client — for malformed-packet tests.
  void sendRaw(List<int> bytes) {
    final address = clientAddress;
    if (address == null) throw StateError('the client has not pinged yet');
    _socket!.send(bytes, address, clientPort);
  }

  Future<void> stop() async {
    _socket?.close();
    _socket = null;
  }
}

void main() {
  late FakePc pc;
  late UdpTransport transport;
  late List<ConnectionStatus> statuses;
  late List<Message> incoming;

  // Short enough to keep the suite quick, long enough not to flake.
  const fastPing = Duration(milliseconds: 25);
  const fastWatchdog = Duration(milliseconds: 150);

  /// Broadcast streams deliver asynchronously, so a status emitted during an
  /// awaited call cannot be read until the microtask queue has drained.
  /// Without this, assertions race the event loop and fail intermittently.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 10));

  Future<void> connect() async {
    await transport.connect(UdpTarget(host: '127.0.0.1', port: pc.port));
    await settle();
  }

  /// Connects, then waits for the first ping to actually reach the server.
  ///
  /// [connect] returning does not mean the server has heard from us yet — the
  /// first ping is one [fastPing] away. Tests that make the server talk *back*
  /// need that packet to have landed, because the server learns the client's
  /// address from it and cannot reply before then.
  Future<void> connectAndSync() async {
    await connect();
    for (var waited = 0; waited < 40 && pc.clientAddress == null; waited++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(pc.clientAddress, isNotNull, reason: 'the first ping never landed');
  }

  setUp(() async {
    pc = FakePc();
    await pc.start();
    transport = UdpTransport(
      pingInterval: fastPing,
      watchdogInterval: fastWatchdog,
    );
    statuses = [];
    incoming = [];
    // Subscribed before connect, so nothing is missed.
    transport.status.listen(statuses.add);
    transport.incoming.listen(incoming.add);
  });

  tearDown(() async {
    await transport.disconnect();
    await pc.stop();
  });

  group('connecting', () {
    test('reports connecting, then connected, in that order', () async {
      await connect();
      expect(statuses, [
        ConnectionStatus.connecting,
        ConnectionStatus.connected,
      ]);
    });

    test('an unresolvable host throws and ends disconnected', () async {
      await expectLater(
        transport.connect(UdpTarget(host: 'no.such.host.invalid', port: 9999)),
        throwsA(isA<SocketException>()),
      );
      await settle();
      expect(statuses, [
        ConnectionStatus.connecting,
        ConnectionStatus.disconnected,
      ]);
    });

    test('a failed connect leaves no timer or socket behind', () async {
      await expectLater(
        transport.connect(UdpTarget(host: 'no.such.host.invalid', port: 9999)),
        throwsA(isA<SocketException>()),
      );
      await settle();

      final after = statuses.length;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(
        statuses.length,
        after,
        reason: 'nothing may keep running after a failed connect',
      );
    });

    test(
      'connecting while already connected never reports disconnected',
      () async {
        // The old socket is dropped silently: announcing a disconnect that the
        // next line contradicts would only make the UI flicker.
        await connect();
        await connect();
        expect(statuses, [
          ConnectionStatus.connecting,
          ConnectionStatus.connected,
          ConnectionStatus.connecting,
          ConnectionStatus.connected,
        ]);
      },
    );
  });

  group('sending', () {
    test('a button arrives as the protocol message it was', () async {
      await connect();
      await transport.send(
        const ButtonMessage(button: GamepadButton.A, pressed: true),
      );
      await settle();

      // Compared field-wise: protocol messages carry no operator==, so a list
      // match would be comparing identities.
      expect(pc.input, hasLength(1));
      final message = pc.input.single as ButtonMessage;
      expect(message.button, GamepadButton.A);
      expect(message.pressed, isTrue);
    });

    test('an analog trigger arrives unscaled', () async {
      await connect();
      await transport.send(
        const TriggerMessage(trigger: GamepadTrigger.LT, value: triggerMax),
      );
      await settle();

      final message = pc.input.single as TriggerMessage;
      expect(message.trigger, GamepadTrigger.LT);
      expect(message.value, 255);
    });

    test('sending before connecting is a no-op, not a throw', () async {
      await expectLater(transport.send(const Ping()), completes);
    });

    test('a disconnected transport sends nothing', () async {
      await connect();
      await transport.disconnect();
      await settle();
      final before = pc.input.length;

      await transport.send(
        const ButtonMessage(button: GamepadButton.B, pressed: true),
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(pc.input.length, before);
    });
  });

  group('health', () {
    test('pings on the configured interval', () async {
      await connect();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      // 200ms at 25ms intervals is 8 pings; ask for a conservative floor so a
      // loaded machine does not fail the suite.
      expect(pc.pings, greaterThanOrEqualTo(3));
    });

    test('incoming carries pongs', () async {
      await connect();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(incoming, isNotEmpty);
      expect(incoming.every((message) => message is Pong), isTrue);
    });

    test('a ping from the server is dropped, not answered', () async {
      await connectAndSync();
      final pingsBefore = pc.pings;
      pc.sendRaw(utf8.encode(const Ping().encode()));
      await settle();

      // The phone initiates; the PC only ever replies. Answering here would
      // invert the protocol.
      expect(pc.pings, pingsBefore);
      expect(incoming.whereType<Ping>(), isEmpty);
    });

    test('the server going silent trips the watchdog to lost', () async {
      await connect();
      pc.answerPings = false;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(statuses, contains(ConnectionStatus.lost));
    });

    test('lost is never overwritten by disconnected', () async {
      // The distinction the enum exists to carry. If teardown emitted its own
      // status, `lost` would be clobbered a microsecond later and be
      // unobservable.
      await connect();
      pc.answerPings = false;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(
        statuses.last,
        ConnectionStatus.lost,
        reason: 'a link lost on its own was not disconnected by request',
      );
    });
  });

  group('robustness', () {
    test('malformed packets do not sever the connection', () async {
      await connectAndSync();
      const junk = [
        'not json at all',
        '', // empty datagram
        '[1,2,3]', // valid JSON, not an object
        '{"action":"A"}', // object, missing value
        '{"action":"TURBO","value":1}', // unknown action
        '{"type":"ping"}', // wrong kind of message
        '{"action":"LT","value":9999}', // out of range
      ];
      for (final payload in junk) {
        pc.sendRaw(utf8.encode(payload));
      }
      await settle();

      final pingsBefore = pc.pings;
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Without the FormatException catch, one junk packet from anyone on the
      // subnet could kill the link.
      expect(statuses.last, ConnectionStatus.connected);
      expect(pc.pings, greaterThan(pingsBefore), reason: 'still talking');
    });

    test('a pong from an unexpected source is ignored', () async {
      // Its own transport, with a long watchdog, so the pongs it legitimately
      // receives cannot be confused with the stranger's.
      final t = UdpTransport(
        pingInterval: const Duration(milliseconds: 40),
        watchdogInterval: const Duration(seconds: 30),
      );
      final seen = <Message>[];
      t.incoming.listen(seen.add);
      addTearDown(t.disconnect);

      await t.connect(UdpTarget(host: '127.0.0.1', port: pc.port));
      await settle();
      for (var waited = 0; waited < 40 && pc.clientAddress == null; waited++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(pc.clientAddress, isNotNull, reason: 'a ping must have landed');

      // Stop the real server answering, so the only pong that could arrive is
      // the stranger's. Otherwise legitimate traffic masks the thing under test.
      pc.answerPings = false;
      await Future<void>.delayed(const Duration(milliseconds: 150));
      seen.clear();

      final stranger = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(stranger.close);
      stranger.send(
        utf8.encode(const Pong().encode()),
        pc.clientAddress!,
        pc.clientPort,
      );
      await settle();
      await settle();

      // Only the peer we dialled may drive the link — on a phone hotspot,
      // plenty of other devices can send us a datagram.
      expect(seen, isEmpty);
    });
  });

  group('lifecycle', () {
    test('disconnecting twice is safe', () async {
      await connect();
      await transport.disconnect();
      await transport.disconnect();
      await settle();
      // Always emitted, so the postcondition is simply "disconnected". The
      // toggle and the watchdog can both decide at once, and identical events
      // are harmless.
      expect(
        statuses.where((s) => s == ConnectionStatus.disconnected),
        hasLength(2),
      );
    });

    test('reconnecting is observable and resumes pinging', () async {
      // Proves the stream controllers were never closed: a closed broadcast
      // stream cannot be listened to again.
      await connect();
      await transport.disconnect();
      await settle();

      final pingsBefore = pc.pings;
      statuses.clear();
      incoming.clear();

      await connect();
      expect(statuses, [
        ConnectionStatus.connecting,
        ConnectionStatus.connected,
      ]);

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(pc.pings, greaterThan(pingsBefore));
      expect(incoming.whereType<Pong>(), isNotEmpty);
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:protocol/protocol.dart';

/// [GamepadTransport] over UDP — the only transport Gamypad ships today.
class UdpTransport implements GamepadTransport {
  UdpTransport({
    this.pingInterval = const Duration(seconds: 3),
    this.watchdogInterval = const Duration(seconds: 5),
  });

  /// How often to [Ping]. Cheap, and it doubles as the server's
  /// "something is still there" signal.
  final Duration pingInterval;

  /// How long the PC may go unheard before the link is declared lost.
  final Duration watchdogInterval;

  RawDatagramSocket? _socket;

  /// Every address [ConnectionTarget.host] resolved to.
  List<InternetAddress> _resolved = const [];

  /// Where sends actually go: the first resolved address, on the port the PC
  /// is listening on.
  InternetAddress? _target;
  int? _targetPort;

  Timer? _pingTimer;
  Timer? _watchdog;

  /// When we last heard a [Pong]. The watchdog's whole input.
  DateTime? _lastPong;

  /// Set while this transport is deliberately shutting down.
  bool _tearingDown = false;

  /// Broadcast, created once, never closed.
  final _status = StreamController<ConnectionStatus>.broadcast();
  final _incoming = StreamController<Message>.broadcast();

  @override
  Stream<ConnectionStatus> get status => _status.stream;

  @override
  Stream<Message> get incoming => _incoming.stream;

  @override
  Future<void> connect(ConnectionTarget target) async {
    if (_socket != null) _teardown();
    _tearingDown = false;
    _status.add(ConnectionStatus.connecting);

    try {
      final addresses = await InternetAddress.lookup(target.host);
      if (addresses.isEmpty) {
        throw SocketException('Could not resolve ${target.host}');
      }

      // Port 0 asks the OS for a free port.
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      _socket = socket;
      _resolved = addresses;
      _target = addresses.first;
      _targetPort = target.port;

      // `onError` and `onDone` both mean the socket died on its own. Easy to
      // wire one and forget the other; both are real failure modes.
      socket.listen(
        _onEvent,
        onError: (Object error, StackTrace _) => _onSocketGone(),
        onDone: _onSocketGone,
      );

      // Grace period. Without a baseline the watchdog has nothing to measure,
      // and the instant the first Pong lands any hiccup would trip it.
      _lastPong = DateTime.now();
      _startPing();
      _startWatchdog();

      _status.add(ConnectionStatus.connected);
    } catch (_) {
      // A failed connect must leave nothing running — the contract says so,
      // and a half-open socket is the worst outcome: the UI says disconnected
      // while writes go nowhere.
      _teardown();
      _status.add(ConnectionStatus.disconnected);
      rethrow; // The caller needs the reason; connect_view shows it to the user.
    }
  }

  @override
  Future<void> disconnect() async {
    _teardown();
    _status.add(ConnectionStatus.disconnected);
  }

  void _teardown() {
    _tearingDown = true;

    _pingTimer?.cancel();
    _pingTimer = null;
    _watchdog?.cancel();
    _watchdog = null;

    _lastPong = null;
    _target = null;
    _targetPort = null;
    _resolved = const [];

    // Nulled before closing, so the close's `onDone` cannot re-enter teardown.
    final socket = _socket;
    _socket = null;
    socket?.close();
  }

  /// The socket died without us asking the peer went away mid-session.
  void _onSocketGone() {
    if (_tearingDown || _socket == null) return;
    _teardown();
    _status.add(ConnectionStatus.lost);
  }

  @override
  Future<void> send(Message message) async {
    // Snapshot into locals: this reads better than four nullable dereferences,
    // and the null-guard is the "am I connected?" check the interface promises.
    final socket = _socket;
    final address = _target;
    final port = _targetPort;

    if (socket == null || address == null || port == null) return;

    try {
      socket.send(utf8.encode(message.encode()), address, port);
    } on SocketException {
      // Closed between the guard above and here. A send is not the place to
      // tear the link down — the watchdog's job is to notice, and it will.
    }
  }

  void _startPing() {
    _pingTimer = Timer.periodic(
      pingInterval,
      (_) => unawaited(send(const Ping())),
    );
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;

    while (true) {
      final datagram = _socket?.receive();
      if (datagram == null) break;
      _handle(datagram);
    }
  }

  void _handle(Datagram datagram) {
    if (!_resolved.contains(datagram.address)) return;
    if (datagram.port != _targetPort) return;

    final Message message;
    try {
      // utf8.decode throws on bad bytes, jsonDecode on bad JSON, and
      // Message.fromJson on the wrong shape
      final json = jsonDecode(utf8.decode(datagram.data));
      if (json is! Map<String, dynamic>) return;
      message = Message.fromJson(json);
    } on FormatException {
      return;
    }

    // The PC answers pings and says nothing else. A [Ping] or an input message
    // arriving here is a protocol mistake, not something to act on.
    if (message is! Pong) return;

    _lastPong = DateTime.now();
    _incoming.add(message);
  }

  void _startWatchdog() {
    _watchdog = Timer.periodic(watchdogInterval, (_) {
      final last = _lastPong;
      if (last == null) return;

      if (DateTime.now().difference(last) > watchdogInterval) {
        _teardown();
        _status.add(ConnectionStatus.lost);
      }
    });
  }
}

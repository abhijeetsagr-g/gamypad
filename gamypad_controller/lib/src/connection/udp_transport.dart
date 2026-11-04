import 'dart:async';
import 'dart:io';

import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:protocol/protocol.dart';
import 'dart:convert';

class UdpTransport implements GamepadTransport {
  UdpTransport({
    this.pingInterval = const Duration(seconds: 3),
    this.watchdogInterval = const Duration(seconds: 5),
    this.connectionTimeout = const Duration(seconds: 2),
  });

  final Duration pingInterval;
  final Duration watchdogInterval;
  final Duration connectionTimeout;

  RawDatagramSocket? _socket;

  List<InternetAddress> _resolved = const [];
  InternetAddress? _target;
  int? _targetPort;

  Timer? _pingTimer;
  Timer? _watchdog;

  DateTime? _lastPong;
  Completer<void>? _firstPong;
  bool _tearingDown = false;

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

      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      _socket = socket;
      _resolved = addresses;
      _target = addresses.first;
      _targetPort = target.port;

      socket.listen(
        _onEvent,
        onError: (Object error, StackTrace _) => _onSocketGone(),
        onDone: _onSocketGone,
      );

      _lastPong = DateTime.now();
      final firstPong = Completer<void>();
      _firstPong = firstPong;
      _startPing();
      _startWatchdog();
      await send(const Ping());
      await firstPong.future.timeout(connectionTimeout);
      _firstPong = null;
      _status.add(ConnectionStatus.connected);
    } catch (_) {
      _firstPong = null;
      _teardown();
      _status.add(ConnectionStatus.disconnected);
      rethrow;
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
    _firstPong = null;
    _target = null;
    _targetPort = null;
    _resolved = const [];

    final socket = _socket;
    _socket = null;
    socket?.close();
  }

  void _onSocketGone() {
    if (_tearingDown || _socket == null) return;
    _teardown();
    _status.add(ConnectionStatus.lost);
  }

  @override
  Future<void> send(Message message) async {
    final socket = _socket;
    final address = _target;
    final port = _targetPort;

    if (socket == null || address == null || port == null) return;

    try {
      socket.send(utf8.encode(message.encode()), address, port);
    } on SocketException {
      // Closed between the guard above and here; the watchdog detects this.
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
      final json = jsonDecode(utf8.decode(datagram.data));
      if (json is! Map<String, dynamic>) return;
      message = Message.fromJson(json);
    } on FormatException {
      return;
    }

    if (message is! Pong) return;

    _lastPong = DateTime.now();
    _incoming.add(message);
    final firstPong = _firstPong;
    if (firstPong != null && !firstPong.isCompleted) firstPong.complete();
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

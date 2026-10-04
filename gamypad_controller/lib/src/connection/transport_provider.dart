import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/gamepad_transport.dart';
import 'package:gamypad_controller/src/connection/udp_transport.dart';

/// The link to the PC. Overridden in tests with a `FakeTransport`, which is why
/// it is a provider and not a field.
///
/// Deliberately not `autoDispose`: the transport owns timers and a socket, and
/// letting Riverpod drop it because a screen stopped watching would tear the
/// link down behind the user's back. One transport lives as long as the app;
/// reconnecting goes through `ConnectionController`.
///
/// Lives here rather than in the state layer so that both the controller and
/// the input layer can depend on it without either depending on the other. The
/// pure files — `udp_transport.dart`, `gamepad_input.dart` — stay free of
/// Riverpod, so they can still be tested with a plain `dart test`.
final transportProvider = Provider<GamepadTransport>(
  (ref) => UdpTransport(),
);
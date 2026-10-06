import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/device/gamepad_device.dart';
import 'package:gamypad_pc/src/device/uinput_device.dart';
import 'package:gamypad_pc/src/session/gamepad_session.dart';
import 'package:gamypad_pc/src/transport/message_socket.dart';
import 'package:gamypad_pc/src/transport/udp_socket.dart';
import 'package:gamypad_pc/src/ui/state/log_controller.dart';
import 'package:protocol/protocol.dart';

final socketProvider = Provider<MessageSocket>((ref) => UdpSocket());

final deviceProvider = Provider<GamepadDevice>((ref) => UinputDevice());

final sessionProvider = Provider<GamepadSession>((ref) {
  final session = GamepadSession(
    socket: ref.watch(socketProvider),
    device: ref.watch(deviceProvider),
  );
  ref.onDispose(session.dispose);
  return session;
});

final socketMessagesProvider = StreamProvider<Message>((ref) {
  return ref.watch(socketProvider).messages;
});

final logControllerProvider = NotifierProvider<LogController, LogState>(
  LogController.new,
);

final localIpProvider = FutureProvider<String>((ref) async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback) return addr.address;
    }
  }
  return '127.0.0.1';
});

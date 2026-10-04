import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/transport_provider.dart';
import 'package:gamypad_controller/src/input/gamepad_input.dart';

final inputProvider = Provider<GamepadInput>((ref) {
  final input = GamepadInput(transport: ref.watch(transportProvider));
  ref.onDispose(input.dispose);
  return input;
});

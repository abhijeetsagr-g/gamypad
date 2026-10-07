import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/connection/transport_provider.dart';
import 'package:gamypad_controller/src/input/gamepad_input.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:gamypad_controller/src/ui/state/setting_controller.dart';

final inputProvider = Provider<GamepadInput>((ref) {
  final transport = ref.watch(transportProvider);

  final settings = ref.watch(settingControllerProvider).value ?? SettingModel();

  final input = GamepadInput(transport: transport, settings: settings);

  ref.onDispose(input.dispose);
  return input;
});

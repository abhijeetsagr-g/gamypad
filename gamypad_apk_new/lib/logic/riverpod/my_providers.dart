import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_apk_new/logic/riverpod/client/client_notifier.dart';
import 'package:gamypad_apk_new/logic/riverpod/client/client_state.dart';
import 'package:gamypad_apk_new/logic/riverpod/tilt/tilt_notifier.dart';
import 'package:gamypad_apk_new/logic/riverpod/tilt/tilt_state.dart';

final clientProvider = NotifierProvider<ClientNotifier, ClientState>(
  ClientNotifier.new,
);

final tiltProvider = NotifierProvider<TiltNotifier, TiltState>(
  TiltNotifier.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/logic/riverpod/client/client_notifier.dart';
import 'package:gamypad_controller/logic/riverpod/client/client_state.dart';

final clientProvider = NotifierProvider<ClientNotifier, ClientState>(
  ClientNotifier.new,
);

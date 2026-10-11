import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_pc/src/settings/server_settings.dart';

final serverSettingsRepositoryProvider = Provider<ServerSettingsRepository>(
  (ref) => const SharedPreferencesServerSettingsRepository(),
);

class ServerSettingsController extends AsyncNotifier<ServerSettings> {
  @override
  Future<ServerSettings> build() =>
      ref.read(serverSettingsRepositoryProvider).load();

  Future<void> setPort(int port) async {
    if (!isValidPort(port)) {
      throw RangeError('Port must be 0 or $minPort-$maxPort, got $port');
    }
    final next = ServerSettings(port: port);
    await ref.read(serverSettingsRepositoryProvider).save(next);
    state = AsyncData(next);
  }
}

final serverSettingsControllerProvider =
    AsyncNotifierProvider<ServerSettingsController, ServerSettings>(
      ServerSettingsController.new,
    );

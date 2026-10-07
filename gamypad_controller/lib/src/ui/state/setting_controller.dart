import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:gamypad_controller/src/settings/setting_repository.dart';

final settingRepositoryProvider = Provider<SettingRepository>(
  (ref) => const SharedPreferencesSettingRepository(),
);

class SettingController extends AsyncNotifier<SettingModel> {
  @override
  Future<SettingModel> build() async {
    final saved = await ref.watch(settingRepositoryProvider).load();
    return saved ?? SettingModel();
  }

  Future<void> commit(SettingModel setting) async {
    state = AsyncData(setting);
    try {
      await ref.read(settingRepositoryProvider).save(setting);
    } catch (_) {}
  }
}

final settingControllerProvider =
    AsyncNotifierProvider<SettingController, SettingModel>(
      SettingController.new,
    );

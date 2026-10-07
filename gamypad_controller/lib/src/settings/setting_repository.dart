import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SettingRepository {
  Future<SettingModel?> load();
  Future<void> save(SettingModel setting);
  Future<void> clear();
}

class SharedPreferencesSettingRepository implements SettingRepository {
  const SharedPreferencesSettingRepository({this.key = 'settings'});

  final String key;

  @override
  Future<void> save(SettingModel setting) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(key, setting.encode());
  }

  @override
  Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }

  @override
  Future<SettingModel?> load() async {
    final pref = await SharedPreferences.getInstance();
    final source = pref.getString(key);
    if (source == null) return SettingModel();

    try {
      return SettingModel.decode(source);
    } on FormatException {
      await pref.remove(key);
      return SettingModel();
    }
  }
}

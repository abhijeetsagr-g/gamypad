import 'package:shared_preferences/shared_preferences.dart';

import 'controller_layout.dart';

abstract interface class LayoutRepository {
  /// The saved layout, or null if there is none.
  Future<ControllerLayout?> load();

  Future<void> save(ControllerLayout layout);

  Future<void> clear();
}

class SharedPreferencesLayoutRepository implements LayoutRepository {
  const SharedPreferencesLayoutRepository({this.key = 'controller_layout'});

  final String key;

  @override
  Future<ControllerLayout?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(key);
    if (source == null) return null;

    try {
      return ControllerLayout.decode(source);
    } on FormatException {
      await preferences.remove(key);
      return null;
    }
  }

  @override
  Future<void> save(ControllerLayout layout) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, layout.encode());
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }
}

class MemoryLayoutRepository implements LayoutRepository {
  MemoryLayoutRepository([this._layout]);

  ControllerLayout? _layout;
  ControllerLayout? get saved => _layout;

  @override
  Future<ControllerLayout?> load() async => _layout;

  @override
  Future<void> save(ControllerLayout layout) async => _layout = layout;

  @override
  Future<void> clear() async => _layout = null;
}

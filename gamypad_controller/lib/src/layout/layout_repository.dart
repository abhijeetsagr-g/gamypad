import 'package:shared_preferences/shared_preferences.dart';

import 'controller_layout.dart';

/// Where a layout survives between sessions.
///
/// An interface rather than a bare `SharedPreferences` call so the views can be
/// handed an in-memory one, and so the storage can move without anything above
/// it noticing.
abstract interface class LayoutRepository {
  /// The saved layout, or null if there is none.
  Future<ControllerLayout?> load();

  Future<void> save(ControllerLayout layout);

  Future<void> clear();
}

/// One JSON string under one key.
///
/// Layouts are small, are only ever read whole, and never queried — a table
/// would buy nothing but a schema to migrate.
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
      // Unreadable storage must never brick the pad: the user gets the default
      // layout and the bad value is overwritten on their next edit. Swallowed
      // deliberately — there is nothing useful to show them and no way to fix
      // it from here.
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

/// For tests, and for the first launch before anything has been saved.
class MemoryLayoutRepository implements LayoutRepository {
  MemoryLayoutRepository([this._layout]);

  ControllerLayout? _layout;

  /// What was last written, so a test can assert a save happened without
  /// reaching through the storage itself.
  ControllerLayout? get saved => _layout;

  @override
  Future<ControllerLayout?> load() async => _layout;

  @override
  Future<void> save(ControllerLayout layout) async => _layout = layout;

  @override
  Future<void> clear() async => _layout = null;
}

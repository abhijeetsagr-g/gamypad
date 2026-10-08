import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'controller_layout.dart';

abstract interface class LayoutRepository {
  Future<ControllerLayout?> load([String? name]);

  Future<void> save(ControllerLayout layout);

  Future<void> saveAs(ControllerLayout layout, String name);

  Future<void> delete(String name);

  Future<List<String>> list();

  Future<void> clear();
}

class SharedPreferencesLayoutRepository implements LayoutRepository {
  const SharedPreferencesLayoutRepository({this.key = 'controller_layout'});

  final String key;

  String get _activeKey => '$key.active';

  @override
  Future<ControllerLayout?> load([String? name]) async {
    final preferences = await SharedPreferences.getInstance();
    final layouts = await _readAll(preferences);
    if (layouts.isEmpty) return null;

    final target =
        name ??
        preferences.getString(_activeKey) ??
        // A lone preset (e.g. just migrated) is implicitly active.
        (layouts.length == 1 ? layouts.keys.single : null);
    if (target == null) return null;

    final source = layouts[target];
    if (source == null) return null;

    try {
      return ControllerLayout.decode(source);
    } on FormatException {
      // Drop just the corrupt preset, keep the rest.
      layouts.remove(target);
      await _writeAll(preferences, layouts);
      return null;
    }
  }

  @override
  Future<void> save(ControllerLayout layout) async {
    final preferences = await SharedPreferences.getInstance();
    final layouts = await _readAll(preferences);
    layouts[layout.name] = layout.encode();
    await _writeAll(preferences, layouts);
    await preferences.setString(_activeKey, layout.name);
  }

  @override
  Future<void> saveAs(ControllerLayout layout, String name) =>
      save(layout.withName(name));

  @override
  Future<void> delete(String name) async {
    final preferences = await SharedPreferences.getInstance();
    final layouts = await _readAll(preferences);
    if (layouts.remove(name) == null) return;

    await _writeAll(preferences, layouts);
    if (preferences.getString(_activeKey) == name) {
      await preferences.remove(_activeKey);
    }
  }

  @override
  Future<List<String>> list() async {
    final preferences = await SharedPreferences.getInstance();
    final names = (await _readAll(preferences)).keys.toList();
    return names..sort();
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
    await preferences.remove(_activeKey);
  }

  Future<Map<String, String>> _readAll(SharedPreferences preferences) async {
    final source = preferences.getString(key);
    if (source == null) return {};

    Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      root = null;
    }

    if (root is Map) {
      if (root.containsKey('elements')) {
        return _migrate(preferences, root);
      }
      return {
        for (final entry in root.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    }

    await clear();
    return {};
  }

  Future<Map<String, String>> _migrate(
    SharedPreferences preferences,
    Map<Object?, Object?> legacy,
  ) async {
    final storedName = legacy['name'];
    final name = storedName is String && storedName.isNotEmpty
        ? storedName
        : 'Default';
    legacy['name'] = name; // layouts saved before `name` was encoded

    final layouts = {name: jsonEncode(legacy)};
    await _writeAll(preferences, layouts);
    if (preferences.getString(_activeKey) == null) {
      await preferences.setString(_activeKey, name);
    }
    return layouts;
  }

  Future<void> _writeAll(
    SharedPreferences preferences,
    Map<String, String> layouts,
  ) async {
    if (layouts.isEmpty) {
      await preferences.remove(key);
    } else {
      await preferences.setString(key, jsonEncode(layouts));
    }
  }
}

class MemoryLayoutRepository implements LayoutRepository {
  MemoryLayoutRepository([ControllerLayout? initial]) {
    if (initial != null) {
      _layouts[initial.name] = initial;
      _active = initial.name;
    }
  }

  final _layouts = <String, ControllerLayout>{};
  String? _active;

  /// The active saved layout, or null when there is none.
  ControllerLayout? get saved => _layouts[_active];

  @override
  Future<ControllerLayout?> load([String? name]) async =>
      _layouts[name ?? _active];

  @override
  Future<void> save(ControllerLayout layout) async {
    _layouts[layout.name] = layout;
    _active = layout.name;
  }

  @override
  Future<void> saveAs(ControllerLayout layout, String name) =>
      save(layout.withName(name));

  @override
  Future<void> delete(String name) async {
    _layouts.remove(name);
    if (_active == name) {
      _active = _layouts.length == 1 ? _layouts.keys.single : null;
    }
  }

  @override
  Future<List<String>> list() async {
    final names = _layouts.keys.toList();
    return names..sort();
  }

  @override
  Future<void> clear() async {
    _layouts.clear();
    _active = null;
  }
}

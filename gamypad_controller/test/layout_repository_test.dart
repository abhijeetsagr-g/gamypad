import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ControllerLayout codec', () {
    test('encode/decode round-trips name, size and elements', () {
      final layout = DefaultLayout.layout;
      final decoded = ControllerLayout.decode(layout.encode());
      expect(decoded, layout);
      expect(decoded.name, 'Default');
    });

    test('decode rejects a non-string name', () {
      final json = jsonDecode(DefaultLayout.layout.encode());
      json['name'] = 42;
      expect(
        () => ControllerLayout.decode(jsonEncode(json)),
        throwsFormatException,
      );
    });

    test('withName keeps everything but the name', () {
      final renamed = DefaultLayout.layout.withName('FPS');
      expect(renamed.name, 'FPS');
      expect(renamed.authoredSize, DefaultLayout.layout.authoredSize);
      expect(renamed.elements, DefaultLayout.layout.elements);
      expect(renamed, isNot(DefaultLayout.layout));
    });
  });

  group('SharedPreferencesLayoutRepository', () {
    late SharedPreferencesLayoutRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = const SharedPreferencesLayoutRepository();
    });

    test('starts empty', () async {
      expect(await repository.load(), isNull);
      expect(await repository.list(), isEmpty);
    });

    test('save stores a preset and makes it active', () async {
      await repository.save(DefaultLayout.layout);
      expect(await repository.load(), DefaultLayout.layout);
      expect(await repository.list(), ['Default']);
    });

    test('saveAs stores a renamed copy and switches to it', () async {
      await repository.saveAs(DefaultLayout.layout, 'FPS');
      final loaded = await repository.load();
      expect(loaded?.name, 'FPS');
      expect(await repository.list(), ['FPS']);
    });

    test('named presets stay independent, active one loads by default',
        () async {
      await repository.save(DefaultLayout.layout);
      await repository.saveAs(DefaultLayout.layout, 'FPS');

      expect((await repository.load())?.name, 'FPS');
      expect((await repository.load('Default'))?.name, 'Default');
      expect(await repository.list(), ['Default', 'FPS']);
    });

    test('delete falls back to the remaining preset when it was active',
        () async {
      await repository.save(DefaultLayout.layout);
      await repository.saveAs(DefaultLayout.layout, 'FPS');

      await repository.delete('FPS');
      expect(await repository.list(), ['Default']);
      expect((await repository.load())?.name, 'Default');

      await repository.delete('Default');
      expect(await repository.load(), isNull);
    });

    test('clear removes every preset', () async {
      await repository.save(DefaultLayout.layout);
      await repository.saveAs(DefaultLayout.layout, 'FPS');
      await repository.clear();
      expect(await repository.load(), isNull);
      expect(await repository.list(), isEmpty);
    });

    test('migrates the pre-preset single-layout value without losing it',
        () async {
      // Old format: one encoded layout under the key, no preset map,
      // and (before `name` was encoded) no name field at all.
      final legacy = jsonDecode(DefaultLayout.layout.encode());
      legacy.remove('name');
      SharedPreferences.setMockInitialValues({
        'controller_layout': jsonEncode(legacy),
      });

      final first = await repository.load();
      expect(first, isNotNull);
      expect(first!.name, 'Default');
      expect(await repository.list(), ['Default']);

      // Repeated loads must not wipe the migrated value.
      expect(await repository.load(), first);
      expect(await repository.load(), first);
    });

    test('migration keeps a legacy name when the value has one', () async {
      final legacy = jsonDecode(DefaultLayout.layout.encode());
      legacy['name'] = 'Mine';
      SharedPreferences.setMockInitialValues({
        'controller_layout': jsonEncode(legacy),
      });

      expect((await repository.load())?.name, 'Mine');
      expect(await repository.list(), ['Mine']);
    });

    test('a corrupt stored value is discarded instead of throwing', () async {
      SharedPreferences.setMockInitialValues({'controller_layout': 'garbage'});
      expect(await repository.load(), isNull);
      expect(await repository.list(), isEmpty);
    });
  });

  group('MemoryLayoutRepository', () {
    test('tracks the active preset', () async {
      final repository = MemoryLayoutRepository();
      expect(await repository.load(), isNull);

      await repository.save(DefaultLayout.layout);
      expect(await repository.load(), DefaultLayout.layout);

      await repository.saveAs(DefaultLayout.layout, 'FPS');
      expect((await repository.load())?.name, 'FPS');
      expect(await repository.list(), ['Default', 'FPS']);
      expect(repository.saved?.name, 'FPS');

      await repository.delete('FPS');
      expect((await repository.load())?.name, 'Default');

      await repository.clear();
      expect(await repository.load(), isNull);
      expect(repository.saved, isNull);
    });

    test('an initial layout is active', () async {
      final repository = MemoryLayoutRepository(DefaultLayout.layout);
      expect(await repository.load(), DefaultLayout.layout);
      expect(await repository.list(), ['Default']);
    });
  });
}

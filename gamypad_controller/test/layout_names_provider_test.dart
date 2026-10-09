import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer containerWith(MemoryLayoutRepository repository) {
    final container = ProviderContainer(
      overrides: [layoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('includes the built-in default before anything is persisted', () async {
    final container = containerWith(MemoryLayoutRepository());
    await container.read(layoutControllerProvider.future);

    expect(await container.read(layoutNamesProvider.future), ['Default']);
  });

  test('lists persisted presets sorted, with the default always present', () async {
    final container = containerWith(MemoryLayoutRepository());
    final controller = container.read(layoutControllerProvider.notifier);
    await container.read(layoutControllerProvider.future);

    await controller.saveAs('RPG');
    await controller.saveAs('FPS');

    expect(
      await container.read(layoutNamesProvider.future),
      ['Default', 'FPS', 'RPG'],
    );
  });

  test('drops a deleted preset from the list', () async {
    final container = containerWith(MemoryLayoutRepository());
    final controller = container.read(layoutControllerProvider.notifier);
    await container.read(layoutControllerProvider.future);

    await controller.saveAs('RPG');
    await controller.saveAs('FPS');
    await controller.delete('FPS');

    expect(
      await container.read(layoutNamesProvider.future),
      ['Default', 'RPG'],
    );
  });

  test('loads the built-in default even when nothing was persisted', () async {
    final container = containerWith(MemoryLayoutRepository());
    final controller = container.read(layoutControllerProvider.notifier);
    await container.read(layoutControllerProvider.future);

    await controller.saveAs('RPG');
    await controller.load('Default');

    expect(
      container.read(layoutControllerProvider).value,
      DefaultLayout.layout,
    );
    expect(
      await container.read(layoutNamesProvider.future),
      contains('Default'),
    );
  });
}
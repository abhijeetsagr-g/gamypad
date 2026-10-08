import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MemoryLayoutRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MemoryLayoutRepository();
    container = ProviderContainer(
      overrides: [layoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  LayoutController controller() =>
      container.read(layoutControllerProvider.notifier);
  ControllerLayout value() => container.read(layoutControllerProvider).value!;

  Future<void> start() => container.read(layoutControllerProvider.future);

  test('saveAs stores the current layout under a new name', () async {
    await start();

    await controller().saveAs('FPS');

    expect(value().name, 'FPS');
    expect(await controller().list(), ['FPS']);
    expect((await repository.load('FPS'))?.name, 'FPS');
  });

  test('load switches back to an earlier preset', () async {
    await start();
    await controller().saveAs('FPS');
    await controller().saveAs('RPG');
    expect(value().name, 'RPG');

    await controller().load('FPS');

    expect(value().name, 'FPS');
    expect(await controller().list(), ['FPS', 'RPG']);
  });

  test('load ignores an unknown preset', () async {
    await start();
    await controller().saveAs('FPS');

    await controller().load('nope');

    expect(value().name, 'FPS');
  });

  test('deleting the active preset falls back to the remaining one', () async {
    await start();
    await controller().saveAs('FPS');
    await controller().saveAs('RPG');

    await controller().delete('RPG');

    expect(value().name, 'FPS');
    expect(await controller().list(), ['FPS']);
  });

  test('deleting a non-active preset leaves the view alone', () async {
    await start();
    await controller().saveAs('FPS');
    await controller().saveAs('RPG');

    await controller().delete('FPS');

    expect(value().name, 'RPG');
    expect(await controller().list(), ['RPG']);
  });
}

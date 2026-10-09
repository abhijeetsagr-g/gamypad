import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
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

  LayoutController controller(ProviderContainer c) =>
      c.read(layoutControllerProvider.notifier);
  ControllerLayout value(ProviderContainer c) =>
      c.read(layoutControllerProvider).value!;

  test('a stored copy of the default is dropped at startup', () async {
    final container = containerWith(MemoryLayoutRepository(
      DefaultLayout.layout.withName('Default').place(
            'X',
            Rect.fromLTWH(600, 160, 56, 56),
          ),
    ));
    await container.read(layoutControllerProvider.future);

    expect(value(container), DefaultLayout.layout);
    expect(await controller(container).list(), isEmpty);
  });

  test('saveAs, delete and commit never touch the reserved name', () async {
    final container = containerWith(MemoryLayoutRepository());
    await container.read(layoutControllerProvider.future);
    await controller(container).saveAs('FPS');

    await controller(container).saveAs('Default');
    await controller(container).delete('Default');
    await controller(container).commit(DefaultLayout.layout);

    expect(value(container).name, 'FPS');
    expect(await controller(container).list(), ['FPS']);
  });

  test('load restores the pristine default and repairs a stored copy', () async {
    final container = containerWith(MemoryLayoutRepository());
    await container.read(layoutControllerProvider.future);
    await controller(container).saveAs('FPS');
    // Corrupt a stored "Default" the way the old code did.
    await container
        .read(layoutRepositoryProvider)
        .save(DefaultLayout.layout.withName('Default').place(
              'X',
              Rect.fromLTWH(600, 160, 56, 56),
            ));

    await controller(container).load('Default');

    expect(value(container), DefaultLayout.layout);
    expect(await controller(container).list(), ['FPS']);
  });

  test('startNew creates a uniquely named draft from the default', () async {
    final container = containerWith(MemoryLayoutRepository());
    await container.read(layoutControllerProvider.future);
    await controller(container).saveAs('New Layout');
    await controller(container).saveAs('New Layout 2');

    final name = await controller(container).startNew();

    expect(name, 'New Layout 3');
    expect(value(container).name, name);
    expect(DefaultLayout.layout.withName(name), value(container));
    expect(await controller(container).list(), contains(name));
  });

  test('rename moves a draft without leaving a duplicate', () async {
    final container = containerWith(MemoryLayoutRepository());
    await container.read(layoutControllerProvider.future);
    await controller(container).startNew();

    await controller(container).rename('FPS');

    expect(value(container).name, 'FPS');
    expect(await controller(container).list(), ['FPS']);
  });
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/view/controller_editor_view.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer containerWith(MemoryLayoutRepository repository) {
    final container = ProviderContainer(
      overrides: [layoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('trigger resizing', () {
    test('triggers are resizable and keep exactly the dragged size', () {
      final lt = DefaultLayout.layout['LT']! as TriggerElement;
      expect(lt.resizable, isTrue);

      final resized = lt.constrain(
        Rect.fromLTWH(10, 10, 200, 90),
        DefaultLayout.canvasSize,
      );
      expect(resized, const Rect.fromLTWH(10, 10, 200, 90));

      // The built-in default trigger still ships with the original size.
      expect(lt.rect.size, TriggerElement.defaultSize);
    });
  });

  group('hidden elements', () {
    test('withHidden / isHidden / visible', () {
      final layout = DefaultLayout.layout.withHidden({'LT', 'GUIDE'});

      expect(layout.isHidden('LT'), isTrue);
      expect(layout.isHidden('LB'), isFalse);
      expect(layout.visible.map((e) => e.id), isNot(contains('LT')));
      expect(
        layout.visible.length,
        DefaultLayout.layout.elements.length - 2,
      );
    });

    test('hidden elements take no space for validity', () {
      final layout = DefaultLayout.layout.withHidden({'LT'});
      // Park LB on top of where LT used to be: valid now.
      final shifted = layout.place('LB', const Rect.fromLTWH(26, 18, 132, 48));
      expect(shifted.isValid, isTrue);

      // The same placement is invalid without the hidden exception.
      expect(DefaultLayout.layout.place('LB', const Rect.fromLTWH(26, 18, 132, 48)).isValid, isFalse);
    });

    test('hidden round-trips through storage', () {
      final layout = DefaultLayout.layout.withHidden({'LT', 'GUIDE'});
      final decoded = ControllerLayout.decode(layout.encode());

      expect(decoded, layout);
      expect(decoded.hidden, {'LT', 'GUIDE'});
    });

    test('v1 layouts decode with nothing hidden', () {
      final json = jsonDecode(DefaultLayout.layout.encode());
      json['version'] = 1;
      json.remove('hidden');

      final decoded = ControllerLayout.decode(jsonEncode(json));

      expect(decoded.hidden, isEmpty);
      expect(decoded, DefaultLayout.layout);
    });

    test('decode rejects unsupported versions', () {
      final json = jsonDecode(DefaultLayout.layout.encode());
      json['version'] = 99;

      expect(
        () => ControllerLayout.decode(jsonEncode(json)),
        throwsFormatException,
      );
    });

    test('setHidden updates the active layout and persists it', () async {
      final container = containerWith(MemoryLayoutRepository());
      await container.read(layoutControllerProvider.future);
      await container.read(layoutControllerProvider.notifier).startNew();

      await container.read(layoutControllerProvider.notifier).setHidden(
        'LT',
        true,
      );

      final state = container.read(layoutControllerProvider).value!;
      expect(state.isHidden('LT'), isTrue);

      final persisted = await container.read(layoutRepositoryProvider).load();
      expect(persisted!.isHidden('LT'), isTrue);
    });
  });

  group('rendering', () {
    testWidgets('live rendering skips hidden elements, editor shows a ghost', (
      tester,
    ) async {
      final layout = DefaultLayout.layout.withHidden({'LT'});

      Future<void> pump({required bool showHidden}) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 800,
                height: 400,
                child: PadRenderer(layout: layout, showHidden: showHidden),
              ),
            ),
          ),
        ),
      );

      await pump(showHidden: false);
      expect(find.textContaining('LT'), findsNothing);

      await pump(showHidden: true);
      expect(find.text('LT'), findsOneWidget);
    });

    testWidgets('editor hide icon toggles the selected element', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = containerWith(MemoryLayoutRepository());
      await container.read(layoutControllerProvider.future);
      await container.read(layoutControllerProvider.notifier).startNew();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ControllerEditorView(isNew: true)),
        ),
      );
      await tester.pumpAndSettle();

      // Nothing selected yet: no hide icon.
      expect(find.byIcon(Icons.visibility_off), findsNothing);

      // Select LT by tapping it. Resize handle (bottom-right) and the hide
      // icon (top-right) both appear.
      await tester.tapAt(const Offset(92, 42));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap the top-right icon to hide LT.
      await tester.tapAt(const Offset(158, 18));
      await tester.pumpAndSettle();

      expect(
        container.read(layoutControllerProvider).value!.isHidden('LT'),
        isTrue,
      );
      // The dashed ghost appears and the icon now offers SHOW.
      expect(find.text('LT'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap again to re-show it.
      await tester.tapAt(const Offset(158, 18));
      await tester.pumpAndSettle();

      expect(
        container.read(layoutControllerProvider).value!.isHidden('LT'),
        isFalse,
      );
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
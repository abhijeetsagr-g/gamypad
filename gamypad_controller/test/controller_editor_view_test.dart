import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/layout_repository.dart';
import 'package:gamypad_controller/src/ui/state/layout_controller.dart';
import 'package:gamypad_controller/src/ui/view/controller_editor_view.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/editor_gestures.dart';

void main() {
  testWidgets('editor view builds and shows the actions fab', (tester) async {
    final repository = MemoryLayoutRepository(DefaultLayout.layout);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [layoutRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ControllerEditorView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EditorGestures), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('reset restores the layout from when the editor opened', (
    tester,
  ) async {
    final repository = MemoryLayoutRepository();
    final container = ProviderContainer(
      overrides: [layoutRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ControllerEditorView()),
      ),
    );
    await tester.pumpAndSettle();

    FloatingActionButton resetFab() => tester.widget<FloatingActionButton>(
      find.ancestor(
        of: find.byIcon(Icons.restart_alt),
        matching: find.byType(FloatingActionButton),
      ),
    );

    // Reveal the actions. Nothing changed yet, so reset is disabled.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(resetFab().onPressed, isNull);

    // Move a button under a draft name (Default itself is never edited in
    // place); reset becomes available.
    final edited = DefaultLayout.layout
        .withName('New Layout')
        .place('X', Rect.fromLTWH(600, 160, 56, 56));
    await container.read(layoutControllerProvider.notifier).commit(edited);
    await tester.pumpAndSettle();
    expect(resetFab().onPressed, isNotNull);

    // Reset restores the entry geometry but keeps the preset's name.
    await tester.tap(find.byIcon(Icons.restart_alt));
    await tester.pumpAndSettle();

    expect(
      container.read(layoutControllerProvider).value,
      DefaultLayout.layout.withName('New Layout'),
    );
    expect(resetFab().onPressed, isNull);
  });
}

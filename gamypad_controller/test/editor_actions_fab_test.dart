import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/ui/widgets/editor/editor_actions_fab.dart';

void main() {
  Future<void> pumpFab(
    WidgetTester tester, {
    required VoidCallback onSaveAs,
    required VoidCallback onReset,
    required bool resetEnabled,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: EditorActionsFab(
            onSaveAs: onSaveAs,
            onReset: onReset,
            resetEnabled: resetEnabled,
          ),
        ),
      ),
    );
  }

  double actionOpacity(WidgetTester tester, String label) {
    final opacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    return opacity.opacity;
  }

  testWidgets('starts collapsed and reveals actions when tapped', (
    tester,
  ) async {
    await pumpFab(
      tester,
      onSaveAs: () {},
      onReset: () {},
      resetEnabled: true,
    );

    expect(actionOpacity(tester, 'SAVE AS'), 0);
    expect(actionOpacity(tester, 'RESET'), 0);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(actionOpacity(tester, 'SAVE AS'), 1);
    expect(actionOpacity(tester, 'RESET'), 1);
  });

  testWidgets('invokes save as and collapses afterwards', (tester) async {
    var saved = 0;
    await pumpFab(
      tester,
      onSaveAs: () => saved++,
      onReset: () {},
      resetEnabled: true,
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
    await tester.pumpAndSettle();

    expect(saved, 1);
    expect(actionOpacity(tester, 'SAVE AS'), 0);
  });

  testWidgets('reset is inert while disabled', (tester) async {
    var reset = 0;
    await pumpFab(
      tester,
      onSaveAs: () {},
      onReset: () => reset++,
      resetEnabled: false,
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.restart_alt));
    await tester.pumpAndSettle();

    expect(reset, 0);
  });

  testWidgets('reset fires once enabled', (tester) async {
    var reset = 0;
    await pumpFab(
      tester,
      onSaveAs: () {},
      onReset: () => reset++,
      resetEnabled: true,
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.restart_alt));
    await tester.pumpAndSettle();

    expect(reset, 1);
  });
}

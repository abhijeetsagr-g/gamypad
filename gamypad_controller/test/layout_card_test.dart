import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/layout_card.dart';

void main() {
  Future<void> pump(WidgetTester tester, LayoutCard card) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: card)));

  testWidgets('tapping a card activates it', (tester) async {
    var taps = 0;
    await pump(
      tester,
      LayoutCard(
        name: 'FPS',
        active: false,
        onTap: () => taps++,
        onEdit: () {},
      ),
    );

    await tester.tap(find.text('FPS'));

    expect(taps, 1);
  });

  testWidgets('overflow menu exposes edit and delete', (tester) async {
    var edits = 0;
    var deletes = 0;
    await pump(
      tester,
      LayoutCard(
        name: 'FPS',
        active: true,
        onTap: () {},
        onEdit: () => edits++,
        onDelete: () => deletes++,
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('EDIT'), findsOneWidget);
    expect(find.text('DELETE'), findsOneWidget);

    await tester.tap(find.text('EDIT'));
    await tester.pumpAndSettle();
    expect(edits, 1);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();
    expect(deletes, 1);
  });

  testWidgets('delete is hidden when onDelete is null', (tester) async {
    await pump(
      tester,
      LayoutCard(
        name: 'Default',
        active: true,
        onTap: () {},
        onEdit: () {},
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('EDIT'), findsOneWidget);
    expect(find.text('DELETE'), findsNothing);
  });

  testWidgets('menu only shows edit when onEdit is provided', (tester) async {
    await pump(
      tester,
      LayoutCard(
        name: 'FPS',
        active: false,
        onTap: () {},
        onEdit: () {},
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('EDIT'), findsOneWidget);
    expect(find.text('DELETE'), findsNothing);
  });

  testWidgets('editing blocked when onEdit is null', (tester) async {
    await pump(
      tester,
      LayoutCard(
        name: 'Default',
        active: true,
        onTap: () {},
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('EDIT'), findsNothing);
    expect(find.text('DELETE'), findsNothing);
  });
}

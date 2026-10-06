import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/connection/connection_status.dart';
import 'package:gamypad_controller/src/ui/widgets/home/connection_status_badge.dart';
import 'package:gamypad_controller/src/ui/widgets/home/home_palette.dart';

void main() {
  group('present', () {
    test('names every status, so none can fall through unlabelled', () {
      // The enum grew `lost` after this badge was written. A switch that did not
      // cover it would not compile, but a `_ =>` fallback would, and would show
      // `lost` as a disconnection the user can fix by pairing again.
      for (final status in ConnectionStatus.values) {
        expect(ConnectionStatusBadge.present(status).label, isNotEmpty);
      }
    });

    test('connected is the only state shown in the accent colour', () {
      for (final status in ConnectionStatus.values) {
        expect(
          ConnectionStatusBadge.present(status).color == HomePalette.accent,
          status == ConnectionStatus.connected,
          reason: status.name,
        );
      }
    });

    test('lost is distinct from disconnected, in label and colour', () {
      final lost = ConnectionStatusBadge.present(ConnectionStatus.lost);
      final off = ConnectionStatusBadge.present(ConnectionStatus.disconnected);

      // They are different situations — the peer went away mid-session versus
      // never being reached — so they must not read the same on screen.
      expect(lost.label, isNot(off.label));
      expect(lost.color, isNot(off.color));
    });

    test('an in-flight connect is neither connected nor off', () {
      final connecting = ConnectionStatusBadge.present(
        ConnectionStatus.connecting,
      );
      expect(connecting.label, isNot('CONNECTED'));
      expect(connecting.label, isNot('NOT PAIRED'));
    });
  });

  group('build', () {
    Future<void> pump(WidgetTester tester, ConnectionStatus status) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ConnectionStatusBadge(status: status)),
        ),
      );
    }

    testWidgets('shows the status name', (tester) async {
      await pump(tester, ConnectionStatus.connected);
      expect(find.text('CONNECTED'), findsOneWidget);
    });

    testWidgets('the label is keyed by text, so it cross-fades on change', (
      tester,
    ) async {
      // Without the key, AnimatedSwitcher has two identical children to compare
      // and updates the text in place instead of animating.
      await pump(tester, ConnectionStatus.disconnected);
      final before = tester.widget<Text>(find.text('NOT PAIRED')).key;

      await pump(tester, ConnectionStatus.connected);
      final after = tester.widget<Text>(find.text('CONNECTED')).key;

      expect(before, isNot(after));
    });

    testWidgets('paints the dot in the status colour', (tester) async {
      await pump(tester, ConnectionStatus.lost);

      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(ConnectionStatusBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = dot.decoration! as BoxDecoration;
      expect(decoration.color, HomePalette.danger);
    });
  });
}

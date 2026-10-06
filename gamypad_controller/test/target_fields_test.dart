import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/connection/connection_target.dart';
import 'package:gamypad_controller/src/ui/widgets/home/target_fields.dart';

void main() {
  late TextEditingController host;
  late TextEditingController port;
  late UdpTarget? reported;

  setUp(() {
    host = TextEditingController();
    port = TextEditingController();
    reported = null;
  });

  tearDown(() {
    host.dispose();
    port.dispose();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TargetFields(
          host: host,
          port: port,
          onChanged: (target) => reported = target,
        ),
      ),
    ),
  );

  Future<void> type(WidgetTester tester, String text) =>
      tester.enterText(find.byType(TextField).first, text);

  Future<void> typePort(WidgetTester tester, String text) =>
      tester.enterText(find.byType(TextField).last, text);

  group('reports a parsed target', () {
    testWidgets('for the pair the PC puts in its QR code', (tester) async {
      await pump(tester);
      await type(tester, '10.0.0.5');
      await typePort(tester, '41234');

      expect(reported?.host, '10.0.0.5');
      expect(reported?.port, 41234);
    });

    testWidgets('trims whitespace, since parse already does', (tester) async {
      await pump(tester);
      await type(tester, '  10.0.0.5  ');
      await typePort(tester, '  41234 ');

      expect(reported?.toString(), '10.0.0.5:41234');
    });

    testWidgets('for a hostname, which parse accepts', (tester) async {
      await pump(tester);
      await type(tester, 'gamypad.local');
      await typePort(tester, '9000');

      expect(reported?.host, 'gamypad.local');
    });
  });

  group('reports null', () {
    testWidgets('while the address is empty', (tester) async {
      await pump(tester);
      await typePort(tester, '41234');
      expect(reported, isNull);
    });

    testWidgets('while the port is empty', (tester) async {
      await pump(tester);
      await type(tester, '10.0.0.5');
      expect(reported, isNull);
    });

    testWidgets('for an out-of-range port', (tester) async {
      await pump(tester);
      await type(tester, '10.0.0.5');
      await typePort(tester, '70000');
      expect(reported, isNull);
    });

    testWidgets('for digits that overflow the port range', (tester) async {
      // Digits, so the field's formatter passes them through untouched, but
      // past 65535 — the case a formatter cannot catch and the parse must.
      await pump(tester);
      await type(tester, '10.0.0.5');
      await typePort(tester, '99999999');
      expect(reported, isNull);
    });

    testWidgets('and clears a good target once the fields are emptied', (
      tester,
    ) async {
      // Sticky validity is the failure this guards: a connect button that stays
      // enabled after the user clears the address.
      await pump(tester);
      await type(tester, '10.0.0.5');
      await typePort(tester, '41234');
      expect(reported, isNotNull);

      await type(tester, '');
      expect(reported, isNull);
    });
  });

  group('editing', () {
    testWidgets('the port field takes digits only', (tester) async {
      // A keyboard can still be bypassed by paste, but the common case is a
      // stray letter, and it must never reach the port parse.
      await pump(tester);
      await typePort(tester, '41a234');
      expect(port.text, '41234');
      expect(reported, isNull);
    });

    testWidgets('the address field allows letters, since a host is legal', (
      tester,
    ) async {
      await pump(tester);
      await type(tester, 'pc.local');
      expect(host.text, 'pc.local');
    });

    testWidgets('both fields keep the controllers the caller owns', (
      tester,
    ) async {
      // The scan writes into these same controllers, so identity matters.
      await pump(tester);
      await type(tester, '10.0.0.5');
      expect(host.text, '10.0.0.5');
      expect(port.text, isEmpty);
    });
  });
}

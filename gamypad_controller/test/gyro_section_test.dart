import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/gyro_section.dart';

Widget _host(
  SettingModel model, {
  ValueChanged<bool>? onEnabled,
  ValueChanged<GyroMode>? onMode,
  ValueChanged<SettingModel>? onChanged,
}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: GyroSection(
        model: model,
        onEnabledChanged: onEnabled ?? (_) {},
        onModeChanged: onMode ?? (_) {},
        onChanged: onChanged ?? (_) {},
      ),
    ),
  ),
);

void main() {
  test('gyro is off by default, with aim preselected', () {
    const model = SettingModel();
    expect(model.gyroEnabled, isFalse);
    expect(model.gyroMode, GyroMode.aim);
  });

  test('settings round-trip, and bad stored values fall back', () {
    const model = SettingModel(gyroEnabled: true, gyroMode: GyroMode.tilt);
    expect(SettingModel.decode(model.encode()), model);

    expect(
      SettingModel.decode('{"gyroEnabled":"yes","gyroMode":"banana"}'),
      const SettingModel(),
    );
    // Settings saved before gyro existed.
    expect(
      SettingModel.decode(
        '{"vibrate":true,"digitalTriggers":false}',
      ).gyroEnabled,
      isFalse,
    );
  });

  testWidgets('hides the mode selector while gyro is off', (tester) async {
    await tester.pumpWidget(_host(const SettingModel()));
    expect(find.byKey(const ValueKey('gyro-mode')), findsNothing);
    expect(find.byKey(const ValueKey('gyro-description')), findsNothing);
  });

  testWidgets('shows three modes, one selected, with its description', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const SettingModel(gyroEnabled: true)));

    final selector = tester.widget<SegmentedButton<GyroMode>>(
      find.byKey(const ValueKey('gyro-mode')),
    );
    expect(selector.segments.map((s) => s.value), GyroMode.values);
    expect(selector.selected, {GyroMode.aim});
    expect(selector.multiSelectionEnabled, isFalse);
    expect(find.text(gyroModeDescriptions[GyroMode.aim]!), findsOneWidget);
  });

  testWidgets('the description follows the selected mode', (tester) async {
    for (final mode in GyroMode.values) {
      await tester.pumpWidget(
        _host(SettingModel(gyroEnabled: true, gyroMode: mode)),
      );
      expect(find.text(gyroModeDescriptions[mode]!), findsOneWidget);
    }
  });

  testWidgets('tapping a segment and the switch report changes', (
    tester,
  ) async {
    GyroMode? picked;
    bool? enabled;
    await tester.pumpWidget(
      _host(
        const SettingModel(gyroEnabled: true),
        onMode: (m) => picked = m,
        onEnabled: (v) => enabled = v,
      ),
    );

    await tester.tap(find.text('TILT'));
    expect(picked, GyroMode.tilt);

    await tester.tap(find.byType(Switch).first); // the gyro toggle
    expect(enabled, isFalse);
  });

  testWidgets('each mode shows only its own options', (tester) async {
    Future<List<String>> shown(GyroMode mode) async {
      await tester.pumpWidget(
        _host(SettingModel(gyroEnabled: true, gyroMode: mode)),
      );
      return [
        for (final o in GyroOption.values)
          if (find
              .byKey(ValueKey('gyro-option-${o.name}'))
              .evaluate()
              .isNotEmpty)
            o.name,
      ];
    }

    expect(await shown(GyroMode.aim), ['invertY', 'holdPosition', 'sixAxis']);
    expect(await shown(GyroMode.tilt), ['sixAxis']);
    expect(await shown(GyroMode.motionDevice), isEmpty);
  });

  testWidgets('options start as invert off, hold off, 6-axis on', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const SettingModel(gyroEnabled: true)));
    bool on(GyroOption o) => tester
        .widget<SwitchListTile>(
          find.descendant(
            of: find.byKey(ValueKey('gyro-option-${o.name}')),
            matching: find.byType(SwitchListTile),
          ),
        )
        .value;

    expect(on(GyroOption.invertY), isFalse);
    expect(on(GyroOption.holdPosition), isFalse);
    expect(on(GyroOption.sixAxis), isTrue);
  });

  testWidgets('flipping an option reports the updated model', (tester) async {
    SettingModel? next;
    await tester.pumpWidget(
      _host(const SettingModel(gyroEnabled: true), onChanged: (m) => next = m),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('gyro-option-invertY')),
        matching: find.byType(Switch),
      ),
    );
    expect(next!.gyroInvertY, isTrue);
    expect(next!.gyroHold, isFalse);
    expect(next!.gyroEnabled, isTrue);
  });

  test('the new options survive a save and load', () {
    const model = SettingModel(
      gyroEnabled: true,
      gyroInvertY: true,
      gyroHold: true,
      gyroSixAxis: false,
    );
    expect(SettingModel.decode(model.encode()), model);
  });
}

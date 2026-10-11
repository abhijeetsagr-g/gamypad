import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_pc/src/ui/state/log_controller.dart';
import 'package:gamypad_pc/src/ui/state/providers.dart'
    show socketMessagesProvider;
import 'package:protocol/protocol.dart';

void main() {
  late StreamController<Message> bus;
  late ProviderContainer container;

  setUp(() {
    bus = StreamController<Message>.broadcast(sync: true);
    container = ProviderContainer(
      overrides: [socketMessagesProvider.overrideWith((ref) => bus.stream)],
    );
    // Keep the provider alive and listening.
    container.listen(socketMessagesProvider, (_, _) {});
    container.read(logControllerProvider);
  });

  tearDown(() async {
    container.dispose();
    await bus.close();
  });

  Future<void> send(Message m) async {
    bus.add(m);
    await Future<void>.delayed(Duration.zero);
  }

  LogState log() => container.read(logControllerProvider);

  test('motion is not recorded unless the motion filter is selected', () async {
    await send(const MotionMessage(gx: 1));
    await send(const ButtonMessage(button: GamepadButton.A, pressed: true));

    expect(log().entries, hasLength(1));
    expect(log().entries.single.message, isA<ButtonMessage>());
  });

  test('with the motion filter on, samples are recorded and shown', () async {
    container.read(logControllerProvider.notifier).setFilter(LogFilter.motion);
    await send(const MotionMessage(gx: 1500, ay: 1000));

    final shown = log().filteredEntries;
    expect(shown, hasLength(1));
    expect((shown.single.message as MotionMessage).gx, 1500);
  });

  test('samples in quick succession coalesce into one row', () async {
    container.read(logControllerProvider.notifier).setFilter(LogFilter.motion);
    await send(const MotionMessage(gx: 1));
    await send(const MotionMessage(gx: 2));
    await send(const MotionMessage(gx: 3));

    expect(log().entries, hasLength(1));
    expect((log().entries.single.message as MotionMessage).gx, 3);
  });

  test('the all filter never shows motion, even if it was recorded', () async {
    final notifier = container.read(logControllerProvider.notifier);
    notifier.setFilter(LogFilter.motion);
    await send(const MotionMessage(gx: 1));
    await send(const ButtonMessage(button: GamepadButton.B, pressed: true));
    notifier.setFilter(LogFilter.all);

    expect(log().filteredEntries.map((e) => e.message), [isA<ButtonMessage>()]);
  });
}

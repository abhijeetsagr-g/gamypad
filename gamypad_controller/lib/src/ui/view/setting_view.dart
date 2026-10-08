import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:gamypad_controller/src/ui/state/setting_controller.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/section_label.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: settings.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: ColorPalette.accent),
          ),
          error: (_, _) => const Center(
            child: Text(
              'Could not load settings.',
              style: TextStyle(color: ColorPalette.muted, fontSize: 13),
            ),
          ),
          data: (model) => _Body(
            model: model,
            onVibrateChanged: (value) => ref
                .read(settingControllerProvider.notifier)
                .commit(model.copyWith(vibrate: value)),
            onDigitalTriggersChanged: (value) => ref
                .read(settingControllerProvider.notifier)
                .commit(model.copyWith(digitalTriggers: value)),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.model,
    required this.onVibrateChanged,
    required this.onDigitalTriggersChanged,
  });

  final SettingModel model;
  final ValueChanged<bool> onVibrateChanged;
  final ValueChanged<bool> onDigitalTriggersChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            SwitchRow(
              label: "FEEDBACK",
              title: "Vibration",
              subtitle: 'Haptic feedback on button presses',
              value: model.vibrate,
              onChanged: onVibrateChanged,
            ),
            const SizedBox(height: 24),
            SwitchRow(
              label: "CONTROLS",
              title: "Digital triggers",
              subtitle: "Touching a trigger sends a full press",
              value: model.digitalTriggers,
              onChanged: onDigitalTriggersChanged,
            ),
          ],
        ),
      ),
    );
  }
}

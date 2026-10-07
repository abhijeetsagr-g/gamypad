import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:gamypad_controller/src/ui/state/setting_controller.dart';
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
            const _SectionLabel('FEEDBACK'),
            const SizedBox(height: 12),
            _SwitchRow(
              title: 'Vibration',
              subtitle: 'Haptic feedback on button presses',
              value: model.vibrate,
              onChanged: onVibrateChanged,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('CONTROLS'),
            const SizedBox(height: 12),
            _SwitchRow(
              title: 'Digital triggers',
              subtitle: 'Touching a trigger sends a full press',
              value: model.digitalTriggers,
              onChanged: onDigitalTriggersChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: ColorPalette.muted,
        fontSize: 10,
        letterSpacing: 3,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorPalette.analogTrack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorPalette.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.black,
        activeTrackColor: ColorPalette.accent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
            color: ColorPalette.text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: ColorPalette.muted, fontSize: 12),
        ),
      ),
    );
  }
}

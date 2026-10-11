import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/settings/setting_model.dart';
import 'package:gamypad_controller/src/ui/widgets/setting/section_label.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

/// What each mode does, shown under the selector.
const gyroModeDescriptions = <GyroMode, String>{
  GyroMode.aim:
      'Turning the phone moves the right stick, like gyro aiming on a '
      'PlayStation or Switch controller. Rotation speed sets how far the '
      'stick goes, and it returns to centre when you stop turning. Works in '
      'any game. Best for aiming a camera.',
  GyroMode.tilt:
      'Tilting the phone like a steering wheel moves the left stick left or '
      'right. Level is centre, about 45° is full. Works in any game. Best for '
      'racing.',
  GyroMode.motionDevice:
      'Sends raw gyro and accelerometer data to a virtual DualSense-style '
      'motion sensor on the PC. Only games and tools that read a motion '
      'device will respond, and sticks are not affected. Experimental.',
};

/// Extra switches that only make sense for some modes.
enum GyroOption { invertY, holdPosition, sixAxis }

const gyroOptionsFor = <GyroMode, List<GyroOption>>{
  GyroMode.aim: [
    GyroOption.invertY,
    GyroOption.holdPosition,
    GyroOption.sixAxis,
  ],
  GyroMode.tilt: [GyroOption.sixAxis],
  GyroMode.motionDevice: [],
};

const _optionText = <GyroOption, ({String title, String subtitle})>{
  GyroOption.invertY: (
    title: 'Invert vertical axis',
    subtitle: 'Raising the far edge of the phone looks down',
  ),
  GyroOption.holdPosition: (
    title: 'Hold position',
    subtitle:
        'The stick stays where you turned it instead of returning to centre. '
        'Turn back to return it, or touch the stick to recentre',
  ),
  GyroOption.sixAxis: (
    title: '6-axis fusion',
    subtitle:
        'Combine gyro and accelerometer to track which way is up. Aim keeps '
        'working when the phone is rolled or tipped, and tilt is steadier',
  ),
};

const _gyroModeLabels = <GyroMode, String>{
  GyroMode.aim: 'AIM',
  GyroMode.tilt: 'TILT',
  GyroMode.motionDevice: 'MOTION',
};

/// The gyro toggle, and under it — only while on — the mode selector.
class GyroSection extends StatelessWidget {
  const GyroSection({
    super.key,
    required this.model,
    required this.onEnabledChanged,
    required this.onModeChanged,
    required this.onChanged,
  });

  final SettingModel model;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<GyroMode> onModeChanged;

  /// Reports the whole model with one option flipped.
  final ValueChanged<SettingModel> onChanged;

  bool _valueOf(GyroOption option) => switch (option) {
    GyroOption.invertY => model.gyroInvertY,
    GyroOption.holdPosition => model.gyroHold,
    GyroOption.sixAxis => model.gyroSixAxis,
  };

  SettingModel _with(GyroOption option, bool value) => switch (option) {
    GyroOption.invertY => model.copyWith(gyroInvertY: value),
    GyroOption.holdPosition => model.copyWith(gyroHold: value),
    GyroOption.sixAxis => model.copyWith(gyroSixAxis: value),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchRow(
          label: 'MOTION',
          title: 'Gyro',
          subtitle: 'Use the phone\'s motion sensors',
          value: model.gyroEnabled,
          onChanged: onEnabledChanged,
        ),
        if (model.gyroEnabled) ...[
          const SizedBox(height: 12),
          SegmentedButton<GyroMode>(
            key: const ValueKey('gyro-mode'),
            showSelectedIcon: false,
            segments: [
              for (final mode in GyroMode.values)
                ButtonSegment(
                  value: mode,
                  label: Text(
                    _gyroModeLabels[mode]!,
                    style: const TextStyle(letterSpacing: 2, fontSize: 12),
                  ),
                ),
            ],
            selected: {model.gyroMode},
            onSelectionChanged: (selection) => onModeChanged(selection.single),
            style: SegmentedButton.styleFrom(
              backgroundColor: ColorPalette.analogTrack,
              foregroundColor: ColorPalette.label,
              selectedBackgroundColor: ColorPalette.accent,
              selectedForegroundColor: Colors.black,
              side: const BorderSide(color: ColorPalette.border),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gyroModeDescriptions[model.gyroMode]!,
            key: const ValueKey('gyro-description'),
            style: const TextStyle(
              color: ColorPalette.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          for (final option in gyroOptionsFor[model.gyroMode]!) ...[
            const SizedBox(height: 12),
            _OptionTile(
              key: ValueKey('gyro-option-${option.name}'),
              title: _optionText[option]!.title,
              subtitle: _optionText[option]!.subtitle,
              value: _valueOf(option),
              onChanged: (value) => onChanged(_with(option, value)),
            ),
          ],
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
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
      child: Material(
        type: MaterialType.transparency,
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.black,
          activeTrackColor: ColorPalette.accent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            title,
            style: const TextStyle(
              color: ColorPalette.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: ColorPalette.muted, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

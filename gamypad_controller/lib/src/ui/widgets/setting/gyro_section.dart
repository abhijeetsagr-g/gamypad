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
  });

  final SettingModel model;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<GyroMode> onModeChanged;

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
        ],
      ],
    );
  }
}

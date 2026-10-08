import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ColorPalette.muted,
            fontSize: 10,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),

        DecoratedBox(
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
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
        ),
      ],
    );
  }
}

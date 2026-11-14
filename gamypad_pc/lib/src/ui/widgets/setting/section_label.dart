import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: ColorPalette.muted,
        fontSize: 10,
        letterSpacing: 3,
      ),
    );
  }
}

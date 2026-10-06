import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_button.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_dpad.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_stick.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_trigger.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';
import 'package:protocol/protocol.dart';

class PadRenderer extends StatelessWidget {
  const PadRenderer({
    super.key,
    required this.layout,
    this.onButton,
    this.onStick,
    this.onTrigger,
    this.enabled = true,
    this.showCanvas = false,
  });

  final ControllerLayout layout;

  final void Function(GamepadButton button, bool pressed)? onButton;
  final void Function(GamepadStick stick, int x, int y)? onStick;
  final void Function(GamepadTrigger trigger, int value)? onTrigger;

  final bool enabled;
  final bool showCanvas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.biggest;
        final authored = layout.authoredSize;

        final scale = (available.width.isFinite && available.height.isFinite)
            ? math.max(
                available.width / authored.width,
                available.height / authored.height,
              )
            : 1.0;
        final rendered = Size(authored.width * scale, authored.height * scale);

        final stage = Stack(
          clipBehavior: Clip.none,
          children: [
            for (final element in layout.ordered)
              Positioned.fromRect(
                rect: _scaled(element.rect, scale),
                child: _widgetFor(element),
              ),
          ],
        );

        return SizedBox.expand(
          child: Center(
            child: SizedBox.fromSize(
              size: rendered,

              child: showCanvas
                  ? DecoratedBox(
                      decoration: const BoxDecoration(
                        color: ColorPalette.stage,
                        border: Border.fromBorderSide(
                          BorderSide(color: ColorPalette.border),
                        ),
                      ),
                      child: stage,
                    )
                  : stage,
            ),
          ),
        );
      },
    );
  }

  static Rect _scaled(Rect rect, double scale) => Rect.fromLTWH(
    rect.left * scale,
    rect.top * scale,
    rect.width * scale,
    rect.height * scale,
  );

  Widget _widgetFor(PadElement element) => switch (element) {
    ButtonElement(:final button) => PadButton(
      label: button.name,
      enabled: enabled,
      onChanged: onButton == null
          ? null
          : (pressed) => onButton!(button, pressed),
    ),
    DpadElement() => PadDpad(
      enabled: enabled,
      onChanged: onButton == null
          ? null
          : (button, pressed) => onButton!(button, pressed),
    ),
    StickElement(:final stick) => PadStick(
      enabled: enabled,
      onChanged: onStick == null ? null : (x, y) => onStick!(stick, x, y),
    ),
    TriggerElement(:final trigger) => PadTrigger(
      label: trigger.name,
      onChanged: onTrigger == null
          ? null
          : (value) => onTrigger!(trigger, value),
    ),
  };
}

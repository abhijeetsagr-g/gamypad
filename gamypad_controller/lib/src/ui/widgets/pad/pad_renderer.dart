import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_button.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_dpad.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_stick.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_trigger.dart';
import 'package:protocol/protocol.dart';

/// A [ControllerLayout] drawn into the space it is given.
///
/// The only path from a layout to pixels. Both surfaces use it, so what the
/// editor arranges is exactly what gets played and no widget can drift between
/// the two. Appearance is identical either way; only the callbacks differ, and a
/// null callback means *display only* rather than a second visual variant.
///
/// Scaling is uniform and derived here:
///
///     scale = max(screenW / authoredW, screenH / authoredH)
///
/// centred. `max`, not `min`: the canvas fills the screen and overflows the
/// short axis, rather than letterboxing a visible band down each side. The
/// 800×400 canvas is authored at a controller's 2:1, and a phone in landscape is
/// wider, so contain-fit left ~10% of the width unusable on every device.
///
/// Normalized coordinates were rejected — see [ControllerLayout] for why a
/// stick stored as a fraction renders wrong on a screen that is not the
/// authored shape.
///
/// Elements at the canvas edge can therefore fall outside the screen. That is
/// known and accepted for now: the default layout is authored against desktop
/// proportions, and it is going to be repositioned rather than preserved. Fixing
/// it properly means authoring the canvas against a phone aspect, not picking a
/// different scale here.
///
/// Elements are laid out at their *rendered* size, not the authored one, so
/// everything inside a widget sees the pixels it is actually drawn in. That is
/// what lets `StickCurve.max` and trigger travel be read from the box rather
/// than stored.
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

  /// Null renders the pad without any input wired up.
  final void Function(GamepadButton button, bool pressed)? onButton;

  /// Null renders the pad without any input wired up.
  final void Function(GamepadStick stick, int x, int y)? onStick;

  /// Null renders the pad without any input wired up.
  final void Function(GamepadTrigger trigger, int value)? onTrigger;

  /// False while disconnected, so the pad is visibly inert rather than
  /// silently swallowing every press.
  final bool enabled;

  /// Outlines the authored canvas. On while editing, off while playing — the
  /// play surface has no such frame to draw.
  final bool showCanvas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.biggest;
        final authored = layout.authoredSize;

        // Unbounded — a caller that has not given this a bounded box gets the
        // authored size rather than a nonsense scale of zero.
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
              // The authored canvas, outlined while editing. Without it the scale
              // is invisible: the pad letterboxes rather than stretches, so there
              // is nothing on screen marking how much room the layout was chosen
              // against.
              child: showCanvas
                  ? DecoratedBox(
                      decoration: const BoxDecoration(
                        color: PadPalette.stage,
                        border: Border.fromBorderSide(
                          BorderSide(color: PadPalette.border),
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

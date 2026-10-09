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
    this.showHidden = false,
    this.digitalTriggers = false,
  });

  final ControllerLayout layout;

  final void Function(GamepadButton button, bool pressed)? onButton;
  final void Function(GamepadStick stick, int x, int y)? onStick;
  final void Function(GamepadTrigger trigger, int value)? onTrigger;

  final bool enabled;
  final bool showCanvas;

  /// Renders hidden elements as dashed ghosts instead of skipping them. Used by
  /// the editor so hidden elements stay reachable for re-showing.
  final bool showHidden;

  final bool digitalTriggers;

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
              if (!layout.isHidden(element.id) || showHidden)
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

  Widget _widgetFor(PadElement element) {
    if (layout.isHidden(element.id)) return _HiddenGhost(element: element);

    return switch (element) {
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
        digital: digitalTriggers,
        onChanged: onTrigger == null
            ? null
            : (value) => onTrigger!(trigger, value),
      ),
    };
  }
}

/// The dashed, dimmed stand-in for a hidden element while editing, so the
/// element stays reachable for re-showing.
class _HiddenGhost extends StatelessWidget {
  const _HiddenGhost({required this.element});

  final PadElement element;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _GhostPainter(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              element.id,
              style: const TextStyle(
                color: ColorPalette.muted,
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  const _GhostPainter();

  static const _dash = 7.0;
  static const _gap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = ColorPalette.dim
        ..style = PaintingStyle.fill,
    );

    final border = Paint()
      ..color = ColorPalette.muted
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final metric in (Path()..addRRect(rrect.deflate(1)))
        .computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(_dash, metric.length - distance);
        canvas.drawPath(
          metric.extractPath(distance, distance + length),
          border,
        );
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_GhostPainter oldDelegate) => false;
}

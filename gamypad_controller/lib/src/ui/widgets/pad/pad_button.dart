import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class PadButton extends StatefulWidget {
  const PadButton({
    super.key,
    required this.label,
    required this.onChanged,
    this.enabled = true,
    this.labelScale = 0.26,
  });

  final String label;

  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final double labelScale;

  @override
  State<PadButton> createState() => _PadButtonState();
}

class _PadButtonState extends State<PadButton> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (widget.onChanged == null || !widget.enabled) return;
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
    widget.onChanged!(pressed);
  }

  @override
  void didUpdateWidget(PadButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.onChanged == null || !oldWidget.enabled) && _pressed) {
      setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _pressed && widget.enabled;

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final shortest = constraints.biggest.shortestSide;
        final label = Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: switch ((active, widget.enabled)) {
              (true, _) => ColorPalette.labelPressed,
              (_, false) => ColorPalette.label,
              _ => ColorPalette.label,
            },
            fontWeight: FontWeight.w600,
            fontSize: (shortest * widget.labelScale).clamp(9.0, 20.0),
            letterSpacing: 1,
          ),
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: active ? ColorPalette.accent : ColorPalette.analogTrack,
            borderRadius: BorderRadius.circular(shortest * 0.22),
            border: Border.all(
              color: active ? ColorPalette.borderPressed : ColorPalette.border,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(shortest * 0.12),
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: label),
            ),
          ),
        );
      },
    );

    if (widget.onChanged == null || !widget.enabled) {
      return content;
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: content,
    );
  }
}

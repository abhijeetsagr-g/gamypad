import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';

/// One digital button, sized by its box.
///
/// The eleven singles — face, shoulders, centre row, GUIDE — all share this.
/// Free resize means the label has to cope with anything from a 44pt sliver to a
/// full-width slab, so it scales with the box and gives up before it would clip.
///
/// A null [onChanged] means *appearance only*: the editor renders the pad with
/// no input wiring rather than with a second visual variant, so what is
/// arranged is exactly what gets played.
class PadButton extends StatefulWidget {
  const PadButton({
    super.key,
    required this.label,
    required this.onChanged,
    this.enabled = true,
    this.labelScale = 0.26,
  });

  final String label;

  /// Emits true on press, false on release. Null disables input.
  final ValueChanged<bool>? onChanged;

  /// False while disconnected, so a press is visibly inert rather than a dead
  /// spot that looks broken.
  final bool enabled;

  /// How much of the box's short side the label takes. D-pad arrows want more
  /// than a word does.
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

    // The pad disappearing mid-press — a reset in the editor, a lost
    // connection on the play surface — must not leave the button stuck lit.
    if ((oldWidget.onChanged == null || !oldWidget.enabled) && _pressed) {
      setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _pressed && widget.enabled;

    // Listener rather than GestureDetector: fires on pointer down without
    // waiting on the gesture arena, so there is no perceptible input lag. On a
    // pad the difference between immediate and one frame late is the difference
    // between a button and a stiff one.
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
              (true, _) => PadPalette.labelPressed,
              (_, false) => PadPalette.disabled,
              _ => PadPalette.label,
            },
            fontWeight: FontWeight.w600,
            // Scales with the box so a stretched button does not end up with a
            // 12pt caption in the middle of it.
            fontSize: (shortest * widget.labelScale).clamp(9.0, 20.0),
            letterSpacing: 1,
          ),
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: active ? PadPalette.surfacePressed : PadPalette.surface,
            borderRadius: BorderRadius.circular(shortest * 0.22),
            border: Border.all(
              color: active ? PadPalette.borderPressed : PadPalette.border,
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

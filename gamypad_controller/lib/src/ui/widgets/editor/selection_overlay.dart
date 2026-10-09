import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';

class SelectionOverlay extends StatelessWidget {
  const SelectionOverlay({
    super.key,
    required this.element,
    required this.scale,
    required this.invalid,
    required this.showHandle,
    required this.hidden,
  });

  final PadElement? element;

  final double scale;
  final bool invalid;
  final bool showHandle;

  /// Whether the selected element is currently hidden (chooses the hide/show
  /// icon glyph).
  final bool hidden;

  static const double handleSize = 26;

  /// Where the resize handle for [element] sits, in rendered px.
  static Rect handleRectFor(PadElement element, double scale) {
    final rect = scaleRect(element.rect, scale);
    return Rect.fromCenter(
      center: rect.bottomRight,
      width: handleSize,
      height: handleSize,
    );
  }

  /// Where the hide/show toggle for [element] sits, in rendered px.
  static Rect hideRectFor(PadElement element, double scale) {
    final rect = scaleRect(element.rect, scale);
    return Rect.fromCenter(
      center: rect.topRight,
      width: handleSize,
      height: handleSize,
    );
  }

  static Rect scaleRect(Rect rect, double scale) => Rect.fromLTWH(
    rect.left * scale,
    rect.top * scale,
    rect.width * scale,
    rect.height * scale,
  );

  @override
  Widget build(BuildContext context) {
    final selected = element;
    if (selected == null) return const SizedBox.shrink();

    final color = invalid ? ColorPalette.invalid : ColorPalette.selection;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(
          rect: scaleRect(selected.rect, scale),
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (showHandle)
          Positioned.fromRect(
            rect: handleRectFor(selected, scale),
            child: const IgnorePointer(child: _Handle()),
          ),
        Positioned.fromRect(
          rect: hideRectFor(selected, scale),
          child: IgnorePointer(child: _HideIcon(hidden: hidden)),
        ),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorPalette.selection,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: ColorPalette.background, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.open_in_full,
          size: SelectionOverlay.handleSize * 0.46,
          color: ColorPalette.background,
        ),
      ),
    );
  }
}

/// The toggle offered at the selected element's top-right corner: hide while
/// visible (`visibility_off`), show while hidden (`visibility`).
class _HideIcon extends StatelessWidget {
  const _HideIcon({required this.hidden});

  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorPalette.selection,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: ColorPalette.background, width: 2),
      ),
      child: Center(
        child: Icon(
          hidden ? Icons.visibility : Icons.visibility_off,
          size: SelectionOverlay.handleSize * 0.46,
          color: ColorPalette.background,
        ),
      ),
    );
  }
}
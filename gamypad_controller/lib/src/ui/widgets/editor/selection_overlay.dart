import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';

class SelectionOverlay extends StatelessWidget {
  const SelectionOverlay({
    super.key,
    required this.element,
    required this.scale,
    required this.invalid,
    required this.showHandle,
  });

  final PadElement? element;

  final double scale;
  final bool invalid;

  final bool showHandle;
  static const double handleSize = 26;

  /// Where the handle for [element] sits, in rendered px.
  static Rect handleRectFor(PadElement element, double scale) {
    final rect = scaleRect(element.rect, scale);
    return Rect.fromCenter(
      center: rect.bottomRight,
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

    final color = invalid ? PadPalette.invalid : PadPalette.selection;

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
        color: PadPalette.selection,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: PadPalette.background, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.open_in_full,
          size: SelectionOverlay.handleSize * 0.46,
          color: PadPalette.background,
        ),
      ),
    );
  }
}

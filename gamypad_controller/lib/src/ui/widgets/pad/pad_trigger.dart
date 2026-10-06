import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/input/trigger_curve.dart';
import 'package:gamypad_controller/src/ui/widgets/pad/pad_palette.dart';
import 'package:protocol/protocol.dart';

/// An analog trigger: slide up for more pressure, release to rest.
///
/// **Slide, not hold.** Finger position is the pressure, so the fill on screen
/// and the number on the wire are the same quantity. That is the opposite of the
/// PC's `AnalogTrigger`, which ramps over a fixed `Duration` — correct for a
/// mouse, which cannot hold a position, and wrong for a thumb.
///
/// **Up for more.** Intuitive in landscape, where your thumbs already reach
/// upward for the triggers. A one-line change if it feels wrong on a device.
///
/// Travel is the rendered height, so a full pull is the height of the element.
/// Nothing stores it, and the element is not resizable, so the feel cannot drift
/// between layouts.
///
/// A null [onChanged] means appearance only — see [PadButton].
class PadTrigger extends StatefulWidget {
  const PadTrigger({super.key, required this.label, required this.onChanged});

  final String label;

  /// Emits `triggerMin..triggerMax`. Null disables input.
  final ValueChanged<int>? onChanged;

  @override
  State<PadTrigger> createState() => _PadTriggerState();
}

class _PadTriggerState extends State<PadTrigger> {
  int _value = triggerMin;

  bool get _live => widget.onChanged != null;

  double get _fill => _value / triggerMax;

  /// Emits the value for a thumb at [localY], given the element's rendered
  /// height. Up is more, so distance is measured up from the resting edge.
  void _report(double localY, double travel) {
    if (!_live) return;

    final next = TriggerCurve(travel: travel).apply(travel - localY);
    if (next == _value) return;

    setState(() => _value = next);
    widget.onChanged!(next);
  }

  void _rest() {
    if (!_live || _value == triggerMin) return;
    setState(() => _value = triggerMin);
    widget.onChanged!(triggerMin);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Travel comes from the rendered height, so it is read here rather than
        // stored anywhere.
        final travel = constraints.maxHeight;

        final content = ClipRRect(
          borderRadius: BorderRadius.circular(travel * 0.28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: PadPalette.analogTrack),
              // Grows from the resting edge, so the fill and the direction of
              // travel are the same thing on screen.
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: _fill,
                  widthFactor: 1,
                  child: const ColoredBox(color: PadPalette.analogFill),
                ),
              ),
              _Readout(
                label: widget.label,
                value: _value,
                // Past halfway the text sits on green, so it flips to dark.
                onFill: _live && _fill > 0.5,
              ),
            ],
          ),
        );

        if (!_live) return _dimmed(content);

        // Listener with no gesture arena: a drag is sampled as it happens, so
        // partial pulls are observable instead of arriving in one jump at the
        // end. Moves outside the box still arrive, which is what lets the thumb
        // carry on past the top and sit at full travel.
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _report(event.localPosition.dy, travel),
          onPointerMove: (event) => _report(event.localPosition.dy, travel),
          onPointerUp: (_) => _rest(),
          onPointerCancel: (_) => _rest(),
          child: content,
        );
      },
    );
  }

  /// The inert look: the outline stays, so the element is still findable, but
  /// nothing claims to be live.
  Widget _dimmed(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: PadPalette.border),
    ),
    child: child,
  );
}

/// Label plus the raw value, so the number reaching the device can be read off
/// the pad rather than inferred from the bar.
class _Readout extends StatelessWidget {
  const _Readout({
    required this.label,
    required this.value,
    required this.onFill,
  });

  final String label;
  final int value;
  final bool onFill;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$label  $value',
            maxLines: 1,
            style: TextStyle(
              color: onFill ? Colors.black : PadPalette.label,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

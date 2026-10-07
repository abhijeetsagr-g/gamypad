import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/input/trigger_curve.dart';
import 'package:gamypad_controller/src/utils/app_theme.dart';
import 'package:protocol/protocol.dart';

class PadTrigger extends StatefulWidget {
  const PadTrigger({
    super.key,
    required this.label,
    required this.onChanged,
    this.digital = false,
  });

  final String label;
  final ValueChanged<int>? onChanged;

  /// When true the trigger is a button: touching it reports [triggerMax]
  /// regardless of where the finger is.
  final bool digital;

  @override
  State<PadTrigger> createState() => _PadTriggerState();
}

class _PadTriggerState extends State<PadTrigger> {
  int _value = triggerMin;

  bool get _live => widget.onChanged != null;

  double get _fill => _value / triggerMax;

  void _report(double localY, double travel) {
    if (!_live) return;

    final next = widget.digital
        ? triggerMax
        : TriggerCurve(travel: travel).apply(travel - localY);
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
        final travel = constraints.maxHeight;

        final content = ClipRRect(
          borderRadius: BorderRadius.circular(travel * 0.28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: ColorPalette.analogTrack),
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: _fill,
                  widthFactor: 1,
                  child: const ColoredBox(color: ColorPalette.accent),
                ),
              ),
              _Readout(
                label: widget.label,
                value: _value,
                onFill: _live && _fill > 0.5,
              ),
            ],
          ),
        );

        if (!_live) return _dimmed(content);

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

  Widget _dimmed(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: ColorPalette.border),
    ),
    child: child,
  );
}

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
              color: onFill ? Colors.black : ColorPalette.label,
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

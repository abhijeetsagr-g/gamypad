import 'package:protocol/protocol.dart';

class TriggerCurve {
  final double travel;
  final double deadzone;

  const TriggerCurve({this.travel = 48.0, this.deadzone = 0.06});
  int apply(double distance) {
    final fraction = (distance / travel).clamp(0.0, 1.0);
    final past = (fraction - deadzone) / (1 - deadzone);
    return (past.clamp(0.0, 1.0) * triggerMax).toInt().clamp(
      triggerMin,
      triggerMax,
    );
  }
}

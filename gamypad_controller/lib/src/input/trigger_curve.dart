import 'package:protocol/protocol.dart';

/// Thumb travel on a trigger → a `TriggerMessage` value.
///
/// **Linear, with a small deadzone.** Deliberately unlike the PC's
/// `AnalogTrigger`, which ramps over a fixed [Duration] instead: that is right
/// for a mouse, which cannot hold a position, and wrong for a thumb, where the
/// finger's position *is* the pressure. So the value on screen and the value on
/// the wire are the same quantity.
///
/// No [gamma]. A trigger is a squeeze, not a direction — easing one would
/// separate how far the thumb has gone from how hard the game thinks it is
/// pressed.
///
/// A pure function of distance, no widget and no Flutter import, so the mapping
/// is testable without a surface to draw on. [travel] is supplied by the caller
/// because it comes from the rendered height, and is never stored.
class TriggerCurve {
  /// How far the thumb has to travel for full pressure, in px.
  final double travel;

  /// Fraction of [travel] below which the trigger reads as released.
  ///
  /// Small, because a real trigger has almost no slack at rest and a thumb
  /// resting on it should not be reported as lightly pressed forever.
  final double deadzone;

  const TriggerCurve({this.travel = 48.0, this.deadzone = 0.06});

  /// Maps a thumb [distance] from the resting edge to `triggerMin..triggerMax`.
  ///
  /// [distance] is measured along the direction of travel, so it grows as the
  /// thumb pulls and is [travel] at full. Values outside are clamped rather
  /// than extrapolated: a finger can slide off the end of the element while the
  /// gesture is still live, and overshooting the wire would be rejected.
  int apply(double distance) {
    final fraction = (distance / travel).clamp(0.0, 1.0);
    final past = (fraction - deadzone) / (1 - deadzone);

    // Truncates rather than rounds, so a trigger only reads pressed once it
    // genuinely is.
    return (past.clamp(0.0, 1.0) * triggerMax).toInt().clamp(
      triggerMin,
      triggerMax,
    );
  }
}

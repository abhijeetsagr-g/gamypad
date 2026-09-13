class TiltState {
  const TiltState({
    this.enabled = false,
    this.calibX = 0,
    this.calibY = 0,
    this.sensitivity = 1.6,
    this.deadzone = 0.14,
    this.rawX = 0,
    this.rawY = 0,
    this.stickX = 0,
    this.stickY = 0,
  });

  final bool enabled;
  final double calibX; // neutral offset captured at Calibrate
  final double calibY;
  final double sensitivity; // multiplier on tilt
  final double deadzone; // 0..1, applied after normalize
  // debug / ui
  final double rawX;
  final double rawY;
  final int stickX; // last sent -32767..32767
  final int stickY;

  TiltState copyWith({
    bool? enabled,
    double? calibX,
    double? calibY,
    double? sensitivity,
    double? deadzone,
    double? rawX,
    double? rawY,
    int? stickX,
    int? stickY,
  }) =>
      TiltState(
        enabled: enabled ?? this.enabled,
        calibX: calibX ?? this.calibX,
        calibY: calibY ?? this.calibY,
        sensitivity: sensitivity ?? this.sensitivity,
        deadzone: deadzone ?? this.deadzone,
        rawX: rawX ?? this.rawX,
        rawY: rawY ?? this.rawY,
        stickX: stickX ?? this.stickX,
        stickY: stickY ?? this.stickY,
      );
}

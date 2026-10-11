import 'dart:convert';

/// What the phone's motion sensors do. One at a time.
enum GyroMode {
  /// Rotation speed moves the right stick (camera / aim).
  aim,

  /// Tilt angle moves the left stick (steering).
  tilt,

  /// Raw gyro + accelerometer sent to a virtual motion-sensor device on the PC.
  motionDevice,
}

class SettingModel {
  final bool vibrate;
  final bool digitalTriggers;
  final bool gyroEnabled;
  final GyroMode gyroMode;

  /// Aim: pushing the phone's far edge up looks down instead of up.
  final bool gyroInvertY;

  /// Aim: the stick keeps its deflection when you stop turning, instead of
  /// springing back to centre.
  final bool gyroHold;

  /// Aim and tilt: fuse gyro and accelerometer instead of using one alone.
  final bool gyroSixAxis;

  const SettingModel({
    this.vibrate = false,
    this.digitalTriggers = false,
    this.gyroEnabled = false,
    this.gyroMode = GyroMode.aim,
    this.gyroInvertY = false,
    this.gyroHold = false,
    this.gyroSixAxis = true,
  });

  SettingModel copyWith({
    bool? vibrate,
    bool? digitalTriggers,
    bool? gyroEnabled,
    GyroMode? gyroMode,
    bool? gyroInvertY,
    bool? gyroHold,
    bool? gyroSixAxis,
  }) => SettingModel(
    vibrate: vibrate ?? this.vibrate,
    digitalTriggers: digitalTriggers ?? this.digitalTriggers,
    gyroEnabled: gyroEnabled ?? this.gyroEnabled,
    gyroMode: gyroMode ?? this.gyroMode,
    gyroInvertY: gyroInvertY ?? this.gyroInvertY,
    gyroHold: gyroHold ?? this.gyroHold,
    gyroSixAxis: gyroSixAxis ?? this.gyroSixAxis,
  );

  String encode() => jsonEncode({
    'vibrate': vibrate,
    'digitalTriggers': digitalTriggers,
    'gyroEnabled': gyroEnabled,
    'gyroMode': gyroMode.name,
    'gyroInvertY': gyroInvertY,
    'gyroHold': gyroHold,
    'gyroSixAxis': gyroSixAxis,
  });

  factory SettingModel.decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map) {
      throw FormatException('Setting Model must be an object, got: $json');
    }
    final vibrate = json['vibrate'];
    final digitalTriggers = json['digitalTriggers'];
    final gyroEnabled = json['gyroEnabled'];
    final gyroMode = json['gyroMode'];
    final gyroInvertY = json['gyroInvertY'];
    final gyroHold = json['gyroHold'];
    final gyroSixAxis = json['gyroSixAxis'];
    return SettingModel(
      vibrate: vibrate is bool ? vibrate : false,
      digitalTriggers: digitalTriggers is bool ? digitalTriggers : false,
      gyroEnabled: gyroEnabled is bool ? gyroEnabled : false,
      gyroMode: GyroMode.values.asNameMap()[gyroMode] ?? GyroMode.aim,
      gyroInvertY: gyroInvertY is bool ? gyroInvertY : false,
      gyroHold: gyroHold is bool ? gyroHold : false,
      gyroSixAxis: gyroSixAxis is bool ? gyroSixAxis : true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingModel &&
          other.vibrate == vibrate &&
          other.digitalTriggers == digitalTriggers &&
          other.gyroEnabled == gyroEnabled &&
          other.gyroMode == gyroMode &&
          other.gyroInvertY == gyroInvertY &&
          other.gyroHold == gyroHold &&
          other.gyroSixAxis == gyroSixAxis;

  @override
  int get hashCode => Object.hash(
    vibrate,
    digitalTriggers,
    gyroEnabled,
    gyroMode,
    gyroInvertY,
    gyroHold,
    gyroSixAxis,
  );

  @override
  String toString() =>
      'SettingModel(vibrate: $vibrate, digitalTriggers: $digitalTriggers, '
      'gyroEnabled: $gyroEnabled, gyroMode: ${gyroMode.name}, '
      'invertY: $gyroInvertY, hold: $gyroHold, sixAxis: $gyroSixAxis)';
}

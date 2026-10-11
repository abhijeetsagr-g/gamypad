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

  const SettingModel({
    this.vibrate = false,
    this.digitalTriggers = false,
    this.gyroEnabled = false,
    this.gyroMode = GyroMode.aim,
  });

  SettingModel copyWith({
    bool? vibrate,
    bool? digitalTriggers,
    bool? gyroEnabled,
    GyroMode? gyroMode,
  }) => SettingModel(
    vibrate: vibrate ?? this.vibrate,
    digitalTriggers: digitalTriggers ?? this.digitalTriggers,
    gyroEnabled: gyroEnabled ?? this.gyroEnabled,
    gyroMode: gyroMode ?? this.gyroMode,
  );

  String encode() => jsonEncode({
    'vibrate': vibrate,
    'digitalTriggers': digitalTriggers,
    'gyroEnabled': gyroEnabled,
    'gyroMode': gyroMode.name,
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
    return SettingModel(
      vibrate: vibrate is bool ? vibrate : false,
      digitalTriggers: digitalTriggers is bool ? digitalTriggers : false,
      gyroEnabled: gyroEnabled is bool ? gyroEnabled : false,
      gyroMode: GyroMode.values.asNameMap()[gyroMode] ?? GyroMode.aim,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingModel &&
          other.vibrate == vibrate &&
          other.digitalTriggers == digitalTriggers &&
          other.gyroEnabled == gyroEnabled &&
          other.gyroMode == gyroMode;

  @override
  int get hashCode =>
      Object.hash(vibrate, digitalTriggers, gyroEnabled, gyroMode);

  @override
  String toString() =>
      'SettingModel(vibrate: $vibrate, digitalTriggers: $digitalTriggers, '
      'gyroEnabled: $gyroEnabled, gyroMode: ${gyroMode.name})';
}

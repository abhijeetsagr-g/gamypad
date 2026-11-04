import 'dart:convert';

class SettingModel {
  final bool vibrate;
  final bool digitalTriggers;
  final bool rememberPcAddress;
  final String? savedPcAddress;
  final int? savedPcPort;

  const SettingModel({
    this.vibrate = false,
    this.digitalTriggers = false,
    this.rememberPcAddress = false,
    this.savedPcAddress,
    this.savedPcPort,
  });

  SettingModel copyWith({
    bool? vibrate,
    bool? digitalTriggers,
    bool? rememberPcAddress,
    String? savedPcAddress,
    int? savedPcPort,
  }) => SettingModel(
    vibrate: vibrate ?? this.vibrate,
    digitalTriggers: digitalTriggers ?? this.digitalTriggers,
    rememberPcAddress: rememberPcAddress ?? this.rememberPcAddress,
    savedPcAddress: savedPcAddress ?? this.savedPcAddress,
    savedPcPort: savedPcPort ?? this.savedPcPort,
  );

  String encode() => jsonEncode({
    'vibrate': vibrate,
    'digitalTriggers': digitalTriggers,
    'rememberPcAddress': rememberPcAddress,
    'savedPcAddress': savedPcAddress,
    'savedPcPort': savedPcPort,
  });

  factory SettingModel.decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map) {
      throw FormatException('Setting Model must be an object, got: $json');
    }
    final vibrate = json['vibrate'];
    final digitalTriggers = json['digitalTriggers'];
    final rememberPcAddress = json['rememberPcAddress'];
    final savedPcAddress = json['savedPcAddress'];
    final savedPcPort = json['savedPcPort'];
    return SettingModel(
      vibrate: vibrate is bool ? vibrate : false,
      digitalTriggers: digitalTriggers is bool ? digitalTriggers : false,
      rememberPcAddress: rememberPcAddress is bool
          ? rememberPcAddress
          : false,
      savedPcAddress: savedPcAddress is String ? savedPcAddress : null,
      savedPcPort: savedPcPort is int ? savedPcPort : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingModel &&
          other.vibrate == vibrate &&
          other.digitalTriggers == digitalTriggers &&
          other.rememberPcAddress == rememberPcAddress &&
          other.savedPcAddress == savedPcAddress &&
          other.savedPcPort == savedPcPort;

  @override
  int get hashCode => Object.hash(
    vibrate,
    digitalTriggers,
    rememberPcAddress,
    savedPcAddress,
    savedPcPort,
  );

  @override
  String toString() =>
      'SettingModel(vibrate: $vibrate, digitalTriggers: $digitalTriggers, '
      'rememberPcAddress: $rememberPcAddress, savedPcAddress: $savedPcAddress, '
      'savedPcPort: $savedPcPort)';
}

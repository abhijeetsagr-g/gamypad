import 'dart:convert';

class SettingModel {
  final bool vibrate;
  final bool digitalTriggers;

  const SettingModel({this.vibrate = false, this.digitalTriggers = false});

  SettingModel copyWith({bool? vibrate, bool? digitalTriggers}) =>
      SettingModel(
        vibrate: vibrate ?? this.vibrate,
        digitalTriggers: digitalTriggers ?? this.digitalTriggers,
      );

  String encode() =>
      jsonEncode({'vibrate': vibrate, 'digitalTriggers': digitalTriggers});

  factory SettingModel.decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map) {
      throw FormatException('Setting Model must be an object, got: $json');
    }
    final vibrate = json['vibrate'];
    final digitalTriggers = json['digitalTriggers'];
    return SettingModel(
      vibrate: vibrate is bool ? vibrate : false,
      digitalTriggers: digitalTriggers is bool ? digitalTriggers : false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingModel &&
          other.vibrate == vibrate &&
          other.digitalTriggers == digitalTriggers;

  @override
  int get hashCode => Object.hash(vibrate, digitalTriggers);

  @override
  String toString() =>
      'SettingModel(vibrate: $vibrate, digitalTriggers: $digitalTriggers)';
}

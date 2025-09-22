import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  bool _isVibrateOn = true;

  bool get isVibrateOn => _isVibrateOn;

  Future<void> toggleVibrate() async {
    _isVibrateOn = !_isVibrateOn;
    notifyListeners();
    await saveSettings(); // persist immediately
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isVibrateOn = prefs.getBool('vibration_enabled') ?? false;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', _isVibrateOn);
  }
}

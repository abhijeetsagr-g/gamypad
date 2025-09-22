import 'package:flutter/material.dart';
import 'package:gamypad_apk/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final settings = Provider.of<Settings>(context);

  void toggleVibration(bool value) async {
    settings.toggleVibrate();
  }

  @override
  Widget build(BuildContext context) {
    bool isVibrateOn = settings.isVibrateOn;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Vibration"),
                SizedBox(width: 20),
                Switch(value: isVibrateOn, onChanged: toggleVibration),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

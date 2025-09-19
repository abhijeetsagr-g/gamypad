import 'package:flutter/material.dart';
import 'package:gamypad_apk/widgets/gamepad.dart';

class GamepadPage extends StatefulWidget {
  const GamepadPage({super.key});

  @override
  State<GamepadPage> createState() => _GamepadPageState();
}

class _GamepadPageState extends State<GamepadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Gamepad());
  }
}

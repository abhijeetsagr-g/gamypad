import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_extra/client.dart';
import 'package:gamypad_extra/widgets/dpad.dart';
import 'package:gamypad_extra/widgets/facebutton.dart';
import 'package:gamypad_extra/widgets/upper_buttons.dart';

class Gamepad extends StatefulWidget {
  const Gamepad({super.key});

  @override
  State<Gamepad> createState() => _GamepadState();
}

class _GamepadState extends State<Gamepad> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Set immersive full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    disconnectServer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 20, 20, 20),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UpperButtons(),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Dpad(), Facebutton()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

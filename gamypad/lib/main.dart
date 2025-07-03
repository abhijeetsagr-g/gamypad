import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad/screens/home.dart';
import 'package:gamypad/screens/gamepad.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/gamepad',
      routes: {'/': (context) => Home(), "/gamepad": (context) => Gamepad()},
    ),
  );
}

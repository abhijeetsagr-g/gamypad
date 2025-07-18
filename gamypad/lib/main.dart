import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad/screens/gamepad.dart';
import 'package:gamypad/screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {'/': (context) => Home(), "/gamepad": (context) => Gamepad()},
    ),
  );
}

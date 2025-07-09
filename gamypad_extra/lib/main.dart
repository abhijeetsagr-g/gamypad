import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_extra/screens/gamepad.dart';
import 'package:gamypad_extra/screens/home.dart';
import 'package:gamypad_extra/screens/help.dart';

// Create a global RouteObserver
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

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
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/gamepad': (context) => Gamepad(),
        '/help': (context) => Help(),
      },
    ),
  );
}

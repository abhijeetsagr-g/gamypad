import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamypad_apk/models/client.dart';
import 'package:gamypad_apk/models/settings.dart';
import 'package:gamypad_apk/pages/gamepad_page.dart';
import 'package:gamypad_apk/pages/home_page.dart';
import 'package:gamypad_apk/pages/settings_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = Settings();
  await settings.loadSettings();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Client()),
        ChangeNotifierProvider(create: (context) => settings),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
          '/gamepad': (context) => GamepadPage(),
          '/settings': (context) => SettingsPage(),
        },
      ),
    ),
  );
}

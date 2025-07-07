import 'package:flutter/material.dart';
import 'package:gamypad_extra/screens/gamepad.dart';
import 'package:gamypad_extra/screens/home.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {'/': (context) => Home(), "/gamepad": (context) => Gamepad()},
  ),
);

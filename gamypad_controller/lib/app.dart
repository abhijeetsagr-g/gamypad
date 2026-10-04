import 'package:flutter/material.dart';
import 'package:gamypad_controller/src/ui/view/home_view.dart';

class GamypadApp extends StatelessWidget {
  const GamypadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark(),
      home: const HomeView(),
    );
  }
}

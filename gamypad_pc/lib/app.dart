import 'package:flutter/material.dart';
import 'package:gamypad_pc/src/ui/view/home_view.dart';
import 'package:gamypad_pc/src/utils/app_theme.dart';

class GamypadApp extends StatelessWidget {
  const GamypadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.myTheme,
      home: const HomeView(),
    );
  }
}

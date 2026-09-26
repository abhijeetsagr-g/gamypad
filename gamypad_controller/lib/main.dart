import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/ui/connect/view/connect_view.dart';

void main() {
  runApp(ProviderScope(child: const GamypadApp()));
}

class GamypadApp extends StatelessWidget {
  const GamypadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const ConnectView(),
    );
  }
}

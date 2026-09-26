import 'package:flutter/material.dart';
import 'package:gamypad_pc/pages/server_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GamypadApp());
}

class GamypadApp extends StatefulWidget {
  const GamypadApp({super.key});

  @override
  State<GamypadApp> createState() => _GamypadAppState();
}

class _GamypadAppState extends State<GamypadApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

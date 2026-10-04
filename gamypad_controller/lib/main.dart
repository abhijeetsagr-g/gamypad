import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamypad_controller/app.dart';

void main() {
  runApp(const ProviderScope(child: GamypadApp()));
}

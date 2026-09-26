import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red[800] : Colors.green[800],
      behavior: SnackBarBehavior.floating,
    ),
  );
}

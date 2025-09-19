import 'package:flutter/material.dart';

void showFloatingSnackbar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating, // makes it float
      margin: const EdgeInsets.all(16), // adds space around
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded corners
      ),
      duration: const Duration(seconds: 3), // auto dismiss
    ),
  );
}

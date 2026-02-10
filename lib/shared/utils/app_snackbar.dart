import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._(); // no instance

  static void success(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.green.shade600);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.red.shade600);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.blue.shade600);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, backgroundColor: Colors.orange.shade600);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

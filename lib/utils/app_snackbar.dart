import 'package:flutter/material.dart';

enum SnackType { error, warning, success }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackType type = SnackType.error,
}) {
  final (Color background, Color foreground, IconData icon) = switch (type) {
    SnackType.error => (
      const Color(0xFFD32F2F),
      Colors.white,
      Icons.error_outline,
    ),
    SnackType.warning => (
      const Color(0xFFF9A825),
      Colors.black87,
      Icons.warning_amber_rounded,
    ),
    SnackType.success => (
      const Color(0xFF2E7D32),
      Colors.white,
      Icons.check_circle_outline,
    ),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

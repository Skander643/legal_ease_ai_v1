import 'package:flutter/material.dart';

/// SnackbarHelper
///
/// Utility class for showing consistent snackbar messages across the app.
///
/// Features:
/// - Success, error, info, warning types
/// - Automatic color coding
/// - Customizable duration
/// - Icon support
///
/// Usage:
/// ```dart
/// SnackbarHelper.showSuccess(context, 'Contrat analysé avec succès');
/// SnackbarHelper.showError(context, 'Erreur lors de l\'analyse');
/// ```
class SnackbarHelper {
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      Icons.check_circle,
      Colors.green,
      duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      Icons.error,
      Colors.red,
      duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      Icons.info,
      Colors.blue,
      duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      Icons.warning_amber_rounded,
      Colors.orange,
      duration,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

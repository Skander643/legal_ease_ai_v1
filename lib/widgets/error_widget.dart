import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool fullScreen;
  final IconData icon;
  final Color? iconColor;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.fullScreen = true,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '❌ Erreur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );

    return fullScreen
        ? Scaffold(
            body: widget,
          )
        : widget;
  }
}

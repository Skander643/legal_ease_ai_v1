import 'package:flutter/material.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final bool fullScreen;
  final IconData icon;
  final Color? iconColor;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.fullScreen = true,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final content = Center(
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
              l10n.errorTitle,
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
                label: Text(retryLabel ?? l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );

    return fullScreen
        ? Scaffold(
            body: content,
          )
        : content;
  }
}

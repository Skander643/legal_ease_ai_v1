import 'package:flutter/material.dart';

/// EmptyStateWidget
///
/// Reusable widget for empty state displays when no data is available.
///
/// Features:
/// - Large icon
/// - Title and description
/// - Optional action button
/// - Customizable styling
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.description,
///   title: 'Aucun document',
///   description: 'Commencez par scanner un contrat',
///   actionLabel: 'Scanner un PDF',
///   onAction: () => pickPdf(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool fullScreen;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.fullScreen = true,
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
              size: 80,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
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

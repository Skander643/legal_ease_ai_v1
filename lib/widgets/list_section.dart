import 'package:flutter/material.dart';

/// ListSection
///
/// Reusable section widget for displaying lists with a header and items.
///
/// Features:
/// - Section title with icon
/// - List item builder
/// - Empty state support
/// - Customizable styling
///
/// Usage:
/// ```dart
/// ListSection(
///   title: 'Clauses Importantes',
///   icon: Icons.check_circle,
///   items: contract.keyClauses,
///   itemBuilder: (context, clause) => ListTile(
///     title: Text(clause),
///     leading: Icon(Icons.check),
///   ),
/// )
/// ```
class ListSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final String emptyMessage;

  const ListSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage = 'Aucun élément disponible',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          )
        else
          ...items.map((item) => itemBuilder(context, item)),
      ],
    );
  }
}

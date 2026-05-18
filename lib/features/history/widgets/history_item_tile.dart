import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';

/// HistoryItemTile
///
/// Reusable feature-level widget for a single history entry.
///
/// Features:
/// - Swipe-to-delete with [Dismissible]
/// - Card layout with file name and date
/// - Tap to open a summary detail dialog
/// - Uses [SnackbarHelper] for delete confirmation
class HistoryItemTile extends StatelessWidget {
  final HistoryItem item;

  const HistoryItemTile({super.key, required this.item});

  String _formattedDate() =>
      '${item.date.day}/${item.date.month}/${item.date.year}';

  void _showSummaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.pdfFileName),
        content: SingleChildScrollView(child: Text(item.summary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Dismissible(
          key: Key(item.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(historyControllerProvider).deleteHistory(item.id);
            SnackbarHelper.showInfo(context, 'Analyse supprimée');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.history_edu),
              title: Text(item.pdfFileName),
              subtitle: Text(
                _formattedDate(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSummaryDialog(context),
            ),
          ),
        );
      },
    );
  }
}

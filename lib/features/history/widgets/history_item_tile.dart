import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';

class HistoryItemTile extends StatelessWidget {
  final HistoryItem item;

  const HistoryItemTile({super.key, required this.item});

  String _formattedDate() =>
      '${item.date.day}/${item.date.month}/${item.date.year}';

  void _showSummaryDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.pdfFileName),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: item.summary,
              selectable: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final l10n = context.l10n;

        return Dismissible(
          key: ValueKey('dismiss_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(historyControllerProvider).deleteHistory(item.id);
            SnackbarHelper.showInfo(context, l10n.analysisDeleted);
          },
          child: Card(
            elevation: 2,
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

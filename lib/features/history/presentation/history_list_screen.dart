import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item_tile.dart';

class HistoryListScreen extends StatelessWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Consumer(
        builder: (context, ref, child) {
          final historyAsync = ref.watch(historyProvider);

          return historyAsync.when(
            loading: () => LoadingSpinner(
              message: l10n.loadingHistory,
              fullScreen: false,
            ),
            error: (error, _) => ErrorDisplayWidget(
              message: error.toString(),
              fullScreen: false,
              retryLabel: l10n.retry,
              onRetry: () => ref.invalidate(historyProvider),
            ),
            data: (historyList) {
              if (historyList.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.history,
                  title: l10n.noHistory,
                  description: l10n.historyEmptyHint,
                  fullScreen: false,
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListView.builder(
                        itemCount: historyList.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          return HistoryItemTile(
                            key: ValueKey('tile_${historyList[index].id}'),
                            item: historyList[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

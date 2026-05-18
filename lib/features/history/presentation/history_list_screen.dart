import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item_tile.dart';

class HistoryListScreen extends StatelessWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsync = ref.watch(historyProvider);

        return Scaffold(
          appBar: AppBar(title: const Text('Historique des analyses')),
          body: historyAsync.when(
            // Loading state
            loading: () => const LoadingSpinner(
              message: 'Chargement de l\'historique...',
              fullScreen: false,
            ),

            // Error state
            error: (error, _) => ErrorDisplayWidget(
              message: error.toString(),
              fullScreen: false,
              onRetry: () => ref.invalidate(historyProvider),
            ),

            // Data state
            data: (historyList) {
              if (historyList.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.history,
                  title: 'Aucun historique disponible',
                  description: 'Vos analyses apparaîtront ici.',
                  fullScreen: false,
                );
              }

              return ListView.builder(
                itemCount: historyList.length,
                itemBuilder: (context, index) =>
                    HistoryItemTile(item: historyList[index]),
              );
            },
          ),
        );
      },
    );
  }
}

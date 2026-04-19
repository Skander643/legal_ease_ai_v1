import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';

class HistoryListScreen extends ConsumerWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des analyses')),
      body: historyList.isEmpty
          ? const Center(child: Text('Aucun historique disponible.'))
          : ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Dismissible(
                  key: Key(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    ref.read(historyProvider.notifier).deleteHistory(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analyse supprimée')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.history_edu),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.date.day}/${item.date.month}/${item.date.year} - ${item.risks.length} risques identifiés',
                      ),
                      onTap: () {
                        // Bonus: Navigate back to a Result Screen passing this specific data
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
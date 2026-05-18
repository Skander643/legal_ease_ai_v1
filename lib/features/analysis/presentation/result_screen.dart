import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/analysis_provider.dart';
import '../../history/models/history_item.dart';
import '../../history/providers/history_provider.dart';
import '../../scan/providers/scan_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final analysisState = ref.watch(analysisProvider);

        return Scaffold(
          appBar: AppBar(title: const Text("Résultat de l'analyse")),
          body: analysisState.when(
            // Loading state
            loading: () => const LoadingSpinner(
              message:
                  "L'IA analyse votre contrat...\ncela peut prendre quelques secondes.",
              fullScreen: false,
            ),

            // Error state
            error: (error, _) => ErrorDisplayWidget(
              message: error.toString(),
              fullScreen: false,
            ),

            // Data state
            data: (result) {
              if (result == null) {
                return const EmptyStateWidget(
                  icon: Icons.find_in_page_outlined,
                  title: 'Aucun résultat',
                  description: "L'analyse n'a pas produit de résultat.",
                  fullScreen: false,
                );
              }

              // Save to history exactly once when data loads
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final historyAsync = ref.read(historyProvider);
                final historyItems = historyAsync.valueOrNull ?? [];
                if (!historyItems.any((item) => item.summary == result.summary)) {
                  final scanState = ref.read(scanProvider);
                  final fileName = scanState.selectedFile != null
                      ? scanState.selectedFile!.path.split('/').last
                      : 'Contrat analysé';

                  final newItem = HistoryItem(
                    pdfFileName: fileName,
                    date: DateTime.now(),
                    summary: result.summary,
                  );
                  ref.read(historyControllerProvider).addHistory(newItem);
                }
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card using CustomCard
                    CustomCard(
                      icon: Icons.summarize,
                      title: 'Résumé Simplifié',
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        result.summary,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

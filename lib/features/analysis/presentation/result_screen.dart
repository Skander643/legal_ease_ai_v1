import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/analysis_provider.dart';
import '../../history/models/history_item.dart';
import '../../history/providers/history_provider.dart';
import '../../scan/providers/scan_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analysisResultTitle)),
      body: Consumer(
        builder: (context, ref, child) {
          final analysisState = ref.watch(analysisProvider);

          return analysisState.when(
            loading: () => LoadingSpinner(
              message: l10n.aiAnalyzing,
              fullScreen: false,
            ),
            error: (error, _) {
              final extractedText = ref.read(scanProvider).extractedText;
              return ErrorDisplayWidget(
                message: error.toString(),
                fullScreen: false,
                retryLabel: l10n.retry,
                onRetry: extractedText.isEmpty
                    ? null
                    : () => ref
                        .read(analysisProvider.notifier)
                        .analyzeContract(extractedText),
              );
            },
            data: (result) {
              if (result == null) {
                return EmptyStateWidget(
                  icon: Icons.find_in_page_outlined,
                  title: l10n.noResult,
                  description: l10n.noResultDescription,
                  fullScreen: false,
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                final historyAsync = ref.read(historyProvider);
                final historyItems = historyAsync.valueOrNull ?? [];
                if (!historyItems.any((item) => item.summary == result.summary)) {
                  final scanState = ref.read(scanProvider);
                  final fileName = scanState.selectedFile != null
                      ? scanState.selectedFile!.path.split('/').last
                      : l10n.analyzedContract;

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
                    CustomCard(
                      icon: Icons.summarize,
                      title: l10n.simplifiedSummary,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: MarkdownBody(
                        data: result.summary,
                        selectable: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

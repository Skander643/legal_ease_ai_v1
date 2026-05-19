import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/features/analysis/presentation/result_screen.dart';
import 'package:legal_ease_ai/features/analysis/providers/analysis_provider.dart';
import '../providers/scan_provider.dart';

class SelectedFilePreview extends StatelessWidget {
  const SelectedFilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final l10n = context.l10n;
        final scanState = ref.watch(scanProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.selectedFile,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () =>
                      ref.read(scanProvider.notifier).clearSelection(),
                ),
              ],
            ),
            Text(scanState.selectedFile!.path.split('/').last),
            const SizedBox(height: 16),
            Text(
              l10n.extractedTextPreview,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  scanState.extractedText.length > 500
                      ? '${scanState.extractedText.substring(0, 500)}...'
                      : scanState.extractedText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref
                    .read(analysisProvider.notifier)
                    .analyzeContract(scanState.extractedText);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResultScreen()),
                );
              },
              child: Text(l10n.launchAiAnalysis),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/features/analysis/presentation/result_screen.dart';
import 'package:legal_ease_ai/features/analysis/providers/analysis_provider.dart';
import '../providers/scan_provider.dart';

/// SelectedFilePreview
///
/// Reusable feature-level widget shown after a PDF is picked.
///
/// Features:
/// - Displays the file name with a clear button
/// - Shows an extracted-text preview (scrollable, capped at 500 chars)
/// - "Lancer l'analyse IA" button that triggers analysis and navigates to [ResultScreen]
class SelectedFilePreview extends ConsumerWidget {
  const SelectedFilePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File name row with clear action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fichier sélectionné :',
              style: TextStyle(fontWeight: FontWeight.bold),
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

        // Extracted text preview
        const Text(
          'Texte extrait (Aperçu) :',
          style: TextStyle(fontWeight: FontWeight.bold),
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

        // Launch analysis button
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
          child: const Text("Lancer l'analyse IA"),
        ),
      ],
    );
  }
}

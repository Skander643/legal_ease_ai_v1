import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_provider.dart';
import '../../history/models/history_item.dart';
import '../../history/providers/history_provider.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  Future<void> _exportToPdf(BuildContext context, dynamic result) async {
    try {
      // Create a new PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfStandardFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final PdfStandardFont titleFont = PdfStandardFont(
          PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);

      // Draw text to the PDF
      page.graphics.drawString('Rapport d\'Analyse Legal-Ease AI', titleFont,
          bounds: const Rect.fromLTWH(0, 0, 500, 30));
      page.graphics.drawString('Résumé :\n${result.summary}', font,
          bounds: const Rect.fromLTWH(0, 40, 500, 150));

      // Convert Clauses and Risks to string blocks
      final clauses = result.keyClauses.join('\n- ');
      page.graphics.drawString('Clauses Clés :\n- $clauses', font,
          bounds: const Rect.fromLTWH(0, 200, 500, 150));

      final risks = result.risks.join('\n- ');
      page.graphics.drawString('Risques :\n- $risks', font,
          bounds: const Rect.fromLTWH(0, 360, 500, 150));

      // Save the document locally
      final List<int> bytes = await document.save();
      document.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/Analyse_Contrat_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Voici l\'analyse de mon contrat générée par Legal-Ease AI.',
        subject: 'Rapport Legal-Ease AI', // Sujet utile pour les emails
      );
    }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la création du PDF : $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de l\'analyse'),
      ),
      body: analysisState.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                  'L\'IA analyse votre contrat... cela peut prendre quelques secondes.'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              error.toString(),
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (result) {
          if (result == null)
            return const Center(child: Text('Aucun résultat.'));

          // Save to history exactly once when it loads
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final historyItems = ref.read(historyProvider);
            // Check if we already saved this specific analysis to prevent duplicates
            if (!historyItems.any((item) => item.summary == result.summary)) {
              final newItem = HistoryItem(
                title:
                    'Analyse du contrat', // In a real app, pass the actual file name
                date: DateTime.now(),
                pdfPath:
                    'local/path/to/pdf', // Pass the real path from the scan provider
                summary: result.summary,
                keyClauses: result.keyClauses,
                risks: result.risks,
              );
              ref.read(historyProvider.notifier).addHistory(newItem);
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Global Summary
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.summarize,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                            const SizedBox(width: 8),
                            Text('Résumé Simplifié',
                                style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(result.summary,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Key Clauses
                Text('Clauses Importantes',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...result.keyClauses.map((clause) => ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(clause),
                    )),
                const SizedBox(height: 24),

                // Risks
                Text('Risques Identifiés',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...result.risks.map((risk) => ListTile(
                      leading:
                          const Icon(Icons.warning, color: Colors.redAccent),
                      title: Text(risk),
                    )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: analysisState.value != null
          ? FloatingActionButton.extended(
              onPressed: () => _exportToPdf(context, analysisState.value),
              icon: const Icon(Icons.ios_share),
              label: const Text('Exporter & Partager'),
            )
          : null,
    );
  }
}

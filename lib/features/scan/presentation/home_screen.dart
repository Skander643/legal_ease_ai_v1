import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/providers/theme_provider.dart';
import 'package:legal_ease_ai/features/analysis/presentation/result_screen.dart';
import 'package:legal_ease_ai/features/analysis/providers/analysis_provider.dart';
import 'package:legal_ease_ai/features/history/presentation/history_list_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/widgets/statistics_chart.dart';
import '../providers/scan_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the scan state
    final scanState = ref.watch(scanProvider);

    // Listen for errors to show a SnackBar
    ref.listen<ScanState>(scanProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Contrats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HistoryListScreen()),
              );
            },
            tooltip: 'Historique',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider).signOut(),
            tooltip: 'Se déconnecter',
          ),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: 'Changer le thème',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phase 6: Chart
            const StatisticsChart(),
            const SizedBox(height: 24),

            // Upload Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    const Text(
                      'Analysez un nouveau contrat',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    scanState.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: () => ref
                                .read(scanProvider.notifier)
                                .pickAndProcessPdf(),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Sélectionner un PDF'),
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Phase 6: Animated Switcher + Layout fixes (No Expanded inside ScrollView)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  ),
                );
              },
              child: scanState.selectedFile != null
                  ? Column(
                      key: const ValueKey('has_file'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fichier sélectionné :',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () => ref
                                  .read(scanProvider.notifier)
                                  .clearSelection(),
                            )
                          ],
                        ),
                        Text(scanState.selectedFile!.path.split('/').last),
                        const SizedBox(height: 16),
                        const Text('Texte extrait (Aperçu) :',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        // FIX: Replaced Expanded with a constrained Container
                        Container(
                          height: 150, // Fixed height for preview
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
                              MaterialPageRoute(
                                  builder: (context) => const ResultScreen()),
                            );
                          },
                          child: const Text('Lancer l\'analyse IA'),
                        ),
                      ],
                    )
                  : const Center(
                      key: ValueKey('no_file'),
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Aucun document sélectionné.',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

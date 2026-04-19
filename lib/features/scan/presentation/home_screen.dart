import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/features/analysis/presentation/result_screen.dart';
import 'package:legal_ease_ai/features/analysis/providers/analysis_provider.dart';
import '../../auth/providers/auth_provider.dart';
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
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logoutMock(),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    const Text(
                      'Analysez un nouveau contrat',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    scanState.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: () => ref.read(scanProvider.notifier).pickAndProcessPdf(),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Sélectionner un PDF'),
                          ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Results Area
            if (scanState.selectedFile != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Fichier sélectionné :', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => ref.read(scanProvider.notifier).clearSelection(),
                  )
                ],
              ),
              Text(scanState.selectedFile!.path.split('/').last), // Show filename
              const SizedBox(height: 16),
              const Text('Texte extrait (Aperçu) :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    // Show only the first 500 characters so it doesn't crash the UI with huge text
                    child: Text(
                      scanState.extractedText.length > 500 
                          ? '${scanState.extractedText.substring(0, 500)}...' 
                          : scanState.extractedText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // This button will be used in Phase 4 to trigger the AI
              FilledButton(
                onPressed: () {
                  // 1. Trigger the AI analysis
                  ref.read(analysisProvider.notifier).analyzeContract(scanState.extractedText);
                  
                  // 2. Navigate to the Result Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResultScreen()),
                  );
                },
                child: const Text('Lancer l\'analyse IA'),
              )
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text('Aucun document sélectionné.', style: TextStyle(color: Colors.grey)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
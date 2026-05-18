import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/providers/theme_provider.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import 'package:legal_ease_ai/features/scan/widgets/main_drawer.dart';
import 'package:legal_ease_ai/features/scan/widgets/selected_file_preview.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/widgets/statistics_chart.dart';
import '../providers/scan_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final user = ref.watch(authStateProvider).value;
    final firstName = user?.displayName?.split(' ').first ?? 'Utilisateur';

    // Show error snackbar via SnackbarHelper
    ref.listen<ScanState>(scanProvider, (previous, next) {
      if (next.error != null) {
        SnackbarHelper.showError(context, next.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Contrats'),
        actions: [
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
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Welcome message
            Text(
              'Salut $firstName 👋',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Que souhaitez-vous analyser aujourd'hui ?",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Statistics overview
            const StatisticsChart(),
            const SizedBox(height: 24),

            // Upload card using CustomCard
            CustomCard(
              icon: Icons.picture_as_pdf,
              title: 'Analysez un nouveau contrat',
              elevation: 4,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: scanState.isLoading
                    ? const LoadingSpinner(
                        fullScreen: false,
                        message: 'Extraction du texte...',
                        spinnerSize: 36,
                      )
                    : CustomButton(
                        label: 'Sélectionner un PDF',
                        onPressed: () =>
                            ref.read(scanProvider.notifier).pickAndProcessPdf(),
                        icon: Icons.upload_file,
                        fullWidth: false,
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Animated switcher: file selected vs. no file
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(sizeFactor: animation, child: child),
              ),
              child: scanState.selectedFile != null
                  ? const SelectedFilePreview(key: ValueKey('has_file'))
                  : const EmptyStateWidget(
                      key: ValueKey('no_file'),
                      icon: Icons.insert_drive_file_outlined,
                      title: 'Aucun document sélectionné',
                      description:
                          'Sélectionnez un PDF ci-dessus pour commencer l\'analyse.',
                      fullScreen: false,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

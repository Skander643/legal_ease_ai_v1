import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/core/providers/theme_provider.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import 'package:legal_ease_ai/features/scan/widgets/main_drawer.dart';
import 'package:legal_ease_ai/features/scan/widgets/selected_file_preview.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/widgets/statistics_chart.dart';
import '../providers/scan_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final l10n = context.l10n;
        final scanState = ref.watch(scanProvider);
        final user = ref.watch(authStateProvider).value;
        final firstName =
            user?.displayName?.split(' ').first ?? l10n.userDefault;

        ref.listen<ScanState>(scanProvider, (previous, next) {
          if (next.error != null) {
            SnackbarHelper.showError(context, next.error!);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myContracts),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => ref.read(authControllerProvider).signOut(),
                tooltip: l10n.logout,
              ),
              IconButton(
                icon: Icon(Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () =>
                    ref.read(themeProvider.notifier).toggleTheme(),
                tooltip: l10n.toggleTheme,
              ),
            ],
          ),
          drawer: const MainDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.helloUser(firstName),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.whatToAnalyzeToday,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const StatisticsChart(),
                const SizedBox(height: 24),
                CustomCard(
                  icon: Icons.picture_as_pdf,
                  title: l10n.analyzeNewContract,
                  elevation: 4,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: scanState.isLoading
                        ? LoadingSpinner(
                            fullScreen: false,
                            message: l10n.extractingText,
                            spinnerSize: 36,
                          )
                        : CustomButton(
                            label: l10n.selectPdf,
                            onPressed: () => ref
                                .read(scanProvider.notifier)
                                .pickAndProcessPdf(),
                            icon: Icons.upload_file,
                            fullWidth: false,
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(sizeFactor: animation, child: child),
                  ),
                  child: scanState.selectedFile != null
                      ? const SelectedFilePreview(key: ValueKey('has_file'))
                      : EmptyStateWidget(
                          key: const ValueKey('no_file'),
                          icon: Icons.insert_drive_file_outlined,
                          title: l10n.noDocumentSelected,
                          description: l10n.selectPdfToStart,
                          fullScreen: false,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/core/providers/locale_provider.dart';

/// Drawer tile to switch between French and English.
class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final locale = ref.watch(localeProvider);
        final l10n = context.l10n;

        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(
            locale.languageCode == 'fr'
                ? l10n.languageFrench
                : l10n.languageEnglish,
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: locale.languageCode,
              items: [
                DropdownMenuItem(
                  value: 'fr',
                  child: Text(l10n.languageFrench),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.languageEnglish),
                ),
              ],
              onChanged: (code) {
                if (code != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(code));
                }
              },
            ),
          ),
        );
      },
    );
  }
}

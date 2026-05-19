import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefsKey = 'app_locale';

/// Supported app locales (French and English).
const supportedAppLocales = <Locale>[
  Locale('fr'),
  Locale('en'),
];

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefsKey);
    if (code == null) return;

    final locale = Locale(code);
    if (supportedAppLocales.any((l) => l.languageCode == locale.languageCode)) {
      state = locale;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedAppLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefsKey, locale.languageCode);
  }

  void toggleLocale() {
    final next = state.languageCode == 'fr' ? const Locale('en') : const Locale('fr');
    setLocale(next);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ThemeNotifier
///
/// Gère l'état du thème de l'application (clair/sombre).
/// Utilise Riverpod StateNotifier pour la réactivité.
///
/// ThemeMode:
/// - system: Suit le paramètre système du téléphone
/// - light: Force le thème clair
/// - dark: Force le thème sombre
///
/// Avantages:
/// - Centralisé en un seul provider
/// - Changements en temps réel (tous les widgets écoutent)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Initialiser avec le mode système par défaut
  ThemeNotifier() : super(ThemeMode.system);

  /// toggleTheme
  ///
  /// Bascule entre les modes clair et sombre.
  ///
  /// Logique:
  /// - Si actuellement en mode sombre → passer au clair
  /// - Sinon (système ou clair) → passer au sombre
  ///
  /// Impact:
  /// - Tous les widgets écoutant themeProvider se rebuild automatiquement
  /// - Material3 adapte les couleurs immédiatement
  void toggleTheme() {
    // Si actuellement sombre, passer à clair. Sinon, sombre.
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// themeProvider
///
/// Provider Riverpod exposant le thème global de l'app.
///
/// Utilisation:
/// ```dart
/// // Regarder le thème actuel
/// final themeMode = ref.watch(themeProvider);
///
/// // Changer le thème
/// ref.read(themeProvider.notifier).toggleTheme();
/// ```
///
/// Dans MaterialApp:
/// ```dart
/// final themeMode = ref.watch(themeProvider);
/// return MaterialApp(
///   themeMode: themeMode,
///   theme: ThemeData(...),
///   darkTheme: ThemeData.dark(...),
/// );
/// ```
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

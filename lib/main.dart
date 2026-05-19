import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:legal_ease_ai/core/providers/locale_provider.dart';
import 'package:legal_ease_ai/core/providers/theme_provider.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

  runApp(ProviderScope(child: LegalEaseApp(showOnboarding: showOnboarding)));
}

class LegalEaseApp extends StatelessWidget {
  final bool showOnboarding;
  const LegalEaseApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeProvider);
        final locale = ref.watch(localeProvider);

        return MaterialApp(
          title: 'Legal-Ease AI',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: showOnboarding
              ? const OnboardingScreen()
              : const AuthWrapper(),
        );
      },
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/providers/theme_provider.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/onboarding_screen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env"); // Load API key


  // VÉRIFICATION DU PREMIER LANCEMENT
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

  // On passe la variable showOnboarding à notre app
  runApp(ProviderScope(child: LegalEaseApp(showOnboarding: showOnboarding)));
  

}

class LegalEaseApp extends ConsumerWidget {

  final bool showOnboarding;
  const LegalEaseApp({super.key,required this.showOnboarding});

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Legal-Ease AI',
      debugShowCheckedModeBanner: false,
      // Automatic light/dark mode based on the user's system 
      themeMode: themeMode, 
      
      // Light Theme Setup 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // You can change this primary color later
          brightness: Brightness.light,
        ),
      ),
      
      // Dark Theme Setup 
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      
      // A temporary home screen to test that the app runs
     home: showOnboarding ? const OnboardingScreen() : const AuthWrapper(),
    );
  }
}
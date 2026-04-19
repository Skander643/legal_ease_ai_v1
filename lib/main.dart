import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/providers/theme_provider.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env"); // Load API key
// Initialize Hive and open the required analysis_box
  await Hive.initFlutter();
  await Hive.openBox('analysis_box');
  

  // Wrap the entire app in a ProviderScope (required by Riverpod) 
  runApp(const ProviderScope(child: LegalEaseApp()));
}

class LegalEaseApp extends ConsumerWidget {
  const LegalEaseApp({super.key});

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
      home: const AuthWrapper(),
    );
  }
}
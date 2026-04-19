import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // Wrap the entire app in a ProviderScope (required by Riverpod) 
  runApp(const ProviderScope(child: LegalEaseApp()));
}

class LegalEaseApp extends StatelessWidget {
  const LegalEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal-Ease AI',
      debugShowCheckedModeBanner: false,
      // Automatic light/dark mode based on the user's system 
      themeMode: ThemeMode.system, 
      
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
      home: Scaffold(
        appBar: AppBar(title: const Text('Legal-Ease AI')),
        body: const Center(
          child: Text(
            'Phase 1 Complete: App Initialized!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
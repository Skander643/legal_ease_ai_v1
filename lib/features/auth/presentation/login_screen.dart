import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion - Legal-Ease AI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gavel, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                'Bienvenue sur Legal-Ease AI',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre simplificateur de contrats propulsé par l\'IA.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Se connecter avec Google'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  try {
                    // Show a loading indicator snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connexion en cours...')),
                    );
                    await ref.read(authControllerProvider).signInWithGoogle();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
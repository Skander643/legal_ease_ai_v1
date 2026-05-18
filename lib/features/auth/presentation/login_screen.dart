import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin(WidgetRef ref) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.showWarning(context, 'Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider).signInWithEmail(email, password);
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin(WidgetRef ref) async {
    SnackbarHelper.showInfo(context, 'Connexion Google en cours...');
    try {
      await ref.read(authControllerProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Connexion - Legal-Ease AI')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.gavel, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenue',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    label: 'Mot de passe',
                    controller: _passwordController,
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    isRequired: true,
                  ),
                  const SizedBox(height: 24),

                  // Login button with loading state
                  CustomButton(
                    label: 'Se connecter',
                    onPressed: () => _handleEmailLogin(ref),
                    isLoading: _isLoading,
                    icon: Icons.login,
                  ),

                  const SizedBox(height: 16),

                  // Navigate to register
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text("Pas encore de compte ? S'inscrire"),
                  ),

                  const Divider(height: 48),

                  // Google sign-in
                  CustomButton(
                    label: 'Se connecter avec Google',
                    onPressed: () => _handleGoogleLogin(ref),
                    icon: Icons.account_circle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

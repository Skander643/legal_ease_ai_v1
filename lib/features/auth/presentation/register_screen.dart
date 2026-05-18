import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      SnackbarHelper.showWarning(context, 'Veuillez remplir tous les champs');
      return;
    }

    if (password != confirmPassword) {
      SnackbarHelper.showError(
          context, 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider).registerWithEmail(email, password);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),

            // Confirm password field
            CustomTextField(
              label: 'Confirmer le mot de passe',
              controller: _confirmPasswordController,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              isRequired: true,
            ),
            const SizedBox(height: 32),

            // Register button with loading state
            CustomButton(
              label: "S'inscrire",
              onPressed: _handleRegister,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

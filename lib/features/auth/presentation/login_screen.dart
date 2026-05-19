import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/core/utils/auth_error_message.dart';
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
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.showWarning(context, l10n.fillAllFields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider).signInWithEmail(email, password);
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, formatAuthErrorMessage(e, l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin(WidgetRef ref) async {
    final l10n = context.l10n;
    SnackbarHelper.showInfo(context, l10n.googleSignInInProgress);
    try {
      await ref.read(authControllerProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          l10n.authErrorGoogle(formatAuthErrorMessage(e, l10n)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.loginTitle)),
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
                    l10n.welcome,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: l10n.email,
                    controller: _emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.password,
                    controller: _passwordController,
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    isRequired: true,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: l10n.signIn,
                    loadingLabel: l10n.loading,
                    onPressed: () => _handleEmailLogin(ref),
                    isLoading: _isLoading,
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Text(l10n.noAccountSignUp),
                  ),
                  const Divider(height: 48),
                  CustomButton(
                    label: l10n.signInWithGoogle,
                    loadingLabel: l10n.loading,
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

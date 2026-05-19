import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/core/utils/auth_error_message.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  Future<void> _handleRegister(WidgetRef ref) async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      SnackbarHelper.showWarning(context, l10n.fillAllFields);
      return;
    }

    if (password != confirmPassword) {
      SnackbarHelper.showError(context, l10n.passwordsDoNotMatch);
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
        SnackbarHelper.showError(context, formatAuthErrorMessage(e, l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.createAccount)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: l10n.confirmPassword,
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  isRequired: true,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: l10n.signUp,
                  loadingLabel: l10n.loading,
                  onPressed: () => _handleRegister(ref),
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

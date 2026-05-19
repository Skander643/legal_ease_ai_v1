import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../scan/presentation/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authStateProvider);
        final l10n = context.l10n;

        return authState.when(
          data: (user) {
            if (user != null) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, trace) => Scaffold(
            body: Center(child: Text(l10n.authErrorTitle(e.toString()))),
          ),
        );
      },
    );
  }
}

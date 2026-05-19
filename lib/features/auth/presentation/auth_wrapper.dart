import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart'; // Ensure this points to your new Firebase provider
import 'login_screen.dart';
import '../../scan/presentation/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authStateProvider);

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
            body: Center(child: Text('Erreur d\'authentification : $e')),
          ),
        );
      },
    );
  }
}
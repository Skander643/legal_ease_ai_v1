import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../scan/presentation/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the current authentication state
    final authState = ref.watch(authProvider);

    // Route based on state
    if (authState == AuthStatus.authenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Define the possible authentication states
enum AuthStatus { initial, loading, authenticated, unauthenticated }

// 2. Create the StateNotifier to manage the state 
class AuthNotifier extends StateNotifier<AuthStatus> {
  // We start in an 'initial' or 'unauthenticated' state
  AuthNotifier() : super(AuthStatus.unauthenticated);

  // Mocked login function 
  Future<void> loginMock(String email, String password) async {
    state = AuthStatus.loading;
    
    // Simulate a network delay of 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, we'd check credentials here. For the mock, we just succeed.
    state = AuthStatus.authenticated;
  }

  // Mocked logout function
  void logoutMock() {
    state = AuthStatus.unauthenticated;
  }
}

// 3. Expose the provider to be consumed by the UI 
final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  return AuthNotifier();
});
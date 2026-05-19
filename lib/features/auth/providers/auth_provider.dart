import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État:
/// - User? : Retourne User quand connecté, null quand déconnecté
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthController {
  // Instance Firebase Auth - singleton pour gérer les sessions
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance Google Sign-In pour les authentifications OAuth
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // 1. Affiche la boîte de dialogue de sélection Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // Utilisateur a annulé

      // 2. Récupérer l'authentification avec tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Créer les credentials Firebase à partir des tokens Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Connecter l'utilisateur
      await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
final authControllerProvider =
    Provider<AuthController>((ref) => AuthController());

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StreamProvider automatically listens to Firebase Auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});


class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- NOUVEAU : Connexion Email / Mot de passe ---
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      throw Exception('Erreur de connexion : ${_formatAuthError(e)}');
    }
  }

  // --- NOUVEAU : Inscription Email / Mot de passe ---
  Future<void> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      throw Exception('Erreur d\'inscription : ${_formatAuthError(e)}');
    }
  }

  // Connexion Google existante
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Erreur de connexion Google: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Petit helper pour traduire les erreurs Firebase en français
  String _formatAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found': return 'Aucun utilisateur trouvé pour cet email.';
        case 'wrong-password': return 'Mot de passe incorrect.';
        case 'email-already-in-use': return 'Cet email est déjà utilisé.';
        case 'weak-password': return 'Le mot de passe est trop faible (6 caractères min).';
        case 'invalid-email': return 'L\'adresse email n\'est pas valide.';
        default: return error.message ?? 'Erreur inconnue';
      }
    }
    return error.toString();
  }
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController());
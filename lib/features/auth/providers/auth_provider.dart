import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// authStateProvider
///
/// StreamProvider qui écoute continuellement les changements d'état de Firebase Auth.
///
/// Utilité:
/// - Détecte automatiquement quand un utilisateur se connecte/déconnecte
/// - Utilisé pour router l'app (Auth vs Home)
/// - Affiche les infos de l'utilisateur connecté (avatar, nom)
///
/// État:
/// - User? : Retourne User quand connecté, null quand déconnecté
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// AuthController
///
/// Classe responsable de la gestion de l'authentification.
/// Gère les méthodes de connexion (Email/Password + Google SSO).
/// Traduit les erreurs Firebase en messages français.
///
/// Points clés:
/// - Utilise Firebase Auth (backend sécurisé)
/// - Support du SSO Google (++bonus)
/// - Gestion centralisée des erreurs
class AuthController {
  // Instance Firebase Auth - singleton pour gérer les sessions
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance Google Sign-In pour les authentifications OAuth
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// signInWithEmail
  ///
  /// Connecte un utilisateur avec son email et mot de passe.
  ///
  /// Paramètres:
  /// - email: Adresse email de l'utilisateur
  /// - password: Mot de passe (6 caractères min requis par Firebase)
  ///
  /// Exceptions levées:
  /// - 'user-not-found': Aucun compte avec cet email
  /// - 'wrong-password': Mot de passe incorrect
  /// - 'invalid-email': Format email invalide
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

  /// registerWithEmail
  ///
  /// Crée un nouveau compte utilisateur avec email et mot de passe.
  ///
  /// Paramètres:
  /// - email: Adresse email unique
  /// - password: Mot de passe sécurisé (6 caractères min)
  ///
  /// Exceptions levées:
  /// - 'email-already-in-use': Email déjà enregistré
  /// - 'weak-password': Mot de passe < 6 caractères
  /// - 'invalid-email': Format email invalide
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

  /// signInWithGoogle
  ///
  /// Authentification via Google (SSO - Single Sign-On).
  /// L'utilisateur est redirigé vers l'écran Google, puis revient à l'app.
  ///
  /// Processus:
  /// 1. Affiche l'écran de sélection de compte Google
  /// 2. Récupère le token d'accès et l'ID token
  /// 3. Crée une credential Firebase
  /// 4. Connecte l'utilisateur silencieusement
  ///
  /// Avantage:
  /// - Pas de gestion de mots de passe
  /// - Expérience utilisateur fluide
  /// - Sécurité déléguée à Google
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
      throw Exception('Erreur de connexion Google: $e');
    }
  }

  /// signOut
  ///
  /// Déconnecte l'utilisateur à la fois de Google et de Firebase.
  ///
  /// Important:
  /// - Appeler les deux signOut (Google + Firebase)
  /// - Détruit la session utilisateur
  /// - Efface l'accès aux données sécurisées
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// _formatAuthError (helper privé)
  ///
  /// Traduit les erreurs Firebase en messages français compréhensibles.
  ///
  /// Objectif:
  /// - Éviter d'exposer les codes d'erreur techniques aux utilisateurs
  /// - Fournir des messages clairs et utiles
  /// - Améliorer l'UX
  String _formatAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé pour cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé.';
        case 'weak-password':
          return 'Le mot de passe est trop faible (6 caractères min).';
        case 'invalid-email':
          return 'L\'adresse email n\'est pas valide.';
        default:
          return error.message ?? 'Erreur inconnue';
      }
    }
    return error.toString();
  }
}

/// authControllerProvider
///
/// Provider Riverpod qui expose l'AuthController.
///
/// Utilisation:
/// ```dart
/// // Dans un ConsumerWidget
/// final auth = ref.read(authControllerProvider);
/// await auth.signInWithEmail(email, password);
/// ```
final authControllerProvider =
    Provider<AuthController>((ref) => AuthController());

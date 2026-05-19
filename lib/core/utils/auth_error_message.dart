import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatAuthErrorMessage(Object error, AppLocalizations l10n) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return l10n.authErrorUserNotFound;
      case 'wrong-password':
        return l10n.authErrorWrongPassword;
      case 'email-already-in-use':
        return l10n.authErrorEmailInUse;
      case 'weak-password':
        return l10n.authErrorWeakPassword;
      case 'invalid-email':
        return l10n.authErrorInvalidEmail;
      default:
        return error.message ?? l10n.authErrorUnknown;
    }
  }

  final message = error.toString().replaceFirst('Exception: ', '');
  if (message.startsWith('Erreur de connexion Google') ||
      message.startsWith('Google sign-in error')) {
    return message;
  }
  return message;
}

import 'package:dio/dio.dart';

String formatApiErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return 'Pas de connexion internet. Vérifiez votre réseau Wi‑Fi ou données mobiles, puis réessayez.';

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connexion trop lente ou expirée. Vérifiez votre internet et réessayez.';

      case DioExceptionType.receiveTimeout:
        return 'Le serveur met trop de temps à répondre. Réessayez dans quelques instants.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return 'Clé API invalide ou refusée. Vérifiez GROQ_API_KEY dans le fichier .env.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Le service d\'analyse est temporairement indisponible. Réessayez plus tard.';
        }
        return 'Erreur du serveur (code ${statusCode ?? 'inconnu'}). Réessayez.';

      case DioExceptionType.cancel:
        return 'Analyse annulée.';

      case DioExceptionType.badCertificate:
        return 'Connexion sécurisée impossible. Vérifiez la date/heure de l\'appareil.';

      case DioExceptionType.unknown:
        final message = (error.message ?? '').toLowerCase();
        if (_looksLikeOffline(message, error.error)) {
          return 'Pas de connexion internet. Vérifiez votre réseau Wi‑Fi ou données mobiles, puis réessayez.';
        }
        return 'Erreur réseau inattendue. Vérifiez votre connexion et réessayez.';
    }
  }

  final text = error.toString().replaceFirst('Exception: ', '');
  if (text.contains('GROQ_API_KEY') || text.contains('Clé API')) {
    return text;
  }
  return 'Erreur d\'analyse : $text';
}

bool _looksLikeOffline(String message, Object? innerError) {
  const offlineHints = [
    'socket',
    'network',
    'failed host lookup',
    'connection refused',
    'connection reset',
    'no address associated',
    'network is unreachable',
  ];
  if (offlineHints.any(message.contains)) {
    return true;
  }
  final inner = innerError?.toString().toLowerCase() ?? '';
  return offlineHints.any(inner.contains);
}

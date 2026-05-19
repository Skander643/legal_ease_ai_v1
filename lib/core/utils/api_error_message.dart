import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatApiErrorMessage(Object error, AppLocalizations l10n) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return l10n.errorNoInternet;

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return l10n.errorConnectionTimeout;

      case DioExceptionType.receiveTimeout:
        return l10n.errorReceiveTimeout;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return l10n.errorInvalidApiKey;
        }
        if (statusCode != null && statusCode >= 500) {
          return l10n.errorServerUnavailable;
        }
        return l10n.errorServerCode('${statusCode ?? 'unknown'}');

      case DioExceptionType.cancel:
        return l10n.errorAnalysisCancelled;

      case DioExceptionType.badCertificate:
        return l10n.errorBadCertificate;

      case DioExceptionType.unknown:
        final message = (error.message ?? '').toLowerCase();
        if (_looksLikeOffline(message, error.error)) {
          return l10n.errorNoInternet;
        }
        return l10n.errorUnexpectedNetwork;
    }
  }

  final text = error.toString().replaceFirst('Exception: ', '');
  if (text.contains('GROQ_API_KEY') ||
      text.contains('Clé API') ||
      text.contains('API key')) {
    return text;
  }
  return l10n.errorAnalysisGeneric(text);
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

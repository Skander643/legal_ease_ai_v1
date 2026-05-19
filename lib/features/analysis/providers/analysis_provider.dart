import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:legal_ease_ai/core/providers/locale_provider.dart';
import 'package:legal_ease_ai/core/utils/api_error_message.dart';
import '../models/analysis_result.dart';

class AnalysisNotifier extends AsyncNotifier<AnalysisResult?> {
  final Dio _dio = Dio();

  @override
  FutureOr<AnalysisResult?> build() {
    return null;
  }

  AppLocalizations get _l10n =>
      lookupAppLocalizations(ref.read(localeProvider));

  Future<void> analyzeContract(String extractedText) async {
    state = const AsyncValue.loading();
    final l10n = _l10n;

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(l10n.errorGroqApiKeyMissing);
      }

      final textToAnalyze = extractedText.length > 4000
          ? extractedText.substring(0, 4000)
          : extractedText;

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': l10n.aiSystemPrompt,
            },
            {
              'role': 'user',
              'content': '${l10n.aiUserPromptPrefix}$textToAnalyze',
            }
          ],
          'temperature': 0.6,
          'top_p': 0.95,
          'max_tokens': 1024,
          'frequency_penalty': 0,
          'presence_penalty': 0,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final choices = response.data['choices'] as List<dynamic>;

        if (choices.isNotEmpty) {
          final summaryText = choices[0]['message']['content'] as String;
          state = AsyncValue.data(AnalysisResult.fromRawText(summaryText));
        } else {
          throw Exception(l10n.errorNoGroqResponse);
        }
      } else {
        throw Exception(l10n.errorGroqHttp(response.statusCode ?? 0));
      }
    } catch (e, stack) {
      state = AsyncValue.error(formatApiErrorMessage(e, _l10n), stack);
    }
  }

  void clearResult() {
    state = const AsyncData(null);
  }
}

final analysisProvider =
    AsyncNotifierProvider<AnalysisNotifier, AnalysisResult?>(() {
  return AnalysisNotifier();
});

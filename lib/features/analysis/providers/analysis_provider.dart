import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:legal_ease_ai/core/utils/api_error_message.dart';
import '../models/analysis_result.dart';

class AnalysisNotifier extends AsyncNotifier<AnalysisResult?> {
  // Instance HTTP client (Dio) pour les requêtes API
  final Dio _dio = Dio();

  @override
  FutureOr<AnalysisResult?> build() {
    // État initial : null (aucune analyse n'a été effectuée)
    return null;
  }

  Future<void> analyzeContract(String extractedText) async {
    // Définir l'état à "chargement"
    state = const AsyncValue.loading();

    try {
      // 1. Récupérer la clé API depuis le fichier .env
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            "Clé API Groq introuvable. Vérifiez votre fichier .env.");
      }

      final textToAnalyze = extractedText.length > 4000
          ? extractedText.substring(0, 4000)
          : extractedText;

      // Endpoint: https://api.groq.com/openai/v1/chat/completions
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          // Timeouts pour éviter les connexions infinies
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          // Configuration du modèle d'IA disponible sur GroqCloud
          "model": "llama-3.3-70b-versatile",

          // Messages pour le modèle (système + utilisateur)
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a legal document analysis expert. Summarize the following contract in 100-300 words, highlighting key terms, obligations, and risks."
            },
            {
              "role": "user",
              "content": "Please analyze this contract:\n\n$textToAnalyze"
            }
          ],

          // Paramètres d'IA pour contrôler la qualité
          "temperature": 0.6, // Équilibre entre créativité et cohérence
          "top_p": 0.95, // Nucleus sampling pour diversité
          "max_tokens": 1024, // Limite de la réponse
          "frequency_penalty": 0, // Pas de pénalité de répétition
          "presence_penalty": 0 // Pas de pénalité de présence
        },
      );

      // 4. Parser la réponse et créer l'état de résultat
      if (response.statusCode == 200 && response.data != null) {
        // Extraire l'array 'choices' de la réponse Groq
        final choices = response.data['choices'] as List<dynamic>;

        if (choices.isNotEmpty) {
          // Extraire le texte du message retourné
          final summaryText = choices[0]['message']['content'] as String;

          // Créer un objet AnalysisResult et mettre à jour l'état
          state = AsyncValue.data(AnalysisResult.fromRawText(summaryText));
        } else {
          // Erreur: pas de réponse du modèle
          throw Exception("Erreur: Aucune réponse de l'API Groq");
        }
      } else {
        // Erreur HTTP
        throw Exception("Erreur de l'API: ${response.statusCode}");
      }
    } catch (e, stack) {
      state = AsyncValue.error(formatApiErrorMessage(e), stack);
    }
  }

  /// clearResult
  ///
  /// Réinitialise l'état de l'analyse à null.
  /// Utilisé après partage ou suppression d'une analyse.
  void clearResult() {
    state = const AsyncData(null);
  }
}

final analysisProvider =
    AsyncNotifierProvider<AnalysisNotifier, AnalysisResult?>(() {
  return AnalysisNotifier();
});
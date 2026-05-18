import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';

/// AnalysisNotifier
///
/// Responsable de la gestion de l'état de l'analyse des contrats.
/// Communique avec l'API NVIDIA Llama Nemotron Super pour obtenir des analyses juridiques.
///
/// État :
/// - Loading: Lors de l'appel API
/// - Data: Lorsque l'analyse est réussie
/// - Error: En cas d'erreur réseau ou validation
class AnalysisNotifier extends AsyncNotifier<AnalysisResult?> {
  // Instance HTTP client (Dio) pour les requêtes API
  final Dio _dio = Dio();

  @override
  FutureOr<AnalysisResult?> build() {
    // État initial : null (aucune analyse n'a été effectuée)
    return null;
  }

  /// analyzeContract
  ///
  /// Envoie le texte extrait du PDF à l'API NVIDIA pour une analyse juridique.
  ///
  /// Paramètres:
  /// - extractedText: Texte complet du contrat (avant limitation)
  ///
  /// Processus:
  /// 1. Limiter le texte à 4000 caractères (limite de tokens approximative)
  /// 2. Préparer la requête avec les paramètres d'IA
  /// 3. Appeler l'API NVIDIA avec authentification Bearer
  /// 4. Parser la réponse et créer AnalysisResult
  /// 5. Gérer les erreurs 
  Future<void> analyzeContract(String extractedText) async {
    // Définir l'état à "chargement"
    state = const AsyncValue.loading();

    try {
      // 1. Récupérer la clé API depuis le fichier .env
      final apiKey = dotenv.env['NVIDIA_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
            "Clé API NVIDIA introuvable. Vérifiez votre fichier .env.");
      }

      // 2. Limiter le texte pour respecter les limites de tokens (~1024 tokens)
      // Approximation: 1 token ≈ 4 caractères
      final textToAnalyze = extractedText.length > 4000
          ? extractedText.substring(0, 4000)
          : extractedText;

      // 3. Configurer et envoyer la requête à l'API NVIDIA
      // Endpoint: https://integrate.api.nvidia.com/v1/chat/completions
      // Modèle: nvidia/llama-3.3-nemotron-super-49b-v1
      final response = await _dio.post(
        'https://integrate.api.nvidia.com/v1/chat/completions',
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
          // Configuration du modèle d'IA
          "model": "nvidia/llama-3.3-nemotron-super-49b-v1",

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
        // Extraire l'array 'choices' de la réponse NVIDIA
        final choices = response.data['choices'] as List<dynamic>;

        if (choices.isNotEmpty) {
          // Extraire le texte du message retourné
          final summaryText = choices[0]['message']['content'] as String;

          // Créer un objet AnalysisResult et mettre à jour l'état
          state = AsyncValue.data(AnalysisResult.fromRawText(summaryText));
        } else {
          // Erreur: pas de réponse du modèle
          throw Exception("Erreur: Aucune réponse de l'API NVIDIA");
        }
      } else {
        // Erreur HTTP
        throw Exception("Erreur de l'API: ${response.statusCode}");
      }
    } catch (e, stack) {
      // Capturer toute erreur et mettre à jour l'état avec le message d'erreur
      // stack est utilisé pour les logs de débogage
      state = AsyncValue.error("Erreur d'analyse : ${e.toString()}", stack);
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

/// analysisProvider
///
/// Provider Riverpod qui expose le AnalysisNotifier.
/// Utilisé partout dans l'app via ref.watch() ou ref.read()
///
/// Exemple d'utilisation:
/// ```dart
/// // Dans un widget ConsumerWidget
/// final analysisState = ref.watch(analysisProvider);
/// await ref.read(analysisProvider.notifier).analyzeContract(text);
/// ```
final analysisProvider =
    AsyncNotifierProvider<AnalysisNotifier, AnalysisResult?>(() {
  return AnalysisNotifier();
});

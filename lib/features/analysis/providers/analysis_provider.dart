import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';

class AnalysisNotifier extends AsyncNotifier<AnalysisResult?> {
  final Dio _dio = Dio();

  @override
  FutureOr<AnalysisResult?> build() {
    return null; // Initial state is null (no analysis run yet)
  }

  Future<void> analyzeContract(String extractedText) async {
    state = const AsyncValue.loading();

    try {
      final apiKey = dotenv.env['HF_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("Clé API introuvable. Vérifiez votre fichier .env.");
      }

      // 1. Limit text size to avoid Token limits (approx 1024 tokens)
      final textToAnalyze = extractedText.length > 3000 
          ? extractedText.substring(0, 3000) 
          : extractedText;

      // 2. Setup the API Call
      final response = await _dio.post(
        'https://router.huggingface.co/hf-inference/models/facebook/bart-large-cnn',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: {
          "inputs": textToAnalyze,
          "parameters": {"max_length": 300, "min_length": 100}
        },
      );

      // 3. Parse Response
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        final summaryText = data[0]['summary_text'] as String;
        
        state = AsyncValue.data(AnalysisResult.fromRawText(summaryText));
      } else {
        throw Exception("Erreur de l'API: ${response.statusCode}");
      }
    } catch (e, stack) {
      state = AsyncValue.error("Erreur d'analyse : ${e.toString()}", stack);
    }
  }
  
  void clearResult() {
    state = const AsyncData(null);
  }
}

final analysisProvider = AsyncNotifierProvider<AnalysisNotifier, AnalysisResult?>(() {
  return AnalysisNotifier();
});
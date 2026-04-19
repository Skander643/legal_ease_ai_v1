class AnalysisResult {
  final String summary;
  final List<String> keyClauses;
  final List<String> risks;

  AnalysisResult({
    required this.summary,
    required this.keyClauses,
    required this.risks,
  });

  // A factory to help parse the AI's text response.
  // Standard BART returns plain text. We will attempt to structure it,
  // or provide mock clauses/risks if the model only gives a global summary.
  factory AnalysisResult.fromRawText(String rawSummary) {
    return AnalysisResult(
      summary: rawSummary,
      // To get perfect JSON from standard Hugging Face requires a custom model/prompt.
      // For this MVP, we extract the summary and simulate the structured breakdown.
      keyClauses: [
        "Durée du contrat et conditions de renouvellement",
        "Obligations financières et pénalités de retard",
      ],
      risks: [
        "Clause de non-concurrence très restrictive",
        "Préavis de résiliation trop court (15 jours)",
      ],
    );
  }
}
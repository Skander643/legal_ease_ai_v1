class AnalysisResult {
  final String summary;

  AnalysisResult({
    required this.summary,
  });

  // A factory to help parse the AI's text response.
  // Standard BART returns plain text. We will attempt to structure it,
  // or provide mock clauses/risks if the model only gives a global summary.
  factory AnalysisResult.fromRawText(String rawSummary) {
    return AnalysisResult(
      summary: rawSummary,
    
    );
  }
}
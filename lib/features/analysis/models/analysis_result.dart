class AnalysisResult {
  final String summary;

  AnalysisResult({
    required this.summary,
  });

  factory AnalysisResult.fromRawText(String rawSummary) {
    return AnalysisResult(
      summary: rawSummary,
    
    );
  }
}
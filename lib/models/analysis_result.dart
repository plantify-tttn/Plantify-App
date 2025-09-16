class AnalysisResult {
  final String timeline;
  final String answer;
  final String detail;
  final String suggest;

  AnalysisResult({
    required this.timeline,
    required this.answer,
    required this.detail,
    required this.suggest,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> j) => AnalysisResult(
        timeline: (j['timeline'] ?? '').toString(),
        answer: (j['answer'] ?? '').toString(),
        detail: (j['detail'] ?? '').toString(),
        suggest: (j['suggest'] ?? '').toString(),
      );
}

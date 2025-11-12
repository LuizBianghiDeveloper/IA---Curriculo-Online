class CurriculoAnalysis {
  final double compatibilityScore;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final bool isSuitable;

  CurriculoAnalysis({
    required this.compatibilityScore,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.isSuitable,
  });

  factory CurriculoAnalysis.fromJson(Map<String, dynamic> json) {
    return CurriculoAnalysis(
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble() ?? 0.0,
      summary: json['summary'] as String? ?? '',
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isSuitable: json['isSuitable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'compatibilityScore': compatibilityScore,
      'summary': summary,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'isSuitable': isSuitable,
    };
  }
}


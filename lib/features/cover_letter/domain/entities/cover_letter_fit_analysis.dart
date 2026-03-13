class CoverLetterFitAnalysis {
  const CoverLetterFitAnalysis({
    required this.matchScore,
    required this.missingSkills,
    required this.strengths,
    required this.positioningSummary,
  });

  final int matchScore;
  final List<String> missingSkills;
  final List<String> strengths;
  final String positioningSummary;
}

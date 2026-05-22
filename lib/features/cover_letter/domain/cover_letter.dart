class CoverLetter {
  final String id;
  final String companyName;
  final String roleName;
  final String jobDescription;
  final String generatedText;
  final String tone; // 'professional', 'friendly', 'confident'
  final DateTime createdAt;

  const CoverLetter({
    required this.id,
    required this.companyName,
    required this.roleName,
    required this.jobDescription,
    required this.generatedText,
    required this.tone,
    required this.createdAt,
  });

  CoverLetter copyWith({String? generatedText, String? tone}) => CoverLetter(
    id: id,
    companyName: companyName,
    roleName: roleName,
    jobDescription: jobDescription,
    generatedText: generatedText ?? this.generatedText,
    tone: tone ?? this.tone,
    createdAt: createdAt,
  );
}

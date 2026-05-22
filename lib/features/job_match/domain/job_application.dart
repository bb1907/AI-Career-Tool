class JobApplication {
  final String id;
  final String companyName;
  final String roleName;
  final String jobDescription;
  final double matchScore; // 0.0 - 1.0
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final DateTime createdAt;

  const JobApplication({
    required this.id,
    required this.companyName,
    required this.roleName,
    required this.jobDescription,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.createdAt,
  });
}

class CoverLetterCandidateContext {
  const CoverLetterCandidateContext({
    required this.name,
    required this.email,
    required this.location,
    required this.yearsExperience,
    required this.roles,
    required this.skills,
    required this.industries,
    required this.seniority,
    required this.education,
  });

  final String name;
  final String email;
  final String location;
  final int yearsExperience;
  final List<String> roles;
  final List<String> skills;
  final List<String> industries;
  final String seniority;
  final String education;
}

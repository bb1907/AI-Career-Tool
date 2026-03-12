class CandidateProfile {
  const CandidateProfile({
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

  CandidateProfile copyWith({
    String? name,
    String? email,
    String? location,
    int? yearsExperience,
    List<String>? roles,
    List<String>? skills,
    List<String>? industries,
    String? seniority,
    String? education,
  }) {
    return CandidateProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      roles: roles ?? this.roles,
      skills: skills ?? this.skills,
      industries: industries ?? this.industries,
      seniority: seniority ?? this.seniority,
      education: education ?? this.education,
    );
  }
}

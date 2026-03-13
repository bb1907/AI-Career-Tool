class JobSearchRequest {
  const JobSearchRequest({
    required this.role,
    required this.location,
    required this.yearsExperience,
    this.skills = const <String>[],
  });

  final String role;
  final String location;
  final int yearsExperience;
  final List<String> skills;

  JobSearchRequest copyWith({
    String? role,
    String? location,
    int? yearsExperience,
    List<String>? skills,
  }) {
    return JobSearchRequest(
      role: role ?? this.role,
      location: location ?? this.location,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      skills: skills ?? this.skills,
    );
  }
}

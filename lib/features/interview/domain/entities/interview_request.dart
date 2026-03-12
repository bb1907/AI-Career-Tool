class InterviewRequest {
  const InterviewRequest({
    required this.roleName,
    required this.seniority,
    required this.companyType,
    required this.interviewType,
    required this.focusAreas,
  });

  final String roleName;
  final String seniority;
  final String companyType;
  final String interviewType;
  final List<String> focusAreas;
}

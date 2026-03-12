class CoverLetterRequest {
  const CoverLetterRequest({
    required this.companyName,
    required this.roleTitle,
    required this.jobDescription,
    required this.userBackground,
    required this.tone,
  });

  final String companyName;
  final String roleTitle;
  final String jobDescription;
  final String userBackground;
  final String tone;
}

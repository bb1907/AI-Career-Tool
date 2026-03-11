class SignUpRequest {
  const SignUpRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.targetRole,
    required this.yearsOfExperience,
  });

  final String fullName;
  final String email;
  final String password;
  final String targetRole;
  final int yearsOfExperience;
}

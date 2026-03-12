class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    this.fullName,
    this.targetRole,
    this.yearsOfExperience,
  });

  final String userId;
  final String email;
  final String? fullName;
  final String? targetRole;
  final int? yearsOfExperience;
}

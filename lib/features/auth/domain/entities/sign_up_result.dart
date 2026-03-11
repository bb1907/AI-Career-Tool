import 'auth_session.dart';

class SignUpResult {
  const SignUpResult({
    required this.message,
    required this.requiresEmailConfirmation,
    this.session,
  });

  final String message;
  final bool requiresEmailConfirmation;
  final AuthSession? session;
}

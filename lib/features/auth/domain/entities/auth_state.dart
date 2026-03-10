import 'auth_session.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  const AuthState._({
    required this.status,
    this.session,
    this.isSubmitting = false,
  });

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(
    AuthSession session, {
    bool isSubmitting = false,
  }) : this._(
         status: AuthStatus.authenticated,
         session: session,
         isSubmitting: isSubmitting,
       );

  const AuthState.unauthenticated({bool isSubmitting = false})
    : this._(status: AuthStatus.unauthenticated, isSubmitting: isSubmitting);

  final AuthStatus status;
  final AuthSession? session;
  final bool isSubmitting;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;
}

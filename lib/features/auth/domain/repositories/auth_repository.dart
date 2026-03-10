import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restoreSession();
  Future<AuthSession> signIn();
  Future<void> signOut();
}

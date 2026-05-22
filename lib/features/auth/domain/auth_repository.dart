import 'auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;
  bool get isAuthenticated;

  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithApple();
  Future<void> logout();

  /// Permanently delete the account and all associated user data.
  Future<void> deleteAccount();

  /// Stream of auth state changes. Emits null on sign-out.
  Stream<AuthUser?> onAuthStateChange();
}

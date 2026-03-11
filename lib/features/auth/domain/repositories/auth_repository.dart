import '../entities/auth_session.dart';
import '../entities/sign_up_request.dart';
import '../entities/sign_up_result.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restoreSession();
  Stream<AuthSession?> observeAuthStateChanges();
  Future<AuthSession> signIn({required String email, required String password});
  Future<SignUpResult> signUp(SignUpRequest request);
  Future<void> signOut();
}

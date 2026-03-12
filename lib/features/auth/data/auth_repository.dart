import '../domain/entities/auth_session.dart';
import '../domain/entities/sign_up_request.dart';
import '../domain/entities/sign_up_result.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();
  Stream<AuthSession?> observeAuthStateChanges();
  Future<AuthSession> signIn({required String email, required String password});
  Future<SignUpResult> signUp(SignUpRequest request);
  Future<void> signOut();
}

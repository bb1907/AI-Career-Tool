import '../../../services/supabase/auth_service.dart';
import '../domain/entities/auth_session.dart';
import '../domain/entities/sign_up_request.dart';
import '../domain/entities/sign_up_result.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Stream<AuthSession?> observeAuthStateChanges() {
    return _service.observeAuthStateChanges();
  }

  @override
  Future<AuthSession?> restoreSession() {
    return _service.restoreSession();
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    return _service.signIn(email: email, password: password);
  }

  @override
  Future<SignUpResult> signUp(SignUpRequest request) {
    return _service.signUp(request);
  }

  @override
  Future<void> signOut() {
    return _service.signOut();
  }
}

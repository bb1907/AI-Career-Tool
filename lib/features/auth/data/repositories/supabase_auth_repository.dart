import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_up_request.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/supabase_auth_service.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._service);

  final SupabaseAuthService _service;

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

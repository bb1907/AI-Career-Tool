import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_up_request.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  AuthSession? _session;

  @override
  Future<AuthSession?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return _session;
  }

  @override
  Stream<AuthSession?> observeAuthStateChanges() {
    return const Stream<AuthSession?>.empty();
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    _session = AuthSession(
      userId: 'demo-user',
      email: email,
      fullName: 'Demo User',
      targetRole: 'AI Product Manager',
      yearsOfExperience: 5,
    );

    return _session!;
  }

  @override
  Future<SignUpResult> signUp(SignUpRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    _session = AuthSession(
      userId: 'demo-user',
      email: request.email,
      fullName: request.fullName,
      targetRole: request.targetRole,
      yearsOfExperience: request.yearsOfExperience,
    );

    return SignUpResult(
      message: 'Demo account created.',
      requiresEmailConfirmation: false,
      session: _session,
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _session = null;
  }
}

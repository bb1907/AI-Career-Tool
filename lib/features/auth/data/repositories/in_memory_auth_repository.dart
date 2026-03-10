import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  AuthSession? _session;

  @override
  Future<AuthSession?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return _session;
  }

  @override
  Future<AuthSession> signIn() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    _session = const AuthSession(
      userId: 'demo-user',
      email: 'demo@aicareertools.app',
    );

    return _session!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _session = null;
  }
}

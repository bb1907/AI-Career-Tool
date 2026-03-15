import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/in_memory_auth_repository.dart';
import '../../domain/auth_user.dart';

final authRepositoryProvider = Provider<InMemoryAuthRepository>(
  (_) => InMemoryAuthRepository(),
);

class AuthStateNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  InMemoryAuthRepository get _repo => ref.read(authRepositoryProvider);

  String? login(String email, String password) {
    final user = _repo.login(email.trim(), password);
    if (user == null) {
      return 'Invalid email or password';
    }
    state = user;
    return null;
  }

  String? register(String email, String password) {
    final error = _repo.register(email.trim(), password);
    if (error != null) return error;
    final user = _repo.login(email.trim(), password);
    if (user == null) return 'Registration failed unexpectedly';
    state = user;
    return null;
  }

  void logout() => state = null;
}

final authStateNotifierProvider =
    NotifierProvider<AuthStateNotifier, AuthUser?>(
  AuthStateNotifier.new,
);

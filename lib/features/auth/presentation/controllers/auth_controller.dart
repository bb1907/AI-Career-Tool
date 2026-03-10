import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_auth_repository.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => InMemoryAuthRepository(),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future<void>.microtask(_restoreSession);
    return const AuthState.loading();
  }

  Future<void> _restoreSession() async {
    final session = await ref.read(authRepositoryProvider).restoreSession();
    state = session == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(session);
  }

  Future<void> signIn() async {
    state = const AuthState.unauthenticated(isSubmitting: true);
    final session = await ref.read(authRepositoryProvider).signIn();
    state = AuthState.authenticated(session);
  }

  Future<void> signOut() async {
    final currentSession = state.session;

    if (currentSession != null) {
      state = AuthState.authenticated(currentSession, isSubmitting: true);
    }

    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState.unauthenticated();
  }
}

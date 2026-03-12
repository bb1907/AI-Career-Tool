import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/supabase/auth_service.dart';
import '../../../../services/supabase/supabase_client_provider.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/entities/sign_up_request.dart';
import '../../domain/entities/sign_up_result.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthService(ref.watch(supabaseClientProvider))),
);

final authStateChangesProvider = StreamProvider<AuthSession?>((ref) {
  return ref.watch(authRepositoryProvider).observeAuthStateChanges();
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.listen<AsyncValue<AuthSession?>>(authStateChangesProvider, (
      previous,
      next,
    ) {
      next.whenData((session) {
        state = session == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(session);
      });
    });

    Future<void>.microtask(_restoreSession);
    return const AuthState.loading();
  }

  Future<void> _restoreSession() async {
    final session = await ref.read(authRepositoryProvider).restoreSession();
    state = session == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(session);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthState.unauthenticated(isSubmitting: true);

    try {
      final session = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = AuthState.authenticated(session);
    } catch (_) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<SignUpResult> signUp(SignUpRequest request) async {
    state = const AuthState.unauthenticated(isSubmitting: true);

    try {
      final result = await ref.read(authRepositoryProvider).signUp(request);
      state = result.session == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(result.session!);
      return result;
    } catch (_) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signOut() async {
    final currentSession = state.session;

    if (currentSession != null) {
      state = AuthState.authenticated(currentSession, isSubmitting: true);
    }

    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AuthState.unauthenticated();
    } catch (_) {
      state = currentSession == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(currentSession);
      rethrow;
    }
  }
}

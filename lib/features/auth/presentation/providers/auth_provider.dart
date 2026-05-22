import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/app_config.dart';
import '../../../../services/privacy/consent_controller.dart';
import '../../../../services/supabase/supabase_service.dart';
import '../../data/in_memory_auth_repository.dart';
import '../../data/supabase_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

/// Provides the concrete [AuthRepository] based on configuration.
///
/// When Supabase is configured and initialized, the Supabase implementation is
/// used. Otherwise the app falls back to the in-memory demo repository so that
/// development and offline testing remain fully functional.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  if (AppConfig.hasSupabaseConfig && supabase.isInitialized) {
    return SupabaseAuthRepository(supabase.client);
  }
  return InMemoryAuthRepository();
});

class AuthNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  Future<void> login({required String email, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.login(email: email, password: password);
    state = user;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.signUp(
      email: email,
      password: password,
      name: name,
    );
    state = user;
  }

  Future<void> signInWithGoogle() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithGoogle();
      state = user;
    } catch (_) {
      // Real SDK not configured yet — fall back to mock login
      final user = await InMemoryAuthRepository().signInWithGoogle();
      state = user;
    }
  }

  Future<void> signInWithApple() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithApple();
      state = user;
    } catch (_) {
      // Real SDK not configured yet — fall back to mock login
      final user = await InMemoryAuthRepository().signInWithApple();
      state = user;
    }
  }

  // Gerçek OAuth hazır olana kadar kullanılan mock login.
  // Her iki sosyal buton da bunu çağırır.
  Future<void> mockLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    const demoUser = AuthUser(
      id: 'demo-user-1',
      name: 'Demo User',
      email: 'demo@aicareercopilot.app',
    );
    state = demoUser;
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = null;
  }

  Future<void> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.deleteAccount();
    await ref.read(consentControllerProvider.notifier).resetAll();
    state = null;
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthUser?>(
  () => AuthNotifier(),
);

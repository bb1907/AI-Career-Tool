import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/resume/presentation/pages/resume_wizard_page.dart';
import '../features/resume/presentation/pages/resume_preview_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStateNotifierProvider) != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/resume/wizard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (ctx, _) => const RegisterPage()),
      GoRoute(path: '/resume/wizard', builder: (ctx, _) => const ResumeWizardPage()),
      GoRoute(path: '/resume/preview', builder: (ctx, _) => const ResumePreviewPage()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

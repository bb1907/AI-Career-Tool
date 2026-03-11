import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  const publicRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.register,
  };

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginPage(redirectTo: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            RegisterPage(redirectTo: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final isPublicRoute = publicRoutes.contains(location);

      switch (authState.status) {
        case AuthStatus.loading:
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        case AuthStatus.unauthenticated:
          if (location == AppRoutes.splash) {
            return AppRoutes.login;
          }

          if (isPublicRoute) {
            return null;
          }

          return Uri(
            path: AppRoutes.login,
            queryParameters: {'from': state.uri.toString()},
          ).toString();
        case AuthStatus.authenticated:
          if (location == AppRoutes.splash ||
              location == AppRoutes.login ||
              location == AppRoutes.register) {
            final redirectTo = state.uri.queryParameters['from'];
            return redirectTo?.isNotEmpty == true ? redirectTo : AppRoutes.home;
          }

          return null;
      }
    },
  );
});

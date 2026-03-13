import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/cover_letter/presentation/pages/cover_letter_input_page.dart';
import '../features/cover_letter/presentation/pages/cover_letter_result_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/job_matching/presentation/pages/job_matching_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/interview/presentation/pages/interview_input_page.dart';
import '../features/interview/presentation/pages/interview_result_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/paywall/presentation/pages/paywall_page.dart';
import '../features/profile_import/presentation/pages/profile_import_page.dart';
import '../features/resume/presentation/pages/resume_input_page.dart';
import '../features/resume/presentation/pages/resume_result_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const resume = '/resume';
  static const resumeResult = '/resume/result';
  static const coverLetter = '/cover-letter';
  static const coverLetterResult = '/cover-letter/result';
  static const interview = '/interview';
  static const interviewResult = '/interview/result';
  static const profileImport = '/profile-import';
  static const history = '/history';
  static const jobMatching = '/job-matching';
  static const paywall = '/premium';
  static const settings = '/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final onboardingState = ref.watch(onboardingControllerProvider);
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
        path: AppRoutes.onboarding,
        builder: (context, state) =>
            OnboardingPage(redirectTo: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.resume,
        builder: (context, state) => const ResumeInputPage(),
      ),
      GoRoute(
        path: AppRoutes.resumeResult,
        builder: (context, state) => const ResumeResultPage(),
      ),
      GoRoute(
        path: AppRoutes.coverLetter,
        builder: (context, state) => const CoverLetterInputPage(),
      ),
      GoRoute(
        path: AppRoutes.coverLetterResult,
        builder: (context, state) => const CoverLetterResultPage(),
      ),
      GoRoute(
        path: AppRoutes.interview,
        builder: (context, state) => const InterviewInputPage(),
      ),
      GoRoute(
        path: AppRoutes.interviewResult,
        builder: (context, state) => const InterviewResultPage(),
      ),
      GoRoute(
        path: AppRoutes.profileImport,
        builder: (context, state) => const ProfileImportPage(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.jobMatching,
        builder: (context, state) => const JobMatchingPage(),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => PaywallPage(
          redirectTo: state.uri.queryParameters['from'],
          sourceFeature: state.uri.queryParameters['feature'],
          reason: state.uri.queryParameters['reason'],
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    redirect: (context, state) {
      final location = state.uri.path;
      final isPublicRoute = publicRoutes.contains(location);
      final onboardingIsLoading =
          authState.status == AuthStatus.authenticated &&
          onboardingState.isLoading;
      final hasCompletedOnboarding = onboardingState.asData?.value ?? false;

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
          if (onboardingIsLoading) {
            return location == AppRoutes.splash ? null : AppRoutes.splash;
          }

          if (!hasCompletedOnboarding) {
            if (location == AppRoutes.onboarding) {
              return null;
            }

            final onboardingTarget =
                location == AppRoutes.splash ||
                    location == AppRoutes.login ||
                    location == AppRoutes.register
                ? AppRoutes.home
                : state.uri.toString();

            return Uri(
              path: AppRoutes.onboarding,
              queryParameters: {'from': onboardingTarget},
            ).toString();
          }

          if (location == AppRoutes.splash ||
              location == AppRoutes.login ||
              location == AppRoutes.register ||
              location == AppRoutes.onboarding) {
            final redirectTo = state.uri.queryParameters['from'];
            return redirectTo?.isNotEmpty == true ? redirectTo : AppRoutes.home;
          }

          return null;
      }
    },
  );
});

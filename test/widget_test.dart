import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_career_tools/app/app.dart';
import 'package:ai_career_tools/features/auth/domain/entities/auth_session.dart';
import 'package:ai_career_tools/features/auth/domain/entities/sign_up_request.dart';
import 'package:ai_career_tools/features/auth/domain/entities/sign_up_result.dart';
import 'package:ai_career_tools/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_career_tools/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ai_career_tools/features/onboarding/data/local/onboarding_local_storage.dart';
import 'package:ai_career_tools/features/onboarding/presentation/controllers/onboarding_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.restoredSession,
    this.restoreDelay = Duration.zero,
  });

  final AuthSession? restoredSession;
  final Duration restoreDelay;

  @override
  Stream<AuthSession?> observeAuthStateChanges() {
    return const Stream<AuthSession?>.empty();
  }

  @override
  Future<AuthSession?> restoreSession() async {
    if (restoreDelay > Duration.zero) {
      await Future<void>.delayed(restoreDelay);
    }

    return restoredSession;
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<SignUpResult> signUp(SignUpRequest request) {
    throw UnimplementedError();
  }
}

class _FakeOnboardingLocalStorage implements OnboardingLocalStorage {
  _FakeOnboardingLocalStorage({required this.isCompleted});

  bool isCompleted;

  @override
  Future<bool> readIsCompleted() async => isCompleted;

  @override
  Future<void> writeIsCompleted(bool value) async {
    isCompleted = value;
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required AuthRepository authRepository,
  required OnboardingLocalStorage onboardingStorage,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        onboardingLocalStorageProvider.overrideWithValue(onboardingStorage),
      ],
      child: const AICareerToolsApp(),
    ),
  );
}

void main() {
  const restoredSession = AuthSession(
    userId: 'user-1',
    email: 'jane@example.com',
    fullName: 'Jane Doe',
    targetRole: 'Product Designer',
    yearsOfExperience: 5,
  );

  testWidgets('shows splash screen while auth bootstrap is in progress', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        restoreDelay: const Duration(milliseconds: 900),
      ),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: false),
    );

    await tester.pump();

    expect(find.text('Preparing your workspace...'), findsOneWidget);
    expect(find.text('AI Career Tools'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('shows onboarding for authenticated users on first launch', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: false),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Welcome to AI Career Tools'), findsOneWidget);
    expect(find.text('Build stronger resumes'), findsOneWidget);
  });

  testWidgets('shows home for returning users after onboarding', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Resume Builder'), findsOneWidget);
    expect(find.text('Cover Letter Generator'), findsOneWidget);
    expect(find.text('Interview Prep'), findsOneWidget);
  });

  testWidgets('navigates from home to a feature route', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('role-focused resumes'), findsOneWidget);
  });
}

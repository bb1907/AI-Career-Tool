import 'package:flutter/material.dart';
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
import 'package:ai_career_tools/features/resume/domain/entities/resume_request.dart';
import 'package:ai_career_tools/features/resume/domain/entities/resume_result.dart';
import 'package:ai_career_tools/features/resume/domain/repositories/resume_repository.dart';
import 'package:ai_career_tools/features/resume/presentation/controllers/resume_builder_controller.dart';

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

class _FakeResumeRepository implements ResumeRepository {
  _FakeResumeRepository({required this.response, this.delay = Duration.zero});

  final ResumeResult response;
  final Duration delay;
  final List<ResumeResult> _history = [];

  @override
  Future<ResumeResult> generateResume(ResumeRequest request) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return response;
  }

  @override
  Future<void> saveResume(ResumeResult result) async {
    _history.insert(0, result);
  }

  @override
  Future<List<ResumeResult>> fetchHistory() async {
    return List<ResumeResult>.unmodifiable(_history);
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required AuthRepository authRepository,
  required OnboardingLocalStorage onboardingStorage,
  ResumeRepository? resumeRepository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        onboardingLocalStorageProvider.overrideWithValue(onboardingStorage),
        resumeRepositoryProvider.overrideWithValue(
          resumeRepository ??
              _FakeResumeRepository(
                response: const ResumeResult(
                  summary: 'Generated summary',
                  experienceBullets: ['Generated bullet'],
                  skills: ['Figma', 'Research'],
                  education: 'B.A. in Design',
                ),
              ),
        ),
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
  const generatedResume = ResumeResult(
    summary:
        'Senior Product Designer with 5 years of experience designing measurable product improvements.',
    experienceBullets: [
      'Improved onboarding completion by 18% through iterative product design experiments.',
      'Launched a reusable design system adopted by four product squads.',
    ],
    skills: ['Figma', 'Design Systems', 'User Research'],
    education: 'B.A. in Visual Communication Design, Bilkent University',
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

    expect(find.text('ATS-friendly resume generation'), findsOneWidget);
    expect(find.text('Generate resume'), findsOneWidget);
  });

  testWidgets('submits the resume form and opens the result page', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        delay: const Duration(milliseconds: 300),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Senior Product Designer',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '5');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Product Designer at Atlas\nUX Designer at Northstar',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Figma, Design systems, User research, Prototyping',
    );
    await tester.enterText(
      find.byType(TextFormField).at(4),
      'Improved onboarding completion by 18%\nLaunched a reusable design system adopted by four squads',
    );
    await tester.enterText(
      find.byType(TextFormField).at(5),
      'B.A. in Visual Communication Design, Bilkent University',
    );

    await tester.scrollUntilVisible(
      find.text('Generate resume'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate resume'));
    await tester.pump();

    expect(find.text('Generating resume...'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('ATS-ready draft'), findsOneWidget);
    expect(find.text(generatedResume.summary), findsOneWidget);
    expect(find.text('Experience bullets'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
  });
}

import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_career_tools/app/app.dart';
import 'package:ai_career_tools/core/errors/app_exception.dart';
import 'package:ai_career_tools/features/auth/data/auth_repository.dart';
import 'package:ai_career_tools/features/auth/domain/entities/auth_session.dart';
import 'package:ai_career_tools/features/auth/domain/entities/sign_up_request.dart';
import 'package:ai_career_tools/features/auth/domain/entities/sign_up_result.dart';
import 'package:ai_career_tools/features/auth/presentation/providers/auth_controller.dart';
import 'package:ai_career_tools/features/cover_letter/application/cover_letter_controller.dart';
import 'package:ai_career_tools/features/cover_letter/domain/entities/cover_letter_request.dart';
import 'package:ai_career_tools/features/cover_letter/domain/entities/cover_letter_result.dart';
import 'package:ai_career_tools/features/cover_letter/domain/repositories/cover_letter_repository.dart';
import 'package:ai_career_tools/features/interview/application/interview_controller.dart';
import 'package:ai_career_tools/features/interview/domain/entities/interview_question.dart';
import 'package:ai_career_tools/features/interview/domain/entities/interview_request.dart';
import 'package:ai_career_tools/features/interview/domain/entities/interview_result.dart';
import 'package:ai_career_tools/features/interview/domain/repositories/interview_repository.dart';
import 'package:ai_career_tools/features/history/application/history_controller.dart';
import 'package:ai_career_tools/features/history/domain/entities/history_section.dart';
import 'package:ai_career_tools/features/history/domain/entities/history_snapshot.dart';
import 'package:ai_career_tools/features/history/domain/repositories/history_repository.dart';
import 'package:ai_career_tools/features/onboarding/data/local/onboarding_local_storage.dart';
import 'package:ai_career_tools/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ai_career_tools/features/profile_import/application/profile_import_controller.dart';
import 'package:ai_career_tools/features/profile_import/domain/entities/candidate_profile.dart';
import 'package:ai_career_tools/features/profile_import/domain/entities/cv_upload_file.dart';
import 'package:ai_career_tools/features/profile_import/domain/repositories/profile_import_repository.dart';
import 'package:ai_career_tools/features/resume/application/resume_controller.dart';
import 'package:ai_career_tools/features/resume/domain/entities/resume_request.dart';
import 'package:ai_career_tools/features/resume/domain/entities/resume_result.dart';
import 'package:ai_career_tools/features/resume/domain/repositories/resume_repository.dart';

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

class _InteractiveAuthRepository implements AuthRepository {
  _InteractiveAuthRepository({AuthSession? initialSession})
    : _currentSession = initialSession;

  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _currentSession;

  void emitSession(AuthSession? session) {
    _currentSession = session;
    _controller.add(session);
  }

  @override
  Stream<AuthSession?> observeAuthStateChanges() => _controller.stream;

  @override
  Future<AuthSession?> restoreSession() async => _currentSession;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = _currentSession;
    if (session == null) {
      throw UnimplementedError();
    }

    _controller.add(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    emitSession(null);
  }

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
  _FakeResumeRepository({
    required this.response,
    this.delay = Duration.zero,
    List<ResumeResult> initialHistory = const [],
  }) : _history = List<ResumeResult>.from(initialHistory);

  final ResumeResult response;
  final Duration delay;
  final List<ResumeResult> _history;

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

class _FakeCoverLetterRepository implements CoverLetterRepository {
  _FakeCoverLetterRepository({
    required this.response,
    this.delay = Duration.zero,
    List<CoverLetterResult> initialHistory = const [],
    this.fetchHistoryError,
  }) : _history = List<CoverLetterResult>.from(initialHistory);

  final CoverLetterResult response;
  final Duration delay;
  final List<CoverLetterResult> _history;
  final Object? fetchHistoryError;

  @override
  Future<CoverLetterResult> generateCoverLetter(
    CoverLetterRequest request,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return response;
  }

  @override
  Future<void> saveCoverLetter(CoverLetterResult result) async {
    _history.insert(0, result);
  }

  @override
  Future<List<CoverLetterResult>> fetchHistory() async {
    if (fetchHistoryError != null) {
      throw fetchHistoryError!;
    }

    return List<CoverLetterResult>.unmodifiable(_history);
  }
}

class _FakeInterviewRepository implements InterviewRepository {
  _FakeInterviewRepository({
    required this.response,
    this.delay = Duration.zero,
    List<InterviewResult> initialHistory = const [],
  }) : _history = List<InterviewResult>.from(initialHistory);

  final InterviewResult response;
  final Duration delay;
  final List<InterviewResult> _history;

  @override
  Future<InterviewResult> generateInterviewPrep(
    InterviewRequest request,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return response;
  }

  @override
  Future<void> saveInterviewPrep(InterviewResult result) async {
    _history.insert(0, result);
  }

  @override
  Future<List<InterviewResult>> fetchHistory() async {
    return List<InterviewResult>.unmodifiable(_history);
  }
}

class _FakeProfileImportRepository implements ProfileImportRepository {
  _FakeProfileImportRepository({
    required this.response,
    this.delay = Duration.zero,
  });

  final CandidateProfile response;
  final Duration delay;

  @override
  Future<CandidateProfile> importCv(CvUploadFile file) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return response;
  }
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({
    required this.snapshotsByUserId,
    required this.activeUserId,
  });

  final Map<String, HistorySnapshot> snapshotsByUserId;
  String activeUserId;

  @override
  Future<HistorySnapshot> fetchHistory() async {
    return snapshotsByUserId[activeUserId] ?? const HistorySnapshot();
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required AuthRepository authRepository,
  required OnboardingLocalStorage onboardingStorage,
  ResumeRepository? resumeRepository,
  CoverLetterRepository? coverLetterRepository,
  InterviewRepository? interviewRepository,
  ProfileImportRepository? profileImportRepository,
  HistoryRepository? historyRepository,
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
        coverLetterRepositoryProvider.overrideWithValue(
          coverLetterRepository ??
              _FakeCoverLetterRepository(
                response: const CoverLetterResult(
                  coverLetter: 'Generated cover letter',
                ),
              ),
        ),
        interviewRepositoryProvider.overrideWithValue(
          interviewRepository ??
              _FakeInterviewRepository(
                response: const InterviewResult(
                  technicalQuestions: [
                    InterviewQuestion(
                      question: 'Generated technical question',
                      sampleAnswer: 'Generated technical answer',
                    ),
                  ],
                  behavioralQuestions: [
                    InterviewQuestion(
                      question: 'Generated behavioral question',
                      sampleAnswer: 'Generated behavioral answer',
                    ),
                  ],
                ),
              ),
        ),
        profileImportRepositoryProvider.overrideWithValue(
          profileImportRepository ??
              _FakeProfileImportRepository(
                response: const CandidateProfile(
                  name: 'Jane Doe',
                  email: 'jane@example.com',
                  location: 'Istanbul, Turkey',
                  yearsExperience: 5,
                  roles: ['Product Designer', 'UX Designer'],
                  skills: ['Figma', 'Design Systems', 'User Research'],
                  industries: ['SaaS', 'B2B'],
                  seniority: 'Senior',
                  education: 'B.A. in Visual Communication Design',
                ),
              ),
        ),
        if (historyRepository != null)
          historyRepositoryProvider.overrideWithValue(historyRepository),
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
  const secondSession = AuthSession(
    userId: 'user-2',
    email: 'john@example.com',
    fullName: 'John Appleseed',
    targetRole: 'Mobile Engineer',
    yearsOfExperience: 7,
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
  const generatedCoverLetter = CoverLetterResult(
    coverLetter:
        'Dear Hiring Team,\n\nI am excited to apply for the Senior Product Designer role at Acme Labs.\n\nSincerely,\nJane Doe',
  );
  const generatedInterviewResult = InterviewResult(
    technicalQuestions: [
      InterviewQuestion(
        question: 'How would you measure design quality for a B2B workflow?',
        sampleAnswer:
            'I would combine task completion, error rate, time-on-task and qualitative feedback, then map those metrics back to the workflow goals.',
      ),
      InterviewQuestion(
        question: 'How do you prioritize product design improvements?',
        sampleAnswer:
            'I prioritize based on impact, confidence, effort and strategic relevance, then align tradeoffs with product and engineering partners.',
      ),
    ],
    behavioralQuestions: [
      InterviewQuestion(
        question: 'Tell me about a time you influenced stakeholders.',
        sampleAnswer:
            'I used a concise narrative around user evidence, business impact and clear next steps to align the group around a shared direction.',
      ),
      InterviewQuestion(
        question: 'Describe a time you handled ambiguity.',
        sampleAnswer:
            'I reduced ambiguity by clarifying assumptions, defining decision checkpoints and keeping the team aligned on what we needed to learn next.',
      ),
    ],
  );
  const parsedCandidateProfile = CandidateProfile(
    name: 'Jane Doe',
    email: 'jane@example.com',
    location: 'Istanbul, Turkey',
    yearsExperience: 5,
    roles: ['Product Designer', 'UX Designer'],
    skills: ['Figma', 'Design Systems', 'User Research'],
    industries: ['SaaS', 'B2B'],
    seniority: 'Senior',
    education: 'B.A. in Visual Communication Design',
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

  testWidgets('submits the cover letter form and opens the result page', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      coverLetterRepository: _FakeCoverLetterRepository(
        response: generatedCoverLetter,
        delay: const Duration(milliseconds: 300),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Cover Letter Generator').first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cover Letter Generator').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Acme Labs');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Senior Product Designer',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Design product experiences, collaborate across teams, and own quality from idea to launch.',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      '5 years designing B2B and consumer product experiences with measurable improvements in onboarding and retention.',
    );

    await tester.scrollUntilVisible(
      find.text('Generate cover letter'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate cover letter'));
    await tester.pump();

    expect(find.text('Generating cover letter...'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Tailored company draft'), findsOneWidget);
    expect(find.text('Editable draft'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.textContaining('Dear Hiring Team'), findsOneWidget);
  });

  testWidgets('submits the interview form and opens the result page', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      interviewRepository: _FakeInterviewRepository(
        response: generatedInterviewResult,
        delay: const Duration(milliseconds: 300),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Interview Prep').first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Interview Prep').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Senior Product Designer',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'System design, stakeholder management, analytics',
    );

    await tester.scrollUntilVisible(
      find.text('Generate interview prep'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate interview prep'));
    await tester.pump();

    expect(find.text('Generating interview prep...'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Role-specific question set'), findsOneWidget);
    expect(find.text('Technical questions'), findsOneWidget);
    expect(find.text('Behavioral questions'), findsOneWidget);
    expect(
      find.text(generatedInterviewResult.technicalQuestions.first.question),
      findsOneWidget,
    );
    expect(
      find.text(generatedInterviewResult.behavioralQuestions.first.question),
      findsOneWidget,
    );
  });

  testWidgets('shows grouped history sections for saved content', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        initialHistory: const [generatedResume],
      ),
      coverLetterRepository: _FakeCoverLetterRepository(
        response: generatedCoverLetter,
        initialHistory: const [generatedCoverLetter],
      ),
      interviewRepository: _FakeInterviewRepository(
        response: generatedInterviewResult,
        initialHistory: const [generatedInterviewResult],
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Resumes'), findsOneWidget);
    expect(find.text('Cover Letters'), findsOneWidget);
    expect(find.text('Interview Sets'), findsOneWidget);
    expect(find.textContaining('Senior Product Designer'), findsWidgets);
    expect(find.textContaining('Dear Hiring Team'), findsOneWidget);
    expect(
      find.text(generatedInterviewResult.technicalQuestions.first.question),
      findsOneWidget,
    );
  });

  testWidgets(
    'scopes history state to the active authenticated user across auth changes',
    (WidgetTester tester) async {
      final authRepository = _InteractiveAuthRepository(
        initialSession: restoredSession,
      );
      final historyRepository = _FakeHistoryRepository(
        activeUserId: restoredSession.userId,
        snapshotsByUserId: {
          restoredSession.userId: const HistorySnapshot(
            resumes: HistorySection(
              items: [
                ResumeResult(
                  summary: 'User A resume snapshot',
                  experienceBullets: ['A bullet'],
                  skills: ['Figma'],
                  education: 'A education',
                ),
              ],
            ),
          ),
          secondSession.userId: const HistorySnapshot(
            resumes: HistorySection(
              items: [
                ResumeResult(
                  summary: 'User B resume snapshot',
                  experienceBullets: ['B bullet'],
                  skills: ['Dart'],
                  education: 'B education',
                ),
              ],
            ),
          ),
        },
      );

      await _pumpApp(
        tester,
        authRepository: authRepository,
        onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
        historyRepository: historyRepository,
      );

      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('History'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('User A resume snapshot'), findsOneWidget);
      expect(find.text('User B resume snapshot'), findsNothing);

      authRepository.emitSession(null);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('User A resume snapshot'), findsNothing);

      historyRepository.activeUserId = secondSession.userId;
      authRepository.emitSession(secondSession);
      await tester.pump();

      expect(find.text('User A resume snapshot'), findsNothing);

      await tester.pumpAndSettle();

      if (find.text('History').evaluate().isEmpty) {
        await tester.tap(find.byTooltip('History'));
        await tester.pumpAndSettle();
      }

      expect(find.text('History'), findsOneWidget);
      expect(find.text('User B resume snapshot'), findsOneWidget);
      expect(find.text('User A resume snapshot'), findsNothing);
    },
  );

  testWidgets('renders healthy history sections when one source fails', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        initialHistory: const [generatedResume],
      ),
      coverLetterRepository: _FakeCoverLetterRepository(
        response: generatedCoverLetter,
        fetchHistoryError: const AppException(
          'Cover letter history is temporarily unavailable.',
        ),
      ),
      interviewRepository: _FakeInterviewRepository(
        response: generatedInterviewResult,
        initialHistory: const [generatedInterviewResult],
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('History unavailable'), findsNothing);
    expect(find.text('Resumes'), findsOneWidget);
    expect(find.text('Cover Letters'), findsOneWidget);
    expect(find.text('Interview Sets'), findsOneWidget);
    expect(
      find.text('Cover letter history is temporarily unavailable.'),
      findsOneWidget,
    );
    expect(find.text('Retry section load'), findsOneWidget);
    expect(find.textContaining('Senior Product Designer'), findsWidgets);
    expect(
      find.text(generatedInterviewResult.technicalQuestions.first.question),
      findsOneWidget,
    );
  });

  testWidgets('imports a CV and renders the parsed candidate profile', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      profileImportRepository: _FakeProfileImportRepository(
        response: parsedCandidateProfile,
        delay: const Duration(milliseconds: 300),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import CV'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AICareerToolsApp)),
    );
    container
        .read(profileImportControllerProvider.notifier)
        .selectFile(
          CvUploadFile(
            fileName: 'jane-doe-cv.pdf',
            bytes: Uint8List.fromList(const [1, 2, 3]),
            sizeInBytes: 3,
          ),
        );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload and parse'));
    await tester.pump();

    expect(find.text('Processing...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Structured candidate profile'), findsOneWidget);
    expect(find.text(parsedCandidateProfile.name), findsOneWidget);
    expect(find.text(parsedCandidateProfile.email), findsOneWidget);
    expect(find.text(parsedCandidateProfile.skills.first), findsOneWidget);
  });
}

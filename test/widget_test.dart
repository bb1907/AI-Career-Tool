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
import 'package:ai_career_tools/features/job_matching/application/job_matching_controller.dart';
import 'package:ai_career_tools/features/job_matching/domain/entities/job_listing.dart';
import 'package:ai_career_tools/features/job_matching/domain/entities/job_search_request.dart';
import 'package:ai_career_tools/features/job_matching/domain/repositories/job_matching_repository.dart';
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
import 'package:ai_career_tools/services/analytics/analytics_events.dart';
import 'package:ai_career_tools/services/analytics/analytics_service.dart';
import 'package:ai_career_tools/services/subscription/premium_access_feature.dart';
import 'package:ai_career_tools/services/subscription/premium_access_service.dart';
import 'package:ai_career_tools/services/subscription/revenuecat_subscription_service.dart';
import 'package:ai_career_tools/services/subscription/subscription_package.dart';
import 'package:ai_career_tools/services/subscription/subscription_plan.dart';
import 'package:ai_career_tools/services/subscription/subscription_service.dart';
import 'package:ai_career_tools/services/subscription/subscription_status.dart';
import 'package:ai_career_tools/services/subscription/subscription_sync_service.dart';

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
    this.generateError,
  }) : _history = List<ResumeResult>.from(initialHistory);

  final ResumeResult response;
  final Duration delay;
  final List<ResumeResult> _history;
  final Object? generateError;

  @override
  Future<ResumeResult> generateResume(ResumeRequest request) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (generateError != null) {
      throw generateError!;
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
    CandidateProfile? latestProfile,
  }) : _latestProfile = latestProfile;

  final CandidateProfile response;
  final Duration delay;
  CandidateProfile? _latestProfile;

  @override
  Future<CandidateProfile> importCv(CvUploadFile file) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    _latestProfile = response;
    return response;
  }

  @override
  Future<CandidateProfile?> fetchLatestProfile() async => _latestProfile;

  @override
  Future<CandidateProfile> updateProfile(CandidateProfile profile) async {
    _latestProfile = profile;
    return profile;
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

class _FakeJobMatchingRepository implements JobMatchingRepository {
  _FakeJobMatchingRepository({required this.results});

  final List<JobListing> results;
  JobSearchRequest? lastRequest;

  @override
  Future<List<JobListing>> searchJobs(JobSearchRequest request) async {
    lastRequest = request;
    return List<JobListing>.unmodifiable(results);
  }
}

class _FakeSubscriptionService implements SubscriptionService {
  _FakeSubscriptionService({
    SubscriptionStatus? status,
    List<SubscriptionPackage> packages = const <SubscriptionPackage>[
      SubscriptionPackage(
        identifier: 'weekly',
        productIdentifier: 'premium_weekly',
        plan: SubscriptionPlan.weekly,
        title: 'Weekly Premium',
        description: 'Short-term premium access',
        priceLabel: r'$4.99',
        billingLabel: r'$4.99 / week',
      ),
      SubscriptionPackage(
        identifier: 'monthly',
        productIdentifier: 'premium_monthly',
        plan: SubscriptionPlan.monthly,
        title: 'Monthly Premium',
        description: 'Monthly premium access',
        priceLabel: r'$12.99',
        billingLabel: r'$12.99 / month',
      ),
      SubscriptionPackage(
        identifier: 'annual',
        productIdentifier: 'premium_annual',
        plan: SubscriptionPlan.annual,
        title: 'Annual Premium',
        description: 'Best long-term value',
        priceLabel: r'$79.99',
        billingLabel: r'$79.99 / year',
      ),
    ],
  }) : _status = status ?? const SubscriptionStatus(),
       _packages = List<SubscriptionPackage>.unmodifiable(packages);

  final _controller = StreamController<SubscriptionStatus>.broadcast();
  SubscriptionStatus _status;
  final List<SubscriptionPackage> _packages;

  @override
  Future<void> initialize() async {}

  @override
  Stream<SubscriptionStatus> observeSubscriptionStatus() => _controller.stream;

  @override
  Future<List<SubscriptionPackage>> loadPackages() async => _packages;

  @override
  Future<SubscriptionStatus> purchasePackage(
    SubscriptionPackage package,
  ) async {
    _status = SubscriptionStatus(
      appUserId: _status.appUserId,
      plan: package.plan,
      isPremium: true,
      entitlementId: 'premium',
      productIdentifier: package.productIdentifier,
      willRenew: true,
    );
    _controller.add(_status);
    return _status;
  }

  @override
  Future<SubscriptionStatus> refreshStatus() async => _status;

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    _controller.add(_status);
    return _status;
  }

  @override
  Future<SubscriptionStatus> syncUser(String? appUserId) async {
    _status = appUserId == null
        ? _status.copyWith(
            clearAppUserId: true,
            plan: SubscriptionPlan.free,
            isPremium: false,
            clearEntitlement: true,
            clearProductIdentifier: true,
            clearExpiresAt: true,
            clearManagementUrl: true,
            willRenew: false,
          )
        : _status.copyWith(appUserId: appUserId);
    _controller.add(_status);
    return _status;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class _FakeSubscriptionSyncService implements SubscriptionSyncService {
  const _FakeSubscriptionSyncService();

  @override
  Future<void> syncStatus({
    required String userId,
    required SubscriptionStatus status,
  }) async {}
}

class _TrackedAnalyticsEvent {
  const _TrackedAnalyticsEvent({required this.name, required this.parameters});

  final String name;
  final Map<String, Object?> parameters;
}

class _FakeAnalyticsService implements AnalyticsService {
  final List<_TrackedAnalyticsEvent> events = <_TrackedAnalyticsEvent>[];
  String? lastUserId;

  bool hasEvent(String name) => events.any((event) => event.name == name);

  @override
  Future<void> initialize() async {
    events.add(
      const _TrackedAnalyticsEvent(
        name: AnalyticsEvents.appOpen,
        parameters: <String, Object?>{},
      ),
    );
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    events.add(_TrackedAnalyticsEvent(name: name, parameters: parameters));
  }

  @override
  Future<void> setUserId(String? userId) async {
    lastUserId = userId;
  }

  @override
  void dispose() {}
}

class _FakePremiumAccessService implements PremiumAccessService {
  _FakePremiumAccessService({Map<String, int> initialUsageByUserId = const {}})
    : _usageByUserId = Map<String, int>.from(initialUsageByUserId);

  final Map<String, int> _usageByUserId;
  final Map<String, String> _reservationOwners = <String, String>{};
  int _nextReservationId = 0;

  int committedUsageFor(String userId) => _usageByUserId[userId] ?? 0;

  int _activeUsageFor(String userId) {
    final pendingCount = _reservationOwners.values
        .where((id) => id == userId)
        .length;
    return committedUsageFor(userId) + pendingCount;
  }

  @override
  Future<PremiumAccessDecision> evaluateAccess({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  }) async {
    final normalizedUserId = userId?.trim();
    final snapshot = await loadSnapshot(userId: userId, isPremium: isPremium);

    if (snapshot.isPremium || !snapshot.hasReachedLimit) {
      final reservationId =
          !isPremium && normalizedUserId != null && normalizedUserId.isNotEmpty
          ? 'reservation-${_nextReservationId++}'
          : null;
      if (reservationId != null) {
        _reservationOwners[reservationId] = normalizedUserId!;
      }

      return PremiumAccessDecision(
        feature: feature,
        snapshot: snapshot,
        isAllowed: true,
        reservationId: reservationId,
      );
    }

    return PremiumAccessDecision(
      feature: feature,
      snapshot: snapshot,
      isAllowed: false,
      message: 'Free limit reached.',
    );
  }

  @override
  Future<PremiumAccessSnapshot> loadSnapshot({
    required String? userId,
    required bool isPremium,
  }) async {
    final normalizedUserId = userId?.trim();

    return PremiumAccessSnapshot(
      userId: userId,
      isPremium: isPremium,
      usedFreeGenerations: normalizedUserId == null || normalizedUserId.isEmpty
          ? 0
          : _activeUsageFor(normalizedUserId),
    );
  }

  @override
  Future<PremiumAccessSnapshot> recordSuccessfulUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
    String? reservationId,
  }) async {
    final normalizedUserId = userId?.trim();
    final owner = reservationId == null
        ? null
        : _reservationOwners.remove(reservationId);

    if (!isPremium &&
        normalizedUserId != null &&
        normalizedUserId.isNotEmpty &&
        owner == normalizedUserId) {
      _usageByUserId[normalizedUserId] =
          (_usageByUserId[normalizedUserId] ?? 0) + 1;
    }

    return loadSnapshot(userId: userId, isPremium: isPremium);
  }

  @override
  Future<PremiumAccessSnapshot> releasePendingUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
    String? reservationId,
  }) async {
    if (reservationId != null) {
      _reservationOwners.remove(reservationId);
    }

    return loadSnapshot(userId: userId, isPremium: isPremium);
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
  JobMatchingRepository? jobMatchingRepository,
  SubscriptionService? subscriptionService,
  PremiumAccessService? premiumAccessService,
  AnalyticsService? analyticsService,
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
        if (jobMatchingRepository != null)
          jobMatchingRepositoryProvider.overrideWithValue(
            jobMatchingRepository,
          ),
        subscriptionServiceProvider.overrideWithValue(
          subscriptionService ?? _FakeSubscriptionService(),
        ),
        subscriptionSyncServiceProvider.overrideWithValue(
          const _FakeSubscriptionSyncService(),
        ),
        analyticsServiceProvider.overrideWithValue(
          analyticsService ?? _FakeAnalyticsService(),
        ),
        premiumAccessServiceProvider.overrideWithValue(
          premiumAccessService ?? _FakePremiumAccessService(),
        ),
      ],
      child: const AICareerToolsApp(),
    ),
  );
}

Future<void> _fillResumeForm(WidgetTester tester) async {
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
  const matchedJobs = <JobListing>[
    JobListing(
      id: 'job-1',
      title: 'Senior Product Designer',
      company: 'Northstar Labs',
      location: 'Istanbul, Turkey',
      source: 'LinkedIn',
      url: 'https://jobs.example.com/northstar-labs/senior-product-designer',
      jobDescription:
          'Northstar Labs is hiring a Senior Product Designer to lead product design work across a growing B2B SaaS platform.',
    ),
    JobListing(
      id: 'job-2',
      title: 'Product Designer, Growth',
      company: 'Orbit Commerce',
      location: 'Istanbul, Turkey',
      source: 'Indeed',
      url: 'https://jobs.example.com/orbit-commerce/product-designer-growth',
      jobDescription:
          'Orbit Commerce is hiring a Product Designer, Growth to improve acquisition and activation funnels.',
    ),
  ];

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

  testWidgets('shows recent saved items on home as a mixed list', (
    WidgetTester tester,
  ) async {
    final mostRecentCoverLetter = CoverLetterResult(
      coverLetter: 'Cover letter for Orbit Labs',
      createdAt: DateTime.utc(2026, 3, 12, 10, 30),
    );
    final recentInterview = InterviewResult(
      technicalQuestions: const [
        InterviewQuestion(
          question: 'How do you scope mobile architecture decisions?',
          sampleAnswer: 'I start with lifecycle, ownership and testability.',
        ),
      ],
      behavioralQuestions: const [
        InterviewQuestion(
          question: 'Tell me about a difficult stakeholder conversation.',
          sampleAnswer: 'I reframed the discussion around tradeoffs and risks.',
        ),
      ],
      createdAt: DateTime.utc(2026, 3, 12, 9, 45),
    );
    final recentResume = ResumeResult(
      summary: 'Resume tailored for senior mobile engineer applications',
      experienceBullets: const ['Improved release confidence by 20%.'],
      skills: const ['Flutter', 'Dart'],
      education: 'B.S. in Computer Engineering',
      createdAt: DateTime.utc(2026, 3, 12, 8, 30),
    );
    final olderResume = ResumeResult(
      summary: 'Older resume draft',
      experienceBullets: const ['Built reusable UI modules.'],
      skills: const ['Flutter'],
      education: 'B.S. in Computer Engineering',
      createdAt: DateTime.utc(2026, 3, 11, 15, 0),
    );

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        initialHistory: [recentResume, olderResume],
      ),
      coverLetterRepository: _FakeCoverLetterRepository(
        response: generatedCoverLetter,
        initialHistory: [mostRecentCoverLetter],
      ),
      interviewRepository: _FakeInterviewRepository(
        response: generatedInterviewResult,
        initialHistory: [recentInterview],
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Recently saved'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Recently saved'), findsOneWidget);
    expect(find.text('Cover Letter'), findsOneWidget);
    expect(find.text('Interview Set'), findsOneWidget);
    expect(find.text('Resume'), findsWidgets);
    expect(find.text('Cover letter for Orbit Labs'), findsOneWidget);
    expect(
      find.text('How do you scope mobile architecture decisions?'),
      findsOneWidget,
    );
    expect(
      find.text('Resume tailored for senior mobile engineer applications'),
      findsOneWidget,
    );

    final coverLetterY = tester
        .getTopLeft(find.text('Cover letter for Orbit Labs'))
        .dy;
    final interviewY = tester
        .getTopLeft(
          find.text('How do you scope mobile architecture decisions?'),
        )
        .dy;
    final resumeY = tester
        .getTopLeft(
          find.text('Resume tailored for senior mobile engineer applications'),
        )
        .dy;

    expect(coverLetterY, lessThan(interviewY));
    expect(interviewY, lessThan(resumeY));
    expect(find.text('Open full history'), findsOneWidget);
  });

  testWidgets('shows an empty recent state when there is no saved work', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('No saved work yet'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No saved work yet'), findsOneWidget);
    expect(find.text('Open history'), findsOneWidget);
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

  testWidgets(
    'shows matching jobs from the candidate profile and lets the user select one',
    (WidgetTester tester) async {
      final jobMatchingRepository = _FakeJobMatchingRepository(
        results: matchedJobs,
      );

      await _pumpApp(
        tester,
        authRepository: _FakeAuthRepository(restoredSession: restoredSession),
        onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
        profileImportRepository: _FakeProfileImportRepository(
          response: parsedCandidateProfile,
          latestProfile: parsedCandidateProfile,
        ),
        jobMatchingRepository: jobMatchingRepository,
      );

      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Find jobs'));
      await tester.pumpAndSettle();

      expect(find.text('Find jobs that fit your profile'), findsOneWidget);
      expect(find.text('Northstar Labs'), findsOneWidget);
      expect(find.text('LinkedIn'), findsOneWidget);
      expect(jobMatchingRepository.lastRequest, isNotNull);
      expect(jobMatchingRepository.lastRequest!.role, 'Product Designer');
      expect(jobMatchingRepository.lastRequest!.location, 'Istanbul, Turkey');
      expect(jobMatchingRepository.lastRequest!.yearsExperience, 5);

      await tester.scrollUntilVisible(
        find.text('Select job').first,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select job').first);
      await tester.pumpAndSettle();

      expect(find.text('Selected job'), findsOneWidget);
      expect(
        find.text('Senior Product Designer at Northstar Labs'),
        findsOneWidget,
      );
    },
  );

  testWidgets('uses the selected job to prefill the cover letter form', (
    WidgetTester tester,
  ) async {
    final jobMatchingRepository = _FakeJobMatchingRepository(
      results: matchedJobs,
    );

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      profileImportRepository: _FakeProfileImportRepository(
        response: parsedCandidateProfile,
        latestProfile: parsedCandidateProfile,
      ),
      jobMatchingRepository: jobMatchingRepository,
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find jobs'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Use in cover letter').first,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use in cover letter').first);
    await tester.pumpAndSettle();

    expect(find.text('Cover Letter Generator'), findsOneWidget);
    expect(
      find.textContaining('Selected job details from Northstar Labs'),
      findsOneWidget,
    );

    final fields = find.byType(TextFormField);
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      'Northstar Labs',
    );
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      'Senior Product Designer',
    );
    expect(
      tester.widget<TextFormField>(fields.at(2)).controller!.text,
      matchedJobs.first.jobDescription,
    );
  });

  testWidgets('prefills the resume form from the saved candidate profile', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      profileImportRepository: _FakeProfileImportRepository(
        response: parsedCandidateProfile,
        latestProfile: parsedCandidateProfile,
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);

    expect(
      find.textContaining('prefilled from your imported candidate profile'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      'Product Designer',
    );
    expect(tester.widget<TextFormField>(fields.at(1)).controller!.text, '5');
    expect(
      tester.widget<TextFormField>(fields.at(2)).controller!.text,
      'Product Designer\nUX Designer',
    );
    expect(
      tester.widget<TextFormField>(fields.at(3)).controller!.text,
      'Figma, Design Systems, User Research',
    );
    expect(
      tester.widget<TextFormField>(fields.at(5)).controller!.text,
      'B.A. in Visual Communication Design',
    );
  });

  testWidgets('submits the resume form and opens the result page', (
    WidgetTester tester,
  ) async {
    final accessService = _FakePremiumAccessService();
    final analyticsService = _FakeAnalyticsService();

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      analyticsService: analyticsService,
      premiumAccessService: accessService,
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        delay: const Duration(milliseconds: 300),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();

    await _fillResumeForm(tester);

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
    expect(accessService.committedUsageFor(restoredSession.userId), 1);
    expect(
      analyticsService.hasEvent(AnalyticsEvents.resumeGenerationStarted),
      true,
    );
    expect(
      analyticsService.hasEvent(AnalyticsEvents.resumeGenerationCompleted),
      true,
    );
  });

  testWidgets('does not count failed resume generations against usage', (
    WidgetTester tester,
  ) async {
    final accessService = _FakePremiumAccessService();

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      premiumAccessService: accessService,
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        generateError: const AppException('Resume generation failed.'),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();
    await _fillResumeForm(tester);

    await tester.scrollUntilVisible(
      find.text('Generate resume'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate resume'));
    await tester.pumpAndSettle();

    expect(find.text('Resume generation failed.'), findsOneWidget);
    expect(accessService.committedUsageFor(restoredSession.userId), 0);
  });

  testWidgets('shows paywall when a free user reaches the generation limit', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      premiumAccessService: _FakePremiumAccessService(
        initialUsageByUserId: {restoredSession.userId: 3},
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();
    await _fillResumeForm(tester);

    await tester.scrollUntilVisible(
      find.text('Generate resume'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate resume'));
    await tester.pumpAndSettle();

    expect(find.text('Free limit reached'), findsOneWidget);
    expect(find.text('Available plans'), findsOneWidget);
    expect(find.textContaining('3 of 3 free generations'), findsOneWidget);
  });

  testWidgets(
    'returns to the originating flow after a successful premium purchase',
    (WidgetTester tester) async {
      final analyticsService = _FakeAnalyticsService();

      await _pumpApp(
        tester,
        authRepository: _FakeAuthRepository(restoredSession: restoredSession),
        onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
        analyticsService: analyticsService,
        premiumAccessService: _FakePremiumAccessService(
          initialUsageByUserId: {restoredSession.userId: 3},
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resume Builder').first);
      await tester.pumpAndSettle();
      await _fillResumeForm(tester);

      await tester.scrollUntilVisible(
        find.text('Generate resume'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate resume'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Choose plan').first,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose plan').first);
      await tester.pumpAndSettle();

      expect(find.text('ATS-ready draft'), findsOneWidget);
      expect(find.text('Experience bullets'), findsOneWidget);
      expect(analyticsService.hasEvent(AnalyticsEvents.paywallViewed), true);
      expect(analyticsService.hasEvent(AnalyticsEvents.purchaseStarted), true);
      expect(
        analyticsService.hasEvent(AnalyticsEvents.purchaseCompleted),
        true,
      );
    },
  );

  testWidgets('premium users are not blocked by the free generation limit', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      subscriptionService: _FakeSubscriptionService(
        status: SubscriptionStatus(
          appUserId: restoredSession.userId,
          plan: SubscriptionPlan.monthly,
          isPremium: true,
          entitlementId: 'premium',
          productIdentifier: 'premium_monthly',
          willRenew: true,
        ),
      ),
      premiumAccessService: _FakePremiumAccessService(
        initialUsageByUserId: {restoredSession.userId: 3},
      ),
      resumeRepository: _FakeResumeRepository(
        response: generatedResume,
        delay: const Duration(milliseconds: 300),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resume Builder').first);
    await tester.pumpAndSettle();
    await _fillResumeForm(tester);

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
    expect(find.text('Free limit reached'), findsNothing);
  });

  testWidgets(
    'prefills the cover letter form from the saved candidate profile',
    (WidgetTester tester) async {
      await _pumpApp(
        tester,
        authRepository: _FakeAuthRepository(restoredSession: restoredSession),
        onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
        profileImportRepository: _FakeProfileImportRepository(
          response: parsedCandidateProfile,
          latestProfile: parsedCandidateProfile,
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

      final fields = find.byType(TextFormField);

      expect(
        find.textContaining('prefilled the role and background fields'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text,
        'Product Designer',
      );
      expect(
        tester.widget<TextFormField>(fields.at(3)).controller!.text,
        contains(
          'Core strengths include Figma, Design Systems, User Research.',
        ),
      );
    },
  );

  testWidgets('submits the cover letter form and opens the result page', (
    WidgetTester tester,
  ) async {
    final accessService = _FakePremiumAccessService();

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      premiumAccessService: accessService,
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
    expect(accessService.committedUsageFor(restoredSession.userId), 1);
  });

  testWidgets('prefills the interview form from the saved candidate profile', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      profileImportRepository: _FakeProfileImportRepository(
        response: parsedCandidateProfile,
        latestProfile: parsedCandidateProfile,
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

    final fields = find.byType(TextFormField);
    final dropdowns = find.byType(DropdownButtonFormField<String>);

    expect(
      find.textContaining('prefilled from your imported candidate profile'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      'Product Designer',
    );
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      'Figma, Design Systems, User Research, SaaS, B2B',
    );
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(dropdowns.at(0))
          .initialValue,
      'Senior',
    );
  });

  testWidgets('submits the interview form and opens the result page', (
    WidgetTester tester,
  ) async {
    final accessService = _FakePremiumAccessService();

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      premiumAccessService: accessService,
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
    expect(accessService.committedUsageFor(restoredSession.userId), 1);
  });

  testWidgets('shows grouped history sections for saved content', (
    WidgetTester tester,
  ) async {
    final analyticsService = _FakeAnalyticsService();

    await _pumpApp(
      tester,
      authRepository: _FakeAuthRepository(restoredSession: restoredSession),
      onboardingStorage: _FakeOnboardingLocalStorage(isCompleted: true),
      analyticsService: analyticsService,
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
    expect(analyticsService.hasEvent(AnalyticsEvents.historyOpened), true);
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

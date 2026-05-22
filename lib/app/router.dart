import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/paywall/presentation/pages/paywall_page.dart';
import '../features/resume/presentation/pages/resume_list_page.dart';
import '../features/resume/presentation/pages/resume_wizard_page.dart';
import '../features/resume/presentation/pages/resume_preview_page.dart';
import '../features/cover_letter/presentation/pages/cover_letter_form_page.dart';
import '../features/cover_letter/presentation/pages/cover_letter_result_page.dart';
import '../features/cover_letter/presentation/pages/job_cover_letter_page.dart';
import '../features/interview_prep/presentation/pages/interview_prep_form_page.dart';
import '../features/interview_prep/presentation/pages/interview_prep_questions_page.dart';
import '../features/interview_prep/domain/interview_question.dart';
import '../features/cv_upload/presentation/pages/cv_upload_page.dart';
import '../features/job_match/presentation/pages/job_match_page.dart';
import '../features/video_script/presentation/pages/video_script_form_page.dart';
import '../features/video_script/presentation/pages/video_script_result_page.dart';
import '../features/video_script/domain/video_script.dart';
import '../features/video/presentation/pages/teleprompter_page.dart';
import '../features/video/presentation/pages/video_list_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/about_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/chat/domain/chat_message.dart';
import '../features/skill_gap/presentation/pages/skill_gap_page.dart';
import '../features/mock_interview/presentation/pages/mock_interview_page.dart';
import '../features/networking/presentation/pages/networking_result_page.dart';
import '../features/ai_photo/presentation/pages/ai_photo_page.dart';
import '../features/ai_photo/presentation/pages/ai_photo_result_page.dart';
import '../features/paywall/presentation/pages/soft_paywall_page.dart';
import '../features/paywall/presentation/pages/congratulations_page.dart';
import '../features/job_plan/presentation/pages/job_plan_page.dart';
import '../services/subscription/subscription_provider.dart';
import 'shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final sub = ref.watch(subscriptionProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState != null;
      final loc = state.matchedLocation;
      final isOnAuth = loc == '/login';
      final isOnSplash = loc == '/';
      final isOnOnboarding = loc == '/onboarding';
      final isOnSoftPaywall = loc == '/soft-paywall';
      final isOnCongrats = loc == '/congratulations';

      if (isOnSplash || isOnOnboarding) return null;
      if (!isAuthenticated && !isOnAuth) return '/login';
      if (isAuthenticated && isOnAuth) return '/home';

      // After login, show soft paywall once if not yet seen
      if (isAuthenticated &&
          loc == '/home' &&
          !sub.softPaywallShown &&
          !isOnSoftPaywall &&
          !isOnCongrats) {
        return '/soft-paywall';
      }

      return null;
    },
    routes: [
      // ── Auth
      GoRoute(path: '/', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),

      // ── Shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomePage()),
          GoRoute(path: '/history', builder: (c, s) => const HistoryPage()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
        ],
      ),

      // ── Resume (full-screen, no bottom nav)
      GoRoute(path: '/resume', builder: (c, s) => const ResumeListPage()),
      GoRoute(
        path: '/resume/new',
        builder: (c, s) {
          final extra = s.extra;
          Map<String, dynamic>? prefill;
          if (extra is Map && extra['prefill'] is Map) {
            prefill = Map<String, dynamic>.from(extra['prefill'] as Map);
          }
          return ResumeWizardPage(resumeId: null, prefill: prefill);
        },
      ),
      GoRoute(
        path: '/resume/:id',
        builder: (c, s) {
          final id = s.pathParameters['id']!;
          final extra = s.extra;
          Map<String, dynamic>? prefill;
          if (extra is Map && extra['prefill'] is Map) {
            prefill = Map<String, dynamic>.from(extra['prefill'] as Map);
          }
          if (id == 'new') {
            return ResumeWizardPage(resumeId: null, prefill: prefill);
          }
          return ResumeWizardPage(resumeId: id, prefill: prefill);
        },
      ),
      GoRoute(
        path: '/resume/:id/preview',
        builder: (c, s) => ResumePreviewPage(
          resumeId: s.pathParameters['id']!,
          isTeaser:
              (s.extra as Map<String, dynamic>?)?['isTeaser'] as bool? ?? false,
        ),
      ),

      // ── Cover Letter
      GoRoute(
        path: '/cover-letter',
        builder: (c, s) {
          final extra = s.extra;
          Map<String, dynamic>? prefill;
          if (extra is Map && extra['prefill'] is Map) {
            prefill = Map<String, dynamic>.from(extra['prefill'] as Map);
          }
          return CoverLetterFormPage(prefill: prefill);
        },
      ),
      GoRoute(
        path: '/cover-letter/result',
        builder: (c, s) => CoverLetterResultPage(extra: s.extra),
      ),

      // ── Smart Cover Letter
      GoRoute(
        path: '/job-cover-letter',
        builder: (c, s) => const JobCoverLetterPage(),
      ),

      // ── Interview Prep
      GoRoute(
        path: '/interview-prep',
        builder: (c, s) {
          final extra = s.extra;
          Map<String, dynamic>? prefill;
          if (extra is Map && extra['prefill'] is Map) {
            prefill = Map<String, dynamic>.from(extra['prefill'] as Map);
          }
          return InterviewPrepFormPage(prefill: prefill);
        },
      ),
      GoRoute(
        path: '/interview-prep/questions',
        builder: (c, s) {
          // New format: Map {payload: List, isTeaser: bool}
          // Legacy format: bare List
          final extra = s.extra;
          List<Map<String, dynamic>> rawPayload;
          bool isTeaser = false;
          if (extra is Map) {
            rawPayload =
                (extra['payload'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            isTeaser = extra['isTeaser'] as bool? ?? false;
          } else {
            rawPayload = (extra as List?)?.cast<Map<String, dynamic>>() ?? [];
          }
          final questions = rawPayload.map(InterviewQuestion.fromMap).toList();
          return InterviewPrepQuestionsPage(
            questions: questions,
            isTeaser: isTeaser,
          );
        },
      ),

      // ── CV Upload
      GoRoute(path: '/cv-upload', builder: (c, s) => const CvUploadPage()),

      // ── Job Match
      GoRoute(path: '/job-match', builder: (c, s) => const JobMatchPage()),

      // ── Video Script
      GoRoute(
        path: '/video-script',
        builder: (c, s) => const VideoScriptFormPage(),
      ),
      GoRoute(
        path: '/video-script/result',
        builder: (c, s) {
          // New format: Map {script: VideoScript, isTeaser: bool}
          // Legacy format: bare VideoScript
          final extra = s.extra;
          VideoScript script;
          bool isTeaser = false;
          if (extra is Map) {
            script = extra['script'] as VideoScript;
            isTeaser = extra['isTeaser'] as bool? ?? false;
          } else {
            script = extra as VideoScript;
          }
          return VideoScriptResultPage(script: script, isTeaser: isTeaser);
        },
      ),

      // ── Teleprompter
      GoRoute(
        path: '/teleprompter',
        builder: (c, s) =>
            TeleprompterPage(scriptText: s.extra as String? ?? ''),
      ),

      // ── Video list
      GoRoute(path: '/videos', builder: (c, s) => const VideoListPage()),

      // ── Settings & About
      GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
      GoRoute(path: '/about', builder: (c, s) => const AboutPage()),

      // ── Chat (conversational AI)
      GoRoute(
        path: '/chat',
        builder: (c, s) =>
            ChatPage(initialFlow: s.extra as ChatFlow? ?? ChatFlow.none),
      ),

      // ── Paywall
      GoRoute(path: '/paywall', builder: (c, s) => const PaywallPage()),
      GoRoute(
        path: '/soft-paywall',
        builder: (c, s) => const SoftPaywallPage(),
      ),
      GoRoute(
        path: '/congratulations',
        builder: (c, s) => const CongratulationsPage(),
      ),

      // ── Skill Gap Analyzer
      GoRoute(
        path: '/skill-gap',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return SkillGapPage(
            jobDescription: extra['jobDescription'] as String? ?? '',
          );
        },
      ),

      // ── Mock Interview with AI Feedback
      GoRoute(
        path: '/mock-interview',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return MockInterviewPage(
            role: extra['role'] as String? ?? 'Software Engineer',
            seniority: extra['seniority'] as String? ?? 'Mid-level',
          );
        },
      ),

      // ── AI Photo Studio
      GoRoute(path: '/ai-photo', builder: (c, s) => const AiPhotoPage()),
      GoRoute(
        path: '/ai-photo/result',
        builder: (c, s) {
          final data = s.extra;
          if (data is PhotoResultData) {
            return AiPhotoResultPage(data: data);
          }
          // Safety fallback — navigate back if data is missing
          return const AiPhotoPage();
        },
      ),

      // ── Job Application Plan
      GoRoute(
        path: '/job-plan',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return JobPlanPage(
            jobDescription: extra['jobDescription'] as String? ?? '',
          );
        },
      ),

      // ── Networking Message Generator
      GoRoute(
        path: '/networking-result',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return NetworkingResultPage(
            messageType:
                extra['messageType'] as String? ?? 'Networking message',
            recipient: extra['recipient'] as String? ?? 'Recruiter',
            company: extra['company'] as String? ?? '',
            context: extra['context'] as String? ?? '',
            tone: extra['tone'] as String? ?? 'Professional',
          );
        },
      ),
    ],
  );
});

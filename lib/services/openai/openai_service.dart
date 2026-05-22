import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/interview_prep/domain/interview_question.dart';
import '../../features/resume/domain/resume.dart';
import '../ai/ai_router.dart';

/// Legacy service — now delegates to [AiRouter] which handles
/// provider selection, fallback chains, and API calls.
///
/// Kept for backwards compatibility with existing feature providers.
class OpenAiService {
  final AiRouter _router;

  OpenAiService(this._router);

  bool get hasKey => _router.hasAnyProvider;

  Future<String> generateCoverLetter({
    required String company,
    required String role,
    required String jobDescription,
  }) => _router.generateCoverLetter(
    company: company,
    role: role,
    jobDescription: jobDescription,
  );

  Future<List<InterviewQuestion>> generateInterviewQuestions({
    required String role,
    required String seniority,
  }) => _router.generateInterviewQuestions(role: role, seniority: seniority);

  Future<String> generateResumeSummary(Resume resume) =>
      _router.generateResumeSummary(resume);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final openAiServiceProvider = Provider<OpenAiService>((ref) {
  final router = ref.watch(aiRouterProvider);
  return OpenAiService(router);
});

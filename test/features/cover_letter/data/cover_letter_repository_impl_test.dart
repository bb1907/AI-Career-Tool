import 'package:flutter_test/flutter_test.dart';

import 'package:ai_career_tools/features/cover_letter/data/datasources/cover_letter_analysis_remote_datasource.dart';
import 'package:ai_career_tools/features/cover_letter/data/datasources/cover_letter_persistence_datasource.dart';
import 'package:ai_career_tools/features/cover_letter/data/datasources/cover_letter_remote_datasource.dart';
import 'package:ai_career_tools/features/cover_letter/data/models/cover_letter_result_model.dart';
import 'package:ai_career_tools/features/cover_letter/data/repositories/cover_letter_repository_impl.dart';
import 'package:ai_career_tools/features/cover_letter/domain/entities/cover_letter_candidate_context.dart';
import 'package:ai_career_tools/features/cover_letter/domain/entities/cover_letter_job_context.dart';
import 'package:ai_career_tools/features/cover_letter/domain/entities/cover_letter_request.dart';
import 'package:ai_career_tools/services/ai/ai_service.dart';
import 'package:ai_career_tools/services/ai/ai_task_request.dart';
import 'package:ai_career_tools/services/ai/ai_task_response.dart';
import 'package:ai_career_tools/services/ai/ai_task_type.dart';

void main() {
  test(
    'runs job fit analysis before cover letter generation when profile and job exist',
    () async {
      final aiService = _FakeAiService();
      final repository = CoverLetterRepositoryImpl(
        remoteDatasource: CoverLetterRemoteDatasource(aiService),
        analysisRemoteDatasource: CoverLetterAnalysisRemoteDatasource(
          aiService,
        ),
        persistenceDatasource: _FakeCoverLetterPersistenceDatasource(),
      );

      final result = await repository.generateCoverLetter(_requestWithContext);

      expect(result.coverLetter, contains('tailored cover letter'));
      expect(aiService.requests.map((request) => request.type), [
        AiTaskType.jobMatch,
        AiTaskType.coverLetterGenerate,
      ]);

      final generatedInput = aiService.requests.last.input;
      expect(generatedInput['fit_analysis'], isNotNull);
      expect(generatedInput['fit_analysis']['match_score'], 87);
      expect(
        generatedInput['fit_analysis']['positioning_summary'],
        contains('bridge product thinking'),
      );
    },
  );

  test('skips job fit analysis for manual cover letter generation', () async {
    final aiService = _FakeAiService();
    final repository = CoverLetterRepositoryImpl(
      remoteDatasource: CoverLetterRemoteDatasource(aiService),
      analysisRemoteDatasource: CoverLetterAnalysisRemoteDatasource(aiService),
      persistenceDatasource: _FakeCoverLetterPersistenceDatasource(),
    );

    await repository.generateCoverLetter(
      const CoverLetterRequest(
        companyName: 'Northstar',
        roleTitle: 'Product Designer',
        jobDescription: 'Own user journeys and collaborate with engineers.',
        userBackground: 'Product designer with 5 years of experience.',
        tone: 'Professional',
      ),
    );

    expect(aiService.requests.map((request) => request.type), [
      AiTaskType.coverLetterGenerate,
    ]);
  });
}

class _FakeAiService implements AiService {
  final List<AiTaskRequest> requests = <AiTaskRequest>[];

  @override
  Future<AiTaskResponse> execute(AiTaskRequest request) async {
    requests.add(request);

    switch (request.type) {
      case AiTaskType.jobMatch:
        return const AiTaskResponse(
          type: AiTaskType.jobMatch,
          requestId: 'job_match_1',
          output: {
            'match_score': 87,
            'missing_skills': ['Kubernetes'],
            'strengths': ['Flutter leadership', 'Cross-functional delivery'],
            'positioning_summary':
                'Position the candidate as someone who can bridge product thinking with technical execution.',
          },
        );
      case AiTaskType.coverLetterGenerate:
        return const AiTaskResponse(
          type: AiTaskType.coverLetterGenerate,
          requestId: 'cover_letter_1',
          output: {
            'cover_letter':
                'This is a tailored cover letter grounded in the selected role and candidate profile.',
          },
        );
      case AiTaskType.resumeGenerate:
      case AiTaskType.interviewGenerate:
      case AiTaskType.cvParse:
      case AiTaskType.videoIntroductionGenerate:
        throw UnimplementedError();
    }
  }
}

class _FakeCoverLetterPersistenceDatasource
    implements CoverLetterPersistenceDatasource {
  @override
  Future<List<CoverLetterResultModel>> fetchHistory() async {
    return const <CoverLetterResultModel>[];
  }

  @override
  Future<void> save(CoverLetterResultModel result) async {}
}

const _requestWithContext = CoverLetterRequest(
  companyName: 'Atlas',
  roleTitle: 'Senior Flutter Engineer',
  jobDescription:
      'Lead the mobile platform, ship polished user experiences, and mentor other engineers.',
  userBackground:
      'Senior Flutter engineer with experience owning release quality and platform architecture.',
  tone: 'Professional',
  candidateContext: CoverLetterCandidateContext(
    name: 'Annie Case',
    email: 'annie@example.com',
    location: 'Berlin',
    yearsExperience: 6,
    roles: ['Senior Flutter Engineer', 'Mobile Engineer'],
    skills: ['Flutter', 'Dart', 'CI/CD'],
    industries: ['SaaS'],
    seniority: 'Senior',
    education: 'B.Sc. in Computer Science',
  ),
  jobContext: CoverLetterJobContext(
    jobId: 'job_123',
    title: 'Senior Flutter Engineer',
    company: 'Atlas',
    location: 'Remote',
    source: 'Seeded',
    url: 'https://example.com/jobs/123',
    jobDescription:
        'Lead the mobile platform, ship polished user experiences, and mentor other engineers.',
  ),
);

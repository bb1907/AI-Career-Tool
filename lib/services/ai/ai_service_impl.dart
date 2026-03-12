import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import 'ai_service.dart';
import 'ai_task_request.dart';
import 'ai_task_response.dart';
import 'ai_task_type.dart';
import 'json_parser.dart';
import 'prompt_builder.dart';

class AiServiceImpl implements AiService {
  const AiServiceImpl({this.apiClient = const ApiClient()});

  static const _endpoint = '/v1/ai/tasks';

  final ApiClient apiClient;

  @override
  Future<AiTaskResponse> execute(AiTaskRequest request) async {
    final result = await apiClient.guard(() => _executeUnsafe(request));

    return result.when(
      success: (response) => response,
      failure: (failure) => throw AppException(failure.message),
    );
  }

  Future<AiTaskResponse> _executeUnsafe(AiTaskRequest request) async {
    try {
      final backendPayload = PromptBuilder.buildBackendPayload(request);
      final rawResponse = await _postTask(
        backendPayload,
        taskType: request.type,
      );
      return JsonParser.parseAiTaskResponse(
        rawResponse,
        expectedType: request.type,
      );
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const AppException('The AI service timed out. Try again.');
    } on SocketException {
      throw const AppException(
        'Could not reach the AI service. Check your connection and try again.',
      );
    } on FormatException {
      throw const AppException('The AI response could not be parsed.');
    } catch (_) {
      throw const AppException('The AI service is temporarily unavailable.');
    }
  }

  Future<String> _postTask(
    Map<String, dynamic> payload, {
    required AiTaskType taskType,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final response = <String, dynamic>{
      'request_id': 'ai_${DateTime.now().microsecondsSinceEpoch}',
      'task': taskType.value,
      'model': 'placeholder-career-orchestrator-v1',
      'output': _buildPlaceholderOutput(taskType, payload['input']),
      'meta': {'endpoint': _endpoint, 'prompt_version': 1},
    };

    return jsonEncode(response);
  }

  Map<String, dynamic> _buildPlaceholderOutput(AiTaskType type, Object? input) {
    final normalizedInput = input is Map<String, dynamic>
        ? input
        : const <String, dynamic>{};

    return switch (type) {
      AiTaskType.resumeGenerate => _buildResumeOutput(normalizedInput),
      AiTaskType.coverLetterGenerate => _buildCoverLetterOutput(
        normalizedInput,
      ),
      AiTaskType.interviewGenerate => _buildInterviewOutput(normalizedInput),
      AiTaskType.cvParse => _buildCvParseOutput(normalizedInput),
      AiTaskType.jobMatch => <String, dynamic>{
        'score': 0.78,
        'strengths': <String>['Relevant role alignment', 'Transferable skills'],
        'gaps': <String>['Add more quantified achievements'],
      },
    };
  }

  Map<String, dynamic> _buildResumeOutput(Map<String, dynamic> input) {
    final targetRole =
        JsonParser.readOptionalString(input, 'target_role') ?? 'Candidate';
    final years =
        JsonParser.readOptionalInt(input, 'years_of_experience')?.toString() ??
        '0';
    final roles = JsonParser.readStringList(
      input,
      'past_roles',
      fallback: const <String>['multiple roles'],
    );
    final skills = JsonParser.readStringList(
      input,
      'top_skills',
      fallback: const <String>['problem solving'],
    );
    final achievements = JsonParser.readStringList(
      input,
      'achievements',
      fallback: const <String>['delivered measurable outcomes'],
    );
    final education =
        JsonParser.readOptionalString(input, 'education') ??
        'Education details not provided';
    final tone =
        JsonParser.readOptionalString(input, 'preferred_tone')?.toLowerCase() ??
        'professional';

    return <String, dynamic>{
      'summary':
          '$targetRole with $years years of experience across ${roles.take(2).join(' and ')}. Delivers ATS-friendly, $tone resume content by connecting ${skills.take(4).join(', ')} to measurable outcomes such as ${achievements.first}.',
      'experience_bullets': <String>[
        'Built role-specific impact stories for ${targetRole.toLowerCase()} applications by translating ${achievements.first} into concise, metric-aware bullets.',
        'Positioned ${skills.first} and ${skills[1 % skills.length]} as repeat strengths across ${roles.first.toLowerCase()} and adjacent ownership areas.',
        'Reframed ${achievements.length > 1 ? achievements[1] : achievements.first} to emphasize scope, collaboration, and execution quality for ATS screening.',
        'Aligned professional narrative with ${targetRole.toLowerCase()} expectations using $tone language, modern keywords, and clean resume structure.',
      ],
      'skills': skills.take(8).toList(growable: false),
      'education': education,
    };
  }

  Map<String, dynamic> _buildCoverLetterOutput(Map<String, dynamic> input) {
    final companyName =
        JsonParser.readOptionalString(input, 'company_name') ?? 'the company';
    final roleTitle =
        JsonParser.readOptionalString(input, 'role_title') ?? 'the role';
    final jobDescription =
        JsonParser.readOptionalString(input, 'job_description') ??
        'the position requirements';
    final userBackground =
        JsonParser.readOptionalString(input, 'user_background') ??
        'a relevant professional background';
    final tone =
        JsonParser.readOptionalString(input, 'tone')?.toLowerCase() ??
        'professional';

    final coverLetter =
        '''
Dear Hiring Team at $companyName,

I am excited to apply for the $roleTitle role. What stands out most about this opportunity is the emphasis on $jobDescription, which closely aligns with my background and the kind of work I want to keep building on.

Across my experience, I have developed $userBackground. That background has taught me how to turn context into clear execution, collaborate across functions, and communicate value in a way that is both practical and outcome-focused.

I would bring a $tone voice, strong ownership, and a clear commitment to helping $companyName move faster on the priorities behind this role. I would welcome the opportunity to discuss how my experience can support your team.

Sincerely,
[Your Name]
'''
            .trim();

    return <String, dynamic>{'cover_letter': coverLetter};
  }

  Map<String, dynamic> _buildInterviewOutput(Map<String, dynamic> input) {
    final roleName =
        JsonParser.readOptionalString(input, 'role_name') ?? 'the role';
    final seniority =
        JsonParser.readOptionalString(input, 'seniority') ?? 'Senior';
    final companyType =
        JsonParser.readOptionalString(input, 'company_type') ?? 'Startup';
    final interviewType =
        JsonParser.readOptionalString(input, 'interview_type') ?? 'Mixed';
    final focusAreas = JsonParser.readStringList(
      input,
      'focus_areas',
      fallback: const <String>['Execution', 'Communication', 'Strategy'],
    );
    final safeFocusAreas = focusAreas.isEmpty
        ? const <String>['Execution', 'Communication', 'Strategy']
        : focusAreas;

    final technicalQuestions = <Map<String, dynamic>>[
      <String, dynamic>{
        'question':
            'How would you approach a ${safeFocusAreas.first.toLowerCase()} challenge as a $seniority $roleName in a $companyType environment?',
        'sample_answer':
            'I would begin by clarifying the business goal, constraints and success metrics, then break the problem into smaller workstreams. From there I would prioritize the highest-leverage experiments, align stakeholders on tradeoffs and iterate based on measurable outcomes.',
      },
      <String, dynamic>{
        'question':
            'What framework would you use to evaluate success for a $roleName interview focused on ${safeFocusAreas.first.toLowerCase()} and ${safeFocusAreas[1 % safeFocusAreas.length].toLowerCase()}?',
        'sample_answer':
            'I would define the decision criteria first, including user impact, business value, implementation complexity and time-to-learn. Then I would explain how I use those criteria to compare options, make tradeoffs explicit and choose a path that balances speed with quality.',
      },
    ];

    final behavioralQuestions = <Map<String, dynamic>>[
      <String, dynamic>{
        'question':
            'Tell me about a time you had to influence stakeholders while working on ${safeFocusAreas.first.toLowerCase()}.',
        'sample_answer':
            'I would answer this with a concise STAR structure: the context, the conflicting priorities, the actions I took to align the team and the measurable result. I would emphasize how I listened to concerns, reframed the decision around shared goals and kept momentum without creating friction.',
      },
      <String, dynamic>{
        'question':
            'Describe a difficult interview scenario you might face in a $interviewType round for a $roleName role.',
        'sample_answer':
            'I would describe a case where the requirements were ambiguous or expectations changed mid-process. My answer would focus on how I stayed calm, clarified assumptions, communicated tradeoffs and adapted quickly while still driving toward a strong outcome.',
      },
    ];

    return <String, dynamic>{
      'technical_questions': technicalQuestions,
      'behavioral_questions': behavioralQuestions,
    };
  }

  Map<String, dynamic> _buildCvParseOutput(Map<String, dynamic> input) {
    final cvText = JsonParser.readOptionalString(input, 'cv_text') ?? '';
    final lines = cvText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final email =
        RegExp(
          r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
          caseSensitive: false,
        ).firstMatch(cvText)?.group(0) ??
        '';
    final years = RegExp(
      r'(\d{1,2})\+?\s+years',
      caseSensitive: false,
    ).firstMatch(cvText)?.group(1);
    final skillsLine = _extractLabeledLine(cvText, 'skills');
    final educationLine = _extractLabeledLine(cvText, 'education');
    final locationLine =
        _extractLabeledLine(cvText, 'location') ??
        lines
            .skip(1)
            .firstWhere(
              (line) => line.contains(',') && !line.contains('@'),
              orElse: () => '',
            );
    final roles = _extractRoleCandidates(cvText);
    final skills = _extractCsvEntries(skillsLine).isEmpty
        ? _extractKeywordCandidates(cvText, const <String>[
            'Flutter',
            'Dart',
            'Figma',
            'Product design',
            'User research',
            'Design systems',
            'SQL',
            'Python',
            'Project management',
          ])
        : _extractCsvEntries(skillsLine);
    final industries = _extractKeywordCandidates(cvText, const <String>[
      'SaaS',
      'Fintech',
      'E-commerce',
      'Healthtech',
      'Edtech',
      'B2B',
      'Consumer',
    ]);
    final yearsExperience = int.tryParse(years ?? '') ?? 0;
    final seniority = yearsExperience >= 8
        ? 'Lead'
        : yearsExperience >= 5
        ? 'Senior'
        : yearsExperience >= 2
        ? 'Mid-level'
        : 'Junior';

    return <String, dynamic>{
      'name': lines.isNotEmpty ? lines.first : 'Candidate',
      'email': email,
      'location': locationLine,
      'years_experience': yearsExperience,
      'roles': roles.isEmpty ? const <String>['Candidate'] : roles,
      'skills': skills.isEmpty ? const <String>['Communication'] : skills,
      'industries': industries,
      'seniority': seniority,
      'education': educationLine ?? 'Not provided',
    };
  }

  String? _extractLabeledLine(String source, String label) {
    final pattern = RegExp(
      '$label\\s*[:|-]\\s*(.+)',
      caseSensitive: false,
      multiLine: true,
    );

    return pattern.firstMatch(source)?.group(1)?.trim();
  }

  List<String> _extractCsvEntries(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const <String>[];
    }

    return value
        .split(RegExp(r',|\u2022|;'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _extractKeywordCandidates(String source, List<String> keywords) {
    final lowerSource = source.toLowerCase();

    return keywords
        .where((keyword) => lowerSource.contains(keyword.toLowerCase()))
        .toList(growable: false);
  }

  List<String> _extractRoleCandidates(String source) {
    return _extractKeywordCandidates(source, const <String>[
      'Software Engineer',
      'Mobile Engineer',
      'Product Designer',
      'Product Manager',
      'UX Designer',
      'Data Analyst',
      'Marketing Manager',
    ]);
  }
}

final aiServiceProvider = Provider<AiService>((ref) => const AiServiceImpl());

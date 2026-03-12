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
      AiTaskType.interviewGenerate => <String, dynamic>{
        'questions': <String>[
          'Tell me about yourself.',
          'Describe a recent high-impact project.',
        ],
        'focus_areas': <String>['Clarity', 'Metrics', 'Leadership'],
      },
      AiTaskType.cvParse => <String, dynamic>{
        'full_name':
            JsonParser.readOptionalString(normalizedInput, 'full_name') ??
            'Candidate',
        'skills': JsonParser.readStringList(normalizedInput, 'skills'),
      },
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
}

final aiServiceProvider = Provider<AiService>((ref) => const AiServiceImpl());

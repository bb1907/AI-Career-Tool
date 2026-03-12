import 'dart:convert';

import 'ai_task_request.dart';
import 'ai_task_type.dart';

abstract final class PromptBuilder {
  static String buildSystemPrompt(AiTaskType type) {
    return switch (type) {
      AiTaskType.resumeGenerate =>
        'You are an ATS-focused career assistant that writes crisp, metric-aware resume content.',
      AiTaskType.coverLetterGenerate =>
        'You are a career assistant that writes tailored cover letters with clear positioning and concise structure.',
      AiTaskType.interviewGenerate =>
        'You are an interview coach that produces focused practice questions and strong answer frameworks.',
      AiTaskType.cvParse =>
        'You extract structured candidate data from CV text and return valid JSON only.',
      AiTaskType.jobMatch =>
        'You compare a candidate profile to a target job and return structured fit analysis in valid JSON.',
    };
  }

  static String buildUserPrompt(AiTaskRequest request) {
    if (request.type == AiTaskType.resumeGenerate) {
      return '''
Target role: ${request.input['target_role'] ?? ''}
Years of experience: ${request.input['years_of_experience'] ?? ''}
Past roles: ${_joinList(request.input['past_roles'])}
Top skills: ${_joinList(request.input['top_skills'])}
Achievements: ${_joinList(request.input['achievements'])}
Education: ${request.input['education'] ?? ''}
Preferred tone: ${request.input['preferred_tone'] ?? ''}
'''
          .trim();
    }

    return jsonEncode(request.input);
  }

  static Map<String, dynamic> buildBackendPayload(AiTaskRequest request) {
    return {
      ...request.toJson(),
      'prompt': {
        'system': buildSystemPrompt(request.type),
        'user': buildUserPrompt(request),
      },
    };
  }

  static String _joinList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).join(', ');
    }

    return value?.toString() ?? '';
  }
}

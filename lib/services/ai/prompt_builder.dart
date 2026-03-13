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

    if (request.type == AiTaskType.coverLetterGenerate) {
      final candidateProfile =
          request.input['candidate_profile'] as Map<String, dynamic>?;
      final selectedJob =
          request.input['selected_job'] as Map<String, dynamic>?;
      final clarifyingContext =
          request.input['clarifying_context'] as Map<String, dynamic>?;

      return '''
Company name: ${request.input['company_name'] ?? ''}
Role title: ${request.input['role_title'] ?? ''}
Job description: ${request.input['job_description'] ?? ''}
User background: ${request.input['user_background'] ?? ''}
Tone: ${request.input['tone'] ?? ''}
Candidate profile name: ${candidateProfile?['name'] ?? ''}
Candidate profile email: ${candidateProfile?['email'] ?? ''}
Candidate profile location: ${candidateProfile?['location'] ?? ''}
Candidate profile years of experience: ${candidateProfile?['years_experience'] ?? ''}
Candidate profile roles: ${_joinList(candidateProfile?['roles'])}
Candidate profile skills: ${_joinList(candidateProfile?['skills'])}
Candidate profile industries: ${_joinList(candidateProfile?['industries'])}
Candidate profile seniority: ${candidateProfile?['seniority'] ?? ''}
Candidate profile education: ${candidateProfile?['education'] ?? ''}
Selected job source: ${selectedJob?['source'] ?? ''}
Selected job url: ${selectedJob?['url'] ?? ''}
Selected job location: ${selectedJob?['location'] ?? ''}
Selected job title: ${selectedJob?['title'] ?? ''}
Selected job company: ${selectedJob?['company'] ?? ''}
Clarifying answer - why this company: ${clarifyingContext?['why_this_company'] ?? ''}
Clarifying answer - key achievement: ${clarifyingContext?['key_achievement'] ?? ''}
Clarifying answer - emphasis notes: ${clarifyingContext?['emphasis_notes'] ?? ''}
'''
          .trim();
    }

    if (request.type == AiTaskType.interviewGenerate) {
      return '''
Role name: ${request.input['role_name'] ?? ''}
Seniority: ${request.input['seniority'] ?? ''}
Company type: ${request.input['company_type'] ?? ''}
Interview type: ${request.input['interview_type'] ?? ''}
Focus areas: ${_joinList(request.input['focus_areas'])}
'''
          .trim();
    }

    if (request.type == AiTaskType.cvParse) {
      return '''
File name: ${request.input['file_name'] ?? ''}
Extracted CV text:
${request.input['cv_text'] ?? ''}
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

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_career_tools/core/errors/app_exception.dart';
import 'package:ai_career_tools/services/ai/ai_task_type.dart';
import 'package:ai_career_tools/services/ai/json_parser.dart';

void main() {
  test('parses a valid resume response envelope', () {
    final response = JsonParser.parseAiTaskResponse('''
      {
        "request_id": "req_123",
        "task": "resume_generate",
        "model": "career-model-v1",
        "output": {
          "summary": "Senior mobile engineer with strong ATS-ready positioning.",
          "experience_bullets": ["Improved release stability by 20%."],
          "skills": ["Flutter", "Dart"],
          "education": "B.S. in Computer Engineering"
        }
      }
      ''', expectedType: AiTaskType.resumeGenerate);

    expect(response.requestId, 'req_123');
    expect(response.type, AiTaskType.resumeGenerate);
    expect(response.output['summary'], contains('Senior mobile engineer'));
  });

  test('throws AppException for invalid interview question structure', () {
    expect(
      () => JsonParser.parseAiTaskResponse('''
        {
          "request_id": "req_456",
          "task": "interview_generate",
          "output": {
            "technical_questions": [{"question": "How do you scale Flutter?"}],
            "behavioral_questions": []
          }
        }
        ''', expectedType: AiTaskType.interviewGenerate),
      throwsA(isA<AppException>()),
    );
  });

  test('throws AppException when task does not match expected type', () {
    expect(
      () => JsonParser.parseAiTaskResponse('''
        {
          "request_id": "req_789",
          "task": "cover_letter_generate",
          "output": {"cover_letter": "Draft"}
        }
        ''', expectedType: AiTaskType.resumeGenerate),
      throwsA(isA<AppException>()),
    );
  });

  test('parses a valid job match response envelope', () {
    final response = JsonParser.parseAiTaskResponse('''
      {
        "request_id": "req_match_123",
        "task": "job_match",
        "output": {
          "match_score": 82,
          "missing_skills": ["Kubernetes"],
          "strengths": ["Flutter architecture", "Product mindset"],
          "positioning_summary": "Lead with mobile platform ownership and delivery impact."
        }
      }
      ''', expectedType: AiTaskType.jobMatch);

    expect(response.type, AiTaskType.jobMatch);
    expect(response.output['match_score'], 82);
    expect(response.output['missing_skills'], ['Kubernetes']);
    expect(
      response.output['positioning_summary'],
      contains('mobile platform ownership'),
    );
  });

  test('parses a valid video introduction response envelope', () {
    final response = JsonParser.parseAiTaskResponse('''
      {
        "request_id": "req_video_123",
        "task": "video_introduction_generate",
        "output": {
          "script": "Hi, I am Annie. I am a senior Flutter engineer with six years of experience building reliable mobile products.",
          "duration": "60 sec"
        }
      }
      ''', expectedType: AiTaskType.videoIntroductionGenerate);

    expect(response.type, AiTaskType.videoIntroductionGenerate);
    expect(response.output['duration'], '60 sec');
    expect(response.output['script'], contains('senior Flutter engineer'));
  });
}

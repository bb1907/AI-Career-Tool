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
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ai_career_tools/core/errors/app_exception.dart';
import 'package:ai_career_tools/core/network/api_client.dart';
import 'package:ai_career_tools/services/ai/ai_service_impl.dart';
import 'package:ai_career_tools/services/ai/ai_task_request.dart';
import 'package:ai_career_tools/services/ai/ai_task_type.dart';

class _QueuedApiClient extends ApiClient {
  _QueuedApiClient(this._queue);

  final List<Object> _queue;
  int attempts = 0;

  @override
  Future<String> postJson(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, String> headers = const <String, String>{},
    Duration timeout = const Duration(seconds: 30),
  }) async {
    attempts += 1;
    final next = _queue.removeAt(0);

    if (next is Exception) {
      throw next;
    }

    if (next is Error) {
      throw next;
    }

    return next as String;
  }
}

void main() {
  const testRequest = AiTaskRequest(
    type: AiTaskType.resumeGenerate,
    input: <String, dynamic>{
      'target_role': 'Senior Mobile Engineer',
      'years_of_experience': 6,
      'past_roles': <String>['Flutter Engineer'],
      'top_skills': <String>['Flutter', 'Dart'],
      'achievements': <String>['Reduced crash rate by 32%'],
      'education': 'B.S. in Computer Engineering',
      'preferred_tone': 'Professional',
    },
  );

  SupabaseClient createClient() {
    return SupabaseClient('https://example.com', 'anon-key');
  }

  test('retries transient timeout errors before succeeding', () async {
    final apiClient = _QueuedApiClient([
      TimeoutException('Request timed out'),
      '''
      {
        "request_id": "req_retry_success",
        "task": "resume_generate",
        "output": {
          "summary": "Senior mobile engineer profile",
          "experience_bullets": ["Improved release confidence by 20%."],
          "skills": ["Flutter", "Dart"],
          "education": "B.S. in Computer Engineering"
        }
      }
      ''',
    ]);

    final service = AiServiceImpl(
      apiClient: apiClient,
      supabaseClient: createClient(),
      backendBaseUrl: 'https://example.com',
    );

    final response = await service.execute(testRequest);

    expect(apiClient.attempts, 2);
    expect(response.requestId, 'req_retry_success');
    expect(response.output['summary'], 'Senior mobile engineer profile');
  });

  test('throws a safe fallback error for empty AI responses', () async {
    final apiClient = _QueuedApiClient(['']);
    final service = AiServiceImpl(
      apiClient: apiClient,
      supabaseClient: createClient(),
      backendBaseUrl: 'https://example.com',
    );

    await expectLater(
      () => service.execute(testRequest),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          contains('empty'),
        ),
      ),
    );

    expect(apiClient.attempts, 1);
  });

  test('does not retry malformed JSON responses', () async {
    final apiClient = _QueuedApiClient(['{"task":"resume_generate"']);
    final service = AiServiceImpl(
      apiClient: apiClient,
      supabaseClient: createClient(),
      backendBaseUrl: 'https://example.com',
    );

    await expectLater(
      () => service.execute(testRequest),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          contains('valid JSON'),
        ),
      ),
    );

    expect(apiClient.attempts, 1);
  });
}

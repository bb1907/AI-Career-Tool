import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/constants.dart';
import '../../core/config/env.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../supabase/supabase_client_provider.dart';
import 'ai_service.dart';
import 'ai_task_request.dart';
import 'ai_task_response.dart';
import 'ai_task_type.dart';
import 'json_parser.dart';
import 'prompt_builder.dart';

class AiServiceImpl implements AiService {
  AiServiceImpl({
    this.apiClient = const ApiClient(),
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final ApiClient apiClient;
  final SupabaseClient _supabaseClient;

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
      final enrichedRequest = _enrichRequest(request);
      final backendPayload = PromptBuilder.buildBackendPayload(enrichedRequest);
      final rawResponse = await apiClient.postJson(
        _buildEndpointUri(),
        body: backendPayload,
        headers: _buildHeaders(enrichedRequest),
        timeout: AppConstants.aiRequestTimeout,
      );

      return JsonParser.parseAiTaskResponse(
        rawResponse,
        expectedType: request.type,
      );
    } on HttpException {
      throw const AppException('The AI service returned an invalid response.');
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

  AiTaskRequest _enrichRequest(AiTaskRequest request) {
    return AiTaskRequest(
      type: request.type,
      input: request.input,
      userId: request.userId ?? _supabaseClient.auth.currentUser?.id,
      locale: request.locale,
      traceId:
          request.traceId ??
          'ai_${request.type.value}_${DateTime.now().microsecondsSinceEpoch}',
      metadata: request.metadata,
    );
  }

  Uri _buildEndpointUri() {
    final backendUrl = Env.requireAiBackendUrl();

    try {
      final baseUri = Uri.parse(backendUrl);
      return baseUri.replace(
        path: _joinPaths(baseUri.path, AppConstants.aiTasksEndpointPath),
      );
    } on FormatException {
      throw const AppException(
        'AI backend config is invalid. Check AI_BACKEND_URL.',
      );
    }
  }

  Map<String, String> _buildHeaders(AiTaskRequest request) {
    final headers = <String, String>{
      'X-AI-Task-Type': request.type.value,
      if (request.traceId != null) 'X-Trace-Id': request.traceId!,
    };

    final accessToken = _supabaseClient.auth.currentSession?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    }

    return headers;
  }

  String _joinPaths(String basePath, String suffixPath) {
    final trimmedBase = basePath.replaceAll(RegExp(r'/$'), '');
    final trimmedSuffix = suffixPath.replaceFirst(RegExp(r'^/'), '');

    if (trimmedBase.isEmpty) {
      return '/$trimmedSuffix';
    }

    return '$trimmedBase/$trimmedSuffix';
  }
}

final aiServiceProvider = Provider<AiService>(
  (ref) => AiServiceImpl(supabaseClient: ref.watch(supabaseClientProvider)),
);

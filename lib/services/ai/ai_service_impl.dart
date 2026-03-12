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
    String? backendBaseUrl,
  }) : _supabaseClient = supabaseClient,
       _backendBaseUrl = backendBaseUrl;

  final ApiClient apiClient;
  final SupabaseClient _supabaseClient;
  final String? _backendBaseUrl;

  @override
  Future<AiTaskResponse> execute(AiTaskRequest request) async {
    final result = await apiClient.guard(() => _executeUnsafe(request));

    return result.when(
      success: (response) => response,
      failure: (failure) => throw AppException(failure.message),
    );
  }

  Future<AiTaskResponse> _executeUnsafe(AiTaskRequest request) async {
    final enrichedRequest = _enrichRequest(request);
    final backendPayload = PromptBuilder.buildBackendPayload(enrichedRequest);
    final endpointUri = _buildEndpointUri();
    AppException? lastRetryableError;

    for (var attempt = 1; attempt <= AppConstants.aiMaxAttempts; attempt++) {
      try {
        final rawResponse = await apiClient.postJson(
          endpointUri,
          body: backendPayload,
          headers: _buildHeaders(enrichedRequest),
          timeout: AppConstants.aiRequestTimeout,
        );

        return JsonParser.parseAiTaskResponse(
          rawResponse,
          expectedType: request.type,
        );
      } catch (error) {
        final normalizedError = _normalizeError(error);
        if (!_shouldRetry(normalizedError, attempt)) {
          throw normalizedError;
        }

        lastRetryableError = normalizedError;
        await Future<void>.delayed(_retryDelay(attempt));
      }
    }

    throw lastRetryableError ??
        const AppException('The AI service is temporarily unavailable.');
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
    final backendUrl = _backendBaseUrl?.trim().isNotEmpty == true
        ? _backendBaseUrl!.trim()
        : Env.requireAiBackendUrl();

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

  AppException _normalizeError(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is TimeoutException) {
      return const AppException(
        'The AI service timed out. Try again.',
        code: 'ai_timeout',
        isRetryable: true,
      );
    }

    if (error is SocketException) {
      return const AppException(
        'Could not reach the AI service. Check your connection and try again.',
        code: 'ai_network_unreachable',
        isRetryable: true,
      );
    }

    if (error is HandshakeException) {
      return const AppException(
        'Could not establish a secure connection to the AI service.',
        code: 'ai_tls_error',
        isRetryable: true,
      );
    }

    if (error is HttpException) {
      return const AppException(
        'The AI service returned an invalid response.',
        code: 'ai_http_error',
        isRetryable: true,
      );
    }

    if (error is FormatException) {
      return const AppException(
        'The AI response could not be parsed.',
        code: 'ai_invalid_json',
      );
    }

    return const AppException(
      'The AI service is temporarily unavailable.',
      code: 'ai_unexpected_error',
    );
  }

  bool _shouldRetry(AppException error, int attempt) {
    return error.isRetryable && attempt < AppConstants.aiMaxAttempts;
  }

  Duration _retryDelay(int attempt) {
    final multiplier = attempt <= 1 ? 1 : 1 << (attempt - 1);
    return Duration(
      milliseconds: AppConstants.aiRetryBaseDelay.inMilliseconds * multiplier,
    );
  }
}

final aiServiceProvider = Provider<AiService>(
  (ref) => AiServiceImpl(supabaseClient: ref.watch(supabaseClientProvider)),
);

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../errors/app_exception.dart';
import '../errors/failure.dart';
import 'result.dart';

class ApiClient {
  const ApiClient();

  Future<Result<T>> guard<T>(Future<T> Function() request) async {
    try {
      return Success<T>(await request());
    } on AppException catch (error) {
      return Error<T>(Failure(error.message, cause: error));
    } catch (error) {
      return Error<T>(Failure('Unexpected network failure.', cause: error));
    }
  }

  Future<String> postJson(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, String> headers = const <String, String>{},
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri).timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }

      request.write(jsonEncode(body));

      final response = await request.close().timeout(timeout);
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      }

      throw _mapHttpError(response.statusCode, responseBody);
    } on HandshakeException {
      throw const AppException(
        'Could not establish a secure connection to the AI service.',
      );
    } finally {
      client.close(force: true);
    }
  }

  AppException _mapHttpError(int statusCode, String responseBody) {
    final backendMessage = _extractErrorMessage(responseBody);

    return switch (statusCode) {
      400 => AppException(
        backendMessage ??
            'The AI request was rejected. Review the input and try again.',
      ),
      401 || 403 => AppException(
        backendMessage ?? 'The AI request was not authorized.',
      ),
      404 => AppException(
        backendMessage ?? 'The AI endpoint could not be reached.',
      ),
      408 || 504 => AppException(
        backendMessage ?? 'The AI service timed out. Try again.',
      ),
      409 => AppException(
        backendMessage ??
            'The AI service could not complete the request right now.',
      ),
      422 => AppException(
        backendMessage ?? 'The AI response format was invalid.',
      ),
      429 => AppException(
        backendMessage ??
            'The AI service is busy right now. Please try again shortly.',
      ),
      >= 500 => AppException(
        backendMessage ?? 'The AI service is temporarily unavailable.',
      ),
      _ => AppException(
        backendMessage ?? 'The AI request failed unexpectedly.',
      ),
    };
  }

  String? _extractErrorMessage(String responseBody) {
    final normalizedBody = responseBody.trim();
    if (normalizedBody.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(normalizedBody);
      if (decoded is Map<String, dynamic>) {
        final nestedError = decoded['error'];
        if (nestedError is Map<String, dynamic>) {
          final nestedMessage = nestedError['message']?.toString().trim();
          if (nestedMessage != null && nestedMessage.isNotEmpty) {
            return nestedMessage;
          }
        }

        final directMessage = decoded['message']?.toString().trim();
        if (directMessage != null && directMessage.isNotEmpty) {
          return directMessage;
        }

        final directError = decoded['error']?.toString().trim();
        if (directError != null && directError.isNotEmpty) {
          return directError;
        }
      }
    } catch (_) {
      if (normalizedBody.length <= 240) {
        return normalizedBody;
      }
    }

    return null;
  }
}

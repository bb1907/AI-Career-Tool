import 'dart:convert';

import '../../core/errors/app_exception.dart';
import 'ai_task_response.dart';
import 'ai_task_type.dart';

abstract final class JsonParser {
  static Map<String, dynamic> decodeObject(
    String source, {
    String context = 'response',
  }) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw FormatException('Expected a JSON object for $context.');
    } on FormatException {
      throw AppException('The AI $context was not valid JSON.');
    }
  }

  static AiTaskResponse parseAiTaskResponse(
    String source, {
    required AiTaskType expectedType,
  }) {
    final payload = decodeObject(source, context: 'response');
    final taskValue = readString(payload, 'task');
    final responseType = AiTaskTypeX.fromValue(taskValue);

    if (responseType != expectedType) {
      throw const AppException(
        'The AI response did not match the requested task.',
      );
    }

    return AiTaskResponse(
      type: responseType,
      requestId: readString(payload, 'request_id'),
      model: readOptionalString(payload, 'model'),
      output: readMap(payload, 'output'),
      raw: payload,
    );
  }

  static Map<String, dynamic> readMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw AppException(
      'The AI response field "$key" had an invalid structure.',
    );
  }

  static String readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    throw AppException('The AI response field "$key" was missing.');
  }

  static String? readOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }

    if (value is String) {
      final normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }

    return value.toString();
  }

  static int? readOptionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static List<String> readStringList(
    Map<String, dynamic> json,
    String key, {
    List<String> fallback = const <String>[],
  }) {
    final value = json[key];
    if (value == null) {
      return fallback;
    }

    if (value is! List) {
      throw AppException('The AI response field "$key" must be a list.');
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

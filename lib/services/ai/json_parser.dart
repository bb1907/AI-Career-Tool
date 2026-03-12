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
    final envelope = readNestedMap(payload, 'data') ?? payload;
    final taskValue =
        readOptionalString(envelope, 'task') ??
        readOptionalString(envelope, 'type');

    if (taskValue == null) {
      throw const AppException(
        'The AI response did not include a task identifier.',
      );
    }

    final responseType = AiTaskTypeX.fromValue(taskValue);

    if (responseType != expectedType) {
      throw const AppException(
        'The AI response did not match the requested task.',
      );
    }

    final output = readMap(envelope, 'output');
    validateTaskOutput(output, type: responseType);

    return AiTaskResponse(
      type: responseType,
      requestId:
          readOptionalString(envelope, 'request_id') ??
          readOptionalString(envelope, 'id') ??
          'unknown',
      model: readOptionalString(envelope, 'model'),
      output: output,
      raw: payload,
    );
  }

  static void validateTaskOutput(
    Map<String, dynamic> output, {
    required AiTaskType type,
  }) {
    switch (type) {
      case AiTaskType.resumeGenerate:
        validateStringField(output, 'summary');
        readStringList(output, 'experience_bullets');
        readStringList(output, 'skills');
        validateStringField(output, 'education', allowEmpty: true);
      case AiTaskType.coverLetterGenerate:
        validateStringField(output, 'cover_letter');
      case AiTaskType.interviewGenerate:
        readQuestionList(output, 'technical_questions');
        readQuestionList(output, 'behavioral_questions');
      case AiTaskType.cvParse:
        validateStringField(output, 'name', allowEmpty: true);
        validateStringField(output, 'email', allowEmpty: true);
        validateStringField(output, 'location', allowEmpty: true);
        validateIntField(output, 'years_experience');
        readStringList(output, 'roles');
        readStringList(output, 'skills');
        readStringList(output, 'industries');
        validateStringField(output, 'seniority', allowEmpty: true);
        validateStringField(
          output,
          'education',
          allowEmpty: true,
          required: false,
        );
      case AiTaskType.jobMatch:
        validateNumField(output, 'score');
        readStringList(output, 'strengths');
        readStringList(output, 'gaps');
    }
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

  static Map<String, dynamic>? readNestedMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) {
      return null;
    }

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

  static void validateStringField(
    Map<String, dynamic> json,
    String key, {
    bool allowEmpty = false,
    bool required = true,
  }) {
    final value = json[key];
    if (value == null) {
      if (required) {
        throw AppException('The AI response field "$key" was missing.');
      }

      return;
    }

    if (value is! String) {
      throw AppException('The AI response field "$key" must be a string.');
    }

    if (!allowEmpty && value.trim().isEmpty) {
      throw AppException('The AI response field "$key" was empty.');
    }
  }

  static void validateIntField(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return;
    }

    if (value is String && int.tryParse(value) != null) {
      return;
    }

    throw AppException('The AI response field "$key" must be an integer.');
  }

  static void validateNumField(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) {
      return;
    }

    if (value is String && num.tryParse(value) != null) {
      return;
    }

    throw AppException('The AI response field "$key" must be numeric.');
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

  static List<Map<String, dynamic>> readQuestionList(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List) {
      throw AppException('The AI response field "$key" must be a list.');
    }

    return value
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw AppException(
              'The AI response field "$key" had an invalid question item.',
            );
          }

          validateStringField(item, 'question');
          validateStringField(item, 'sample_answer');
          return item;
        })
        .toList(growable: false);
  }
}

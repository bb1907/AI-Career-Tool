import 'ai_task_type.dart';

class AiTaskRequest {
  const AiTaskRequest({
    required this.type,
    required this.input,
    this.userId,
    this.locale,
    this.traceId,
    this.metadata = const <String, dynamic>{},
  });

  final AiTaskType type;
  final Map<String, dynamic> input;
  final String? userId;
  final String? locale;
  final String? traceId;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return {
      'task': type.value,
      'input': input,
      if (userId != null) 'user_id': userId,
      if (locale != null) 'locale': locale,
      if (traceId != null) 'trace_id': traceId,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }
}

import 'ai_task_type.dart';

class AiTaskResponse {
  const AiTaskResponse({
    required this.type,
    required this.output,
    required this.requestId,
    this.model,
    this.raw = const <String, dynamic>{},
  });

  final AiTaskType type;
  final Map<String, dynamic> output;
  final String requestId;
  final String? model;
  final Map<String, dynamic> raw;
}

import 'ai_task_request.dart';
import 'ai_task_response.dart';

abstract class AiService {
  Future<AiTaskResponse> execute(AiTaskRequest request);
}

import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/ai_task_request.dart';
import '../../../../services/ai/ai_task_type.dart';
import '../models/resume_request_model.dart';
import '../models/resume_result_model.dart';

class ResumeRemoteDatasource {
  const ResumeRemoteDatasource(this._aiService);

  final AiService _aiService;

  Future<ResumeResultModel> generateResume(ResumeRequestModel request) async {
    final response = await _aiService.execute(
      AiTaskRequest(type: AiTaskType.resumeGenerate, input: request.toJson()),
    );

    return ResumeResultModel.fromJson(response.output);
  }
}

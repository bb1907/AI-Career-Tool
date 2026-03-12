import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/ai_task_request.dart';
import '../../../../services/ai/ai_task_type.dart';
import '../models/interview_request_model.dart';
import '../models/interview_result_model.dart';

class InterviewRemoteDatasource {
  const InterviewRemoteDatasource(this._aiService);

  final AiService _aiService;

  Future<InterviewResultModel> generateInterviewPrep(
    InterviewRequestModel request,
  ) async {
    final response = await _aiService.execute(
      AiTaskRequest(
        type: AiTaskType.interviewGenerate,
        input: request.toJson(),
      ),
    );

    return InterviewResultModel.fromJson(response.output);
  }
}

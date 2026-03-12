import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/ai_task_request.dart';
import '../../../../services/ai/ai_task_type.dart';
import '../models/cover_letter_request_model.dart';
import '../models/cover_letter_result_model.dart';

class CoverLetterRemoteDatasource {
  const CoverLetterRemoteDatasource(this._aiService);

  final AiService _aiService;

  Future<CoverLetterResultModel> generateCoverLetter(
    CoverLetterRequestModel request,
  ) async {
    final response = await _aiService.execute(
      AiTaskRequest(
        type: AiTaskType.coverLetterGenerate,
        input: request.toJson(),
      ),
    );

    return CoverLetterResultModel.fromJson(response.output);
  }
}

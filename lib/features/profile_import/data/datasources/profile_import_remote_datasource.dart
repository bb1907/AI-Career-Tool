import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/ai_task_request.dart';
import '../../../../services/ai/ai_task_type.dart';
import '../models/candidate_profile_model.dart';

class ProfileImportRemoteDatasource {
  const ProfileImportRemoteDatasource(this._aiService);

  final AiService _aiService;

  Future<CandidateProfileModel> parseCv({
    required String extractedText,
    required String fileName,
  }) async {
    final response = await _aiService.execute(
      AiTaskRequest(
        type: AiTaskType.cvParse,
        input: {'file_name': fileName, 'cv_text': extractedText},
      ),
    );

    return CandidateProfileModel.fromJson(response.output);
  }
}

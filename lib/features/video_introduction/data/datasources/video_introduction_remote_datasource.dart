import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/ai_task_request.dart';
import '../../../../services/ai/ai_task_type.dart';
import '../models/video_introduction_request_model.dart';
import '../models/video_introduction_result_model.dart';

class VideoIntroductionRemoteDatasource {
  const VideoIntroductionRemoteDatasource(this._aiService);

  final AiService _aiService;

  Future<VideoIntroductionResultModel> generateScript(
    VideoIntroductionRequestModel request,
  ) async {
    final response = await _aiService.execute(
      AiTaskRequest(
        type: AiTaskType.videoIntroductionGenerate,
        input: request.toJson(),
      ),
    );

    return VideoIntroductionResultModel.fromJson(response.output);
  }
}

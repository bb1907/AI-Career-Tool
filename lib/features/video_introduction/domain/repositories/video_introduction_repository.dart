import '../entities/video_introduction_request.dart';
import '../entities/video_introduction_result.dart';

abstract class VideoIntroductionRepository {
  Future<VideoIntroductionResult> generateScript(
    VideoIntroductionRequest request,
  );
}

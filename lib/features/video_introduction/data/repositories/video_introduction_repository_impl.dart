import '../../domain/entities/video_introduction_request.dart';
import '../../domain/entities/video_introduction_result.dart';
import '../../domain/repositories/video_introduction_repository.dart';
import '../datasources/video_introduction_remote_datasource.dart';
import '../models/video_introduction_request_model.dart';

class VideoIntroductionRepositoryImpl implements VideoIntroductionRepository {
  const VideoIntroductionRepositoryImpl({required this.remoteDatasource});

  final VideoIntroductionRemoteDatasource remoteDatasource;

  @override
  Future<VideoIntroductionResult> generateScript(
    VideoIntroductionRequest request,
  ) {
    return remoteDatasource.generateScript(
      VideoIntroductionRequestModel.fromEntity(request),
    );
  }
}

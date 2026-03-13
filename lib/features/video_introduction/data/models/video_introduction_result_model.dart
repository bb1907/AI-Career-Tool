import '../../domain/entities/video_introduction_result.dart';

class VideoIntroductionResultModel extends VideoIntroductionResult {
  const VideoIntroductionResultModel({
    required super.script,
    required super.duration,
  });

  factory VideoIntroductionResultModel.fromJson(Map<String, dynamic> json) {
    return VideoIntroductionResultModel(
      script: json['script'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }
}

import '../domain/entities/video_introduction_request.dart';
import '../domain/entities/video_introduction_result.dart';

class VideoIntroductionState {
  const VideoIntroductionState({
    this.request,
    this.result,
    this.isGenerating = false,
    this.errorMessage,
  });

  final VideoIntroductionRequest? request;
  final VideoIntroductionResult? result;
  final bool isGenerating;
  final String? errorMessage;

  VideoIntroductionState copyWith({
    VideoIntroductionRequest? request,
    VideoIntroductionResult? result,
    bool? isGenerating,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return VideoIntroductionState(
      request: request ?? this.request,
      result: clearResult ? null : result ?? this.result,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

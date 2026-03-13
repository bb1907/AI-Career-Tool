class TeleprompterState {
  const TeleprompterState({
    this.script = '',
    this.durationLabel = '',
    this.isInitializing = false,
    this.isReady = false,
    this.isRecording = false,
    this.isAutoScrolling = false,
    this.isMirrored = false,
    this.isUsingFrontCamera = true,
    this.canSwitchCamera = false,
    this.hasPreview = false,
    this.cameraMessage,
    this.errorMessage,
    this.recordingPath,
    this.scrollSpeed = 34,
    this.fontSize = 28,
  });

  final String script;
  final String durationLabel;
  final bool isInitializing;
  final bool isReady;
  final bool isRecording;
  final bool isAutoScrolling;
  final bool isMirrored;
  final bool isUsingFrontCamera;
  final bool canSwitchCamera;
  final bool hasPreview;
  final String? cameraMessage;
  final String? errorMessage;
  final String? recordingPath;
  final double scrollSpeed;
  final double fontSize;

  TeleprompterState copyWith({
    String? script,
    String? durationLabel,
    bool? isInitializing,
    bool? isReady,
    bool? isRecording,
    bool? isAutoScrolling,
    bool? isMirrored,
    bool? isUsingFrontCamera,
    bool? canSwitchCamera,
    bool? hasPreview,
    String? cameraMessage,
    String? errorMessage,
    String? recordingPath,
    double? scrollSpeed,
    double? fontSize,
    bool clearError = false,
    bool clearRecordingPath = false,
  }) {
    return TeleprompterState(
      script: script ?? this.script,
      durationLabel: durationLabel ?? this.durationLabel,
      isInitializing: isInitializing ?? this.isInitializing,
      isReady: isReady ?? this.isReady,
      isRecording: isRecording ?? this.isRecording,
      isAutoScrolling: isAutoScrolling ?? this.isAutoScrolling,
      isMirrored: isMirrored ?? this.isMirrored,
      isUsingFrontCamera: isUsingFrontCamera ?? this.isUsingFrontCamera,
      canSwitchCamera: canSwitchCamera ?? this.canSwitchCamera,
      hasPreview: hasPreview ?? this.hasPreview,
      cameraMessage: cameraMessage ?? this.cameraMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      recordingPath: clearRecordingPath
          ? null
          : recordingPath ?? this.recordingPath,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

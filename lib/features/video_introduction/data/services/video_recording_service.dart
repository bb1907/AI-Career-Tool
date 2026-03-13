import 'package:flutter/widgets.dart';

abstract class VideoRecordingService {
  bool get isInitialized;
  bool get isRecording;
  bool get isUsingFrontCamera;
  bool get canSwitchCamera;
  bool get hasPreview;
  String? get unavailableMessage;

  Future<void> initialize({bool preferFrontCamera = true});
  Future<void> switchCamera();
  Future<void> startRecording();
  Future<String> stopRecording();
  Widget buildPreview();
  Future<void> dispose();
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import 'video_recording_service.dart';

class CameraVideoRecordingService implements VideoRecordingService {
  List<CameraDescription> _cameras = const <CameraDescription>[];
  CameraController? _controller;
  CameraDescription? _activeCamera;
  String? _unavailableMessage;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  @override
  bool get isUsingFrontCamera =>
      _activeCamera?.lensDirection == CameraLensDirection.front;

  @override
  bool get canSwitchCamera => _cameras.length > 1;

  @override
  bool get hasPreview => isInitialized;

  @override
  String? get unavailableMessage => _unavailableMessage;

  @override
  Future<void> initialize({bool preferFrontCamera = true}) async {
    if (isInitialized) {
      return;
    }

    try {
      _cameras = await availableCameras();
    } on CameraException catch (error) {
      throw _mapCameraException(error);
    } catch (_) {
      throw const AppException(
        'Camera access could not be initialized right now.',
        code: 'camera_initialize_failed',
      );
    }

    if (_cameras.isEmpty) {
      _unavailableMessage =
          'Camera preview is not available on this device. You can still use teleprompter mode.';
      return;
    }

    final preferredLens = preferFrontCamera
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final selectedCamera =
        _cameraForDirection(preferredLens) ??
        _cameraForDirection(CameraLensDirection.back) ??
        _cameras.first;

    await _configureController(selectedCamera);
  }

  @override
  Future<void> switchCamera() async {
    if (!canSwitchCamera) {
      return;
    }

    final nextDirection = isUsingFrontCamera
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    final nextCamera =
        _cameraForDirection(nextDirection) ??
        _cameras.firstWhere(
          (camera) => camera != _activeCamera,
          orElse: () => _cameras.first,
        );

    await _configureController(nextCamera);
  }

  @override
  Future<void> startRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const AppException(
        'Camera preview is not ready yet. Please try again in a moment.',
        code: 'camera_not_ready',
      );
    }

    if (controller.value.isRecordingVideo) {
      return;
    }

    try {
      await controller.startVideoRecording();
    } on CameraException catch (error) {
      throw _mapCameraException(error);
    } catch (_) {
      throw const AppException(
        'Video recording could not be started right now.',
        code: 'recording_start_failed',
      );
    }
  }

  @override
  Future<String> stopRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      throw const AppException(
        'Recording has not started yet.',
        code: 'recording_not_started',
      );
    }

    try {
      final file = await controller.stopVideoRecording();
      return file.path;
    } on CameraException catch (error) {
      throw _mapCameraException(error);
    } catch (_) {
      throw const AppException(
        'Video recording could not be finished right now.',
        code: 'recording_stop_failed',
      );
    }
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF111827),
        alignment: Alignment.center,
        child: const Icon(
          Icons.videocam_off_outlined,
          size: 64,
          color: Colors.white54,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CameraPreview(controller),
    );
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    _activeCamera = null;
    _unavailableMessage = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  Future<void> _configureController(CameraDescription camera) async {
    final previousController = _controller;
    final nextController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await nextController.initialize();
      _controller = nextController;
      _activeCamera = camera;
      _unavailableMessage = null;
      if (previousController != null) {
        await previousController.dispose();
      }
    } on CameraException catch (error) {
      await nextController.dispose();
      throw _mapCameraException(error);
    } catch (_) {
      await nextController.dispose();
      throw const AppException(
        'Camera preview could not be started.',
        code: 'camera_preview_failed',
      );
    }
  }

  CameraDescription? _cameraForDirection(CameraLensDirection direction) {
    for (final camera in _cameras) {
      if (camera.lensDirection == direction) {
        return camera;
      }
    }

    return null;
  }

  AppException _mapCameraException(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return const AppException(
          'Camera access is needed to preview and record your introduction.',
          code: 'camera_access_denied',
        );
      case 'AudioAccessDenied':
      case 'AudioAccessDeniedWithoutPrompt':
      case 'AudioAccessRestricted':
        return const AppException(
          'Microphone access is needed to record your introduction.',
          code: 'microphone_access_denied',
        );
      default:
        return AppException(
          error.description ??
              'The camera is temporarily unavailable. Please try again.',
          code: error.code,
        );
    }
  }
}

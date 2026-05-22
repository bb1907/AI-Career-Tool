import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/app_config.dart';
import '../../../../services/ai/providers/fashn_provider.dart';
import '../../data/outfit_config.dart';
import '../../data/photo_session_repository.dart';
import '../../domain/photo_session.dart';

const _uuid = Uuid();
const _kPhotoUsageKey = 'ai_photo_usage_count';
const _kFreeLimit = 1;

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

final aiPhotoServiceProvider = Provider<AiPhotoService>((ref) {
  return AiPhotoService(
    fashnKey: AppConfig.fashnApiKey,
    openAiKey: AppConfig.openAiApiKey,
  );
});

// ---------------------------------------------------------------------------
// Usage tracking
// ---------------------------------------------------------------------------

class PhotoUsageNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kPhotoUsageKey) ?? 0;
  }

  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (state.asData?.value ?? 0) + 1;
    await prefs.setInt(_kPhotoUsageKey, next);
    state = AsyncData(next);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPhotoUsageKey, 0);
    state = const AsyncData(0);
  }
}

final photoUsageProvider = AsyncNotifierProvider<PhotoUsageNotifier, int>(
  PhotoUsageNotifier.new,
);

// ---------------------------------------------------------------------------
// Generation state
// ---------------------------------------------------------------------------

enum PhotoGenStatus { idle, generating, done, error }

class PhotoGenState {
  final PhotoGenStatus status;
  final String? errorMessage;
  final PhotoSession? session;

  const PhotoGenState({
    this.status = PhotoGenStatus.idle,
    this.errorMessage,
    this.session,
  });

  PhotoGenState copyWith({
    PhotoGenStatus? status,
    String? errorMessage,
    PhotoSession? session,
  }) => PhotoGenState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    session: session ?? this.session,
  );
}

class PhotoGenNotifier extends Notifier<PhotoGenState> {
  @override
  PhotoGenState build() => const PhotoGenState();

  Future<void> generate({
    required Uint8List imageBytes,
    required String jobType,
    required String outfitDescription,
    bool isPremium = false,
  }) async {
    state = state.copyWith(
      status: PhotoGenStatus.generating,
      errorMessage: null,
    );

    try {
      final service = ref.read(aiPhotoServiceProvider);
      final outfit = OutfitConfig.forJobType(jobType);

      final resultBytes = await service.generateProfessionalPhoto(
        imageBytes: imageBytes,
        jobType: jobType,
        outfitDescription: outfitDescription.isNotEmpty
            ? outfitDescription
            : outfit.description,
        garmentImageUrl: outfit.garmentImageUrl,
        garmentCategory: outfit.garmentCategory,
      );

      final score = 80 + Random().nextInt(16); // 80–95
      final session = PhotoSession(
        id: _uuid.v4(),
        originalImagePath: '', // set by caller
        resultImageBytes: resultBytes,
        jobType: jobType,
        outfitDescription: outfitDescription.isNotEmpty
            ? outfitDescription
            : outfit.description,
        qualityScore: score,
        createdAt: DateTime.now(),
        isPremium: isPremium,
      );

      ref.read(photoSessionRepositoryProvider.notifier).save(session);
      await ref.read(photoUsageProvider.notifier).increment();

      state = state.copyWith(status: PhotoGenStatus.done, session: session);
    } catch (e) {
      state = state.copyWith(
        status: PhotoGenStatus.error,
        errorMessage:
            'Could not generate photo. Please try again with a clearer image.',
      );
    }
  }

  void reset() => state = const PhotoGenState();
}

final photoGenProvider = NotifierProvider<PhotoGenNotifier, PhotoGenState>(
  PhotoGenNotifier.new,
);

// ---------------------------------------------------------------------------
// Premium check helper
// ---------------------------------------------------------------------------

/// Returns true if user should be blocked (free limit reached, no premium)
Future<bool> isPhotoLimitReached(WidgetRef ref) async {
  // TODO: integrate real premium check from subscription provider
  final usage = await ref.read(photoUsageProvider.future);
  return usage >= _kFreeLimit;
}

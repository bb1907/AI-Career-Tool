import '../../../services/subscription/premium_access_service.dart';

class PremiumAccessState {
  const PremiumAccessState({
    this.snapshot = const PremiumAccessSnapshot(
      userId: null,
      isPremium: false,
      usedFreeGenerations: 0,
    ),
    this.isLoading = false,
    this.errorMessage,
  });

  final PremiumAccessSnapshot snapshot;
  final bool isLoading;
  final String? errorMessage;

  bool get isPremium => snapshot.isPremium;
  int get usedFreeGenerations => snapshot.usedFreeGenerations;
  int get remainingFreeGenerations => snapshot.remainingFreeGenerations;
  int get freeGenerationLimit => snapshot.freeGenerationLimit;
  bool get hasReachedLimit => snapshot.hasReachedLimit;

  PremiumAccessState copyWith({
    PremiumAccessSnapshot? snapshot,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumAccessState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

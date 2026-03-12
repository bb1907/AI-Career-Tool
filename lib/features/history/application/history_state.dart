import '../domain/entities/history_snapshot.dart';

class HistoryState {
  const HistoryState({
    this.isLoading = false,
    this.snapshot = const HistorySnapshot(),
    this.errorMessage,
  });

  final bool isLoading;
  final HistorySnapshot snapshot;
  final String? errorMessage;

  bool get isEmpty => snapshot.isEmpty;

  HistoryState copyWith({
    bool? isLoading,
    HistorySnapshot? snapshot,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

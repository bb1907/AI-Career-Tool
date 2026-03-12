import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../cover_letter/application/cover_letter_controller.dart';
import '../../interview/application/interview_controller.dart';
import '../../resume/application/resume_controller.dart';
import '../data/repositories/history_repository_impl.dart';
import '../domain/repositories/history_repository.dart';
import 'history_state.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(
    resumeRepository: ref.watch(resumeRepositoryProvider),
    coverLetterRepository: ref.watch(coverLetterRepositoryProvider),
    interviewRepository: ref.watch(interviewRepositoryProvider),
  ),
);

final historyControllerProvider = NotifierProvider.autoDispose
    .family<HistoryController, HistoryState, String>(HistoryController.new);

class HistoryController extends Notifier<HistoryState> {
  HistoryController(this.userId);

  final String userId;

  @override
  HistoryState build() {
    Future<void>.microtask(loadHistory);
    return const HistoryState(isLoading: true);
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final snapshot = await ref.read(historyRepositoryProvider).fetchHistory();
      if (!ref.mounted) {
        return;
      }
      state = HistoryState(snapshot: snapshot);
    } on AppException catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = HistoryState(
        snapshot: state.snapshot,
        errorMessage: error.message,
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      state = HistoryState(
        snapshot: state.snapshot,
        errorMessage: 'History could not be loaded right now. Try again.',
      );
    }
  }
}

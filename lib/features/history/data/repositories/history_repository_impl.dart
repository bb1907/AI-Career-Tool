import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/history_snapshot.dart';
import '../../domain/entities/history_section.dart';
import '../../domain/repositories/history_repository.dart';
import '../../../cover_letter/domain/repositories/cover_letter_repository.dart';
import '../../../interview/domain/repositories/interview_repository.dart';
import '../../../resume/domain/repositories/resume_repository.dart';
import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/entities/resume_result.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl({
    required ResumeRepository resumeRepository,
    required CoverLetterRepository coverLetterRepository,
    required InterviewRepository interviewRepository,
  }) : _resumeRepository = resumeRepository,
       _coverLetterRepository = coverLetterRepository,
       _interviewRepository = interviewRepository;

  final ResumeRepository _resumeRepository;
  final CoverLetterRepository _coverLetterRepository;
  final InterviewRepository _interviewRepository;

  @override
  Future<HistorySnapshot> fetchHistory() async {
    final results = await Future.wait<Object>([
      _loadSection<ResumeResult>(
        _resumeRepository.fetchHistory,
        fallbackMessage: 'Resume history could not be loaded right now.',
      ),
      _loadSection<CoverLetterResult>(
        _coverLetterRepository.fetchHistory,
        fallbackMessage: 'Cover letter history could not be loaded right now.',
      ),
      _loadSection<InterviewResult>(
        _interviewRepository.fetchHistory,
        fallbackMessage: 'Interview history could not be loaded right now.',
      ),
    ]);

    return HistorySnapshot(
      resumes: results[0] as HistorySection<ResumeResult>,
      coverLetters: results[1] as HistorySection<CoverLetterResult>,
      interviewSets: results[2] as HistorySection<InterviewResult>,
    );
  }

  Future<HistorySection<T>> _loadSection<T>(
    Future<List<T>> Function() load, {
    required String fallbackMessage,
  }) async {
    try {
      final items = await load();
      return HistorySection<T>(items: List<T>.from(items));
    } on AppException catch (error) {
      return HistorySection<T>(errorMessage: error.message);
    } catch (_) {
      return HistorySection<T>(errorMessage: fallbackMessage);
    }
  }
}

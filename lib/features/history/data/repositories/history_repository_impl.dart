import '../../domain/entities/history_snapshot.dart';
import '../../domain/repositories/history_repository.dart';
import '../../../cover_letter/domain/repositories/cover_letter_repository.dart';
import '../../../cover_letter/domain/entities/cover_letter_result.dart';
import '../../../interview/domain/repositories/interview_repository.dart';
import '../../../interview/domain/entities/interview_result.dart';
import '../../../resume/domain/repositories/resume_repository.dart';
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
      _resumeRepository.fetchHistory(),
      _coverLetterRepository.fetchHistory(),
      _interviewRepository.fetchHistory(),
    ]);

    return HistorySnapshot(
      resumes: List<ResumeResult>.from(results[0] as List<ResumeResult>),
      coverLetters: List<CoverLetterResult>.from(
        results[1] as List<CoverLetterResult>,
      ),
      interviewSets: List<InterviewResult>.from(
        results[2] as List<InterviewResult>,
      ),
    );
  }
}

import '../entities/interview_request.dart';
import '../entities/interview_result.dart';

abstract class InterviewRepository {
  Future<InterviewResult> generateInterviewPrep(InterviewRequest request);
  Future<void> saveInterviewPrep(InterviewResult result);
  Future<List<InterviewResult>> fetchHistory();
}

import 'resume.dart';

abstract class ResumeRepository {
  Future<List<Resume>> getResumes();
  Future<Resume?> getResume(String id);
  Future<Resume> saveResume(Resume resume);
  Future<void> deleteResume(String id);
}

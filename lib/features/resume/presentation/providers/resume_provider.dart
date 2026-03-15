import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/resume_data.dart';

class ResumeNotifier extends Notifier<ResumeData> {
  @override
  ResumeData build() => const ResumeData();

  void updatePersonalInfo(PersonalInfo info) =>
      state = state.copyWith(personalInfo: info);

  void updateSummary(String summary) =>
      state = state.copyWith(summary: summary);

  void updateWorkExperience(List<WorkEntry> work) =>
      state = state.copyWith(workExperience: work);

  void updateEducation(List<EducationEntry> edu) =>
      state = state.copyWith(education: edu);

  void updateSkills(List<String> skills) =>
      state = state.copyWith(skills: skills);

  void updateProjects(List<ProjectEntry> projects) =>
      state = state.copyWith(projects: projects);
}

final resumeProvider = NotifierProvider<ResumeNotifier, ResumeData>(
  ResumeNotifier.new,
);

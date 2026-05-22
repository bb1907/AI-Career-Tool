import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/ai/ai_router.dart';
import '../../data/in_memory_resume_repository.dart';
import '../../domain/resume.dart';
import '../../domain/resume_repository.dart';

const _uuid = Uuid();

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return InMemoryResumeRepository();
});

final resumeListProvider = FutureProvider<List<Resume>>((ref) async {
  final repo = ref.watch(resumeRepositoryProvider);
  return repo.getResumes();
});

final resumeProvider = FutureProvider.family<Resume?, String>((ref, id) async {
  final repo = ref.watch(resumeRepositoryProvider);
  return repo.getResume(id);
});

// State for the resume wizard/editor
class ResumeEditorState {
  final Resume resume;
  final int currentStep;
  final bool isSaving;
  final String? error;

  const ResumeEditorState({
    required this.resume,
    this.currentStep = 0,
    this.isSaving = false,
    this.error,
  });

  ResumeEditorState copyWith({
    Resume? resume,
    int? currentStep,
    bool? isSaving,
    String? error,
  }) => ResumeEditorState(
    resume: resume ?? this.resume,
    currentStep: currentStep ?? this.currentStep,
    isSaving: isSaving ?? this.isSaving,
    error: error,
  );
}

final _emptyResume = Resume(
  id: 'new-${DateTime.now().millisecondsSinceEpoch}',
  title: 'My Resume',
  personalInfo: const PersonalInfo(
    fullName: '',
    email: '',
    phone: '',
    location: '',
  ),
  summary: '',
  workExperiences: const [],
  educations: const [],
  skills: const [],
  projects: const [],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

class ResumeEditorNotifier extends Notifier<ResumeEditorState> {
  final String? resumeId;

  ResumeEditorNotifier(this.resumeId);

  @override
  ResumeEditorState build() {
    if (resumeId != null) {
      // Load existing resume async
      Future.microtask(() async {
        final repo = ref.read(resumeRepositoryProvider);
        final resume = await repo.getResume(resumeId!);
        if (resume != null) {
          state = state.copyWith(resume: resume);
        }
      });
    }
    return ResumeEditorState(
      resume: _emptyResume.copyWith(
        id: resumeId ?? 'new-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  void updatePersonalInfo(PersonalInfo info) {
    state = state.copyWith(resume: state.resume.copyWith(personalInfo: info));
  }

  void updateSummary(String summary) {
    state = state.copyWith(resume: state.resume.copyWith(summary: summary));
  }

  void updateWorkExperiences(List<WorkExperience> list) {
    state = state.copyWith(
      resume: state.resume.copyWith(workExperiences: list),
    );
  }

  void updateEducations(List<Education> list) {
    state = state.copyWith(resume: state.resume.copyWith(educations: list));
  }

  void updateSkills(List<Skill> list) {
    state = state.copyWith(resume: state.resume.copyWith(skills: list));
  }

  void updateProjects(List<Project> list) {
    state = state.copyWith(resume: state.resume.copyWith(projects: list));
  }

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true);
    try {
      final repo = ref.read(resumeRepositoryProvider);
      final saved = await repo.saveResume(state.resume);
      state = state.copyWith(resume: saved, isSaving: false);
      ref.invalidate(resumeListProvider);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  /// Generate a complete resume from chat-collected prefill data using the AI
  /// router, then apply the result to the editor state.
  Future<void> generateFromPrefill(Map<String, dynamic> prefill) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final router = ref.read(aiRouterProvider);
      final json = await router.generateFullResume(
        fullName: state.resume.personalInfo.fullName.isNotEmpty
            ? state.resume.personalInfo.fullName
            : 'Candidate',
        targetRole: prefill['targetRole']?.toString() ?? '',
        seniority: prefill['seniority']?.toString() ?? '',
        recentExperience: prefill['recentExp']?.toString() ?? '',
        skills: prefill['skills']?.toString() ?? '',
      );

      final summary = json['summary']?.toString() ?? '';

      final workList = (json['workExperiences'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (m) => WorkExperience(
              id: _uuid.v4(),
              company: m['company']?.toString() ?? '',
              position: m['position']?.toString() ?? '',
              startDate: m['startDate']?.toString() ?? '',
              endDate: m['endDate']?.toString(),
              isCurrent: m['isCurrent'] == true,
              description: m['description']?.toString() ?? '',
            ),
          )
          .toList();

      final eduList = (json['education'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (m) => Education(
              id: _uuid.v4(),
              institution: m['institution']?.toString() ?? '',
              degree: m['degree']?.toString() ?? '',
              field: m['field']?.toString() ?? '',
              startDate: m['startDate']?.toString() ?? '',
              endDate: m['endDate']?.toString(),
            ),
          )
          .toList();

      // Education from chat is a free-text answer; if AI didn't include any,
      // store the raw user text as a single line so it isn't lost.
      final eduRaw = prefill['education']?.toString() ?? '';
      final finalEdu = eduList.isNotEmpty
          ? eduList
          : (eduRaw.trim().isEmpty
                ? <Education>[]
                : [
                    Education(
                      id: _uuid.v4(),
                      institution: eduRaw,
                      degree: '',
                      field: '',
                      startDate: '',
                    ),
                  ]);

      final skillsFromAi = (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
      final skillsRaw = prefill['skills']?.toString() ?? '';
      final skillsFromChat = skillsRaw
          .split(RegExp(r'[,;\n]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final allSkillNames = (skillsFromAi.isNotEmpty
          ? skillsFromAi
          : skillsFromChat);
      final skillObjects = allSkillNames
          .map(
            (name) => Skill(id: _uuid.v4(), name: name, category: 'technical'),
          )
          .toList();

      final updated = state.resume.copyWith(
        title: prefill['targetRole']?.toString().isNotEmpty == true
            ? '${prefill['targetRole']} Resume'
            : state.resume.title,
        summary: summary,
        workExperiences: workList,
        educations: finalEdu,
        skills: skillObjects,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(resume: updated, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final resumeEditorProvider =
    NotifierProvider.family<ResumeEditorNotifier, ResumeEditorState, String?>(
      (arg) => ResumeEditorNotifier(arg),
    );

import '../domain/resume.dart';
import '../domain/resume_repository.dart';

final _demoResume = Resume(
  id: 'resume-1',
  title: 'Software Engineer Resume',
  personalInfo: const PersonalInfo(
    fullName: 'Alex Johnson',
    email: 'alex@example.com',
    phone: '+1 (555) 123-4567',
    location: 'San Francisco, CA',
    linkedIn: 'linkedin.com/in/alexjohnson',
    website: 'alexjohnson.dev',
  ),
  summary:
      'Experienced software engineer with 5+ years building scalable mobile and web applications. Passionate about clean architecture and user-centric design.',
  workExperiences: [
    WorkExperience(
      id: 'we-1',
      company: 'Tech Corp',
      position: 'Senior Software Engineer',
      startDate: 'Jan 2022',
      isCurrent: true,
      description:
          'Led development of Flutter mobile app with 500K+ downloads. Architected microservices backend using Go and Kubernetes.',
    ),
    WorkExperience(
      id: 'we-2',
      company: 'Startup Inc',
      position: 'Software Engineer',
      startDate: 'Mar 2019',
      endDate: 'Dec 2021',
      description:
          'Built React Native app from scratch. Implemented CI/CD pipeline reducing deployment time by 60%.',
    ),
  ],
  educations: [
    Education(
      id: 'edu-1',
      institution: 'University of California',
      degree: 'Bachelor of Science',
      field: 'Computer Science',
      startDate: '2015',
      endDate: '2019',
      gpa: '3.8',
    ),
  ],
  skills: [
    Skill(id: 's-1', name: 'Flutter', category: 'technical', level: 5),
    Skill(id: 's-2', name: 'Dart', category: 'technical', level: 5),
    Skill(id: 's-3', name: 'Go', category: 'technical', level: 4),
    Skill(id: 's-4', name: 'React Native', category: 'technical', level: 4),
    Skill(id: 's-5', name: 'Team Leadership', category: 'soft', level: 4),
  ],
  projects: [
    Project(
      id: 'p-1',
      name: 'CareerBoost App',
      description: 'AI-powered career coaching app with 10K+ active users',
      url: 'github.com/alex/careerboost',
      technologies: ['Flutter', 'Firebase', 'GPT-4'],
    ),
  ],
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 3, 10),
);

class InMemoryResumeRepository implements ResumeRepository {
  final List<Resume> _resumes = [_demoResume];

  @override
  Future<List<Resume>> getResumes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_resumes);
  }

  @override
  Future<Resume?> getResume(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _resumes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Resume> saveResume(Resume resume) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _resumes.indexWhere((r) => r.id == resume.id);
    final updated = resume.copyWith(updatedAt: DateTime.now());
    if (index >= 0) {
      _resumes[index] = updated;
    } else {
      _resumes.add(updated);
    }
    return updated;
  }

  @override
  Future<void> deleteResume(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _resumes.removeWhere((r) => r.id == id);
  }
}

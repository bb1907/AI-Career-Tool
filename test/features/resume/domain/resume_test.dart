import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/resume/domain/resume.dart';

void main() {
  // ---------------------------------------------------------------------------
  // PersonalInfo
  // ---------------------------------------------------------------------------
  group('PersonalInfo', () {
    test('creates with required fields', () {
      const info = PersonalInfo(
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555-1234',
        location: 'New York, NY',
      );

      expect(info.fullName, 'Jane Doe');
      expect(info.email, 'jane@example.com');
      expect(info.phone, '555-1234');
      expect(info.location, 'New York, NY');
      expect(info.linkedIn, isNull);
      expect(info.website, isNull);
    });

    test('creates with optional fields', () {
      const info = PersonalInfo(
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555-1234',
        location: 'New York, NY',
        linkedIn: 'linkedin.com/in/janedoe',
        website: 'janedoe.dev',
      );

      expect(info.linkedIn, 'linkedin.com/in/janedoe');
      expect(info.website, 'janedoe.dev');
    });

    test('copyWith replaces only specified fields', () {
      const original = PersonalInfo(
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555-1234',
        location: 'New York, NY',
      );

      final updated = original.copyWith(
        fullName: 'John Doe',
        email: 'john@example.com',
      );

      expect(updated.fullName, 'John Doe');
      expect(updated.email, 'john@example.com');
      expect(updated.phone, '555-1234');
      expect(updated.location, 'New York, NY');
    });

    test('copyWith preserves all fields when no arguments given', () {
      const original = PersonalInfo(
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '555-1234',
        location: 'New York, NY',
        linkedIn: 'linkedin.com/in/janedoe',
        website: 'janedoe.dev',
      );

      final copy = original.copyWith();

      expect(copy.fullName, original.fullName);
      expect(copy.email, original.email);
      expect(copy.phone, original.phone);
      expect(copy.location, original.location);
      expect(copy.linkedIn, original.linkedIn);
      expect(copy.website, original.website);
    });
  });

  // ---------------------------------------------------------------------------
  // WorkExperience
  // ---------------------------------------------------------------------------
  group('WorkExperience', () {
    test('creates with required fields and default isCurrent', () {
      const exp = WorkExperience(
        id: 'w1',
        company: 'Acme Inc',
        position: 'Developer',
        startDate: '2020-01',
        description: 'Built things',
      );

      expect(exp.id, 'w1');
      expect(exp.company, 'Acme Inc');
      expect(exp.isCurrent, false);
      expect(exp.endDate, isNull);
    });

    test('creates with isCurrent true', () {
      const exp = WorkExperience(
        id: 'w1',
        company: 'Acme Inc',
        position: 'Developer',
        startDate: '2020-01',
        isCurrent: true,
        description: 'Building things',
      );

      expect(exp.isCurrent, true);
    });

    test('copyWith updates selected fields', () {
      const original = WorkExperience(
        id: 'w1',
        company: 'Acme Inc',
        position: 'Developer',
        startDate: '2020-01',
        description: 'Built things',
      );

      final updated = original.copyWith(company: 'Beta Corp', isCurrent: true);

      expect(updated.company, 'Beta Corp');
      expect(updated.isCurrent, true);
      expect(updated.id, 'w1');
      expect(updated.position, 'Developer');
    });
  });

  // ---------------------------------------------------------------------------
  // Education
  // ---------------------------------------------------------------------------
  group('Education', () {
    test('creates with required fields', () {
      const edu = Education(
        id: 'e1',
        institution: 'MIT',
        degree: 'BS',
        field: 'Computer Science',
        startDate: '2016-09',
      );

      expect(edu.institution, 'MIT');
      expect(edu.degree, 'BS');
      expect(edu.endDate, isNull);
      expect(edu.gpa, isNull);
    });

    test('creates with optional fields', () {
      const edu = Education(
        id: 'e1',
        institution: 'MIT',
        degree: 'BS',
        field: 'Computer Science',
        startDate: '2016-09',
        endDate: '2020-06',
        gpa: '3.8',
      );

      expect(edu.endDate, '2020-06');
      expect(edu.gpa, '3.8');
    });

    test('copyWith updates selected fields', () {
      const original = Education(
        id: 'e1',
        institution: 'MIT',
        degree: 'BS',
        field: 'Computer Science',
        startDate: '2016-09',
      );

      final updated = original.copyWith(degree: 'MS', gpa: '4.0');

      expect(updated.degree, 'MS');
      expect(updated.gpa, '4.0');
      expect(updated.institution, 'MIT');
    });
  });

  // ---------------------------------------------------------------------------
  // Skill
  // ---------------------------------------------------------------------------
  group('Skill', () {
    test('creates with default level', () {
      const skill = Skill(id: 's1', name: 'Flutter', category: 'technical');

      expect(skill.name, 'Flutter');
      expect(skill.category, 'technical');
      expect(skill.level, 3);
    });

    test('creates with custom level', () {
      const skill = Skill(
        id: 's1',
        name: 'Leadership',
        category: 'soft',
        level: 5,
      );

      expect(skill.level, 5);
    });
  });

  // ---------------------------------------------------------------------------
  // Project
  // ---------------------------------------------------------------------------
  group('Project', () {
    test('creates with required fields and default technologies', () {
      const project = Project(
        id: 'p1',
        name: 'My App',
        description: 'A great app',
      );

      expect(project.name, 'My App');
      expect(project.url, isNull);
      expect(project.technologies, isEmpty);
    });

    test('creates with all fields', () {
      const project = Project(
        id: 'p1',
        name: 'My App',
        description: 'A great app',
        url: 'https://myapp.dev',
        technologies: ['Flutter', 'Dart'],
      );

      expect(project.url, 'https://myapp.dev');
      expect(project.technologies, ['Flutter', 'Dart']);
    });

    test('copyWith updates selected fields', () {
      const original = Project(
        id: 'p1',
        name: 'My App',
        description: 'A great app',
        technologies: ['Flutter'],
      );

      final updated = original.copyWith(
        name: 'My New App',
        technologies: ['Flutter', 'Dart', 'Firebase'],
      );

      expect(updated.name, 'My New App');
      expect(updated.technologies, hasLength(3));
      expect(updated.description, 'A great app');
    });
  });

  // ---------------------------------------------------------------------------
  // Resume
  // ---------------------------------------------------------------------------
  group('Resume', () {
    Resume createResume({
      String fullName = 'Jane Doe',
      String summary = 'Experienced developer',
      List<WorkExperience> workExperiences = const [],
      List<Education> educations = const [],
      List<Skill> skills = const [],
      List<Project> projects = const [],
    }) {
      final now = DateTime(2024, 1, 1);
      return Resume(
        id: 'r1',
        title: 'My Resume',
        personalInfo: PersonalInfo(
          fullName: fullName,
          email: 'jane@example.com',
          phone: '555-1234',
          location: 'New York, NY',
        ),
        summary: summary,
        workExperiences: workExperiences,
        educations: educations,
        skills: skills,
        projects: projects,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('creates with all fields', () {
      final resume = createResume();

      expect(resume.id, 'r1');
      expect(resume.title, 'My Resume');
      expect(resume.personalInfo.fullName, 'Jane Doe');
      expect(resume.summary, 'Experienced developer');
    });

    test('copyWith replaces only specified fields', () {
      final original = createResume();
      final updated = original.copyWith(title: 'Updated Resume');

      expect(updated.title, 'Updated Resume');
      expect(updated.id, 'r1');
      expect(updated.personalInfo.fullName, 'Jane Doe');
    });

    group('completionPercentage', () {
      test('returns 0.0 when all sections are empty', () {
        final resume = createResume(
          fullName: '',
          summary: '',
          workExperiences: [],
          educations: [],
          skills: [],
          projects: [],
        );

        expect(resume.completionPercentage, 0.0);
      });

      test('returns 1/6 when only fullName is filled', () {
        final resume = createResume(
          fullName: 'Jane Doe',
          summary: '',
          workExperiences: [],
          educations: [],
          skills: [],
          projects: [],
        );

        expect(resume.completionPercentage, closeTo(1 / 6, 0.001));
      });

      test('returns 2/6 when fullName and summary are filled', () {
        final resume = createResume(
          fullName: 'Jane Doe',
          summary: 'A summary',
          workExperiences: [],
          educations: [],
          skills: [],
          projects: [],
        );

        expect(resume.completionPercentage, closeTo(2 / 6, 0.001));
      });

      test('returns 1.0 when all sections are filled', () {
        final resume = createResume(
          fullName: 'Jane Doe',
          summary: 'Experienced developer',
          workExperiences: [
            const WorkExperience(
              id: 'w1',
              company: 'Acme',
              position: 'Dev',
              startDate: '2020-01',
              description: 'Work',
            ),
          ],
          educations: [
            const Education(
              id: 'e1',
              institution: 'MIT',
              degree: 'BS',
              field: 'CS',
              startDate: '2016',
            ),
          ],
          skills: [
            const Skill(id: 's1', name: 'Flutter', category: 'technical'),
          ],
          projects: [const Project(id: 'p1', name: 'App', description: 'Desc')],
        );

        expect(resume.completionPercentage, 1.0);
      });

      test('returns 3/6 when half the sections are filled', () {
        final resume = createResume(
          fullName: 'Jane Doe',
          summary: 'A summary',
          workExperiences: [
            const WorkExperience(
              id: 'w1',
              company: 'Acme',
              position: 'Dev',
              startDate: '2020-01',
              description: 'Work',
            ),
          ],
          educations: [],
          skills: [],
          projects: [],
        );

        expect(resume.completionPercentage, closeTo(3 / 6, 0.001));
      });
    });
  });
}

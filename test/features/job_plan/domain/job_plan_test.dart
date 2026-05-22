import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/job_plan/domain/job_plan.dart';

void main() {
  group('JobPlan', () {
    JobPlan createJobPlan({
      bool resumeTailored = false,
      bool coverLetterWritten = false,
      bool photoUpdated = false,
      bool interviewPrepped = false,
      bool networkingMessageSent = false,
    }) {
      return JobPlan(
        id: 'jp1',
        jobDescription: 'Build Flutter apps for our team',
        role: 'Flutter Developer',
        company: 'Acme Inc',
        matchScore: 85,
        matchingSkills: ['Flutter', 'Dart', 'REST APIs'],
        missingSkills: ['GraphQL', 'AWS'],
        sector: 'Technology',
        photoRecommendation: 'Business casual headshot recommended',
        createdAt: DateTime(2024, 3, 15),
        resumeTailored: resumeTailored,
        coverLetterWritten: coverLetterWritten,
        photoUpdated: photoUpdated,
        interviewPrepped: interviewPrepped,
        networkingMessageSent: networkingMessageSent,
      );
    }

    test('creates with all required fields', () {
      final plan = createJobPlan();

      expect(plan.id, 'jp1');
      expect(plan.role, 'Flutter Developer');
      expect(plan.company, 'Acme Inc');
      expect(plan.matchScore, 85);
      expect(plan.matchingSkills, ['Flutter', 'Dart', 'REST APIs']);
      expect(plan.missingSkills, ['GraphQL', 'AWS']);
      expect(plan.sector, 'Technology');
      expect(plan.photoRecommendation, 'Business casual headshot recommended');
    });

    test('checklist defaults to all false', () {
      final plan = createJobPlan();

      expect(plan.resumeTailored, false);
      expect(plan.coverLetterWritten, false);
      expect(plan.photoUpdated, false);
      expect(plan.interviewPrepped, false);
      expect(plan.networkingMessageSent, false);
    });

    // -------------------------------------------------------------------------
    // completedCount
    // -------------------------------------------------------------------------
    group('completedCount', () {
      test('returns 0 when no items completed', () {
        final plan = createJobPlan();
        expect(plan.completedCount, 0);
      });

      test('returns 1 when one item completed', () {
        final plan = createJobPlan(resumeTailored: true);
        expect(plan.completedCount, 1);
      });

      test('returns 2 when two items completed', () {
        final plan = createJobPlan(
          resumeTailored: true,
          coverLetterWritten: true,
        );
        expect(plan.completedCount, 2);
      });

      test('returns 3 when three items completed', () {
        final plan = createJobPlan(
          resumeTailored: true,
          coverLetterWritten: true,
          photoUpdated: true,
        );
        expect(plan.completedCount, 3);
      });

      test('returns 4 when four items completed', () {
        final plan = createJobPlan(
          resumeTailored: true,
          coverLetterWritten: true,
          photoUpdated: true,
          interviewPrepped: true,
        );
        expect(plan.completedCount, 4);
      });

      test('returns 5 when all items completed', () {
        final plan = createJobPlan(
          resumeTailored: true,
          coverLetterWritten: true,
          photoUpdated: true,
          interviewPrepped: true,
          networkingMessageSent: true,
        );
        expect(plan.completedCount, 5);
      });
    });

    // -------------------------------------------------------------------------
    // copyWith
    // -------------------------------------------------------------------------
    group('copyWith', () {
      test('updates only specified fields', () {
        final original = createJobPlan();
        final updated = original.copyWith(
          role: 'Senior Developer',
          matchScore: 92,
        );

        expect(updated.role, 'Senior Developer');
        expect(updated.matchScore, 92);
        expect(updated.company, 'Acme Inc');
        expect(updated.id, 'jp1');
      });

      test('toggles checklist items', () {
        final plan = createJobPlan();

        final step1 = plan.copyWith(resumeTailored: true);
        expect(step1.resumeTailored, true);
        expect(step1.completedCount, 1);

        final step2 = step1.copyWith(coverLetterWritten: true);
        expect(step2.coverLetterWritten, true);
        expect(step2.completedCount, 2);

        final untoggled = step2.copyWith(resumeTailored: false);
        expect(untoggled.resumeTailored, false);
        expect(untoggled.completedCount, 1);
      });

      test('preserves all fields when no arguments given', () {
        final original = createJobPlan(
          resumeTailored: true,
          interviewPrepped: true,
        );
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.role, original.role);
        expect(copy.company, original.company);
        expect(copy.matchScore, original.matchScore);
        expect(copy.matchingSkills, original.matchingSkills);
        expect(copy.missingSkills, original.missingSkills);
        expect(copy.resumeTailored, original.resumeTailored);
        expect(copy.interviewPrepped, original.interviewPrepped);
      });
    });

    // -------------------------------------------------------------------------
    // toJson / fromJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      test('serializes all fields', () {
        final plan = createJobPlan(resumeTailored: true);
        final json = plan.toJson();

        expect(json['id'], 'jp1');
        expect(json['role'], 'Flutter Developer');
        expect(json['company'], 'Acme Inc');
        expect(json['matchScore'], 85);
        expect(json['matchingSkills'], ['Flutter', 'Dart', 'REST APIs']);
        expect(json['missingSkills'], ['GraphQL', 'AWS']);
        expect(json['sector'], 'Technology');
        expect(
          json['photoRecommendation'],
          'Business casual headshot recommended',
        );
        expect(json['createdAt'], DateTime(2024, 3, 15).toIso8601String());
        expect(json['resumeTailored'], true);
        expect(json['coverLetterWritten'], false);
        expect(json['photoUpdated'], false);
        expect(json['interviewPrepped'], false);
        expect(json['networkingMessageSent'], false);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'id': 'jp2',
          'jobDescription': 'A job description',
          'role': 'PM',
          'company': 'Beta Corp',
          'matchScore': 70,
          'matchingSkills': ['Leadership', 'Agile'],
          'missingSkills': ['SQL'],
          'sector': 'Finance',
          'photoRecommendation': 'Formal headshot',
          'createdAt': '2024-06-01T00:00:00.000',
          'resumeTailored': true,
          'coverLetterWritten': true,
          'photoUpdated': false,
          'interviewPrepped': false,
          'networkingMessageSent': false,
        };

        final plan = JobPlan.fromJson(json);

        expect(plan.id, 'jp2');
        expect(plan.role, 'PM');
        expect(plan.company, 'Beta Corp');
        expect(plan.matchScore, 70);
        expect(plan.matchingSkills, ['Leadership', 'Agile']);
        expect(plan.missingSkills, ['SQL']);
        expect(plan.sector, 'Finance');
        expect(plan.resumeTailored, true);
        expect(plan.coverLetterWritten, true);
        expect(plan.photoUpdated, false);
      });

      test('defaults checklist booleans to false when missing', () {
        final json = {
          'id': 'jp3',
          'jobDescription': 'desc',
          'role': 'Dev',
          'company': 'Co',
          'matchScore': 50,
          'matchingSkills': <String>[],
          'missingSkills': <String>[],
          'sector': 'Tech',
          'photoRecommendation': 'None',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final plan = JobPlan.fromJson(json);

        expect(plan.resumeTailored, false);
        expect(plan.coverLetterWritten, false);
        expect(plan.photoUpdated, false);
        expect(plan.interviewPrepped, false);
        expect(plan.networkingMessageSent, false);
      });

      test('roundtrip toJson -> fromJson preserves data', () {
        final original = createJobPlan(
          resumeTailored: true,
          coverLetterWritten: true,
          photoUpdated: true,
          interviewPrepped: true,
          networkingMessageSent: true,
        );

        final restored = JobPlan.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.role, original.role);
        expect(restored.company, original.company);
        expect(restored.matchScore, original.matchScore);
        expect(restored.matchingSkills, original.matchingSkills);
        expect(restored.missingSkills, original.missingSkills);
        expect(restored.sector, original.sector);
        expect(restored.photoRecommendation, original.photoRecommendation);
        expect(restored.resumeTailored, original.resumeTailored);
        expect(restored.coverLetterWritten, original.coverLetterWritten);
        expect(restored.photoUpdated, original.photoUpdated);
        expect(restored.interviewPrepped, original.interviewPrepped);
        expect(restored.networkingMessageSent, original.networkingMessageSent);
        expect(restored.completedCount, 5);
      });
    });
  });
}

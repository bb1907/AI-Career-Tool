import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/cover_letter/domain/cover_letter.dart';

void main() {
  group('CoverLetter', () {
    CoverLetter createCoverLetter({
      String id = 'cl1',
      String companyName = 'Acme Inc',
      String roleName = 'Flutter Developer',
      String jobDescription = 'Build mobile apps with Flutter',
      String generatedText = 'Dear Hiring Manager...',
      String tone = 'professional',
      DateTime? createdAt,
    }) {
      return CoverLetter(
        id: id,
        companyName: companyName,
        roleName: roleName,
        jobDescription: jobDescription,
        generatedText: generatedText,
        tone: tone,
        createdAt: createdAt ?? DateTime(2024, 1, 15),
      );
    }

    test('creates with all required fields', () {
      final cl = createCoverLetter();

      expect(cl.id, 'cl1');
      expect(cl.companyName, 'Acme Inc');
      expect(cl.roleName, 'Flutter Developer');
      expect(cl.jobDescription, 'Build mobile apps with Flutter');
      expect(cl.generatedText, 'Dear Hiring Manager...');
      expect(cl.tone, 'professional');
      expect(cl.createdAt, DateTime(2024, 1, 15));
    });

    test('copyWith updates generatedText only', () {
      final original = createCoverLetter();
      final updated = original.copyWith(generatedText: 'Updated letter text');

      expect(updated.generatedText, 'Updated letter text');
      expect(updated.tone, 'professional');
      expect(updated.id, 'cl1');
      expect(updated.companyName, 'Acme Inc');
      expect(updated.roleName, 'Flutter Developer');
      expect(updated.jobDescription, 'Build mobile apps with Flutter');
      expect(updated.createdAt, DateTime(2024, 1, 15));
    });

    test('copyWith updates tone only', () {
      final original = createCoverLetter();
      final updated = original.copyWith(tone: 'friendly');

      expect(updated.tone, 'friendly');
      expect(updated.generatedText, 'Dear Hiring Manager...');
    });

    test('copyWith updates both generatedText and tone', () {
      final original = createCoverLetter();
      final updated = original.copyWith(
        generatedText: 'New text',
        tone: 'confident',
      );

      expect(updated.generatedText, 'New text');
      expect(updated.tone, 'confident');
    });

    test('copyWith preserves all fields when no arguments given', () {
      final original = createCoverLetter();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.companyName, original.companyName);
      expect(copy.roleName, original.roleName);
      expect(copy.jobDescription, original.jobDescription);
      expect(copy.generatedText, original.generatedText);
      expect(copy.tone, original.tone);
      expect(copy.createdAt, original.createdAt);
    });

    test('supports all valid tone values', () {
      for (final tone in ['professional', 'friendly', 'confident']) {
        final cl = createCoverLetter(tone: tone);
        expect(cl.tone, tone);
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/interview_prep/domain/interview_question.dart';

void main() {
  group('InterviewQuestion', () {
    test('creates with required fields', () {
      const q = InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'Explain widget lifecycle in Flutter',
        sampleAnswer: 'The widget lifecycle includes...',
      );

      expect(q.category, QuestionCategory.technical);
      expect(q.question, 'Explain widget lifecycle in Flutter');
      expect(q.sampleAnswer, 'The widget lifecycle includes...');
    });

    group('toMap', () {
      test('serializes technical question correctly', () {
        const q = InterviewQuestion(
          category: QuestionCategory.technical,
          question: 'What is a Stream?',
          sampleAnswer: 'A Stream is...',
        );

        final map = q.toMap();

        expect(map['category'], 'technical');
        expect(map['question'], 'What is a Stream?');
        expect(map['sampleAnswer'], 'A Stream is...');
      });

      test('serializes behavioral question correctly', () {
        const q = InterviewQuestion(
          category: QuestionCategory.behavioral,
          question: 'Tell me about a time you led a team',
          sampleAnswer: 'In my previous role...',
        );

        final map = q.toMap();

        expect(map['category'], 'behavioral');
        expect(map['question'], 'Tell me about a time you led a team');
        expect(map['sampleAnswer'], 'In my previous role...');
      });

      test('returns map with exactly three keys', () {
        const q = InterviewQuestion(
          category: QuestionCategory.technical,
          question: 'Q',
          sampleAnswer: 'A',
        );

        final map = q.toMap();

        expect(map.keys, hasLength(3));
        expect(map.keys, containsAll(['category', 'question', 'sampleAnswer']));
      });
    });

    group('fromMap', () {
      test('deserializes technical question from map', () {
        final map = {
          'category': 'technical',
          'question': 'Explain dependency injection',
          'sampleAnswer': 'Dependency injection is...',
        };

        final q = InterviewQuestion.fromMap(map);

        expect(q.category, QuestionCategory.technical);
        expect(q.question, 'Explain dependency injection');
        expect(q.sampleAnswer, 'Dependency injection is...');
      });

      test('deserializes behavioral question from map', () {
        final map = {
          'category': 'behavioral',
          'question': 'Describe a conflict you resolved',
          'sampleAnswer': 'I once had a disagreement...',
        };

        final q = InterviewQuestion.fromMap(map);

        expect(q.category, QuestionCategory.behavioral);
        expect(q.question, 'Describe a conflict you resolved');
      });

      test('roundtrip toMap -> fromMap preserves data', () {
        const original = InterviewQuestion(
          category: QuestionCategory.behavioral,
          question: 'How do you handle deadlines?',
          sampleAnswer: 'I prioritize tasks by...',
        );

        final restored = InterviewQuestion.fromMap(original.toMap());

        expect(restored.category, original.category);
        expect(restored.question, original.question);
        expect(restored.sampleAnswer, original.sampleAnswer);
      });

      test('throws when category is invalid', () {
        final map = {
          'category': 'invalid_category',
          'question': 'Q',
          'sampleAnswer': 'A',
        };

        expect(
          () => InterviewQuestion.fromMap(map),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });

  group('QuestionCategory', () {
    test('has exactly two values', () {
      expect(QuestionCategory.values, hasLength(2));
    });

    test('contains technical and behavioral', () {
      expect(QuestionCategory.values, contains(QuestionCategory.technical));
      expect(QuestionCategory.values, contains(QuestionCategory.behavioral));
    });
  });
}

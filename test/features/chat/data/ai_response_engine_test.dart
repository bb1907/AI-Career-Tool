import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/chat/data/ai_response_engine.dart';
import 'package:ai_career_tools/features/chat/domain/chat_message.dart';
import 'package:ai_career_tools/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l;

  setUpAll(() async {
    l = await AppLocalizations.delegate.load(const Locale('en'));
  });

  // ---------------------------------------------------------------------------
  // greeting
  // ---------------------------------------------------------------------------
  group('AiResponseEngine.greeting', () {
    test('returns non-empty string for every ChatFlow value', () {
      for (final flow in ChatFlow.values) {
        final result = AiResponseEngine.greeting(flow, l);
        expect(
          result,
          isNotEmpty,
          reason: 'greeting for $flow should be non-empty',
        );
      }
    });

    test('resume greeting mentions resume', () {
      final g = AiResponseEngine.greeting(ChatFlow.resume, l);
      expect(g.toLowerCase(), contains('resume'));
    });

    test('coverLetter greeting mentions cover letter', () {
      final g = AiResponseEngine.greeting(ChatFlow.coverLetter, l);
      expect(g.toLowerCase(), contains('cover letter'));
    });

    test('interview greeting mentions interview', () {
      final g = AiResponseEngine.greeting(ChatFlow.interview, l);
      expect(g.toLowerCase(), contains('interview'));
    });

    test('jobPlan greeting mentions application plan', () {
      final g = AiResponseEngine.greeting(ChatFlow.jobPlan, l);
      expect(g.toLowerCase(), contains('application plan'));
    });

    test('none greeting is generic assistant greeting', () {
      final g = AiResponseEngine.greeting(ChatFlow.none, l);
      expect(g.toLowerCase(), contains('career'));
    });
  });

  // ---------------------------------------------------------------------------
  // firstStep
  // ---------------------------------------------------------------------------
  group('AiResponseEngine.firstStep', () {
    test('returns non-null for flows with steps', () {
      final flowsWithSteps = [
        ChatFlow.resume,
        ChatFlow.coverLetter,
        ChatFlow.interview,
        ChatFlow.cvUpload,
        ChatFlow.jobMatch,
        ChatFlow.videoIntro,
        ChatFlow.skillGap,
        ChatFlow.mockInterview,
        ChatFlow.networking,
        ChatFlow.jobPlan,
      ];

      for (final flow in flowsWithSteps) {
        final step = AiResponseEngine.firstStep(flow, l);
        expect(
          step,
          isNotNull,
          reason: 'firstStep for $flow should not be null',
        );
        expect(step!.question, isNotEmpty);
        expect(step.dataKey, isNotEmpty);
      }
    });

    test('returns null for flows with no steps', () {
      expect(AiResponseEngine.firstStep(ChatFlow.none, l), isNull);
      expect(AiResponseEngine.firstStep(ChatFlow.aiPhoto, l), isNull);
    });

    test('resume first step asks about existing CV', () {
      final step = AiResponseEngine.firstStep(ChatFlow.resume, l);
      expect(step!.question.toLowerCase(), contains('cv'));
      expect(step.dataKey, 'hasCV');
      expect(step.chips, isNotNull);
      expect(step.chips, isNotEmpty);
    });

    test('coverLetter first step asks about company', () {
      final step = AiResponseEngine.firstStep(ChatFlow.coverLetter, l);
      expect(step!.question.toLowerCase(), contains('company'));
      expect(step.dataKey, 'company');
    });

    test('jobPlan first step asks for job description', () {
      final step = AiResponseEngine.firstStep(ChatFlow.jobPlan, l);
      expect(step!.question.toLowerCase(), contains('job description'));
      expect(step.dataKey, 'jobDescription');
    });
  });

  // ---------------------------------------------------------------------------
  // next — resume flow (6 steps)
  // ---------------------------------------------------------------------------
  group('AiResponseEngine.next — resume flow', () {
    test('step 0 returns first question about target role', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.resume,
        step: 0,
        data: {},
        userInput: 'Start from scratch',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.isComplete, false);
    });

    test('progresses through all 6 steps returning questions', () {
      for (int i = 0; i < 6; i++) {
        final result = AiResponseEngine.next(
          flow: ChatFlow.resume,
          step: i,
          data: {},
          userInput: 'test input',
          l: l,
        );

        expect(
          result.nextQuestion,
          isNotNull,
          reason: 'Step $i should return a question',
        );
        expect(
          result.isComplete,
          false,
          reason: 'Step $i should not complete the flow',
        );
      }
    });

    test('step >= 6 returns completion result', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.resume,
        step: 6,
        data: {},
        userInput: 'last answer',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.nextQuestion!.toLowerCase(), contains('resume'));
      expect(result.chips, isNotNull);
      expect(result.isComplete, false);
    });

    test('steps with chips return non-empty chip lists', () {
      final step0 = AiResponseEngine.next(
        flow: ChatFlow.resume,
        step: 0,
        data: {},
        userInput: '',
        l: l,
      );
      expect(step0.chips, isNotNull);
      expect(step0.chips, isNotEmpty);

      final step2 = AiResponseEngine.next(
        flow: ChatFlow.resume,
        step: 2,
        data: {},
        userInput: '',
        l: l,
      );
      expect(step2.chips, isNotNull);
      expect(step2.chips, isNotEmpty);

      final step4 = AiResponseEngine.next(
        flow: ChatFlow.resume,
        step: 4,
        data: {},
        userInput: '',
        l: l,
      );
      expect(step4.chips, isNotNull);
      expect(step4.chips, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // next — coverLetter flow (4 steps)
  // ---------------------------------------------------------------------------
  group('AiResponseEngine.next — coverLetter flow', () {
    test('progresses through all 4 steps', () {
      for (int i = 0; i < 4; i++) {
        final result = AiResponseEngine.next(
          flow: ChatFlow.coverLetter,
          step: i,
          data: {},
          userInput: 'input',
          l: l,
        );

        expect(
          result.nextQuestion,
          isNotNull,
          reason: 'Step $i should return a question',
        );
        expect(result.isComplete, false);
      }
    });

    test('step >= 4 returns completion result', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.coverLetter,
        step: 4,
        data: {},
        userInput: 'Professional',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.nextQuestion!.toLowerCase(), contains('cover letter'));
      expect(result.chips, isNotNull);
    });

    test('last step (tone) has chip options', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.coverLetter,
        step: 3,
        data: {},
        userInput: '',
        l: l,
      );

      expect(result.chips, isNotNull);
      expect(
        result.chips,
        containsAll(['Professional', 'Friendly', 'Confident']),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // _completeFlow navigation targets
  // ---------------------------------------------------------------------------
  group('AiResponseEngine.next — completion navigation', () {
    test('cvUpload completion navigates to /cv-upload', () {
      final completion = AiResponseEngine.next(
        flow: ChatFlow.cvUpload,
        step: 2,
        data: {'uploadMethod': 'Upload PDF'},
        userInput: 'done',
        l: l,
      );

      expect(completion.isComplete, true);
      expect(completion.navigationTarget, '/cv-upload');
    });

    test('jobMatch completion navigates to /skill-gap', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.jobMatch,
        step: 1,
        data: {'jobDescription': 'A great job'},
        userInput: 'some JD',
        l: l,
      );

      expect(result.isComplete, true);
      expect(result.navigationTarget, '/skill-gap');
      expect(result.navigationExtra, isNotNull);
      expect(result.navigationExtra!['jobDescription'], 'A great job');
    });

    test('skillGap completion navigates to /skill-gap', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.skillGap,
        step: 1,
        data: {'jobDescription': 'JD text'},
        userInput: 'desc',
        l: l,
      );

      expect(result.isComplete, true);
      expect(result.navigationTarget, '/skill-gap');
    });

    test('aiPhoto completion navigates to /ai-photo', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.aiPhoto,
        step: 0,
        data: {},
        userInput: '',
        l: l,
      );

      expect(result.isComplete, true);
      expect(result.navigationTarget, '/ai-photo');
    });

    test('resume completion does not navigate (stays in chat)', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.resume,
        step: 6,
        data: {},
        userInput: '',
        l: l,
      );

      expect(result.isComplete, false);
      expect(result.navigationTarget, isNull);
      expect(result.chips, isNotNull);
    });

    test('jobPlan completion stays in chat with generate chip', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.jobPlan,
        step: 1,
        data: {'jobDescription': 'A JD'},
        userInput: 'JD text',
        l: l,
      );

      expect(result.isComplete, false);
      expect(result.navigationTarget, isNull);
      expect(result.chips, isNotNull);
      expect(result.chips, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // CV method handling
  // ---------------------------------------------------------------------------
  group('AiResponseEngine.next — cvUpload method handling', () {
    test('PDF upload method returns file picker prompt', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.cvUpload,
        step: 1,
        data: {'uploadMethod': 'Upload PDF / DOC'},
        userInput: 'Upload PDF / DOC',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.nextQuestion!.toLowerCase(), contains('file'));
    });

    test('LinkedIn URL method returns URL prompt', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.cvUpload,
        step: 1,
        data: {},
        userInput: 'Paste LinkedIn URL',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.nextQuestion!.toLowerCase(), contains('linkedin'));
    });

    test('copy-paste method returns paste prompt', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.cvUpload,
        step: 1,
        data: {},
        userInput: 'Copy-paste text',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.nextQuestion!.toLowerCase(), contains('paste'));
    });

    test('voice method returns tell-me prompt', () {
      final result = AiResponseEngine.next(
        flow: ChatFlow.cvUpload,
        step: 1,
        data: {},
        userInput: 'Tell me by voice',
        l: l,
      );

      expect(result.nextQuestion, isNotNull);
      expect(result.nextQuestion!.toLowerCase(), contains('tell me'));
    });
  });

  // ---------------------------------------------------------------------------
  // FlowResult and AiStep
  // ---------------------------------------------------------------------------
  group('FlowResult', () {
    test('default values are correct', () {
      const result = FlowResult();

      expect(result.nextQuestion, isNull);
      expect(result.chips, isNull);
      expect(result.isComplete, false);
      expect(result.navigationTarget, isNull);
      expect(result.navigationExtra, isNull);
    });
  });

  group('AiStep', () {
    test('creates with required fields', () {
      const step = AiStep(question: 'What is your name?', dataKey: 'name');

      expect(step.question, 'What is your name?');
      expect(step.dataKey, 'name');
      expect(step.chips, isNull);
    });

    test('creates with chips', () {
      const step = AiStep(
        question: 'Choose one',
        dataKey: 'choice',
        chips: ['A', 'B', 'C'],
      );

      expect(step.chips, ['A', 'B', 'C']);
    });
  });
}

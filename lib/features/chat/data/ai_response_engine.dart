import '../../../l10n/app_localizations.dart';
import '../domain/chat_message.dart';
// ChipAction constants live alongside ChatMessage.

class AiStep {
  final String question;
  final String dataKey;
  final List<String>? chips;
  // Parallel list of semantic action codes (see ChipAction). Same length as
  // [chips] when present. Null entries mean "send chip text as a message".
  final List<String?>? chipActions;

  const AiStep({
    required this.question,
    required this.dataKey,
    this.chips,
    this.chipActions,
  });
}

class FlowResult {
  final String? nextQuestion;
  final List<String>? chips;
  final List<String?>? chipActions;
  final bool isComplete;
  final String? navigationTarget;
  final Map<String, dynamic>? navigationExtra;

  const FlowResult({
    this.nextQuestion,
    this.chips,
    this.chipActions,
    this.isComplete = false,
    this.navigationTarget,
    this.navigationExtra,
  });
}

class AiResponseEngine {
  // ── Flow definitions (localized) ───────────────────────────────────────────

  static List<AiStep> _getSteps(ChatFlow flow, AppLocalizations l) =>
      switch (flow) {
        ChatFlow.resume => [
          AiStep(
            question: l.chatResumeQ1,
            dataKey: 'hasCV',
            chips: [
              l.chatResumeChipFromScratch,
              l.chatResumeChipUploadPdf,
              l.chatResumeChipPasteLinkedIn,
            ],
            chipActions: [
              ChipAction.scratch,
              ChipAction.pdfPick,
              ChipAction.linkedInUrl,
            ],
          ),
          AiStep(question: l.chatResumeQ2, dataKey: 'targetRole'),
          AiStep(
            question: l.chatResumeQ3,
            dataKey: 'seniority',
            chips: [
              l.chatResumeChipExp02,
              l.chatResumeChipExp35,
              l.chatResumeChipExp510,
              l.chatResumeChipExp10Plus,
            ],
          ),
          AiStep(question: l.chatResumeQ4, dataKey: 'recentExp'),
          AiStep(
            question: l.chatResumeQ5,
            dataKey: 'skills',
            chips: [
              'Python',
              'React',
              'Flutter',
              l.chatResumeChipManagement,
              l.chatResumeChipDataAnalysis,
              l.chatResumeChipMarketing,
            ],
          ),
          AiStep(question: l.chatResumeQ6, dataKey: 'education'),
        ],
        ChatFlow.coverLetter => [
          AiStep(question: l.chatCoverLetterQ1, dataKey: 'company'),
          AiStep(question: l.chatCoverLetterQ2, dataKey: 'role'),
          AiStep(question: l.chatCoverLetterQ3, dataKey: 'jobDescription'),
          AiStep(
            question: l.chatCoverLetterQ4,
            dataKey: 'tone',
            chips: [
              l.chatCoverLetterChipProfessional,
              l.chatCoverLetterChipFriendly,
              l.chatCoverLetterChipConfident,
            ],
          ),
        ],
        ChatFlow.interview => [
          AiStep(question: l.chatInterviewQ1, dataKey: 'role'),
          AiStep(
            question: l.chatInterviewQ2,
            dataKey: 'seniority',
            chips: [
              l.chatInterviewChipJunior,
              l.chatInterviewChipMidLevel,
              l.chatInterviewChipSenior,
              l.chatInterviewChipLead,
            ],
          ),
          AiStep(
            question: l.chatInterviewQ3,
            dataKey: 'focusArea',
            chips: [
              l.chatInterviewChipTechnical,
              l.chatInterviewChipBehavioral,
              l.chatInterviewChipSystemDesign,
              l.chatInterviewChipAllAbove,
            ],
          ),
        ],
        ChatFlow.cvUpload => [
          AiStep(
            question: l.chatCvUploadQ1,
            dataKey: 'uploadMethod',
            chips: [
              l.chatCvUploadChipPdf,
              l.chatCvUploadChipLinkedIn,
              l.chatCvUploadChipPaste,
              l.chatCvUploadChipVoice,
            ],
          ),
        ],
        ChatFlow.jobMatch => [
          AiStep(question: l.chatJobMatchQ1, dataKey: 'jobDescription'),
        ],
        ChatFlow.videoIntro => [
          AiStep(question: l.chatVideoQ1, dataKey: 'role'),
          AiStep(
            question: l.chatVideoQ2,
            dataKey: 'duration',
            chips: [l.chatVideoChip30s, l.chatVideoChip60s, l.chatVideoChip90s],
          ),
          AiStep(
            question: l.chatVideoQ3,
            dataKey: 'tone',
            chips: [
              l.chatVideoChipFormal,
              l.chatVideoChipCasual,
              l.chatVideoChipConfident,
            ],
          ),
        ],
        ChatFlow.skillGap => [
          AiStep(question: l.chatSkillGapQ1, dataKey: 'jobDescription'),
        ],
        ChatFlow.mockInterview => [
          AiStep(question: l.chatMockQ1, dataKey: 'role'),
          AiStep(
            question: l.chatMockQ2,
            dataKey: 'seniority',
            chips: [
              l.chatInterviewChipJunior,
              l.chatInterviewChipMidLevel,
              l.chatInterviewChipSenior,
              l.chatInterviewChipLead,
            ],
          ),
        ],
        ChatFlow.networking => [
          AiStep(
            question: l.chatNetQ1,
            dataKey: 'messageType',
            chips: [
              l.chatNetChipColdOutreach,
              l.chatNetChipThankYou,
              l.chatNetChipFollowUp,
              l.chatNetChipReferral,
              l.chatNetChipLinkedIn,
            ],
          ),
          AiStep(question: l.chatNetQ2, dataKey: 'recipient'),
          AiStep(question: l.chatNetQ3, dataKey: 'context'),
          AiStep(
            question: l.chatNetQ4,
            dataKey: 'tone',
            chips: [
              l.chatNetChipProfessional,
              l.chatNetChipFriendly,
              l.chatNetChipBrief,
            ],
          ),
        ],
        ChatFlow.aiPhoto => [],
        ChatFlow.jobPlan => [
          AiStep(question: l.chatJobPlanQ1, dataKey: 'jobDescription'),
        ],
        ChatFlow.none => [],
      };

  // ── Greeting ──────────────────────────────────────────────────────────────

  static String greeting(ChatFlow flow, AppLocalizations l) => switch (flow) {
    ChatFlow.resume => l.chatGreetingResume,
    ChatFlow.coverLetter => l.chatGreetingCoverLetter,
    ChatFlow.interview => l.chatGreetingInterview,
    ChatFlow.cvUpload => l.chatGreetingCvUpload,
    ChatFlow.jobMatch => l.chatGreetingJobMatch,
    ChatFlow.videoIntro => l.chatGreetingVideoIntro,
    ChatFlow.skillGap => l.chatGreetingSkillGap,
    ChatFlow.mockInterview => l.chatGreetingMockInterview,
    ChatFlow.networking => l.chatGreetingNetworking,
    ChatFlow.aiPhoto => l.chatGreetingAiPhoto,
    ChatFlow.jobPlan => l.chatGreetingJobPlan,
    ChatFlow.none => l.chatGreetingNone,
  };

  // ── Next step ─────────────────────────────────────────────────────────────

  static FlowResult next({
    required ChatFlow flow,
    required int step,
    required Map<String, String> data,
    required String userInput,
    required AppLocalizations l,
  }) {
    final steps = _getSteps(flow, l);

    // Special CV method handling
    if (flow == ChatFlow.cvUpload && step == 1) {
      return _handleCvMethod(userInput, l);
    }

    if (steps.isEmpty || step >= steps.length) {
      return _completeFlow(flow, data, l);
    }

    final s = steps[step];
    return FlowResult(
      nextQuestion: s.question,
      chips: s.chips,
      chipActions: s.chipActions,
    );
  }

  // ── Complete flow ─────────────────────────────────────────────────────────

  static FlowResult _completeFlow(
    ChatFlow flow,
    Map<String, String> data,
    AppLocalizations l,
  ) {
    switch (flow) {
      case ChatFlow.resume:
        return FlowResult(
          nextQuestion: l.chatResumeComplete,
          chips: [l.chatResumeCompleteChip],
          isComplete: false,
        );
      case ChatFlow.coverLetter:
        return FlowResult(
          nextQuestion: l.chatCoverLetterComplete,
          chips: [l.chatCoverLetterCompleteChip],
          isComplete: false,
        );
      case ChatFlow.interview:
        return FlowResult(
          nextQuestion: l.chatInterviewComplete,
          chips: [l.chatInterviewCompleteChip],
          isComplete: false,
        );
      case ChatFlow.cvUpload:
        return FlowResult(
          nextQuestion: l.chatCvUploadComplete,
          isComplete: true,
          navigationTarget: '/cv-upload',
        );
      case ChatFlow.jobMatch:
        return FlowResult(
          nextQuestion: l.chatJobMatchComplete,
          isComplete: true,
          navigationTarget: '/skill-gap',
          navigationExtra: {'jobDescription': data['jobDescription'] ?? ''},
        );
      case ChatFlow.skillGap:
        return FlowResult(
          nextQuestion: l.chatSkillGapComplete,
          isComplete: true,
          navigationTarget: '/skill-gap',
          navigationExtra: {'jobDescription': data['jobDescription'] ?? ''},
        );
      case ChatFlow.videoIntro:
        return FlowResult(
          nextQuestion: l.chatVideoComplete,
          chips: [l.chatVideoCompleteChip],
          isComplete: false,
        );
      case ChatFlow.mockInterview:
        return FlowResult(
          nextQuestion: l.chatMockComplete,
          chips: [l.chatMockCompleteChip],
          isComplete: false,
        );
      case ChatFlow.networking:
        return FlowResult(
          nextQuestion: l.chatNetComplete,
          chips: [l.chatNetCompleteChip],
          isComplete: false,
        );
      case ChatFlow.aiPhoto:
        return FlowResult(
          nextQuestion: l.chatPaywallPhotoOpening,
          isComplete: true,
          navigationTarget: '/ai-photo',
        );
      case ChatFlow.jobPlan:
        return FlowResult(
          nextQuestion: l.chatJobPlanComplete,
          chips: [l.chatJobPlanCompleteChip],
          isComplete: false,
        );
      case ChatFlow.none:
        return FlowResult(nextQuestion: l.chatNoneComplete, isComplete: false);
    }
  }

  // ── CV method handler ─────────────────────────────────────────────────────

  static FlowResult _handleCvMethod(String method, AppLocalizations l) {
    final m = method.toLowerCase();
    if (m.contains('pdf') ||
        m.contains('upload') ||
        m.contains('doc') ||
        m.contains('yukle') ||
        m.contains('dosya')) {
      return FlowResult(
        nextQuestion: l.chatCvMethodPdf,
        chips: [l.chatCvMethodFileChip],
        chipActions: [ChipAction.pdfPick],
      );
    } else if (m.contains('linkedin') || m.contains('url')) {
      return FlowResult(nextQuestion: l.chatCvMethodLinkedIn);
    } else if (m.contains('text') ||
        m.contains('paste') ||
        m.contains('copy') ||
        m.contains('yapistir') ||
        m.contains('kopyala')) {
      return FlowResult(nextQuestion: l.chatCvMethodPaste);
    } else {
      return FlowResult(nextQuestion: l.chatCvMethodVoice);
    }
  }

  // ── First question ────────────────────────────────────────────────────────

  static AiStep? firstStep(ChatFlow flow, AppLocalizations l) {
    final steps = _getSteps(flow, l);
    if (steps.isEmpty) return null;
    return steps.first;
  }
}

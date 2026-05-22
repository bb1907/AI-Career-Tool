import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_message.dart';
import '../../data/ai_response_engine.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../cv_upload/domain/uploaded_cv.dart';

const _uuid = Uuid();

class ChatState {
  final List<ChatMessage> messages;
  final ChatFlow flow;
  final int step;
  final Map<String, String> data;
  final bool isTyping;
  final bool isListening;
  final String? pendingNavigation;
  final Map<String, dynamic>? pendingNavigationExtra;

  const ChatState({
    this.messages = const [],
    this.flow = ChatFlow.none,
    this.step = 0,
    this.data = const {},
    this.isTyping = false,
    this.isListening = false,
    this.pendingNavigation,
    this.pendingNavigationExtra,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatFlow? flow,
    int? step,
    Map<String, String>? data,
    bool? isTyping,
    bool? isListening,
    String? pendingNavigation,
    Map<String, dynamic>? pendingNavigationExtra,
    bool clearNav = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    flow: flow ?? this.flow,
    step: step ?? this.step,
    data: data ?? this.data,
    isTyping: isTyping ?? this.isTyping,
    isListening: isListening ?? this.isListening,
    pendingNavigation: clearNav
        ? null
        : (pendingNavigation ?? this.pendingNavigation),
    pendingNavigationExtra: clearNav
        ? null
        : (pendingNavigationExtra ?? this.pendingNavigationExtra),
  );
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  // ── Start a new flow ───────────────────────────────────────────────────────

  Future<void> startFlow(ChatFlow flow, AppLocalizations l10n) async {
    final sub = ref.read(subscriptionProvider);
    final greeting = AiResponseEngine.greeting(flow, l10n);

    final msgs = <ChatMessage>[_makeAi(greeting)];

    state = state.copyWith(
      messages: msgs,
      flow: flow,
      step: 0,
      data: {},
      isTyping: false,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Subscription-gated features: show paywall for free users
    if (flow == ChatFlow.aiPhoto) {
      if (!sub.isPremium) {
        _addAiMessage(l10n.chatPaywallPhotoPreview);
        await Future.delayed(const Duration(milliseconds: 400));
        _addAiMessage(
          l10n.chatPaywallPhotoFeatures,
          chips: [l10n.chatPaywallPhotoChip],
        );
      } else {
        _addAiMessage(l10n.chatPaywallPhotoOpening);
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(pendingNavigation: '/ai-photo');
      }
      return;
    }

    if (flow == ChatFlow.mockInterview) {
      if (!sub.isPremium) {
        _addAiMessage(
          l10n.chatPaywallMockInterview,
          chips: [l10n.chatPaywallMockInterviewChip],
        );
        return;
      }
    }

    if (flow == ChatFlow.videoIntro) {
      if (!sub.isPremium) {
        _addAiMessage(
          l10n.chatPaywallVideoIntro,
          chips: [l10n.chatPaywallVideoIntroChip],
        );
        return;
      }
    }

    // Show first question
    final firstStep = AiResponseEngine.firstStep(flow, l10n);
    if (firstStep != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _addAiMessage(
        firstStep.question,
        chips: firstStep.chips,
        chipActions: firstStep.chipActions,
      );
      state = state.copyWith(step: 1);
    } else {
      // Flow with no steps — complete immediately
      final result = AiResponseEngine.next(
        flow: flow,
        step: 0,
        data: {},
        userInput: '',
        l: l10n,
      );
      if (result.isComplete && result.navigationTarget != null) {
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(
          pendingNavigation: result.navigationTarget,
          pendingNavigationExtra: result.navigationExtra,
        );
      }
    }
  }

  // ── User sends a message (step answer) ─────────────────────────────────────

  Future<void> sendMessage(String text, AppLocalizations l10n) async {
    if (text.trim().isEmpty) return;

    final trimmed = text.trim();

    // Handle paywall CTA chips ([PRO] prefix is language-independent)
    if (trimmed.startsWith('[PRO] ')) {
      _addUserMessage(trimmed);
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(pendingNavigation: '/soft-paywall');
      return;
    }

    // Handle "Generate" action chips — these complete the flow
    if (trimmed.startsWith('[GO] ')) {
      _addUserMessage(trimmed);
      await Future.delayed(const Duration(milliseconds: 400));
      await _triggerGenerate(state.flow, state.data, l10n);
      return;
    }

    final currentStep = state.step;
    final steps = _getStepKeys(state.flow);
    final dataKey = (currentStep > 0 && currentStep <= steps.length)
        ? steps[currentStep - 1]
        : 'input';

    _addUserMessage(trimmed);

    final updatedData = Map<String, String>.from(state.data)
      ..[dataKey] = trimmed;
    state = state.copyWith(data: updatedData, isTyping: true);

    await Future.delayed(const Duration(milliseconds: 700));

    final result = AiResponseEngine.next(
      flow: state.flow,
      step: currentStep,
      data: updatedData,
      userInput: trimmed,
      l: l10n,
    );

    if (result.isComplete) {
      if (result.nextQuestion != null) {
        _addAiMessage(result.nextQuestion!);
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      state = state.copyWith(
        isTyping: false,
        pendingNavigation: result.navigationTarget,
        pendingNavigationExtra: result.navigationExtra,
      );
    } else {
      // Skip ahead through any subsequent steps whose data was already
      // collected upstream (e.g. populated by a PDF/LinkedIn parse). This
      // avoids re-asking the user for data we already have.
      final nextStep = _findNextUnansweredStep(currentStep + 1, updatedData);
      if (nextStep == null) {
        // Everything else is already filled — go straight to generate.
        await _triggerGenerate(state.flow, updatedData, l10n);
        return;
      }
      if (nextStep != currentStep + 1) {
        // We're skipping. Re-derive the next question from the first
        // unanswered step instead of the immediate next one.
        final skippedResult = AiResponseEngine.next(
          flow: state.flow,
          step: nextStep - 1,
          data: updatedData,
          userInput: '',
          l: l10n,
        );
        if (skippedResult.nextQuestion != null) {
          _addAiMessage(
            skippedResult.nextQuestion!,
            chips: skippedResult.chips,
            chipActions: skippedResult.chipActions,
          );
        }
      } else if (result.nextQuestion != null) {
        _addAiMessage(
          result.nextQuestion!,
          chips: result.chips,
          chipActions: result.chipActions,
        );
      }
      state = state.copyWith(step: nextStep, isTyping: false);
    }
  }

  /// Walks forward from [fromStep] through the current flow's step keys and
  /// returns the index (1-based) of the first step whose data is missing.
  /// Returns null when every remaining step is already filled — signal to the
  /// caller that the flow can finish without more questions.
  int? _findNextUnansweredStep(int fromStep, Map<String, String> data) {
    final keys = _getStepKeys(state.flow);
    for (var i = fromStep; i <= keys.length; i++) {
      final key = keys[i - 1];
      final value = data[key];
      if (value == null || value.trim().isEmpty) return i;
    }
    return null;
  }

  // ── Trigger final generation action ────────────────────────────────────────

  Future<void> _triggerGenerate(
    ChatFlow flow,
    Map<String, String> data,
    AppLocalizations l10n,
  ) async {
    switch (flow) {
      case ChatFlow.resume:
        _addAiMessage(l10n.chatResumeGenerate);
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/resume/new',
          pendingNavigationExtra: {
            'prefill': {
              'targetRole': data['targetRole'] ?? '',
              'seniority': data['seniority'] ?? '',
              'recentExp': data['recentExp'] ?? '',
              'skills': data['skills'] ?? '',
              'education': data['education'] ?? '',
            },
          },
        );

      case ChatFlow.coverLetter:
        _addAiMessage(l10n.chatCoverLetterGenerate);
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/cover-letter',
          pendingNavigationExtra: {
            'prefill': {
              'company': data['company'] ?? '',
              'role': data['role'] ?? '',
              'jobDescription': data['jobDescription'] ?? '',
              'tone': data['tone'] ?? 'professional',
            },
          },
        );

      case ChatFlow.interview:
        _addAiMessage(l10n.chatInterviewGenerate);
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/interview-prep',
          pendingNavigationExtra: {
            'prefill': {
              'role': data['role'] ?? '',
              'seniority': data['seniority'] ?? '',
              'focusArea': data['focusArea'] ?? l10n.chatInterviewChipAllAbove,
            },
          },
        );

      case ChatFlow.videoIntro:
        _addAiMessage(l10n.chatVideoGenerate);
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/video-script',
          pendingNavigationExtra: {
            'prefill': {
              'role': data['role'] ?? '',
              'duration': data['duration'] ?? '30 seconds',
              'tone': data['tone'] ?? 'Formal',
            },
          },
        );

      case ChatFlow.mockInterview:
        _addAiMessage(l10n.chatMockGenerate);
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/mock-interview',
          pendingNavigationExtra: {
            'role': data['role'] ?? 'Software Engineer',
            'seniority': data['seniority'] ?? 'Mid-level',
          },
        );

      case ChatFlow.networking:
        _addAiMessage(l10n.chatNetGenerate);
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/networking-result',
          pendingNavigationExtra: {
            'messageType': data['messageType'] ?? 'Networking message',
            'recipient': data['recipient'] ?? 'Recruiter',
            'company': data['company'] ?? '',
            'context': data['context'] ?? '',
            'tone': data['tone'] ?? 'Professional',
          },
        );

      case ChatFlow.jobPlan:
        state = state.copyWith(isTyping: true);
        _addAiMessage(l10n.chatJobPlanGenAnalyzing);
        await Future.delayed(const Duration(milliseconds: 1100));
        _addAiMessage(l10n.chatJobPlanGenMatching);
        await Future.delayed(const Duration(milliseconds: 900));
        _addAiMessage(l10n.chatJobPlanGenCreating);
        await Future.delayed(const Duration(milliseconds: 700));
        state = state.copyWith(
          isTyping: false,
          pendingNavigation: '/job-plan',
          pendingNavigationExtra: {
            'jobDescription': data['jobDescription'] ?? '',
          },
        );

      default:
        break;
    }
  }

  // ── Resume Q1 chip handlers ────────────────────────────────────────────────

  /// User chose "Start from scratch" on resume Q1. Records the answer and
  /// advances to the targetRole question (Q2). Mirrors what sendMessage()
  /// would do for a regular text answer, but is triggered explicitly so the
  /// UI can call it without language-dependent string matching.
  Future<void> startResumeFromScratch(AppLocalizations l10n) async {
    if (state.flow != ChatFlow.resume || state.step != 1) return;

    _addUserMessage(l10n.chatResumeChipFromScratch);
    final updatedData = Map<String, String>.from(state.data)
      ..['hasCV'] = 'scratch';
    state = state.copyWith(data: updatedData, isTyping: true);

    await Future.delayed(const Duration(milliseconds: 600));

    final result = AiResponseEngine.next(
      flow: state.flow,
      step: 1,
      data: updatedData,
      userInput: 'scratch',
      l: l10n,
    );

    if (result.nextQuestion != null) {
      _addAiMessage(
        result.nextQuestion!,
        chips: result.chips,
        chipActions: result.chipActions,
      );
    }
    state = state.copyWith(step: 2, isTyping: false);
  }

  /// Called from the chat page after the user picked a CV file and the AI
  /// router has parsed it. Stores the parsed values into the chat data map
  /// (so they will flow into the resume wizard prefill) and posts a summary
  /// message with a "Continue" chip that advances to the targetRole question.
  Future<void> applyParsedCv({
    required ParsedProfile parsed,
    required String fileName,
    required AppLocalizations l10n,
  }) async {
    if (state.flow != ChatFlow.resume) return;

    // Pre-populate the data the resume wizard expects so we can skip the
    // recentExp / skills / education steps later.
    final updatedData = Map<String, String>.from(state.data);
    updatedData['hasCV'] = fileName;
    if (parsed.skills.isNotEmpty) {
      updatedData['skills'] = parsed.skills.join(', ');
    }
    if (parsed.experiences.isNotEmpty) {
      updatedData['recentExp'] = parsed.experiences.join('\n');
    }
    if (parsed.education.isNotEmpty) {
      updatedData['education'] = parsed.education.join('\n');
    }
    if (parsed.summary != null && parsed.summary!.isNotEmpty) {
      updatedData['summary'] = parsed.summary!;
    }

    final summary = _buildCvSummary(parsed, l10n);
    state = state.copyWith(data: updatedData, isTyping: true);
    await Future.delayed(const Duration(milliseconds: 600));

    _addAiMessage(
      summary,
      chips: [l10n.chatCvParsedContinueChip],
      chipActions: [ChipAction.cvContinue],
    );
    state = state.copyWith(isTyping: false);
  }

  /// Called when the user accepts the parsed CV summary and wants to
  /// continue. Asks the targetRole question (Q2) so we can build a polished
  /// resume tailored to a specific role.
  Future<void> continueAfterCv(AppLocalizations l10n) async {
    if (state.flow != ChatFlow.resume) return;

    _addUserMessage(l10n.chatCvParsedContinueChip);
    state = state.copyWith(isTyping: true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Skip ahead to step 2 (targetRole) regardless of where we were.
    final result = AiResponseEngine.next(
      flow: state.flow,
      step: 1,
      data: state.data,
      userInput: '',
      l: l10n,
    );
    if (result.nextQuestion != null) {
      _addAiMessage(
        result.nextQuestion!,
        chips: result.chips,
        chipActions: result.chipActions,
      );
    }
    state = state.copyWith(step: 2, isTyping: false);
  }

  /// User pasted a LinkedIn URL. We can't fetch profile contents from the
  /// client, so we record the URL into the chat data so it lands in the
  /// resume profile, then advance to targetRole. Honest behaviour: no
  /// fabricated data.
  Future<void> submitLinkedInUrl(String url, AppLocalizations l10n) async {
    if (state.flow != ChatFlow.resume || url.trim().isEmpty) return;

    final cleanUrl = url.trim();
    _addUserMessage(cleanUrl);

    final updatedData = Map<String, String>.from(state.data);
    updatedData['hasCV'] = 'linkedin';
    updatedData['linkedInUrl'] = cleanUrl;

    state = state.copyWith(data: updatedData, isTyping: true);
    await Future.delayed(const Duration(milliseconds: 600));

    _addAiMessage(l10n.chatLinkedInReceived);
    await Future.delayed(const Duration(milliseconds: 300));

    // Advance to the targetRole question.
    final result = AiResponseEngine.next(
      flow: state.flow,
      step: 1,
      data: updatedData,
      userInput: cleanUrl,
      l: l10n,
    );
    if (result.nextQuestion != null) {
      _addAiMessage(
        result.nextQuestion!,
        chips: result.chips,
        chipActions: result.chipActions,
      );
    }
    state = state.copyWith(step: 2, isTyping: false);
  }

  String _buildCvSummary(ParsedProfile parsed, AppLocalizations l10n) {
    final parts = <String>[];
    parts.add(l10n.chatCvParsedHeader);
    final stats = <String>[];
    if (parsed.experiences.isNotEmpty) {
      stats.add(l10n.chatCvParsedExperiences(parsed.experiences.length));
    }
    if (parsed.skills.isNotEmpty) {
      // Show up to 4 skill names so the message stays compact.
      final shownSkills = parsed.skills.take(4).join(', ');
      stats.add(l10n.chatCvParsedSkills(parsed.skills.length, shownSkills));
    }
    if (parsed.education.isNotEmpty) {
      stats.add(l10n.chatCvParsedEducation(parsed.education.length));
    }
    if (stats.isNotEmpty) parts.add(stats.join('\n'));
    parts.add(l10n.chatCvParsedQuestion);
    return parts.join('\n\n');
  }

  // ── Free-form message ──────────────────────────────────────────────────────

  static const _kCareerSystemPrompt =
      'You are AI Career Copilot, a friendly and knowledgeable career assistant. '
      'Help users with resumes, cover letters, interview preparation, job search, '
      'networking, and career development. '
      'Keep responses concise and actionable (2-4 sentences max unless asked for more). '
      'When a user asks about a specific feature (resume, cover letter, interview, '
      'photo studio, networking messages), suggest they use the dedicated tool by '
      'mentioning it. Be warm, encouraging, and professional. '
      'LANGUAGE RULE: Always respond in the same language the user writes in.';

  Future<void> sendFreeText(String text, AppLocalizations l10n) async {
    if (state.flow != ChatFlow.none) {
      // In an active flow: detect conversational vs step-answer
      if (_looksConversational(text.trim())) {
        await _chatInFlow(text.trim());
      } else {
        await sendMessage(text, l10n);
      }
      return;
    }

    _addUserMessage(text.trim());
    state = state.copyWith(isTyping: true);

    try {
      final aiRouter = ref.read(aiRouterProvider);

      // Build conversation history for context
      final history = <Map<String, String>>[
        {'role': 'system', 'content': _kCareerSystemPrompt},
        ...state.messages.map(
          (m) => {
            'role': m.role == MessageRole.ai ? 'assistant' : 'user',
            'content': m.text,
          },
        ),
        {'role': 'user', 'content': text.trim()},
      ];

      final response = await aiRouter.chatResponse(history);
      _addAiMessage(response);
    } catch (_) {
      // Fallback to keyword-based response if all APIs fail
      final lower = text.toLowerCase();
      if (lower.contains('resume') ||
          lower.contains('cv') ||
          lower.contains('özgeçmiş') ||
          lower.contains('ozgecmis')) {
        _addAiMessage(
          l10n.chatFallbackResume,
          chips: [l10n.chatFallbackResumeChip],
        );
      } else if (lower.contains('cover') ||
          lower.contains('letter') ||
          lower.contains('ön yazı') ||
          lower.contains('on yazi')) {
        _addAiMessage(
          l10n.chatFallbackCoverLetter,
          chips: [l10n.chatFallbackCoverLetterChip],
        );
      } else if (lower.contains('interview') ||
          lower.contains('mülakat') ||
          lower.contains('mulakat')) {
        _addAiMessage(
          l10n.chatFallbackInterview,
          chips: [l10n.chatFallbackInterviewChip],
        );
      } else {
        _addAiMessage(
          l10n.chatFallbackGeneral,
          chips: [
            l10n.chatFallbackChipResume,
            l10n.chatFallbackChipCoverLetter,
            l10n.chatFallbackChipInterview,
            l10n.chatFallbackChipNetworking,
          ],
        );
      }
    }

    state = state.copyWith(isTyping: false);
  }

  // ── In-flow conversational AI response ─────────────────────────────────────

  /// Decides whether free-text the user typed during a structured flow looks
  /// like a side question / greeting (route to AI) or a real step answer
  /// (advance the flow). When in doubt we treat it as an answer — interrupting
  /// a flow with a chatty reply is more annoying than a brief AI tangent.
  bool _looksConversational(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return false;
    final t = raw.toLowerCase();

    // 1. Anything ending with a question mark in any script.
    if (t.endsWith('?') || t.endsWith('？') || t.endsWith('؟')) return true;

    // 2. Known greetings / pleasantries (multilingual).
    const greetings = [
      'merhaba',
      'selam',
      'nasılsın',
      'nasilsin',
      'naber',
      'merhabalar',
      'günaydın',
      'gunaydin',
      'iyi günler',
      'iyi gunler',
      'iyi akşamlar',
      'iyi aksamlar',
      'hello',
      'hi there',
      'hey there',
      'good morning',
      'good afternoon',
      'good evening',
      'thanks',
      'thank you',
      'teşekkür',
      'tesekkur',
      'sağol',
      'sagol',
      'sağ ol',
      'sag ol',
      'hola',
      'buenos días',
      'buenos dias',
      'gracias',
      'bonjour',
      'merci',
      'salut',
      'hallo',
      'guten tag',
      'danke',
      'ciao',
      'grazie',
      'こんにちは',
      '你好',
      '안녕',
    ];
    for (final p in greetings) {
      if (t == p ||
          t.startsWith('$p ') ||
          t.startsWith('$p,') ||
          t.startsWith('$p!') ||
          t.startsWith('$p.')) {
        return true;
      }
    }

    // 3. Question-word starts (common interrogatives) — e.g. "what is X",
    //    "how do I…", "ne yapmaliyim", "nedir bu". Single word answers like
    //    "Python" obviously won't match.
    const questionWords = [
      'what',
      'how',
      'why',
      'when',
      'where',
      'who',
      'which',
      'can you',
      'could you',
      'would you',
      'is it',
      'are you',
      'do you',
      'ne ',
      'nedir',
      'nasıl',
      'nasil',
      'neden',
      'niye',
      'niçin',
      'nicin',
      'nerede',
      'kim',
      'hangi',
      'kaç',
      'kac',
      'mı ',
      'mi ',
      'mu ',
      'mü ',
      'qué',
      'que ',
      'cómo',
      'como ',
      'por qué',
      'porque',
      'quoi',
      'comment',
      'pourquoi',
      'was ',
      'wie ',
      'warum',
      'cosa',
      'come ',
      'perché',
      'perche',
    ];
    for (final p in questionWords) {
      if (t == p.trim() || t.startsWith(p)) return true;
    }

    // 4. Long sentences (more than ~12 words) inside short-answer steps look
    //    more like commentary than an answer. We only treat them as chat when
    //    the current step expects a short answer (chips, role, seniority).
    final wordCount = raw.split(RegExp(r'\s+')).length;
    if (wordCount > 14 && _stepExpectsShortAnswer()) return true;

    return false;
  }

  /// Returns true when the current flow step is asking for a short, structured
  /// answer (single word, chip pick, role title, etc.). Used by
  /// [_looksConversational] to decide whether a long sentence is an answer or
  /// a side question.
  bool _stepExpectsShortAnswer() {
    final keys = _getStepKeys(state.flow);
    if (state.step <= 0 || state.step > keys.length) return false;
    final key = keys[state.step - 1];
    const shortKeys = {
      'hasCV',
      'targetRole',
      'role',
      'seniority',
      'tone',
      'duration',
      'focusArea',
      'messageType',
      'recipient',
      'company',
      'uploadMethod',
    };
    return shortKeys.contains(key);
  }

  /// Sends user text to AI without advancing the flow step.
  Future<void> _chatInFlow(String text) async {
    _addUserMessage(text);
    state = state.copyWith(isTyping: true);

    try {
      final aiRouter = ref.read(aiRouterProvider);
      final history = <Map<String, String>>[
        {'role': 'system', 'content': _kCareerSystemPrompt},
        ...state.messages.map(
          (m) => {
            'role': m.role == MessageRole.ai ? 'assistant' : 'user',
            'content': m.text,
          },
        ),
      ];
      final response = await aiRouter.chatResponse(history);
      _addAiMessage(response);
    } catch (_) {
      // Minimal fallback — just acknowledge
      _addAiMessage('Hi there!');
    }

    state = state.copyWith(isTyping: false);
  }

  void clearNavigation() => state = state.copyWith(clearNav: true);
  void setListening(bool v) => state = state.copyWith(isListening: v);
  void setTyping(bool v) => state = state.copyWith(isTyping: v);
  void reset() => state = const ChatState();

  /// Adds a user message representing a picked file (used by the chat page
  /// when a CV upload starts so the chat shows what the user did before the
  /// AI parses it).
  void addUserFileMessage(String fileName) {
    _addUserMessage(fileName);
  }

  /// Posts an AI message from outside the notifier (e.g. error fallback when
  /// CV parsing failed in the chat page).
  void postAiMessage(String text, {List<String>? chips}) {
    _addAiMessage(text, chips: chips);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  ChatMessage _makeAi(
    String text, {
    List<String>? chips,
    List<String?>? chipActions,
  }) => ChatMessage(
    id: _uuid.v4(),
    role: MessageRole.ai,
    text: text,
    createdAt: DateTime.now(),
    chips: chips,
    chipActions: chipActions,
  );

  void _addAiMessage(
    String text, {
    List<String>? chips,
    List<String?>? chipActions,
  }) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        _makeAi(text, chips: chips, chipActions: chipActions),
      ],
      isTyping: false,
    );
  }

  void _addUserMessage(String text) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: _uuid.v4(),
          role: MessageRole.user,
          text: text,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  List<String> _getStepKeys(ChatFlow flow) {
    const keys = <ChatFlow, List<String>>{
      ChatFlow.resume: [
        'hasCV',
        'targetRole',
        'seniority',
        'recentExp',
        'skills',
        'education',
      ],
      ChatFlow.coverLetter: ['company', 'role', 'jobDescription', 'tone'],
      ChatFlow.interview: ['role', 'seniority', 'focusArea'],
      ChatFlow.cvUpload: ['uploadMethod'],
      ChatFlow.jobMatch: ['jobDescription'],
      ChatFlow.videoIntro: ['role', 'duration', 'tone'],
      ChatFlow.skillGap: ['jobDescription'],
      ChatFlow.mockInterview: ['role', 'seniority'],
      ChatFlow.networking: ['messageType', 'recipient', 'context', 'tone'],
      ChatFlow.aiPhoto: [],
      ChatFlow.jobPlan: ['jobDescription'],
      ChatFlow.none: [],
    };
    return keys[flow] ?? [];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

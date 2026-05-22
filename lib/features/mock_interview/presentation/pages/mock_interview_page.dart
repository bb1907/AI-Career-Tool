import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../paywall/presentation/widgets/hard_paywall_sheet.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../features/interview_prep/domain/interview_question.dart';
import '../../../../ui/components/app_card.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _AnswerWithFeedback {
  final InterviewQuestion question;
  final String userAnswer;
  final Map<String, dynamic> feedback;
  final String scoreLabel; // 'Strong' | 'Good' | 'Weak'

  const _AnswerWithFeedback({
    required this.question,
    required this.userAnswer,
    required this.feedback,
    required this.scoreLabel,
  });
}

String _scoreLabelFromInt(int score) {
  if (score >= 75) return 'Strong';
  if (score >= 50) return 'Good';
  return 'Weak';
}

Color _colorForLabel(String label) {
  switch (label) {
    case 'Strong':
      return AppColors.success;
    case 'Good':
      return AppColors.warning;
    default:
      return AppColors.error;
  }
}

int _pointsForLabel(String label) {
  switch (label) {
    case 'Strong':
      return 10;
    case 'Good':
      return 7;
    default:
      return 4;
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class MockInterviewPage extends ConsumerStatefulWidget {
  final String role;
  final String seniority;

  const MockInterviewPage({
    super.key,
    required this.role,
    required this.seniority,
  });

  @override
  ConsumerState<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends ConsumerState<MockInterviewPage>
    with TickerProviderStateMixin {
  List<InterviewQuestion> _questions = [];
  int _currentIndex = 0;
  final List<_AnswerWithFeedback> _session = [];
  bool _loading = true;
  bool _answerPending = false;
  bool _finished = false;

  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;
  bool _sttAvailable = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initStt();
    _loadQuestions();
  }

  Future<void> _initStt() async {
    final available = await _stt.initialize();
    if (mounted) setState(() => _sttAvailable = available);
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;
    if (!await ensureAiDataConsent(context, ref)) {
      if (mounted) context.pop();
      return;
    }
    final sub = ref.read(subscriptionProvider);
    if (sub.isBlocked(FeatureType.mockInterview)) {
      if (!mounted) return;
      showHardPaywall(context, HardPaywallType.mockInterview);
      context.pop();
      return;
    }

    try {
      final aiRouter = ref.read(aiRouterProvider);
      final questions = await aiRouter.generateInterviewQuestions(
        role: widget.role,
        seniority: widget.seniority,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Fallback to mock questions
      setState(() {
        _questions = [
          InterviewQuestion(
            question:
                'Tell me about yourself and your experience as a ${widget.role}.',
            category: QuestionCategory.behavioral,
            sampleAnswer:
                'Start with a brief overview of your background, key skills, and what brings you to this role.',
          ),
          InterviewQuestion(
            question:
                'Describe a challenging project you worked on and how you overcame obstacles.',
            category: QuestionCategory.behavioral,
            sampleAnswer:
                'Use the STAR method: describe the Situation, Task, Action you took, and the Result achieved.',
          ),
          InterviewQuestion(
            question:
                'Where do you see yourself in 5 years, and how does this role fit into that vision?',
            category: QuestionCategory.behavioral,
            sampleAnswer:
                'Align your growth goals with the role and company direction, showing ambition balanced with commitment.',
          ),
        ];
        _loading = false;
      });
    }
  }

  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _answerPending) return;

    _answerController.clear();
    final question = _questions[_currentIndex];

    setState(() => _answerPending = true);

    try {
      final aiRouter = ref.read(aiRouterProvider);
      final feedback = await aiRouter.evaluateInterviewAnswer(
        question: question.question,
        answer: answer,
        role: widget.role,
      );

      if (!mounted) return;

      final rawScore = (feedback['score'] as num?)?.toInt() ?? 50;
      final scoreLabel = _scoreLabelFromInt(rawScore);

      final entry = _AnswerWithFeedback(
        question: question,
        userAnswer: answer,
        feedback: feedback,
        scoreLabel: scoreLabel,
      );

      final isLast = _currentIndex >= _questions.length - 1;

      setState(() {
        _session.add(entry);
        _answerPending = false;
        if (isLast) {
          _finished = true;
        } else {
          _currentIndex++;
        }
      });

      // Scroll to bottom after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _answerPending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not evaluate answer: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleListening() async {
    if (!_sttAvailable) return;
    if (_isListening) {
      await _stt.stop();
      if (mounted) setState(() => _isListening = false);
    } else {
      final started = await _stt.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _answerController.text = result.recognizedWords;
              _answerController.selection = TextSelection.fromPosition(
                TextPosition(offset: _answerController.text.length),
              );
            });
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
      if (mounted) setState(() => _isListening = started);
    }
  }

  void _resetSession() {
    setState(() {
      _session.clear();
      _currentIndex = 0;
      _finished = false;
      _answerController.clear();
    });
    _loadQuestions();
    setState(() => _loading = true);
  }

  int get _overallScore {
    if (_session.isEmpty) return 0;
    final total = _session.fold<int>(
      0,
      (sum, e) => sum + _pointsForLabel(e.scoreLabel),
    );
    return (total / _session.length).round();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _answerController.dispose();
    _scrollController.dispose();
    _stt.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.l10n.mockInterviewTitle,
          style: TextStyle(
            color: context.appText1,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_loading && !_finished)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${_questions.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.appBorder),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _loading
            ? _buildLoadingState()
            : _finished
            ? _buildSummaryState()
            : _buildChatState(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return Center(
      key: const ValueKey('loading'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.mockInterviewLoading,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText2,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chat state
  // ---------------------------------------------------------------------------

  Widget _buildChatState() {
    return Column(
      key: const ValueKey('chat'),
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            children: [
              ..._session.expand(
                (entry) => [
                  _AiQuestionBubble(question: entry.question.question),
                  const SizedBox(height: AppSpacing.sm),
                  _UserAnswerBubble(answer: entry.userAnswer),
                  const SizedBox(height: AppSpacing.sm),
                  _AiFeedbackBubble(
                    feedback: entry.feedback,
                    scoreLabel: entry.scoreLabel,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
              if (_currentIndex < _questions.length) ...[
                _AiQuestionBubble(question: _questions[_currentIndex].question),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (_answerPending) ...[
                const _TypingIndicator(),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        if (!_answerPending)
          _InputBar(
            controller: _answerController,
            isListening: _isListening,
            sttAvailable: _sttAvailable,
            onSend: _submitAnswer,
            onMicTap: _toggleListening,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Summary state
  // ---------------------------------------------------------------------------

  Widget _buildSummaryState() {
    final score = _overallScore;
    final weakAreas = _session
        .where((e) => e.scoreLabel == 'Weak')
        .map((e) => e.question.category.name)
        .toSet()
        .toList();

    return SingleChildScrollView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score hero
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: score / 10,
                        strokeWidth: 8,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          '/ 10',
                          style: TextStyle(
                            color: context.appText2,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Interview Complete',
                  style: TextStyle(
                    color: context.appText1,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_session.length} question${_session.length == 1 ? '' : 's'} answered',
                  style: TextStyle(color: context.appText2, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Score breakdown
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.mockInterviewSummaryTitle,
                  style: TextStyle(
                    color: context.appText1,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ..._session.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'Q${idx + 1}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item.question.question,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.appText2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ScorePill(label: item.scoreLabel),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Areas to improve
          if (weakAreas.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        context.l10n.mockInterviewWeakAreas,
                        style: TextStyle(
                          color: context.appText1,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...weakAreas.map(
                    (area) => Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: AppColors.warning, size: 6),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            area,
                            style: TextStyle(
                              color: context.appText2,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Action buttons
          FilledButton.icon(
            onPressed: _resetSession,
            icon: const Icon(Icons.replay_rounded),
            label: Text(context.l10n.mockInterviewNewSession),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              // Expand/scroll to questions — show a simple bottom sheet recap
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: context.appSurface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.card),
                  ),
                ),
                builder: (_) => _QuestionsRecapSheet(session: _session),
              );
            },
            icon: const Icon(Icons.list_alt_rounded),
            label: const Text('View Questions'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble widgets
// ---------------------------------------------------------------------------

class _AiQuestionBubble extends StatelessWidget {
  final String question;
  const _AiQuestionBubble({required this.question});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
                bottomRight: Radius.circular(AppRadius.card),
              ),
              border: Border.all(color: context.appBorder),
            ),
            child: Text(
              question,
              style: TextStyle(
                color: context.appText1,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _UserAnswerBubble extends StatelessWidget {
  final String answer;
  const _UserAnswerBubble({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 44),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withBlue(220)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
                bottomRight: Radius.circular(AppRadius.card),
              ),
            ),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiFeedbackBubble extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final String scoreLabel;

  const _AiFeedbackBubble({required this.feedback, required this.scoreLabel});

  @override
  Widget build(BuildContext context) {
    final summary = (feedback['summary'] as String?) ?? '';
    final improvements = List<String>.from(
      feedback['improvements'] as List? ?? [],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _colorForLabel(scoreLabel).withValues(alpha: 0.15),
            border: Border.all(color: _colorForLabel(scoreLabel), width: 1.5),
          ),
          child: Icon(
            scoreLabel == 'Strong'
                ? Icons.star_rounded
                : scoreLabel == 'Good'
                ? Icons.thumb_up_rounded
                : Icons.trending_up_rounded,
            color: _colorForLabel(scoreLabel),
            size: 16,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _colorForLabel(scoreLabel).withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
                bottomRight: Radius.circular(AppRadius.card),
              ),
              border: Border.all(
                color: _colorForLabel(scoreLabel).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ScorePill(label: scoreLabel),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      context.l10n.mockInterviewFeedbackLabel,
                      style: TextStyle(
                        color: context.appText1,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    summary,
                    style: TextStyle(
                      color: context.appText2,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
                if (improvements.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ...improvements.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_right_rounded,
                            size: 16,
                            color: context.appText2,
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                color: context.appText2,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 16,
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.mockInterviewThinking,
                style: TextStyle(color: context.appText2, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Input bar
// ---------------------------------------------------------------------------

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool sttAvailable;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  const _InputBar({
    required this.controller,
    required this.isListening,
    required this.sttAvailable,
    required this.onSend,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.appSurface,
          border: Border(top: BorderSide(color: context.appBorder)),
        ),
        child: Row(
          children: [
            if (sttAvailable)
              IconButton(
                onPressed: onMicTap,
                icon: Icon(
                  isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: isListening ? AppColors.error : context.appText2,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isListening
                      ? AppColors.error.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: context.l10n.mockInterviewTypeAnswer,
                  hintStyle: TextStyle(
                    color: context.appText2.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: context.appBG,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: context.appText1, fontSize: 14),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score pill
// ---------------------------------------------------------------------------

class _ScorePill extends StatelessWidget {
  final String label;
  const _ScorePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _colorForLabel(label);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label == 'Strong'
            ? context.l10n.mockInterviewStrong
            : label == 'Good'
            ? context.l10n.mockInterviewGood
            : context.l10n.mockInterviewWeak,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Questions recap bottom sheet
// ---------------------------------------------------------------------------

class _QuestionsRecapSheet extends StatelessWidget {
  final List<_AnswerWithFeedback> session;
  const _QuestionsRecapSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Interview Questions',
              style: TextStyle(
                color: context.appText1,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: session.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, idx) {
                  final item = session[idx];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Q${idx + 1}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            _ScorePill(label: item.scoreLabel),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.question.question,
                          style: TextStyle(
                            color: context.appText1,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

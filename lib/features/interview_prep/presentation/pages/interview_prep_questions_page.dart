import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/ai_score_badge.dart';
import '../../../../ui/components/teaser_overlay.dart';
import '../../domain/interview_question.dart';

class InterviewPrepQuestionsPage extends ConsumerStatefulWidget {
  final List<InterviewQuestion> questions;
  final bool isTeaser;

  const InterviewPrepQuestionsPage({
    super.key,
    required this.questions,
    this.isTeaser = false,
  });

  @override
  ConsumerState<InterviewPrepQuestionsPage> createState() =>
      _InterviewPrepQuestionsPageState();
}

class _InterviewPrepQuestionsPageState
    extends ConsumerState<InterviewPrepQuestionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _saved = false;

  // Mock readiness score based on question count
  int get _readinessScore {
    final count = widget.questions.length;
    if (count >= 10) return 88;
    if (count >= 7) return 79;
    return 72;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<InterviewQuestion> get _technical => widget.questions
      .where((q) => q.category == QuestionCategory.technical)
      .toList();

  List<InterviewQuestion> get _behavioral => widget.questions
      .where((q) => q.category == QuestionCategory.behavioral)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.interviewPrepQuestionsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_saved)
            IconButton(
              icon: const Icon(Icons.bookmark_outline_rounded),
              tooltip: 'Saved to history',
              onPressed: () {
                setState(() => _saved = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved to history'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Icon(Icons.bookmark_rounded, color: AppColors.primary),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code_rounded, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${context.l10n.interviewPrepCategoryTechnical} (${_technical.length})',
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline_rounded, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${context.l10n.interviewPrepCategoryBehavioral} (${_behavioral.length})',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Readiness score banner
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: AiScoreBadge(score: _readinessScore),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _QuestionList(questions: _technical, isTeaser: widget.isTeaser),
                _QuestionList(
                  questions: _behavioral,
                  isTeaser: widget.isTeaser,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.l10n.interviewPrepGenerate),
            onPressed: () => context.pop(),
          ),
        ),
      ),
    );
  }
}

class _QuestionList extends StatelessWidget {
  final List<InterviewQuestion> questions;
  final bool isTeaser;

  const _QuestionList({required this.questions, this.isTeaser = false});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: Text('No questions available.'));
    }

    // Always show first 2 questions; tease the rest when isTeaser is true
    const freeCount = 2;
    final freeQuestions = questions.take(freeCount).toList();
    final lockedQuestions = questions.skip(freeCount).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Always-visible first 2 questions
          ...freeQuestions.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _QuestionCard(question: e.value, index: e.key + 1),
            ),
          ),
          // Remaining questions — teased or fully visible
          if (lockedQuestions.isNotEmpty)
            TeaserOverlay(
              isTeaser: isTeaser,
              featureLabel: 'Interview Prep',
              readyMessage:
                  '${questions.length} interview questions ready for you!',
              child: Column(
                children: lockedQuestions
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _QuestionCard(
                          question: e.value,
                          index: freeCount + e.key + 1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final InterviewQuestion question;
  final int index;
  const _QuestionCard({required this.question, required this.index});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _expanded = false;
  bool _showCoaching = false;

  static const _coachingTips = [
    'Use the STAR method: Situation, Task, Action, Result',
    'Be specific — avoid vague answers with concrete examples',
    'Quantify your impact where possible (numbers, percentages)',
    'Keep your answer focused and under 2 minutes',
    'Practice out loud to improve your delivery and confidence',
  ];

  String get _coachingTip {
    final idx = widget.index % _coachingTips.length;
    return _coachingTips[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isTechnical = widget.question.category == QuestionCategory.technical;

    final accentColor = isTechnical
        ? AppColors.primary
        : const Color(0xFF9B5DE5);
    final bgGradient = isTechnical
        ? AppTheme.subtleGradient
        : const LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: context.appBorder),
        boxShadow: AppShadows.card(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: isTechnical
                            ? AppTheme.primaryGradient
                            : const LinearGradient(
                                colors: [Color(0xFF9B5DE5), Color(0xFFB980F0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.question.question,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.appText2,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                // Answer panel
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.md,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  gradient: bgGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb_rounded,
                                          size: 13,
                                          color: accentColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          context
                                              .l10n
                                              .interviewPrepSampleAnswer,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: accentColor,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      widget.question.sampleAnswer,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(height: 1.65),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Coaching tip
                            const SizedBox(height: AppSpacing.sm),
                            GestureDetector(
                              onTap: () => setState(
                                () => _showCoaching = !_showCoaching,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Coaching Tip',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  AnimatedRotation(
                                    turns: _showCoaching ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              child: _showCoaching
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.xs,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withValues(
                                            alpha: 0.07,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: AppColors.accent.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _coachingTip,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: context.isDark
                                                    ? AppColors.accent
                                                          .withValues(
                                                            alpha: 0.9,
                                                          )
                                                    : const Color(0xFF007A6B),
                                              ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

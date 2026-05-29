import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../applications/presentation/providers/application_controller.dart';
import '../../domain/job_plan.dart';
import '../providers/job_plan_provider.dart';

class JobPlanPage extends ConsumerStatefulWidget {
  final String jobDescription;
  const JobPlanPage({super.key, required this.jobDescription});

  @override
  ConsumerState<JobPlanPage> createState() => _JobPlanPageState();
}

class _JobPlanPageState extends ConsumerState<JobPlanPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _loadingStep = 0;

  static const _loadingMessages = [
    'Analyzing job requirements...',
    'Matching your profile...',
    'Creating your application plan...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _cycleLoadingMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobPlanProvider.notifier).analyze(widget.jobDescription);
    });
  }

  Future<void> _cycleLoadingMessages() async {
    for (int i = 0; i < _loadingMessages.length; i++) {
      if (!mounted) return;
      setState(() => _loadingStep = i);
      await Future.delayed(const Duration(milliseconds: 1400));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(jobPlanProvider);
    final sub = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appBG,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.appText1),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Application Plan',
          style: TextStyle(
            color: context.appText1,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: context.appText2, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(),
        data: (plan) =>
            plan == null ? _buildLoading() : _buildContent(plan, sub),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) => Transform.scale(
                scale: 0.92 + _pulseController.value * 0.12,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _loadingMessages[_loadingStep],
                key: ValueKey(_loadingStep),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This takes about 10 seconds',
              style: TextStyle(fontSize: 13, color: context.appText2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Analysis failed',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again',
              style: TextStyle(fontSize: 13, color: context.appText2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref
                  .read(jobPlanProvider.notifier)
                  .analyze(widget.jobDescription),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(JobPlan plan, SubscriptionState sub) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.role,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (plan.company.isNotEmpty &&
                        plan.company != 'Unknown Company')
                      Text(
                        plan.company,
                        style: TextStyle(fontSize: 13, color: context.appText2),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 1. Match Score
        _MatchScoreCard(plan: plan),
        const SizedBox(height: 12),

        // 2. Skill Gap
        _SkillGapCard(plan: plan),
        const SizedBox(height: 12),

        // 3. Tailored Resume (pro)
        _GatedCard(
          isPro: sub.isPremium,
          featureName: 'Tailored Resume',
          icon: Icons.description_rounded,
          accentColor: AppColors.primary,
          teaserTitle: 'Resume optimized for this role',
          teaserBody: plan.matchingSkills.isEmpty
              ? 'Keywords highlighted for ATS optimization'
              : 'Highlights: ${plan.matchingSkills.take(4).join(" · ")}',
          buttonLabel: 'Generate Tailored Resume',
          onAction: () => context.push('/resume/new'),
        ),
        const SizedBox(height: 12),

        // 4. Tailored Cover Letter (pro)
        _GatedCard(
          isPro: sub.isPremium,
          featureName: 'Tailored Cover Letter',
          icon: Icons.mail_rounded,
          accentColor: const Color(0xFF00C2A8),
          teaserTitle: 'Cover letter matched to job requirements',
          teaserBody: 'Personalized for ${plan.company} — ${plan.role}',
          buttonLabel: 'Generate Cover Letter',
          onAction: () => context.push(
            '/cover-letter',
            extra: {
              'prefill': {
                'company': plan.company,
                'role': plan.role,
                'jobDescription': plan.jobDescription,
                'tone': 'Professional',
              },
            },
          ),
        ),
        const SizedBox(height: 12),

        // 5. Interview Prep (pro)
        _GatedCard(
          isPro: sub.isPremium,
          featureName: 'Interview Prep',
          icon: Icons.psychology_rounded,
          accentColor: const Color(0xFFF59E0B),
          teaserTitle: 'Questions prepared for ${plan.role}',
          teaserBody: '15 role-specific questions with coaching tips',
          buttonLabel: 'Start Interview Prep',
          onAction: () => context.push(
            '/interview-prep',
            extra: {
              'prefill': {'role': plan.role, 'seniority': 'Mid-level'},
            },
          ),
        ),
        const SizedBox(height: 12),

        // 6. Photo Suggestion (pro max)
        _PhotoSuggestionCard(plan: plan, sub: sub),
        const SizedBox(height: 12),

        // 7. Networking (pro)
        _GatedCard(
          isPro: sub.isPremium,
          featureName: 'Networking Message',
          icon: Icons.connect_without_contact_rounded,
          accentColor: const Color(0xFF9B5DE5),
          teaserTitle: 'Reach out to recruiters at ${plan.company}',
          teaserBody: 'Cold outreach message tailored to this role',
          buttonLabel: 'Generate Message',
          onAction: () => context.push(
            '/networking-result',
            extra: {
              'messageType': 'Cold outreach',
              'recipient': 'Recruiter',
              'company': plan.company,
              'context': 'Applying for ${plan.role}',
              'tone': 'Professional',
            },
          ),
        ),
        const SizedBox(height: 12),

        // 8. Checklist
        _ChecklistCard(plan: plan),
        const SizedBox(height: 12),

        // 9. Track Application CTA
        _TrackApplicationCard(plan: plan),
      ],
    );
  }
}

// ── 1. Match Score Card ──────────────────────────────────────────────────────

class _MatchScoreCard extends StatelessWidget {
  final JobPlan plan;
  const _MatchScoreCard({required this.plan});

  Color get _scoreColor {
    if (plan.matchScore >= 80) return AppColors.success;
    if (plan.matchScore >= 60) return const Color(0xFFF59E0B);
    return AppColors.error;
  }

  String get _scoreLabel {
    if (plan.matchScore >= 80) return 'Strong match for this role!';
    if (plan.matchScore >= 60) return 'Good match with some gaps';
    return 'Significant skill gaps identified';
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.analytics_rounded,
            iconColor: _scoreColor,
            title: 'Match Score',
            badge: _FreeBadge(),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: plan.matchScore / 100,
                    strokeWidth: 11,
                    backgroundColor: context.appBorder,
                    color: _scoreColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${plan.matchScore}%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _scoreColor,
                        letterSpacing: -1,
                      ),
                    ),
                    const Text(
                      'Match',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _scoreLabel,
              style: TextStyle(
                fontSize: 13,
                color: context.appText2,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Skill Gap Card ────────────────────────────────────────────────────────

class _SkillGapCard extends StatelessWidget {
  final JobPlan plan;
  const _SkillGapCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.primary,
            title: 'Skill Gap Analysis',
            badge: _FreeBadge(),
          ),

          if (plan.matchingSkills.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionLabel(
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              label: 'You have (${plan.matchingSkills.length})',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: plan.matchingSkills
                  .map((s) => _SkillChip(label: s, color: AppColors.success))
                  .toList(),
            ),
          ],

          if (plan.missingSkills.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionLabel(
              icon: Icons.cancel_rounded,
              color: AppColors.error,
              label: 'Missing (${plan.missingSkills.length})',
            ),
            const SizedBox(height: 8),
            ...plan.missingSkills.map(
              (skill) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Flexible(
                      child: _SkillChip(label: skill, color: AppColors.error),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.push('/resume/new'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Add to resume',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 6. Photo Suggestion Card ─────────────────────────────────────────────────

class _PhotoSuggestionCard extends StatelessWidget {
  final JobPlan plan;
  final SubscriptionState sub;
  const _PhotoSuggestionCard({required this.plan, required this.sub});

  bool get _isProMax => sub.plan == PlanType.proMax;

  @override
  Widget build(BuildContext context) {
    const accentGold = Color(0xFFF59E0B);
    const accentOrange = Color(0xFFEA580C);

    return _Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentGold, accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_enhance_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Photo Suggestion',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const Spacer(),
                  _ProMaxBadge(),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.sector.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plan.photoRecommendation,
                style: TextStyle(fontSize: 13, color: context.appText2),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentGold, accentOrange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FilledButton(
                    onPressed: _isProMax
                        ? () => context.push('/ai-photo')
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Transform Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Blur overlay for non-pro-max
          if (!_isProMax)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: context.appSurface.withValues(alpha: 0.72),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => context.push('/soft-paywall'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentGold, accentOrange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: accentGold.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Unlock with Pro Max',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Gated card (pro) ─────────────────────────────────────────────────────────

class _GatedCard extends StatelessWidget {
  final bool isPro;
  final String featureName;
  final IconData icon;
  final Color accentColor;
  final String teaserTitle;
  final String teaserBody;
  final String buttonLabel;
  final VoidCallback onAction;

  const _GatedCard({
    required this.isPro,
    required this.featureName,
    required this.icon,
    required this.accentColor,
    required this.teaserTitle,
    required this.teaserBody,
    required this.buttonLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  icon: icon,
                  iconColor: accentColor,
                  title: featureName,
                  badge: isPro ? null : _ProBadge(),
                ),
                const SizedBox(height: 12),
                Text(
                  teaserTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teaserBody,
                  style: TextStyle(fontSize: 13, color: context.appText2),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: isPro ? onAction : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: accentColor.withValues(
                        alpha: 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Blur overlay for free users
          if (!isPro)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: context.appSurface.withValues(alpha: 0.72),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => context.push('/soft-paywall'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Unlock with Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 9. Track Application CTA ──────────────────────────────────────────────────

class _TrackApplicationCard extends ConsumerStatefulWidget {
  final JobPlan plan;
  const _TrackApplicationCard({required this.plan});

  @override
  ConsumerState<_TrackApplicationCard> createState() =>
      _TrackApplicationCardState();
}

class _TrackApplicationCardState extends ConsumerState<_TrackApplicationCard> {
  bool _loading = false;

  Future<void> _track() async {
    setState(() => _loading = true);
    try {
      final app = await ref
          .read(applicationControllerProvider.notifier)
          .importFromPlan(widget.plan);
      if (mounted) {
        context.push('/applications/${app.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.work_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.applicationTrackFromPlan,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.applicationTrackFromPlanSubtitle,
                  style: TextStyle(fontSize: 12, color: context.appText2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: FilledButton(
              onPressed: _loading ? null : _track,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 8. Checklist Card ─────────────────────────────────────────────────────────

class _ChecklistCard extends ConsumerWidget {
  final JobPlan plan;
  const _ChecklistCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      (
        'resumeTailored',
        Icons.description_rounded,
        'Resume tailored',
        plan.resumeTailored,
      ),
      (
        'coverLetterWritten',
        Icons.mail_rounded,
        'Cover letter written',
        plan.coverLetterWritten,
      ),
      (
        'photoUpdated',
        Icons.camera_enhance_rounded,
        'Photo updated',
        plan.photoUpdated,
      ),
      (
        'interviewPrepped',
        Icons.psychology_rounded,
        'Interview prepped',
        plan.interviewPrepped,
      ),
      (
        'networkingMessageSent',
        Icons.connect_without_contact_rounded,
        'Networking message sent',
        plan.networkingMessageSent,
      ),
    ];

    final completed = plan.completedCount;
    final total = items.length;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.checklist_rounded,
            iconColor: AppColors.primary,
            title: 'Application Checklist',
            badge: Text(
              '$completed/$total',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completed / total,
              backgroundColor: context.appBorder,
              color: completed == total ? AppColors.success : AppColors.primary,
              minHeight: 7,
            ),
          ),

          if (completed == total) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 14,
                  color: AppColors.success,
                ),
                SizedBox(width: 6),
                Text(
                  'All done! You\'re ready to apply!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          ...items.map(
            (item) => _ChecklistItem(
              key: ValueKey(item.$1),
              icon: item.$2,
              label: item.$3,
              checked: item.$4,
              onToggle: () =>
                  ref.read(jobPlanProvider.notifier).toggleChecklist(item.$1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool checked;
  final VoidCallback onToggle;

  const _ChecklistItem({
    super.key,
    required this.icon,
    required this.label,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? AppColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: checked ? AppColors.success : context.appBorder,
                  width: 2,
                ),
              ),
              child: checked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              size: 16,
              color: checked ? AppColors.success : context.appText2,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: checked ? context.appText2 : context.appText1,
                decoration: checked ? TextDecoration.lineThrough : null,
                decorationColor: context.appText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
        boxShadow: AppShadows.card(context),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? badge;

  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const Spacer(),
        ?badge,
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SectionLabel({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'FREE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProMaxBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PRO MAX',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

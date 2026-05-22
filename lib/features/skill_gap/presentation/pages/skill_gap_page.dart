import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../ui/components/app_card.dart';
import '../../../cv_upload/presentation/providers/cv_upload_provider.dart';

class SkillGapPage extends ConsumerStatefulWidget {
  final String jobDescription;

  const SkillGapPage({super.key, required this.jobDescription});

  @override
  ConsumerState<SkillGapPage> createState() => _SkillGapPageState();
}

class _SkillGapPageState extends ConsumerState<SkillGapPage> {
  Map<String, dynamic>? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  Future<void> _runAnalysis() async {
    if (!mounted) return;
    if (!await ensureAiDataConsent(context, ref)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cvState = ref.read(uploadedCVProvider);
      final candidateSkills = cvState?.parsedProfile.skills ?? <String>[];

      final aiRouter = ref.read(aiRouterProvider);
      final result = await aiRouter.analyzeSkillGap(
        jobDescription: widget.jobDescription,
        candidateSkills: candidateSkills,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          context.l10n.skillGapTitle,
          style: TextStyle(
            color: context.appText1,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.appBorder),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _loading
            ? _LoadingView(key: const ValueKey('loading'))
            : _error != null
            ? _ErrorView(
                key: const ValueKey('error'),
                error: _error!,
                onRetry: _runAnalysis,
              )
            : _ResultView(
                key: const ValueKey('result'),
                result: _result!,
                jobDescription: widget.jobDescription,
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.skillGapLoading,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText2,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.skillGapFailed,
                style: TextStyle(
                  color: context.appText1,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.appText2, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.retry),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result
// ---------------------------------------------------------------------------

class _ResultView extends StatelessWidget {
  final Map<String, dynamic> result;
  final String jobDescription;

  const _ResultView({
    super.key,
    required this.result,
    required this.jobDescription,
  });

  @override
  Widget build(BuildContext context) {
    final score = (result['matchScore'] as num?)?.toInt() ?? 0;
    final summary = (result['summary'] as String?) ?? '';
    final matchingSkills = List<String>.from(
      result['matchingSkills'] as List? ?? [],
    );
    final missingSkills = List<String>.from(
      result['missingSkills'] as List? ?? [],
    );
    final recommendations = List<String>.from(
      result['recommendations'] as List? ?? [],
    );

    Color scoreColor;
    String scoreSublabel;
    if (score >= 70) {
      scoreColor = AppColors.success;
      scoreSublabel = context.l10n.skillGapStrong;
    } else if (score >= 50) {
      scoreColor = AppColors.warning;
      scoreSublabel = context.l10n.skillGapModerate;
    } else {
      scoreColor = AppColors.error;
      scoreSublabel = context.l10n.skillGapWeak;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Score Card
          AppCard(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: scoreColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                      Center(
                        child: Text(
                          '$score%',
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '$score% ${context.l10n.skillGapMatchScore}',
                  style: TextStyle(
                    color: context.appText1,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  scoreSublabel,
                  style: TextStyle(color: context.appText2, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary Card
          if (summary.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        context.l10n.skillGapAiSummary,
                        style: TextStyle(
                          color: context.appText1,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    summary,
                    style: TextStyle(
                      color: context.appText2,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Matching Skills
          if (matchingSkills.isNotEmpty) ...[
            _SectionHeader(
              title: context.l10n.skillGapMatchingSkills,
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: matchingSkills
                  .map(
                    (skill) => _SkillChip(
                      label: skill,
                      icon: Icons.check_rounded,
                      color: AppColors.success,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Skills to Develop
          if (missingSkills.isNotEmpty) ...[
            _SectionHeader(
              title: context.l10n.skillGapSkillsToDevelop,
              icon: Icons.trending_up_rounded,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: missingSkills
                  .map((skill) => _MissingSkillChip(skill: skill))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            _SectionHeader(
              title: context.l10n.skillGapRecommendations,
              icon: Icons.lightbulb_rounded,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                children: recommendations.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final rec = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: idx < recommendations.length - 1
                          ? AppSpacing.md
                          : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            rec,
                            style: TextStyle(
                              color: context.appText2,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Bottom CTA buttons
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => context.go('/cover-letter'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    context.l10n.skillGapWriteCoverLetter,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/interview-prep'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    context.l10n.skillGapPracticeInterview,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: TextStyle(
            color: context.appText1,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SkillChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingSkillChip extends StatelessWidget {
  final String skill;

  const _MissingSkillChip({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.xs,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, color: AppColors.error, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(
            skill,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.skillGapAddedToProfile),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              child: Text(
                context.l10n.skillGapAddToResume,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

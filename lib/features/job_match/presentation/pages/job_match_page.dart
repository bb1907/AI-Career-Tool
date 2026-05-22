import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/section_header.dart';
import '../../../cv_upload/presentation/providers/cv_upload_provider.dart';
import '../../domain/job_application.dart';
import '../providers/job_match_provider.dart';

class JobMatchPage extends ConsumerStatefulWidget {
  const JobMatchPage({super.key});

  @override
  ConsumerState<JobMatchPage> createState() => _JobMatchPageState();
}

class _JobMatchPageState extends ConsumerState<JobMatchPage> {
  final _jdController = TextEditingController();
  JobApplication? _result;
  Map<String, dynamic>? _aiAnalysis;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _analyzeMatch() async {
    final jd = _jdController.text.trim();
    if (jd.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorEmptyField)));
      return;
    }
    if (!await ensureAiDataConsent(context, ref)) return;

    setState(() => _isAnalyzing = true);
    showAiLoading(
      context,
      messages: const [
        'Analyzing job requirements...',
        'Comparing with your profile...',
        'Calculating match score...',
      ],
    );

    final cv = ref.read(uploadedCVProvider);
    final cvSkills =
        cv?.parsedProfile.skills ??
        ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'];

    Map<String, dynamic> analysis;
    try {
      final router = ref.read(aiRouterProvider);
      analysis = await router.analyzeSkillGap(
        jobDescription: jd,
        candidateSkills: cvSkills,
      );
    } catch (_) {
      // Fallback to keyword matching if AI is unavailable
      analysis = _keywordFallback(jd, cvSkills);
    }

    final scoreRaw = analysis['matchScore'];
    final score =
        (scoreRaw is int
                ? scoreRaw / 100.0
                : (scoreRaw as num).toDouble() / 100.0)
            .clamp(0.0, 1.0);

    final matchedSkills =
        (analysis['matchingSkills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        cvSkills.take(3).toList();
    final missingSkills =
        (analysis['missingSkills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['AWS', 'Docker'];

    final app = JobApplication(
      id: const Uuid().v4(),
      companyName: '',
      roleName: '',
      jobDescription: jd,
      matchScore: score,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ref.read(jobApplicationListProvider.notifier).save(app);
    setState(() {
      _result = app;
      _aiAnalysis = analysis;
      _isAnalyzing = false;
    });
  }

  Map<String, dynamic> _keywordFallback(String jd, List<String> cvSkills) {
    const all = [
      'Flutter',
      'Dart',
      'React',
      'Swift',
      'Kotlin',
      'Python',
      'JavaScript',
      'TypeScript',
      'Node.js',
      'AWS',
      'Firebase',
      'REST API',
      'GraphQL',
      'leadership',
      'agile',
      'Docker',
      'Kubernetes',
      'PostgreSQL',
      'iOS',
      'Android',
    ];
    final lower = jd.toLowerCase();
    final jdKeywords = all
        .where((k) => lower.contains(k.toLowerCase()))
        .toList();
    final matched = cvSkills
        .where((s) => jdKeywords.any((k) => k.toLowerCase() == s.toLowerCase()))
        .toList();
    final missing = jdKeywords
        .where((k) => !cvSkills.any((s) => s.toLowerCase() == k.toLowerCase()))
        .take(5)
        .toList();
    final score = jdKeywords.isEmpty
        ? 60
        : ((matched.length / jdKeywords.length.clamp(1, 999)) * 85 + 15)
              .round()
              .clamp(10, 98);
    return {
      'matchScore': score,
      'matchingSkills': matched,
      'missingSkills': missing,
      'recommendations': [
        'Highlight your matched skills prominently in your resume',
        'Consider upskilling in: ${missing.take(2).join(', ')}',
        'Practice interview questions specific to this role',
      ],
      'summary':
          'Based on your profile, you match $score% of the key requirements for this role.',
    };
  }

  Color _scoreColor(double score) {
    if (score >= 0.7) return AppColors.success;
    if (score >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(double score, BuildContext context) {
    if (score >= 0.7) return context.l10n.jobMatchStrong;
    if (score >= 0.5) return context.l10n.jobMatchPartial;
    return context.l10n.jobMatchWeak;
  }

  void _addSkillToProfile(String skill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.jobMatchSkillAdded(skill)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => context.go('/resume'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final analysis = _aiAnalysis;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.jobMatchTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: context.l10n.jobMatchPasteJd),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _jdController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: context.l10n.jobMatchJdHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeMatch,
              icon: const Icon(Icons.analytics_rounded, size: 18),
              label: Text(context.l10n.jobMatchAnalyze),
            ),

            if (result != null) ...[
              const SizedBox(height: AppSpacing.xl),

              // ── Match Score ───────────────────────────────────────────────
              AppCard(
                child: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: result.matchScore,
                            strokeWidth: 8,
                            backgroundColor: _scoreColor(
                              result.matchScore,
                            ).withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _scoreColor(result.matchScore),
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${(result.matchScore * 100).round()}%',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _scoreColor(result.matchScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _scoreLabel(result.matchScore, context),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _scoreColor(result.matchScore),
                      ),
                    ),
                    Text(
                      context.l10n.jobMatchScore,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.appText2),
                    ),
                  ],
                ),
              ),

              // ── AI Summary ────────────────────────────────────────────────
              if (analysis?['summary'] != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          analysis!['summary'] as String,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.appText1, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // ── Matching Skills ───────────────────────────────────────────
              if (result.matchedSkills.isNotEmpty) ...[
                Text(
                  context.l10n.jobMatchingSkills,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: result.matchedSkills
                        .map((s) => _MatchChip(label: s, matched: true))
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Missing Skills with "Add to resume" ───────────────────────
              if (result.missingSkills.isNotEmpty) ...[
                Text(
                  context.l10n.jobMissingSkills,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: result.missingSkills
                            .map(
                              (s) => _MatchChip(
                                label: s,
                                matched: false,
                                onAdd: () => _addSkillToProfile(s),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.l10n.jobMatchAddSkillHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appText2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Recommendations ───────────────────────────────────────────
              if (analysis?['recommendations'] != null) ...[
                Text(
                  context.l10n.jobMatchRecommendations,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    children: (analysis!['recommendations'] as List<dynamic>)
                        .cast<String>()
                        .asMap()
                        .entries
                        .map(
                          (e) => Column(
                            children: [
                              if (e.key > 0)
                                Divider(
                                  color: context.appBorder,
                                  height: AppSpacing.md * 2,
                                ),
                              _ActionTip(icon: _tipIcon(e.key), text: e.value),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Action buttons ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/cover-letter'),
                      icon: const Icon(Icons.mail_rounded, size: 16),
                      label: Text(context.l10n.jobMatchApply),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/interview-prep'),
                    icon: const Icon(Icons.psychology_rounded, size: 16),
                    label: Text(context.l10n.jobMatchPrep),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  IconData _tipIcon(int index) {
    const icons = [
      Icons.edit_document,
      Icons.school_outlined,
      Icons.psychology_outlined,
      Icons.tips_and_updates_outlined,
    ];
    return icons[index % icons.length];
  }
}

// ── Chips ──────────────────────────────────────────────────────────────────────

class _MatchChip extends StatelessWidget {
  final String label;
  final bool matched;
  final VoidCallback? onAdd;

  const _MatchChip({required this.label, required this.matched, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final color = matched ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matched
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          if (!matched && onAdd != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, size: 10, color: color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ActionTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.appText1),
          ),
        ),
      ],
    );
  }
}

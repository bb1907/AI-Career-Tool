import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../providers/resume_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/ai_score_badge.dart';
import '../../../../ui/components/suggestion_chip.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/teaser_overlay.dart';
import '../../../../services/pdf/resume_pdf_generator.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../paywall/presentation/widgets/hard_paywall_sheet.dart';
import '../../domain/resume.dart';
import '../../../../app/core/l10n_extension.dart';

class ResumePreviewPage extends ConsumerWidget {
  final String resumeId;
  final bool isTeaser;

  const ResumePreviewPage({
    super.key,
    required this.resumeId,
    this.isTeaser = false,
  });

  int _calcScore(Resume r) {
    int s = (r.completionPercentage * 72).round();
    if (r.summary.length > 80) s += 8;
    if (r.workExperiences.any((e) => e.description.length > 60)) s += 10;
    if (r.skills.length >= 4) s += 7;
    if (r.projects.isNotEmpty) s += 3;
    return s.clamp(0, 100);
  }

  List<String> _suggestions(Resume r) {
    final tips = <String>[];
    if (r.summary.length < 80) tips.add('Strengthen your professional summary');
    if (!r.workExperiences.any((e) => e.description.length > 60)) {
      tips.add('Add measurable impact metrics');
    }
    if (r.skills.length < 4) tips.add('Include more relevant skills');
    if (r.projects.isEmpty) tips.add('Add a portfolio project');
    if (r.personalInfo.linkedIn == null) tips.add('Add your LinkedIn URL');
    tips.add('Include more keywords from job descriptions');
    return tips.take(4).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeAsync = ref.watch(resumeProvider(resumeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/resume'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: context.l10n.resumeExport,
            onPressed: () async {
              final asyncResume = ref.read(resumeProvider(resumeId));
              Resume? resume;
              asyncResume.whenData((val) => resume = val);
              if (resume == null) return;
              final sub = ref.read(subscriptionProvider);
              if (sub.hasPdfWatermark) {
                showHardPaywall(context, HardPaywallType.pdfExport);
                return;
              }
              final doc = ResumePdfGenerator.generate(
                resume!,
                watermark: false,
              );
              await Printing.sharePdf(
                bytes: await doc.save(),
                filename: '${resume!.title.replaceAll(' ', '_')}.pdf',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: context.l10n.edit,
            onPressed: () => context.go('/resume/$resumeId'),
          ),
        ],
      ),
      body: resumeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (resume) {
          if (resume == null) {
            return const Center(child: Text('Resume not found'));
          }
          final score = _calcScore(resume);
          final suggestions = _suggestions(resume);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── AI Score + suggestions
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AiScoreBadge(score: score),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Suggestions',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.appText2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: suggestions
                            .map((s) => AiSuggestionChip(label: s))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                          ),
                          label: const Text('Improve with AI'),
                          onPressed: () => context.go('/resume/$resumeId'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Header card ──────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.personalInfo.fullName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: 4,
                        children: [
                          if (resume.personalInfo.email.isNotEmpty)
                            _InfoChip(
                              icon: Icons.email_outlined,
                              text: resume.personalInfo.email,
                            ),
                          if (resume.personalInfo.phone.isNotEmpty)
                            _InfoChip(
                              icon: Icons.phone_outlined,
                              text: resume.personalInfo.phone,
                            ),
                          if (resume.personalInfo.location.isNotEmpty)
                            _InfoChip(
                              icon: Icons.location_on_outlined,
                              text: resume.personalInfo.location,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Resume sections wrapped in teaser when needed
                TeaserOverlay(
                  isTeaser: isTeaser,
                  featureLabel: 'Resume',
                  readyMessage: 'Your ATS-optimized resume is ready!',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Summary card ─────────────────────────────
                      if (resume.summary.isNotEmpty)
                        _SectionCard(
                          title: context.l10n.resumeStepSummary,
                          onEdit: () => context.go('/resume/$resumeId'),
                          child: Text(
                            resume.summary,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),

                      if (resume.summary.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),

                      // ── Experience card ──────────────────────────
                      if (resume.workExperiences.isNotEmpty)
                        _SectionCard(
                          title: context.l10n.resumeStepExperience,
                          onEdit: () => context.go('/resume/$resumeId'),
                          child: Column(
                            children: resume.workExperiences
                                .map(
                                  (exp) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exp.position,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${exp.company} · ${exp.startDate} – ${exp.isCurrent ? context.l10n.resumePresent : (exp.endDate ?? "")}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          exp.description,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      if (resume.workExperiences.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),

                      // ── Education card ───────────────────────────
                      if (resume.educations.isNotEmpty)
                        _SectionCard(
                          title: context.l10n.resumeStepEducation,
                          onEdit: () => context.go('/resume/$resumeId'),
                          child: Column(
                            children: resume.educations
                                .map(
                                  (edu) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${edu.degree} in ${edu.field}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${edu.institution} · ${edu.startDate} – ${edu.endDate ?? context.l10n.resumePresent}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                        if (edu.gpa != null)
                                          Text(
                                            'GPA: ${edu.gpa}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      if (resume.educations.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),

                      // ── Skills card ──────────────────────────────
                      if (resume.skills.isNotEmpty)
                        _SectionCard(
                          title: context.l10n.resumeStepSkills,
                          onEdit: () => context.go('/resume/$resumeId'),
                          child: Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: resume.skills
                                .map(
                                  (s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.07,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.badge,
                                      ),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      s.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      if (resume.skills.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),

                      // ── Projects card ────────────────────────────
                      if (resume.projects.isNotEmpty)
                        _SectionCard(
                          title: context.l10n.resumeStepProjects,
                          onEdit: () => context.go('/resume/$resumeId'),
                          child: Column(
                            children: resume.projects
                                .map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        Text(
                                          p.description,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        if (p.technologies.isNotEmpty) ...[
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            p.technologies.join(' · '),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Section card with edit button ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 13,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        context.l10n.edit,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(color: context.appBorder, height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.appText2),
        const SizedBox(width: 3),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.appText2),
        ),
      ],
    );
  }
}

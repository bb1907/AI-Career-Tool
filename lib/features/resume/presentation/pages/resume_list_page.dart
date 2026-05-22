import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/resume_provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../paywall/presentation/widgets/hard_paywall_sheet.dart';

class ResumeListPage extends ConsumerWidget {
  const ResumeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(resumeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.resumeTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final sub = ref.read(subscriptionProvider);
          if (!sub.canUse(FeatureType.resume)) {
            showHardPaywall(context, HardPaywallType.resumeGenerate);
            return;
          }
          context.go('/resume/new');
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          context.l10n.resumeNew,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: resumesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.resumeError('$e'))),
        data: (resumes) => resumes.isEmpty
            ? _EmptyState(
                onTap: () {
                  final sub = ref.read(subscriptionProvider);
                  if (!sub.canUse(FeatureType.resume)) {
                    showHardPaywall(context, HardPaywallType.resumeGenerate);
                    return;
                  }
                  context.go('/resume/new');
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.md),
                itemCount: resumes.length,
                itemBuilder: (context, index) {
                  final resume = resumes[index];
                  final pct = (resume.completionPercentage * 100).round();
                  final isComplete = resume.completionPercentage == 1.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.sm),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppTheme.cardRadius,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppTheme.cardRadius,
                        ),
                        child: InkWell(
                          onTap: () => context.go('/resume/${resume.id}'),
                          borderRadius: BorderRadius.circular(
                            AppTheme.cardRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.cardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        resume.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 20,
                                      ),
                                      onPressed: () => context.go(
                                        '/resume/${resume.id}/preview',
                                      ),
                                      tooltip: context.l10n.resumePreview,
                                      visualDensity: VisualDensity.compact,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ],
                                ),
                                if (resume.personalInfo.fullName.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppTheme.sm,
                                    ),
                                    child: Text(
                                      resume.personalInfo.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: resume.completionPercentage,
                                          backgroundColor: Colors.grey.shade100,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isComplete
                                                    ? const Color(0xFF22C55E)
                                                    : AppTheme.primary,
                                              ),
                                          minHeight: 5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.sm),
                                    Text(
                                      '$pct%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isComplete
                                                ? const Color(0xFF22C55E)
                                                : AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.xs),
                                Text(
                                  context.l10n.resumeUpdated(
                                    '${resume.updatedAt.day}/${resume.updatedAt.month}/${resume.updatedAt.year}',
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 40,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppTheme.lg),
            Text(
              context.l10n.resumeEmpty,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.xs),
            Text(
              context.l10n.resumeEmptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.lg),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.resumeCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

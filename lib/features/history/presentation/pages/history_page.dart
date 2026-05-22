import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/app_card.dart';
import '../../../cover_letter/presentation/providers/cover_letter_provider.dart';
import '../../../interview_prep/presentation/providers/interview_set_provider.dart';
import '../../../resume/presentation/providers/resume_provider.dart';
import '../../../video_script/presentation/providers/video_script_provider.dart';
import '../../../chat/domain/chat_message.dart';
import '../../../job_plan/presentation/providers/job_plan_list_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyTitle),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: context.l10n.historyResumes),
            Tab(text: context.l10n.historyCoverLetters),
            Tab(text: context.l10n.historyInterviews),
            Tab(text: context.l10n.historyScripts),
            const Tab(text: 'Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ResumesTab(),
          _CoverLettersTab(),
          _InterviewsTab(),
          _ScriptsTab(),
          _PlansTab(),
        ],
      ),
    );
  }
}

// ── Resumes tab ──────────────────────────────────────────────────────────────

class _ResumesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(resumeListProvider);

    return resumesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (resumes) {
        if (resumes.isEmpty) {
          return _EmptyTab(
            icon: Icons.description_rounded,
            label: context.l10n.historyEmpty,
            action: context.l10n.historyEmptySubtitle,
            onAction: () => GoRouter.of(context).go('/resume/new'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: resumes.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final r = resumes[i];
            final pct = (r.completionPercentage * 100).round();
            return AppCard(
              onTap: () => context.go('/resume/${r.id}'),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${r.personalInfo.fullName.isNotEmpty ? r.personalInfo.fullName : "—"}  ·  $pct% complete',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.appText2),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: context.appText2,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Cover Letters tab ─────────────────────────────────────────────────────────

class _CoverLettersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letters = ref.watch(coverLetterListProvider);

    if (letters.isEmpty) {
      return _EmptyTab(
        icon: Icons.mail_rounded,
        label: context.l10n.historyEmpty,
        action: context.l10n.historyEmptySubtitle,
        onAction: () => context.go('/cover-letter'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: letters.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final cl = letters[i];
        return AppCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B5DE5), Color(0xFFB980F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mail_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cl.roleName} @ ${cl.companyName}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(cl.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.appText2),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: context.appText2,
                ),
                onPressed: () =>
                    ref.read(coverLetterListProvider.notifier).delete(cl.id),
                tooltip: 'Delete',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Interviews tab ────────────────────────────────────────────────────────────

class _InterviewsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(interviewSetListProvider);

    if (sets.isEmpty) {
      return _EmptyTab(
        icon: Icons.psychology_rounded,
        label: context.l10n.historyEmpty,
        action: context.l10n.historyEmptySubtitle,
        onAction: () => context.go('/interview-prep'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sets.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final s = sets[i];
        return AppCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C2A8), Color(0xFF00D4BA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.roleName} · ${s.seniority}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.questions.length} questions · ${_formatDate(s.createdAt)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.appText2),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: context.appText2,
                ),
                onPressed: () =>
                    ref.read(interviewSetListProvider.notifier).delete(s.id),
                tooltip: 'Delete',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Scripts tab ───────────────────────────────────────────────────────────────

class _ScriptsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripts = ref.watch(videoScriptListProvider);

    if (scripts.isEmpty) {
      return _EmptyTab(
        icon: Icons.video_camera_front_rounded,
        label: context.l10n.historyEmpty,
        action: context.l10n.historyEmptySubtitle,
        onAction: () => context.go('/video-script'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: scripts.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final s = scripts[i];
        return AppCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.video_camera_front_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.durationType} · ${_capitalize(s.tone)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(s.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.appText2),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/teleprompter', extra: s.scriptText),
                child: const Text('Practice'),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: context.appText2,
                ),
                onPressed: () =>
                    ref.read(videoScriptListProvider.notifier).delete(s.id),
                tooltip: 'Delete',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Plans tab ────────────────────────────────────────────────────────────────

class _PlansTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(jobPlanListProvider);

    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (plans) {
        if (plans.isEmpty) {
          return _EmptyTab(
            icon: Icons.rocket_launch_rounded,
            label: context.l10n.historyEmpty,
            action: 'Create your first plan',
            onAction: () => context.push('/chat', extra: ChatFlow.jobPlan),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: plans.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final plan = plans[i];
            final scoreColor = plan.matchScore >= 80
                ? AppColors.success
                : plan.matchScore >= 60
                ? const Color(0xFFF59E0B)
                : AppColors.error;

            return AppCard(
              onTap: () => context.push(
                '/job-plan',
                extra: {'jobDescription': plan.jobDescription},
              ),
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
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${plan.role} @ ${plan.company}',
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${plan.matchScore}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${plan.completedCount}/5 done · ${_formatDate(plan.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.appText2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: context.appText2,
                    ),
                    onPressed: () =>
                        ref.read(jobPlanListProvider.notifier).delete(plan.id),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final String action;
  final VoidCallback onAction;

  const _EmptyTab({
    required this.icon,
    required this.label,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: context.appText2),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime dt) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

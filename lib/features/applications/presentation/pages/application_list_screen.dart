import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/app_card.dart';
import '../../domain/application.dart';
import '../providers/application_controller.dart';

class ApplicationListScreen extends ConsumerWidget {
  const ApplicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationControllerProvider);

    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        title: Text(context.l10n.applicationsTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: context.l10n.applicationAddNew,
            onPressed: () => context.push('/applications/new'),
          ),
        ],
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: context.appText2),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(applicationControllerProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (apps) =>
            apps.isEmpty ? _EmptyState() : _ApplicationList(apps: apps),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/applications/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.applicationAddNew),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.applicationsEmpty,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.applicationsEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.appText2),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Application List ──────────────────────────────────────────────────────────

class _ApplicationList extends ConsumerWidget {
  final List<Application> apps;
  const _ApplicationList({required this.apps});

  // Group by status order
  static const _order = [
    ApplicationStatus.interview,
    ApplicationStatus.offer,
    ApplicationStatus.phoneScreen,
    ApplicationStatus.applied,
    ApplicationStatus.wishlist,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build sections: only include statuses that have items
    final grouped = <ApplicationStatus, List<Application>>{};
    for (final a in apps) {
      grouped.putIfAbsent(a.status, () => []).add(a);
    }

    final sections = _order
        .where((s) => grouped.containsKey(s))
        .map((s) => (status: s, items: grouped[s]!))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: sections.fold<int>(0, (acc, s) => acc + 1 + s.items.length),
      itemBuilder: (context, index) {
        // Map flat index → section header or item
        int cursor = 0;
        for (final section in sections) {
          if (index == cursor) {
            return _SectionHeader(status: section.status);
          }
          cursor++;
          for (final app in section.items) {
            if (index == cursor) {
              return _ApplicationTile(app: app);
            }
            cursor++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final ApplicationStatus status;
  const _SectionHeader({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationTile extends ConsumerWidget {
  final Application app;
  const _ApplicationTile({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(app.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(context.l10n.applicationDeleteConfirm),
                  content: Text(context.l10n.applicationDeleteConfirmBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        context.l10n.applicationDeleteConfirmOk,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) {
          ref.read(applicationControllerProvider.notifier).delete(app.id);
        },
        child: AppCard(
          onTap: () => context.push('/applications/${app.id}'),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: app.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(app.status.icon, color: app.status.color, size: 20),
              ),
              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.role,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.company,
                      style: TextStyle(fontSize: 12, color: context.appText2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Follow-up badge or match score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (app.matchScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _matchColor(
                          app.matchScore!,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${app.matchScore}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _matchColor(app.matchScore!),
                        ),
                      ),
                    ),
                  if (app.followUpAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.alarm_rounded,
                          size: 11,
                          color: _isOverdue(app.followUpAt!)
                              ? AppColors.error
                              : context.appText2,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatDate(app.followUpAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: _isOverdue(app.followUpAt!)
                                ? AppColors.error
                                : context.appText2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: context.appText2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _matchColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return const Color(0xFFF59E0B);
    return AppColors.primary;
  }

  bool _isOverdue(DateTime date) => date.isBefore(DateTime.now());

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff < 0) return '${diff.abs()}d ago';
    return 'in ${diff}d';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/app_card.dart';
import '../../domain/application.dart';
import '../providers/application_controller.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;
  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends ConsumerState<ApplicationDetailScreen> {
  List<ApplicationEvent>? _events;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await ref
        .read(applicationControllerProvider.notifier)
        .getEvents(widget.applicationId);
    if (mounted) setState(() => _events = events);
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationControllerProvider);

    final app = applicationsAsync.whenOrNull(
      data: (list) {
        try {
          return list.firstWhere((a) => a.id == widget.applicationId);
        } catch (_) {
          return null;
        }
      },
    );

    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        title: Text(app.role, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
            onPressed: () =>
                context.push('/applications/${app.id}/edit', extra: app),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(app),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // ── Header card ───────────────────────────────────────────────────
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: app.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    app.status.icon,
                    color: app.status.color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.role,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.company,
                        style: TextStyle(fontSize: 13, color: context.appText2),
                      ),
                      if (app.source.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.source_rounded,
                              size: 12,
                              color: context.appText2,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              app.source,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appText2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (app.matchScore != null) ...[
                  const SizedBox(width: 8),
                  _MatchBadge(score: app.matchScore!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Status change ─────────────────────────────────────────────────
          _StatusSection(app: app),
          const SizedBox(height: 12),

          // ── Key info ──────────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Added',
                  value: _formatDate(app.createdAt),
                ),
                if (app.appliedAt != null) ...[
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.send_rounded,
                    label: 'Applied',
                    value: _formatDate(app.appliedAt!),
                  ),
                ],
                if (app.followUpAt != null) ...[
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.alarm_rounded,
                    label: context.l10n.applicationDetailFollowUp,
                    value: _formatDate(app.followUpAt!),
                    valueColor: app.followUpAt!.isBefore(DateTime.now())
                        ? AppColors.error
                        : null,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Notes ─────────────────────────────────────────────────────────
          if (app.notes.isNotEmpty) ...[
            _SectionTitle(context.l10n.applicationDetailNotes),
            const SizedBox(height: 8),
            AppCard(
              child: Text(
                app.notes,
                style: TextStyle(fontSize: 14, color: context.appText1),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Job description preview ───────────────────────────────────────
          if (app.jobDescription.isNotEmpty) ...[
            _SectionTitle('Job Description'),
            const SizedBox(height: 8),
            AppCard(child: _ExpandableText(text: app.jobDescription)),
            const SizedBox(height: 12),
          ],

          // ── Timeline ─────────────────────────────────────────────────────
          _SectionTitle(context.l10n.applicationDetailTimeline),
          const SizedBox(height: 8),
          if (_events == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_events!.isEmpty)
            AppCard(
              child: Text(
                'No events yet',
                style: TextStyle(fontSize: 13, color: context.appText2),
              ),
            )
          else
            AppCard(
              child: Column(
                children: _events!
                    .asMap()
                    .entries
                    .map(
                      (e) => _TimelineItem(
                        event: e.value,
                        isLast: e.key == _events!.length - 1,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Application app) async {
    final confirmed =
        await showDialog<bool>(
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

    if (confirmed && mounted) {
      await ref.read(applicationControllerProvider.notifier).delete(app.id);
      if (mounted) context.pop();
    }
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

// ── Status Change Section ─────────────────────────────────────────────────────

class _StatusSection extends ConsumerWidget {
  final Application app;
  const _StatusSection({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.applicationDetailStatus,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ApplicationStatus.values.map((s) {
                final isSelected = s == app.status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: isSelected
                        ? null
                        : () => ref
                              .read(applicationControllerProvider.notifier)
                              .changeStatus(app.id, s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? s.color.withValues(alpha: 0.15)
                            : context.appBG,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? s.color : context.appBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            s.icon,
                            size: 13,
                            color: isSelected ? s.color : context.appText2,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? s.color : context.appText2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Match Badge ───────────────────────────────────────────────────────────────

class _MatchBadge extends StatelessWidget {
  final int score;
  const _MatchBadge({required this.score});

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return const Color(0xFFF59E0B);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.appText2),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: context.appText2)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? context.appText1,
          ),
        ),
      ],
    );
  }
}

// ── Timeline Item ─────────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final ApplicationEvent event;
  final bool isLast;

  const _TimelineItem({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line + dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 1, color: context.appBorder)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(event.createdAt),
                    style: TextStyle(fontSize: 11, color: context.appText2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: context.appText2,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Expandable Text ───────────────────────────────────────────────────────────

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const maxLines = 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : maxLines,
          overflow: _expanded ? null : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: context.appText1),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show less' : 'Show more',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

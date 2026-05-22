import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/ai_score_badge.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/suggestion_chip.dart';
import '../../../../ui/components/teaser_overlay.dart';
import '../../domain/cover_letter.dart';
import '../providers/cover_letter_provider.dart';
import '../../../../app/core/l10n_extension.dart';

class CoverLetterResultPage extends ConsumerStatefulWidget {
  /// Accept a Map {result: CoverLetter, isTeaser: bool}, a [CoverLetter],
  /// or a plain String (backward compat).
  final dynamic extra;

  const CoverLetterResultPage({super.key, required this.extra});

  @override
  ConsumerState<CoverLetterResultPage> createState() =>
      _CoverLetterResultPageState();
}

class _CoverLetterResultPageState extends ConsumerState<CoverLetterResultPage> {
  late final TextEditingController _controller;
  CoverLetter? _coverLetter;
  bool _copied = false;
  late final bool _isTeaser;

  /// Resolve the CoverLetter/String from various extra formats.
  dynamic get _resolvedExtra {
    if (widget.extra is Map) {
      return (widget.extra as Map)['result'];
    }
    return widget.extra;
  }

  /// Legacy constructor compatibility — accept initialText too.
  String get _initialText {
    final resolved = _resolvedExtra;
    if (resolved is CoverLetter) return resolved.generatedText;
    if (resolved is String) return resolved;
    return '';
  }

  int get _score {
    final len = _controller.text.length;
    final base = 72;
    final bonus = (len / 25).clamp(0, 20).toInt();
    return (base + bonus).clamp(0, 99);
  }

  @override
  void initState() {
    super.initState();
    // Resolve isTeaser flag
    if (widget.extra is Map) {
      final map = widget.extra as Map;
      _isTeaser = map['isTeaser'] as bool? ?? false;
      final resolved = map['result'];
      if (resolved is CoverLetter) _coverLetter = resolved;
    } else {
      _isTeaser = false;
      if (widget.extra is CoverLetter) {
        _coverLetter = widget.extra as CoverLetter;
      }
    }
    _controller = TextEditingController(text: _initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _controller.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  void _saveChanges() {
    if (_coverLetter != null) {
      final updated = _coverLetter!.copyWith(generatedText: _controller.text);
      ref.read(coverLetterListProvider.notifier).save(updated);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.coverLetterTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
            tooltip: _copied ? 'Copied!' : context.l10n.coverLetterCopy,
            onPressed: _copy,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success banner
            AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              showBorder: false,
              color: AppColors.accent.withValues(
                alpha: context.isDark ? 0.15 : 0.07,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Cover letter generated — edit below before copying.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.isDark
                            ? AppColors.accent.withValues(alpha: 0.9)
                            : const Color(0xFF007A6B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // AI Score badge
            AiScoreBadge(score: _score),

            const SizedBox(height: AppSpacing.md),

            // Suggestion chips
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AiSuggestionChip(
                  label: 'Add quantified results',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tip: Include metrics like "increased revenue by 20%"',
                        ),
                      ),
                    );
                  },
                ),
                AiSuggestionChip(
                  label: 'Strengthen opening line',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tip: Start with a compelling statement about your fit',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Editable text area — wrap in teaser if needed
            Expanded(
              child: TeaserOverlay(
                isTeaser: _isTeaser,
                featureLabel: 'Cover Letter',
                readyMessage: 'Your personalized cover letter is ready!',
                child: Container(
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: context.appBorder),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) => setState(() {}),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.65),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(AppSpacing.md),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Improve with AI button
            OutlinedButton.icon(
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Improve with AI'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI improvement requires a premium account'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Start Over'),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _copied ? 'Copied!' : context.l10n.coverLetterCopy,
                    ),
                    onPressed: _copy,
                  ),
                ),
              ],
            ),

            if (_coverLetter != null) ...[
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Changes'),
                onPressed: _saveChanges,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

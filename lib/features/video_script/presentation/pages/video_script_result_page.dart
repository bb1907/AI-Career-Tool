import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../ui/components/ai_score_badge.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/suggestion_chip.dart';
import '../../../../ui/components/teaser_overlay.dart';
import '../../domain/video_script.dart';
import '../providers/video_script_provider.dart';

class VideoScriptResultPage extends ConsumerStatefulWidget {
  final VideoScript script;
  final bool isTeaser;

  const VideoScriptResultPage({
    super.key,
    required this.script,
    this.isTeaser = false,
  });

  @override
  ConsumerState<VideoScriptResultPage> createState() =>
      _VideoScriptResultPageState();
}

class _VideoScriptResultPageState extends ConsumerState<VideoScriptResultPage> {
  late final TextEditingController _controller;
  late VideoScript _current;
  bool _copied = false;

  // Mock quality score based on script length & tone
  int get _score {
    final len = _current.scriptText.length;
    final base = _current.tone == 'confident' ? 85 : 78;
    final lengthBonus = (len / 50).clamp(0, 10).toInt();
    return (base + lengthBonus).clamp(0, 99);
  }

  @override
  void initState() {
    super.initState();
    _current = widget.script;
    _controller = TextEditingController(text: _current.scriptText);
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

  void _saveScript() {
    final updated = _current.copyWith(scriptText: _controller.text);
    ref.read(videoScriptListProvider.notifier).save(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Script saved to history'),
        backgroundColor: AppColors.success,
      ),
    );
    context.go('/history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.videoScriptTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
            onPressed: () {}, // already editable inline
          ),
          IconButton(
            icon: Icon(_copied ? Icons.check_rounded : Icons.share_rounded),
            tooltip: 'Share',
            onPressed: _copy,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score badge
            AiScoreBadge(score: _score),
            const SizedBox(height: AppSpacing.md),

            // Duration + tone chips
            Row(
              children: [
                _InfoChip(
                  icon: Icons.timer_rounded,
                  label: _current.durationType,
                ),
                const SizedBox(width: AppSpacing.xs),
                _InfoChip(
                  icon: Icons.record_voice_over_rounded,
                  label: _capitalize(_current.tone),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Editable script — wrap in teaser if needed
            TeaserOverlay(
              isTeaser: widget.isTeaser,
              featureLabel: 'Video Script',
              readyMessage: 'Your video script is ready!',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.7),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(AppSpacing.md),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Suggestion chips
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AiSuggestionChip(
                  label: 'Add a hook sentence',
                  onTap: () {
                    _controller.text =
                        'Did you know that...? ${_controller.text}';
                    setState(() {});
                  },
                ),
                AiSuggestionChip(
                  label: 'Include a call to action',
                  onTap: () {
                    _controller.text =
                        '${_controller.text}\n\nLet\'s connect — I\'d love to discuss this further.';
                    setState(() {});
                  },
                ),
                AiSuggestionChip(
                  label: 'Make it more concise',
                  onTap: () {
                    final words = _controller.text.split(' ');
                    if (words.length > 40) {
                      _controller.text = '${words.take(40).join(' ')}...';
                    }
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            FilledButton.icon(
              onPressed: () =>
                  context.push('/teleprompter', extra: _controller.text),
              icon: const Icon(Icons.slideshow_rounded, size: 18),
              label: const Text('Practice with Teleprompter'),
            ),

            const SizedBox(height: AppSpacing.sm),

            OutlinedButton.icon(
              onPressed: _saveScript,
              icon: const Icon(Icons.bookmark_rounded, size: 18),
              label: const Text('Save Script'),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

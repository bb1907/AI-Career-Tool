import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/teaser_overlay.dart';

class NetworkingResultPage extends ConsumerStatefulWidget {
  final String messageType;
  final String recipient;
  final String company;
  final String context;
  final String tone;

  const NetworkingResultPage({
    super.key,
    required this.messageType,
    required this.recipient,
    required this.company,
    required this.context,
    required this.tone,
  });

  @override
  ConsumerState<NetworkingResultPage> createState() =>
      _NetworkingResultPageState();
}

class _NetworkingResultPageState extends ConsumerState<NetworkingResultPage> {
  String _generatedMessage = '';
  bool _loading = true;
  late String _currentTone;
  bool _copied = false;

  Timer? _copiedTimer;

  static const _tones = ['Professional', 'Friendly', 'Brief'];

  @override
  void initState() {
    super.initState();
    _currentTone = widget.tone;
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  String get _purpose =>
      '${widget.messageType} for ${widget.company}. Context: ${widget.context}';

  Future<void> _generate({String? extraInstruction}) async {
    if (!mounted) return;
    if (!await ensureAiDataConsent(context, ref)) return;

    final sub = ref.read(subscriptionProvider);
    if (!sub.canUse(FeatureType.networking)) {
      final goPaywall = await showLimitDialog(
        context,
        feature: FeatureType.networking,
      );
      if (mounted && goPaywall) context.push('/paywall');
      return;
    }

    setState(() {
      _loading = true;
      _generatedMessage = '';
    });

    try {
      final aiRouter = ref.read(aiRouterProvider);
      final purpose = extraInstruction != null
          ? '$_purpose $extraInstruction'
          : _purpose;

      final message = await aiRouter.generateNetworkingMessage(
        senderName: 'a job seeker',
        recipientRole: widget.recipient,
        purpose: purpose,
        tone: _currentTone,
      );

      if (!mounted) return;
      setState(() {
        _generatedMessage = message;
        _loading = false;
      });
      ref
          .read(subscriptionProvider.notifier)
          .recordUsage(FeatureType.networking);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generatedMessage = '';
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate message: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectTone(String tone) {
    if (tone == _currentTone) return;
    setState(() => _currentTone = tone);
    _generate();
  }

  void _copyMessage() {
    if (_generatedMessage.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedMessage));

    _copiedTimer?.cancel();
    setState(() => _copied = true);
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider);
    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          context.l10n.networkingTitle,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message type badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      widget.messageType,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Recipient + company info
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: context.appText2,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.recipient,
                  style: TextStyle(color: context.appText2, fontSize: 13),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.appText2.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.business_outlined,
                  size: 14,
                  color: context.appText2,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    widget.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.appText2, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tone selector
            _ToneSelector(
              tones: _tones,
              selected: _currentTone,
              onSelect: _selectTone,
            ),
            const SizedBox(height: AppSpacing.md),

            // Message card
            TeaserOverlay(
              isTeaser:
                  !sub.isPremium && !_loading && _generatedMessage.isNotEmpty,
              featureLabel: 'Networking Message',
              readyMessage: 'Your networking message is ready!',
              child: AppCard(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _loading
                      ? _MessageLoadingPlaceholder(
                          key: const ValueKey('loading'),
                        )
                      : _generatedMessage.isEmpty
                      ? _MessageEmptyState(key: const ValueKey('empty'))
                      : _MessageBody(
                          key: const ValueKey('message'),
                          message: _generatedMessage,
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Copy + Regenerate
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _copyMessage,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _copied ? Icons.check_rounded : Icons.copy_rounded,
                        key: ValueKey(_copied),
                        size: 18,
                      ),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _copied
                            ? context.l10n.networkingCopied
                            : context.l10n.networkingCopy,
                        key: ValueKey(_copied),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _copied
                          ? AppColors.success
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _generate,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(context.l10n.networkingRegenerate),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Make Shorter / Longer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => _generate(extraInstruction: 'Make it shorter.'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appText2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.compress_rounded, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(context.l10n.networkingShorter),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: context.appBorder,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => _generate(extraInstruction: 'Make it longer.'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appText2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.expand_rounded, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text(context.l10n.networkingLonger),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Start new message
            Center(
              child: TextButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Start New Message',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tone selector
// ---------------------------------------------------------------------------

class _ToneSelector extends StatelessWidget {
  final List<String> tones;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ToneSelector({
    required this.tones,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.l10n.networkingTone,
          style: TextStyle(
            color: context.appText2,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Wrap(
            spacing: AppSpacing.xs,
            children: tones.map((tone) {
              final isSelected = tone == selected;
              return GestureDetector(
                onTap: () => onSelect(tone),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    tone,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Message card contents
// ---------------------------------------------------------------------------

class _MessageLoadingPlaceholder extends StatelessWidget {
  const _MessageLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.networkingGenerating,
          style: TextStyle(
            color: context.appText2,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _MessageEmptyState extends StatelessWidget {
  const _MessageEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'No message generated yet. Tap Regenerate to try again.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.appText2, fontSize: 14),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  final String message;
  const _MessageBody({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      message,
      style: TextStyle(color: context.appText1, fontSize: 14, height: 1.7),
    );
  }
}

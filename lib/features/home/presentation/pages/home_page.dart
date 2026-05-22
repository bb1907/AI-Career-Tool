import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../chat/domain/chat_message.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _stt = SpeechToText();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  bool _sttAvailable = false;
  bool _isListening = false;

  // 7 chips — 2 rows of 3 + 1 featured
  List<(IconData, String, ChatFlow)> _chips(BuildContext context) => [
    (Icons.description_rounded, context.l10n.chipResume, ChatFlow.resume),
    (Icons.mail_rounded, context.l10n.chipCoverLetter, ChatFlow.coverLetter),
    (Icons.psychology_rounded, context.l10n.chipInterview, ChatFlow.interview),
    (
      Icons.camera_enhance_rounded,
      context.l10n.chipPhotoStudio,
      ChatFlow.aiPhoto,
    ),
    (
      Icons.connect_without_contact_rounded,
      context.l10n.chipNetworking,
      ChatFlow.networking,
    ),
    (Icons.upload_file_rounded, context.l10n.chipUploadCv, ChatFlow.cvUpload),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initStt();
  }

  Future<void> _initStt() async {
    final available = await _stt.initialize();
    if (mounted) setState(() => _sttAvailable = available);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _pulseController.dispose();
    _stt.stop();
    super.dispose();
  }

  void _openChat(ChatFlow flow) => context.push('/chat', extra: flow);

  void _submit() {
    if (_inputController.text.trim().isEmpty) return;
    _inputController.clear();
    context.push('/chat', extra: ChatFlow.none);
  }

  Future<void> _toggleListening() async {
    if (!_sttAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.speechNotAvailable)));
      return;
    }
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      if (_inputController.text.trim().isNotEmpty) _submit();
    } else {
      setState(() => _isListening = true);
      await _stt.listen(
        onResult: (result) {
          setState(() {
            _inputController.text = result.recognizedWords;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputController.text.length),
            );
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            if (_inputController.text.trim().isNotEmpty) _submit();
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer(
              builder: (ctx, ref, _) {
                final sub = ref.watch(subscriptionProvider);
                if (sub.plan == PlanType.proMax) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.planProMax,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (sub.isPremium) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.planPro,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return TextButton(
                  onPressed: () => context.push('/soft-paywall'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    context.l10n.upgrade,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Centered content ──────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppShadows.elevated(context),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        context.l10n.homeTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        context.l10n.homeSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.appText2,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Chips — wrap layout
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        alignment: WrapAlignment.center,
                        children: _chips(context)
                            .map(
                              (chip) => _ActionChip(
                                icon: chip.$1,
                                label: chip.$2,
                                onTap: () => _openChat(chip.$3),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Apply to Job — featured card
                      _JobPlanCard(onTap: () => _openChat(ChatFlow.jobPlan)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Input bar (sticky bottom, above nav) ─────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm + bottomPad,
              ),
              decoration: BoxDecoration(
                color: context.appSurface,
                border: Border(top: BorderSide(color: context.appBorder)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Attach
                  GestureDetector(
                    onTap: () => _openChat(ChatFlow.cvUpload),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appBG,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.appBorder),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: context.appText2,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Text field (tappable)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openChat(ChatFlow.none),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.appBG,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.appBorder),
                        ),
                        child: Text(
                          _isListening
                              ? _inputController.text.isEmpty
                                    ? context.l10n.listening
                                    : _inputController.text
                              : context.l10n.homeInputHint,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _isListening && _inputController.text.isNotEmpty
                                ? context.appText1
                                : context.appText2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Mic
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, _) => Transform.scale(
                      scale: _isListening ? _pulseAnim.value : 1.0,
                      child: GestureDetector(
                        onTap: _toggleListening,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isListening
                                ? AppColors.success.withValues(alpha: 0.12)
                                : context.appBG,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isListening
                                  ? AppColors.success
                                  : context.appBorder,
                            ),
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            size: 18,
                            color: _isListening
                                ? AppColors.success
                                : context.appText2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Send
                  GestureDetector(
                    onTap: () => _openChat(ChatFlow.none),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Job Application Plan card ────────────────────────────────────────────────

class _JobPlanCard extends StatelessWidget {
  final VoidCallback onTap;
  const _JobPlanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.chatFlowJobPlan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.chatJobPlanQ1,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick action chip ─────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: context.appBorder),
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.appText1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

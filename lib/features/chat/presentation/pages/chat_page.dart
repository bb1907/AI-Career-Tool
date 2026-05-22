import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../cv_upload/data/cv_parser.dart';
import '../../../cv_upload/domain/uploaded_cv.dart';
import '../../../cv_upload/presentation/providers/cv_upload_provider.dart';
import '../../domain/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final ChatFlow initialFlow;
  const ChatPage({super.key, required this.initialFlow});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _stt = SpeechToText();

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  bool _sttAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatProvider.notifier)
          .startFlow(widget.initialFlow, context.l10n);
      _initStt();
    });
  }

  Future<void> _initStt() async {
    final available = await _stt.initialize();
    if (mounted) setState(() => _sttAvailable = available);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    _stt.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final pos = _scrollController.position;
      if (!pos.hasContentDimensions) return;
      _scrollController.animateTo(
        pos.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(chatProvider.notifier).sendFreeText(text, context.l10n);
    _scrollToBottom();
  }

  Future<void> _toggleListening() async {
    if (!_sttAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _stt.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (!mounted) return;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read the selected file')),
      );
      return;
    }

    final l10n = context.l10n;
    final notifier = ref.read(chatProvider.notifier);
    final flow = ref.read(chatProvider).flow;

    // Show the picked file as a user message and switch to typing state
    notifier.addUserFileMessage(file.name);
    notifier.setTyping(true);
    _scrollToBottom();

    // Parse via the AI router (Gemini multimodal preferred). On failure we
    // surface the error in chat instead of leaving the user stuck.
    try {
      final router = ref.read(aiRouterProvider);
      final mime = _mimeFor(file.name);
      final data = await router.parseCvFile(
        bytes: bytes,
        mimeType: mime,
        fileName: file.name,
      );
      final parsed = CvParser.fromAiResponse(data);

      // Save the parsed CV in the global uploadedCVProvider so the rest of
      // the app (resume wizard, cover letter, etc.) can pick it up.
      final cv = UploadedCV(
        id: const Uuid().v4(),
        fileName: file.name,
        parsedText: 'Parsed from ${file.name}',
        parsedProfile: parsed,
        createdAt: DateTime.now(),
      );
      ref.read(uploadedCVProvider.notifier).set(cv);

      if (!mounted) return;
      if (flow == ChatFlow.resume) {
        // Resume builder: show summary in chat and offer to continue
        await notifier.applyParsedCv(
          parsed: parsed,
          fileName: file.name,
          l10n: l10n,
        );
      } else {
        // CV-upload flow (or others): just acknowledge and stop typing
        notifier.setTyping(false);
        notifier.postAiMessage(
          '${l10n.chatCvParsedHeader} '
          '${l10n.chatCvParsedSkills(parsed.skills.length, parsed.skills.take(4).join(', '))}',
        );
      }
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      notifier.setTyping(false);
      notifier.postAiMessage(l10n.chatCvParseFailed);
      _scrollToBottom();
    }
  }

  Future<void> _showLinkedInDialog() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.chatLinkedInDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: l10n.chatLinkedInDialogHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final v = controller.text.trim();
                Navigator.of(ctx).pop(v.isEmpty ? null : v);
              },
              child: Text(l10n.chatLinkedInDialogConfirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (!mounted || url == null || url.isEmpty) return;
    await ref.read(chatProvider.notifier).submitLinkedInUrl(url, l10n);
    _scrollToBottom();
  }

  Future<void> _onChipTap(String chip, String? action) async {
    final l10n = context.l10n;
    final notifier = ref.read(chatProvider.notifier);
    switch (action) {
      case ChipAction.scratch:
        await notifier.startResumeFromScratch(l10n);
        _scrollToBottom();
      case ChipAction.pdfPick:
        await _pickFile();
      case ChipAction.linkedInUrl:
        await _showLinkedInDialog();
      case ChipAction.cvContinue:
        await notifier.continueAfterCv(l10n);
        _scrollToBottom();
      default:
        // Legacy chip — send the label as a normal message.
        _controller.clear();
        await notifier.sendFreeText(chip, l10n);
        _scrollToBottom();
    }
  }

  String _mimeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.doc')) return 'application/msword';
    return 'application/octet-stream';
  }

  String _flowTitle(BuildContext context, ChatFlow flow) {
    switch (flow) {
      case ChatFlow.resume:
        return context.l10n.chatFlowResume;
      case ChatFlow.coverLetter:
        return context.l10n.chatFlowCoverLetter;
      case ChatFlow.interview:
        return context.l10n.chatFlowInterview;
      case ChatFlow.cvUpload:
        return context.l10n.chatFlowCvUpload;
      case ChatFlow.jobMatch:
        return context.l10n.chatFlowJobMatch;
      case ChatFlow.videoIntro:
        return context.l10n.chatFlowVideoIntro;
      case ChatFlow.none:
        return context.l10n.chatFlowNone;
      case ChatFlow.skillGap:
        return context.l10n.chatFlowSkillGap;
      case ChatFlow.mockInterview:
        return context.l10n.chatFlowMockInterview;
      case ChatFlow.networking:
        return context.l10n.chatFlowNetworking;
      case ChatFlow.aiPhoto:
        return context.l10n.chatFlowAiPhoto;
      case ChatFlow.jobPlan:
        return context.l10n.chatFlowJobPlan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Handle navigation when flow completes
    ref.listen(chatProvider, (prev, next) {
      if (next.pendingNavigation != null) {
        final target = next.pendingNavigation!;
        final extra = next.pendingNavigationExtra;
        final router = GoRouter.of(context);
        ref.read(chatProvider.notifier).clearNavigation();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          router.push(target, extra: extra);
        });
      }
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    final plan = ref.watch(subscriptionProvider).plan;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _flowTitle(context, widget.initialFlow),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (plan != PlanType.free) ...[
              const SizedBox(width: AppSpacing.sm),
              _PlanBadge(plan: plan),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(chatProvider.notifier).reset();
            context.go('/home');
          },
        ),
      ),
      body: Column(
        children: [
          // ── Message list ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount:
                  chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length && chatState.isTyping) {
                  return const _TypingIndicator();
                }
                final msg = chatState.messages[index];
                return msg.role == MessageRole.ai
                    ? _AiMessage(message: msg, onChipTap: _onChipTap)
                    : _UserMessage(message: msg);
              },
            ),
          ),

          // ── Input bar ──────────────────────────────────────────────────
          _InputBar(
            controller: _controller,
            isListening: _isListening,
            pulseAnim: _pulseAnim,
            onSend: _send,
            onMic: _toggleListening,
          ),
        ],
      ),
    );
  }
}

// ── AI message bubble ─────────────────────────────────────────────────────────

typedef ChipTapHandler = Future<void> Function(String chip, String? action);

class _AiMessage extends StatelessWidget {
  final ChatMessage message;
  final ChipTapHandler onChipTap;

  const _AiMessage({required this.message, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (Pro badge has been moved to the AppBar)
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: context.appBorder),
                    boxShadow: AppShadows.card(context),
                  ),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                // Quick-reply chips
                if (message.chips != null && message.chips!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: List.generate(message.chips!.length, (i) {
                      final chip = message.chips![i];
                      final action =
                          (message.chipActions != null &&
                              i < message.chipActions!.length)
                          ? message.chipActions![i]
                          : null;
                      final iconForAction = _iconForChipAction(
                        action,
                        chip,
                        context: context,
                      );
                      return GestureDetector(
                        onTap: () => onChipTap(chip, action),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (iconForAction != null) ...[
                                Icon(
                                  iconForAction,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                chip,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Decorates known action chips with a small leading icon. Other chips
  /// (skill suggestions, generic answers) stay text-only.
  IconData? _iconForChipAction(
    String? action,
    String chipLabel, {
    required BuildContext context,
  }) {
    switch (action) {
      case ChipAction.scratch:
        return Icons.edit_note_rounded;
      case ChipAction.pdfPick:
        return Icons.attach_file_rounded;
      case ChipAction.linkedInUrl:
        return Icons.link_rounded;
      case ChipAction.cvContinue:
        return Icons.arrow_forward_rounded;
    }
    // Legacy: cvUpload flow's "Choose file" chip is matched by label.
    if (chipLabel == context.l10n.chatCvMethodFileChip) {
      return Icons.attach_file_rounded;
    }
    return null;
  }
}

// ── User message bubble ───────────────────────────────────────────────────────

class _UserMessage extends StatelessWidget {
  final ChatMessage message;
  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: context.appBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) {
                    final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
                    final bounce = (offset < 0.5 ? offset : 1.0 - offset) * 2;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i < 2 ? 4 : 0,
                        bottom: bounce * 4,
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: 0.4 + bounce * 0.6,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final Animation<double> pulseAnim;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const _InputBar({
    required this.controller,
    required this.isListening,
    required this.pulseAnim,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border(top: BorderSide(color: context.appBorder)),
      ),
      child: Row(
        children: [
          // Mic button
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: isListening ? pulseAnim.value : 1.0,
                child: GestureDetector(
                  onTap: onMic,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isListening
                          ? AppColors.success.withValues(alpha: 0.15)
                          : context.appBG,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isListening
                            ? AppColors.success
                            : context.appBorder,
                      ),
                    ),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      size: 20,
                      color: isListening ? AppColors.success : context.appText2,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: AppSpacing.sm),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.appBG,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.appBorder),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: isListening
                      ? context.l10n.listening
                      : context.l10n.chatInputHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  hintStyle: TextStyle(color: context.appText2, fontSize: 14),
                ),
                style: TextStyle(fontSize: 14, color: context.appText1),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan badge (shown once in the AppBar) ─────────────────────────────────────

class _PlanBadge extends StatelessWidget {
  final PlanType plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final colors = plan == PlanType.proMax
        ? const [Color(0xFFF59E0B), Color(0xFFEA580C)]
        : const [Color(0xFF5B5FEF), Color(0xFF9B5DE5)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        plan == PlanType.proMax ? 'Max' : 'Pro',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

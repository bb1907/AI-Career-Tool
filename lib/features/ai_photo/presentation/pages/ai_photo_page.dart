import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../data/outfit_config.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Data model for conversation messages
// ---------------------------------------------------------------------------

class _Msg {
  final String id;
  final bool isAi;
  final String text;
  final List<String>? chips;
  final bool isPhotoSlot; // true = show photo selection widget

  _Msg({
    required this.isAi,
    required this.text,
    this.chips,
    this.isPhotoSlot = false,
  }) : id = _uuid.v4();
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

enum _Step { welcome, jobType, confirm, custom, generating }

class AiPhotoPage extends ConsumerStatefulWidget {
  const AiPhotoPage({super.key});

  @override
  ConsumerState<AiPhotoPage> createState() => _AiPhotoPageState();
}

class _AiPhotoPageState extends ConsumerState<AiPhotoPage> {
  final _messages = <_Msg>[];
  _Step _step = _Step.welcome;
  File? _selectedImage;
  String? _jobType;
  String? _outfitDescription;
  final _customCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlow());
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Flow helpers ───────────────────────────────────────────────────────────

  void _startFlow() {
    _addAi(
      "Welcome to AI Photo Studio! Upload a photo of yourself and I'll help you look professional for any job.",
      chips: ['Upload photo', 'Take selfie'],
    );
  }

  void _addAi(String text, {List<String>? chips, bool isPhotoSlot = false}) {
    setState(() {
      _messages.add(
        _Msg(isAi: true, text: text, chips: chips, isPhotoSlot: isPhotoSlot),
      );
    });
    _scrollToBottom();
  }

  void _addUser(String text) {
    setState(() => _messages.add(_Msg(isAi: false, text: text)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Photo selection ────────────────────────────────────────────────────────

  Future<void> _selectPhoto({required bool camera}) async {
    if (!await ensureBiometricConsent(context, ref)) return;
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      // Check file size (max 10 MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        if (!mounted) return;
        _addAi(
          'That photo is too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB). '
          'Please pick one under 10 MB.',
          chips: ['Upload photo', 'Take selfie'],
        );
        return;
      }

      _addUser(camera ? 'Take selfie' : 'Upload photo');
      setState(() => _selectedImage = File(file.path));

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      _addAi(
        "Great photo! What type of job are you applying for?",
        chips: [
          'Corporate / Finance',
          'Tech / Startup',
          'Creative / Design',
          'Healthcare',
          'Education',
          'Government',
          'Custom',
        ],
      );
      setState(() => _step = _Step.jobType);
    } catch (e) {
      debugPrint('[AiPhoto] Photo selection error: $e');
      if (!mounted) return;
      _addAi(
        'Could not access the photo. Please check your camera/gallery permissions and try again.',
        chips: ['Upload photo', 'Take selfie'],
      );
    }
  }

  // ── Job type selection ─────────────────────────────────────────────────────

  Future<void> _selectJobType(String jobType) async {
    _addUser(jobType);
    setState(() {
      _jobType = jobType;
      _step = jobType == 'Custom' ? _Step.custom : _Step.confirm;
    });

    if (jobType == 'Custom') {
      await Future.delayed(const Duration(milliseconds: 500));
      _addAi(
        "Describe the outfit you'd like to wear (e.g. 'red blazer with white blouse'):",
      );
      return;
    }

    final outfit = OutfitConfig.forJobType(jobType);
    setState(() => _outfitDescription = outfit.description);

    await Future.delayed(const Duration(milliseconds: 500));
    _addAi(
      "Perfect match! I'll dress you in:\n\n\"${outfit.description}\"\n\nReady to generate your professional look?",
      chips: ['Generate photo', 'Try different style', 'Customize'],
    );
  }

  // ── Confirm action ─────────────────────────────────────────────────────────

  Future<void> _handleConfirmChip(String chip) async {
    if (chip == 'Generate photo') {
      await _generate();
    } else if (chip == 'Try different style') {
      _addUser('Try different style');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      _addAi(
        "Sure! Pick a different job category:",
        chips: [
          'Corporate / Finance',
          'Tech / Startup',
          'Creative / Design',
          'Healthcare',
          'Education',
          'Government',
          'Custom',
        ],
      );
      setState(() => _step = _Step.jobType);
    } else if (chip == 'Customize') {
      _addUser('Customize outfit');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      _addAi("Describe exactly what you'd like to wear:");
      setState(() => _step = _Step.custom);
    } else if (chip == 'Back to home') {
      if (mounted) context.go('/home');
    }
  }

  // ── Generation ─────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    if (_selectedImage == null) return;

    _addUser('Generate photo');
    setState(() => _step = _Step.generating);

    // Show brief loading animation
    showAiLoading(
      context,
      messages: const [
        'Analyzing your photo...',
        'Preparing outfit preview...',
      ],
    );

    try {
      // Brief delay so the loading animation feels natural
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // dismiss loading dialog

      // Show "coming soon" message with the uploaded photo preview
      final outfit = _outfitDescription ?? 'your selected outfit';
      final job = _jobType ?? 'your industry';
      _addAi(
        '✨ Photo transformation coming soon with Pro plan!\n\n'
        'Your photo has been saved for $job. When the AI Photo feature launches, '
        'we\'ll dress you in "$outfit" for a professional look.\n\n'
        'Stay tuned — this feature is being fine-tuned for the best results!',
        chips: ['Try different style', 'Back to home'],
      );
      setState(() => _step = _Step.confirm);
    } catch (e) {
      debugPrint('[AiPhoto] Generate error: $e');
      if (!mounted) return;
      // Safely dismiss dialog if still showing
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      _addAi('Something went wrong. Please try again.', chips: ['Try again']);
      setState(() => _step = _Step.confirm);
    }
  }

  // ── Custom outfit submit ───────────────────────────────────────────────────

  void _submitCustomOutfit() {
    final text = _customCtrl.text.trim();
    if (text.isEmpty) return;
    _customCtrl.clear();
    _addUser(text);
    setState(() {
      _outfitDescription = text;
      _step = _Step.confirm;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _addAi(
        "Got it! I'll dress you in:\n\n\"$text\"\n\nReady to generate?",
        chips: ['Generate photo', 'Change description'],
      );
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBG,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'AI Photo Studio',
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
      body: Column(
        children: [
          // ── Photo quota banner ────────────────────────────────────────────
          Consumer(
            builder: (context, ref, _) {
              final sub = ref.watch(subscriptionProvider);
              if (!sub.isPremium) return const SizedBox.shrink();
              final remaining = sub.remaining(FeatureType.aiPhoto);
              final isUnlimited = remaining == null;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: isUnlimited
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.06),
                  border: Border(bottom: BorderSide(color: context.appBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUnlimited
                          ? Icons.all_inclusive_rounded
                          : Icons.photo_camera_rounded,
                      size: 14,
                      color: isUnlimited
                          ? const Color(0xFFF59E0B)
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isUnlimited
                          ? 'Unlimited AI photos'
                          : '$remaining/5 remaining this month',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUnlimited
                            ? const Color(0xFFF59E0B)
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // ── Conversation area ─────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _MessageBubble(
                  msg: msg,
                  selectedImage: _selectedImage,
                  step: _step,
                  onChipTap: (chip) {
                    if (_step == _Step.welcome) {
                      _selectPhoto(camera: chip == 'Take selfie');
                    } else if (_step == _Step.jobType) {
                      _selectJobType(chip);
                    } else if (_step == _Step.confirm) {
                      _handleConfirmChip(chip);
                    } else if (chip == 'Try again') {
                      setState(() => _step = _Step.confirm);
                      _generate();
                    } else if (chip == 'Change description') {
                      setState(() => _step = _Step.custom);
                      _addAi("What outfit would you like instead?");
                    }
                  },
                );
              },
            ),
          ),

          // ── Custom outfit input ───────────────────────────────────────────
          if (_step == _Step.custom)
            _CustomOutfitInput(
              controller: _customCtrl,
              onSubmit: _submitCustomOutfit,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  final File? selectedImage;
  final _Step step;
  final ValueChanged<String> onChipTap;

  const _MessageBubble({
    required this.msg,
    required this.selectedImage,
    required this.step,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAi = msg.isAi;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: isAi
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // ── Avatar + bubble ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: isAi
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isAi) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isAi ? context.appSurface : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAi ? 4 : 16),
                      bottomRight: Radius.circular(isAi ? 16 : 4),
                    ),
                    border: isAi ? Border.all(color: context.appBorder) : null,
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isAi ? context.appText1 : Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (!isAi) ...[
                const SizedBox(width: AppSpacing.sm),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),

          // ── Selected photo preview (after upload) ─────────────────────────
          if (isAi &&
              selectedImage != null &&
              msg.chips != null &&
              msg.chips!.contains('Corporate / Finance')) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedImage!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          // ── Chips ─────────────────────────────────────────────────────────
          if (isAi && msg.chips != null && msg.chips!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: msg.chips!.map((chip) {
                  return _ActionChip(label: chip, onTap: () => onChipTap(chip));
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action chip
// ---------------------------------------------------------------------------

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom outfit input bar
// ---------------------------------------------------------------------------

class _CustomOutfitInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CustomOutfitInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border(top: BorderSide(color: context.appBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: 'Describe your ideal outfit...',
                hintStyle: TextStyle(color: context.appText2, fontSize: 14),
                border: InputBorder.none,
              ),
              style: TextStyle(color: context.appText1, fontSize: 14),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onSubmit,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

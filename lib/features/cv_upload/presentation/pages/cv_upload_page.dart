import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/ai/ai_router.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../../../ui/components/app_card.dart';
import '../../data/cv_parser.dart';
import '../../domain/uploaded_cv.dart';
import '../providers/cv_upload_provider.dart';

enum _ImportMethod { pdf, linkedinPdf, linkedinUrl, paste, voice }

class CvUploadPage extends ConsumerStatefulWidget {
  const CvUploadPage({super.key});

  @override
  ConsumerState<CvUploadPage> createState() => _CvUploadPageState();
}

class _CvUploadPageState extends ConsumerState<CvUploadPage> {
  _ImportMethod _selected = _ImportMethod.pdf;

  final _urlController = TextEditingController();
  final _pasteController = TextEditingController();

  final _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _isListening = false;
  final _voiceController = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final ok = await _stt.initialize();
    if (mounted) setState(() => _sttAvailable = ok);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _pasteController.dispose();
    _voiceController.dispose();
    _stt.stop();
    super.dispose();
  }

  /// Parse plain-text CV content (paste, voice transcript, LinkedIn URL).
  Future<void> _processTextImport(String text, String fileName) async {
    if (!mounted) return;
    if (!await ensureAiDataConsent(context, ref)) return;
    if (!mounted) return;
    setState(() => _isProcessing = true);

    showAiLoading(
      context,
      messages: [
        context.l10n.aiLoadingReadingCv,
        context.l10n.aiLoadingExtractingSkills,
        context.l10n.aiLoadingBuildingProfile,
      ],
    );

    Map<String, dynamic>? data;
    String? error;
    try {
      final router = ref.read(aiRouterProvider);
      data = await router.parseCv(text);
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss AI loading
    setState(() => _isProcessing = false);

    if (data == null) {
      _showError(error ?? 'Failed to parse CV');
      return;
    }

    _saveParsed(fileName: fileName, parsedText: text, data: data);
  }

  /// Parse a binary CV file (PDF/DOC) via Gemini multimodal.
  Future<void> _processFileImport({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (!mounted) return;
    if (!await ensureAiDataConsent(context, ref)) return;
    if (!mounted) return;
    setState(() => _isProcessing = true);

    showAiLoading(
      context,
      messages: [
        context.l10n.aiLoadingReadingCv,
        context.l10n.aiLoadingExtractingSkills,
        context.l10n.aiLoadingBuildingProfile,
      ],
    );

    Map<String, dynamic>? data;
    String? error;
    try {
      final router = ref.read(aiRouterProvider);
      data = await router.parseCvFile(
        bytes: bytes,
        mimeType: mimeType,
        fileName: fileName,
      );
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss AI loading
    setState(() => _isProcessing = false);

    if (data == null) {
      _showError(error ?? 'Failed to parse CV');
      return;
    }

    _saveParsed(
      fileName: fileName,
      parsedText: 'Parsed from $fileName',
      data: data,
    );
  }

  void _saveParsed({
    required String fileName,
    required String parsedText,
    required Map<String, dynamic> data,
  }) {
    final parsed = CvParser.fromAiResponse(data);
    final cv = UploadedCV(
      id: const Uuid().v4(),
      fileName: fileName,
      parsedText: parsedText,
      parsedProfile: parsed,
      createdAt: DateTime.now(),
    );
    ref.read(uploadedCVProvider.notifier).set(cv);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CV parse failed: $message'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _pickPdf({bool isLinkedIn = false}) async {
    // withData: true forces file_picker to load the bytes into memory so we
    // can stream them straight into the AI parser without going through a
    // platform-specific file path.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showError('Could not read the selected file');
      return;
    }
    final mime = _mimeFor(file.name);
    final displayName = isLinkedIn
        ? 'LinkedIn export: ${file.name}'
        : file.name;
    await _processFileImport(
      bytes: bytes,
      fileName: displayName,
      mimeType: mime,
    );
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

  Future<void> _submitUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    // We can't fetch the LinkedIn profile from the client, but we can let the
    // model use the URL as a hint for parsing the user's expected profile
    // shape. Real fetching would require a backend resolver.
    await _processTextImport(
      'LinkedIn profile URL: $url\n\n'
          'The user shared this LinkedIn URL but the actual profile content is '
          'not available. Return an empty profile JSON skeleton (empty strings / '
          'empty arrays) so the user can fill it in.',
      'LinkedIn Profile',
    );
  }

  Future<void> _submitPaste() async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;
    await _processTextImport(text, 'Pasted CV');
  }

  Future<void> _toggleVoice() async {
    if (!_sttAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.speechNotAvailable)));
      return;
    }
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      if (_voiceController.text.trim().isNotEmpty) {
        await _processTextImport(_voiceController.text.trim(), 'Voice Input');
      }
    } else {
      setState(() => _isListening = true);
      await _stt.listen(
        onResult: (result) {
          setState(() {
            _voiceController.text = result.recognizedWords;
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

  @override
  Widget build(BuildContext context) {
    final cv = ref.watch(uploadedCVProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cvUploadTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.elevated(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.cvUniversalImport,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.cvUploadSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            if (cv == null) ...[
              // ── Method selector ───────────────────────────────────
              Text(
                context.l10n.cvImportMethod,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.appText2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _MethodCard(
                      icon: Icons.picture_as_pdf_rounded,
                      label: context.l10n.cvUploadMethodPdf,
                      selected: _selected == _ImportMethod.pdf,
                      onTap: () =>
                          setState(() => _selected = _ImportMethod.pdf),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MethodCard(
                      icon: Icons.business_center_rounded,
                      label: context.l10n.cvUploadMethodLinkedInPdf,
                      selected: _selected == _ImportMethod.linkedinPdf,
                      onTap: () =>
                          setState(() => _selected = _ImportMethod.linkedinPdf),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MethodCard(
                      icon: Icons.link_rounded,
                      label: context.l10n.cvUploadMethodLinkedInUrl,
                      selected: _selected == _ImportMethod.linkedinUrl,
                      onTap: () =>
                          setState(() => _selected = _ImportMethod.linkedinUrl),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MethodCard(
                      icon: Icons.content_paste_rounded,
                      label: context.l10n.cvUploadMethodPaste,
                      selected: _selected == _ImportMethod.paste,
                      onTap: () =>
                          setState(() => _selected = _ImportMethod.paste),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MethodCard(
                      icon: Icons.mic_rounded,
                      label: context.l10n.cvUploadMethodVoice,
                      selected: _selected == _ImportMethod.voice,
                      onTap: () =>
                          setState(() => _selected = _ImportMethod.voice),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Active method UI ──────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_selected),
                  child: _buildMethodContent(),
                ),
              ),
            ] else ...[
              // ── Success state ────────────────────────────────────
              _SuccessView(
                cv: cv,
                onReset: () {
                  ref.read(uploadedCVProvider.notifier).clear();
                },
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodContent() {
    switch (_selected) {
      case _ImportMethod.pdf:
        return _DropZone(
          title: context.l10n.cvUploadPdfTitle,
          subtitle: context.l10n.cvUploadPdfSubtitle,
          icon: Icons.upload_file_rounded,
          buttonLabel: context.l10n.cvUploadPdfButton,
          onTap: () => _pickPdf(),
          isProcessing: _isProcessing,
        );

      case _ImportMethod.linkedinPdf:
        return _DropZone(
          title: context.l10n.cvLinkedInPdfExportTitle,
          subtitle: context.l10n.cvLinkedInPdfExportSubtitle,
          icon: Icons.business_center_rounded,
          buttonLabel: context.l10n.cvLinkedInPdfExportButton,
          onTap: () => _pickPdf(isLinkedIn: true),
          isProcessing: _isProcessing,
        );

      case _ImportMethod.linkedinUrl:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cvPasteLinkedInUrl,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.cvLinkedInUrlExample,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.appText2),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://linkedin.com/in/...',
                  hintStyle: TextStyle(color: context.appText2, fontSize: 14),
                  prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide(color: context.appBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide(color: context.appBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _submitUrl(),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _submitUrl,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(context.l10n.cvImportFromLinkedIn),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                ),
              ),
            ],
          ),
        );

      case _ImportMethod.paste:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cvPasteYourText,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.cvPasteYourTextSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.appText2),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: context.appBG,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: context.appBorder),
                ),
                child: TextField(
                  controller: _pasteController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: context.l10n.cvPasteHintLong,
                    hintStyle: TextStyle(color: context.appText2, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        _pasteController.text = data!.text!;
                      }
                    },
                    icon: const Icon(Icons.content_paste_rounded, size: 16),
                    label: Text(context.l10n.cvPasteFromClipboard),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _isProcessing ? null : _submitPaste,
                    child: Text(context.l10n.cvImport),
                  ),
                ],
              ),
            ],
          ),
        );

      case _ImportMethod.voice:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cvTellAiAboutCareer,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.cvSpeakNaturally,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.appText2),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: GestureDetector(
                  onTap: _toggleVoice,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isListening
                            ? AppColors.success
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      size: 36,
                      color: _isListening
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  _isListening
                      ? context.l10n.cvUploadVoiceStop
                      : context.l10n.cvUploadVoiceButton,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.appText2),
                ),
              ),
              if (_voiceController.text.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.appBG,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(color: context.appBorder),
                  ),
                  child: Text(
                    _voiceController.text,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _processTextImport(
                            _voiceController.text.trim(),
                            'Voice Input',
                          ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(context.l10n.cvBuildMyProfile),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}

// ── Drop zone for file upload ──────────────────────────────────────────────────

class _DropZone extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool isProcessing;

  const _DropZone({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    required this.onTap,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.appText2),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: isProcessing ? null : onTap,
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Method selector card ───────────────────────────────────────────────────────

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.09)
              : context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.primary : context.appBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.primary : context.appText2,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : context.appText2,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success + profile view ─────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final UploadedCV cv;
  final VoidCallback onReset;

  const _SuccessView({required this.cv, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success banner
        AppCard(
          color: AppColors.success.withValues(alpha: 0.07),
          showBorder: false,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cv.fileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      context.l10n.cvProfileExtracted,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: context.appText2,
                ),
                onPressed: onReset,
                tooltip: context.l10n.cvImportDifferent,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Extracted profile
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cvExtractedProfile,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (cv.parsedProfile.summary != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  cv.parsedProfile.summary!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: context.appText2),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              _ProfileSection(
                title: context.l10n.cvSectionSkills,
                color: AppColors.primary,
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: cv.parsedProfile.skills
                      .map((s) => _SkillChip(label: s))
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              _ProfileSection(
                title: context.l10n.cvSectionExperience,
                color: AppColors.primary,
                child: Column(
                  children: cv.parsedProfile.experiences
                      .map((e) => _BulletRow(text: e, color: AppColors.primary))
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              _ProfileSection(
                title: context.l10n.cvSectionEducation,
                color: AppColors.accent,
                child: Column(
                  children: cv.parsedProfile.education
                      .map((e) => _BulletRow(text: e, color: AppColors.accent))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(context.l10n.cvUseThisProfile),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;
  const _ProfileSection({
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

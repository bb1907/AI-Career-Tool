import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/ai/mock_lang_detector.dart';
import '../../../../services/openai/openai_service.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../domain/cover_letter.dart';
import '../providers/cover_letter_provider.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../settings/providers/ai_language_provider.dart';

class CoverLetterFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? prefill;

  const CoverLetterFormPage({super.key, this.prefill});

  @override
  ConsumerState<CoverLetterFormPage> createState() =>
      _CoverLetterFormPageState();
}

class _CoverLetterFormPageState extends ConsumerState<CoverLetterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _tone = 'professional';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null) {
      _companyController.text = prefill['company'] as String? ?? '';
      _roleController.text = prefill['role'] as String? ?? '';
      _descriptionController.text = prefill['jobDescription'] as String? ?? '';
      final tone = (prefill['tone'] as String? ?? 'professional').toLowerCase();
      _tone = ['professional', 'friendly', 'confident'].contains(tone)
          ? tone
          : 'professional';

      // Auto-generate if all required fields are pre-filled
      final company = _companyController.text.trim();
      final role = _roleController.text.trim();
      final jobDesc = _descriptionController.text.trim();
      if (company.isNotEmpty && role.isNotEmpty && jobDesc.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _onGenerate();
        });
      }
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Mock fallback ─────────────────────────────────────────────────────────

  String _mockCoverLetter() {
    final company = _companyController.text.trim();
    final role = _roleController.text.trim();
    final description = _descriptionController.text.trim();

    // Detect language: explicit AI language setting > input text detection > English
    final aiLangCode = ref.read(aiLanguageProvider);
    String lang;
    if (aiLangCode != 'auto') {
      lang = aiLangCode;
    } else {
      final combined = '$company $role $description';
      lang = MockLangDetector.detect(combined);
    }

    final keywords = _extractKeywords(description);
    final keywordLine = keywords.isNotEmpty
        ? (lang == 'tr'
              ? 'Geçmişim, özellikle ${keywords.take(3).join(', ')} alanlarında gereksinimlerinizle yakından örtüşmektedir.'
              : lang == 'es'
              ? 'Mi perfil se alinea estrechamente con sus requisitos, especialmente en ${keywords.take(3).join(', ')}.'
              : 'My background aligns closely with your requirements, particularly in ${keywords.take(3).join(', ')}.')
        : (lang == 'tr'
              ? 'Geçmişim, iş tanımında belirtilen gereksinimlerle yakından örtüşmektedir.'
              : lang == 'es'
              ? 'Mi perfil se alinea estrechamente con los requisitos del puesto.'
              : 'My background aligns closely with the requirements outlined in the job description.');

    return MockLangDetector.coverLetter(
      lang: lang,
      company: company.isNotEmpty ? company : 'the Company',
      role: role.isNotEmpty ? role : 'this position',
      keywordLine: keywordLine,
      tone: _tone,
    );
  }

  List<String> _extractKeywords(String description) {
    const techKeywords = [
      'Flutter',
      'Dart',
      'React',
      'Swift',
      'Kotlin',
      'Python',
      'JavaScript',
      'TypeScript',
      'Node.js',
      'AWS',
      'Firebase',
      'REST API',
      'GraphQL',
      'leadership',
      'communication',
      'teamwork',
      'agile',
      'scrum',
      'problem-solving',
      'analytics',
      'design',
      'testing',
      'CI/CD',
    ];
    final lower = description.toLowerCase();
    return techKeywords.where((k) => lower.contains(k.toLowerCase())).toList();
  }

  // ─── Generate ──────────────────────────────────────────────────────────────

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureAiDataConsent(context, ref)) return;
    if (!mounted) return;

    // Compute teaser flag BEFORE recordUsage (first gen free, 2nd+ teaser)
    final isTeaser = ref
        .read(subscriptionProvider)
        .shouldShowTeaser(FeatureType.coverLetter);

    setState(() => _isGenerating = true);
    showAiLoading(
      context,
      messages: const [
        'Analyzing job description...',
        'Matching your profile to requirements...',
        'Crafting your cover letter...',
      ],
    );

    String coverLetterText;
    try {
      final service = ref.read(openAiServiceProvider);
      debugPrint('[DEBUG CoverLetter] hasKey: ${service.hasKey}');
      if (service.hasKey) {
        debugPrint('[DEBUG CoverLetter] Calling real AI...');
        coverLetterText = await service.generateCoverLetter(
          company: _companyController.text.trim(),
          role: _roleController.text.trim(),
          jobDescription: _descriptionController.text.trim(),
        );
        debugPrint(
          '[DEBUG CoverLetter] AI returned ${coverLetterText.length} chars',
        );
      } else {
        debugPrint('[DEBUG CoverLetter] Using mock fallback');
        await Future.delayed(const Duration(milliseconds: 3000));
        coverLetterText = _mockCoverLetter();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generation failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() => _isGenerating = false);

    final cl = CoverLetter(
      id: const Uuid().v4(),
      companyName: _companyController.text.trim(),
      roleName: _roleController.text.trim(),
      jobDescription: _descriptionController.text.trim(),
      generatedText: coverLetterText,
      tone: _tone,
      createdAt: DateTime.now(),
    );
    ref.read(coverLetterListProvider.notifier).save(cl);
    await ref
        .read(subscriptionProvider.notifier)
        .recordUsage(FeatureType.coverLetter);
    if (!mounted) return;
    context.push(
      '/cover-letter/result',
      extra: {'result': cl, 'isTeaser': isTeaser},
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.coverLetterTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.coverLetterGenerate,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Fill in the details below to create a personalised cover letter.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.appText2),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: context.l10n.coverLetterCompany,
                  hintText: 'e.g. Google, Spotify',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter company name'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role / Position',
                  hintText: 'e.g. Senior Flutter Developer',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter role'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.coverLetterJobDesc,
                  hintText: context.l10n.coverLetterJobDescHint,
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                textInputAction: TextInputAction.done,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter job description'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Tone',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'professional',
                    label: Text(context.l10n.coverLetterToneProfessional),
                  ),
                  ButtonSegment(
                    value: 'friendly',
                    label: const Text('Friendly'),
                  ),
                  ButtonSegment(
                    value: 'confident',
                    label: const Text('Confident'),
                  ),
                ],
                selected: {_tone},
                onSelectionChanged: (s) => setState(() => _tone = s.first),
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _isGenerating ? null : _onGenerate,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _isGenerating
                      ? 'Generating...'
                      : context.l10n.coverLetterGenerate,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

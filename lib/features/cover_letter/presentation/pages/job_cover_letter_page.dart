import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/openai/openai_service.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../domain/cover_letter.dart';
import '../providers/cover_letter_provider.dart';
import '../../../../app/core/l10n_extension.dart';

class JobCoverLetterPage extends ConsumerStatefulWidget {
  const JobCoverLetterPage({super.key});

  @override
  ConsumerState<JobCoverLetterPage> createState() => _JobCoverLetterPageState();
}

class _JobCoverLetterPageState extends ConsumerState<JobCoverLetterPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _whyController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _jdController = TextEditingController();
  String _tone = 'professional';
  int _step = 0;
  bool _isGenerating = false;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _whyController.dispose();
    _achievementsController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  String _mockGenerate() {
    final company = _companyController.text.trim();
    final role = _roleController.text.trim();
    final why = _whyController.text.trim();
    final achievements = _achievementsController.text.trim();
    final jd = _jdController.text.trim();

    final greeting = _tone == 'friendly' ? 'Hi there,' : 'Dear Hiring Manager,';
    final opening = _tone == 'confident'
        ? 'I am the ideal candidate for the $role position at $company.'
        : 'I am writing to express my strong interest in the $role position at $company.';
    final closing = _tone == 'friendly'
        ? 'I would love to chat and learn more about the team!'
        : 'I welcome the opportunity to discuss how my background aligns with your team\'s goals.';

    const keywords = ['experience', 'skills', 'team', 'results', 'growth'];
    final jdLower = jd.toLowerCase();
    final mentionedKeywords = keywords
        .where((k) => jdLower.contains(k))
        .toList();
    final keywordLine = mentionedKeywords.isNotEmpty
        ? 'My profile aligns with the key requirements including ${mentionedKeywords.take(2).join(' and ')}.'
        : 'My profile closely matches your requirements.';

    return '''$greeting

$opening $keywordLine

${why.isNotEmpty ? 'What drew me to this opportunity: $why\n' : ''}${achievements.isNotEmpty ? 'Among my key achievements: $achievements\n' : ''}
Throughout my career I have delivered high-quality work while collaborating effectively with cross-functional teams. I am particularly excited about ${company}s vision and the opportunity this role offers to make a meaningful impact.

$closing

Thank you for considering my application.

Sincerely,
[Your Name]''';
  }

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);
    showAiLoading(
      context,
      messages: const [
        'Analyzing job description...',
        'Matching your profile to requirements...',
        'Crafting your smart cover letter...',
      ],
    );

    String text;
    try {
      final service = ref.read(openAiServiceProvider);
      if (service.hasKey) {
        text = await service.generateCoverLetter(
          company: _companyController.text.trim(),
          role: _roleController.text.trim(),
          jobDescription: _jdController.text.trim(),
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 3200));
        text = _mockGenerate();
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

    final cl = CoverLetter(
      id: const Uuid().v4(),
      companyName: _companyController.text.trim(),
      roleName: _roleController.text.trim(),
      jobDescription: _jdController.text.trim(),
      generatedText: text,
      tone: _tone,
      createdAt: DateTime.now(),
    );
    ref.read(coverLetterListProvider.notifier).save(cl);
    setState(() => _isGenerating = false);
    context.push('/cover-letter/result', extra: cl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Cover Letter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              _StepIndicator(currentStep: _step),
              const SizedBox(height: AppSpacing.lg),

              if (_step == 0) ...[_buildStep1()] else ...[_buildStep2()],

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about the role',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Provide context so we can craft a personalised letter.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.appText2),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextFormField(
          controller: _companyController,
          decoration: const InputDecoration(
            labelText: 'Company',
            hintText: 'e.g. Google, Stripe',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _roleController,
          decoration: const InputDecoration(
            labelText: 'Role',
            hintText: 'e.g. Senior Flutter Developer',
            prefixIcon: Icon(Icons.work_outline_rounded),
          ),
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _whyController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Why are you applying for this role?',
            hintText: "What excites you about this opportunity...",
            alignLabelWithHint: true,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _achievementsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Top 2 relevant achievements',
            hintText: 'e.g. Led a team of 5, increased revenue by 30%...',
            alignLabelWithHint: true,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Preferred Tone',
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
            const ButtonSegment(value: 'friendly', label: Text('Friendly')),
            const ButtonSegment(value: 'confident', label: Text('Confident')),
          ],
          selected: {_tone},
          onSelectionChanged: (s) => setState(() => _tone = s.first),
          style: ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () {
            if (_companyController.text.trim().isEmpty ||
                _roleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in Company and Role.'),
                ),
              );
              return;
            }
            setState(() => _step = 1);
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paste the Job Description',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "We'll extract key requirements and tailor your letter.",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.appText2),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextFormField(
          controller: _jdController,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: context.l10n.coverLetterJobDesc,
            hintText: context.l10n.coverLetterJobDescHint,
            alignLabelWithHint: true,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please paste the job description'
              : null,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: _isGenerating ? null : _onGenerate,
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Generate Smart Cover Letter'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () => setState(() => _step = 0),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: Text(context.l10n.back),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(index: 0, current: currentStep, label: 'Context'),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: currentStep >= 1 ? AppColors.primary : context.appBorder,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _StepDot(index: 1, current: currentStep, label: 'JD'),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  const _StepDot({
    required this.index,
    required this.current,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final isDone = index < current;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone || isActive ? AppColors.primary : context.appBorder,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : context.appText2,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : context.appText2,
          ),
        ),
      ],
    );
  }
}

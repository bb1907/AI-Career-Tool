import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/l10n_extension.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../services/openai/openai_service.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../../data/mock_question_generator.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../domain/interview_question.dart';
import '../../domain/interview_set.dart';
import '../providers/interview_set_provider.dart';

class InterviewPrepFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? prefill;

  const InterviewPrepFormPage({super.key, this.prefill});

  @override
  ConsumerState<InterviewPrepFormPage> createState() =>
      _InterviewPrepFormPageState();
}

class _InterviewPrepFormPageState extends ConsumerState<InterviewPrepFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  String? _seniority;
  bool _isGenerating = false;

  List<String> _seniorityLevels(BuildContext context) => [
    context.l10n.interviewPrepSeniorityJunior,
    context.l10n.interviewPrepSeniorityMid,
    context.l10n.interviewPrepSenioritySenior,
    context.l10n.interviewPrepSeniorityLead,
  ];

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null) {
      final role = prefill['role'] as String? ?? '';
      if (role.isNotEmpty) {
        _roleController.text = role;
      }
      final seniority = prefill['seniority'] as String? ?? '';
      if (seniority.isNotEmpty) {
        _seniority = seniority;
      }

      // Auto-generate if role and seniority are pre-filled
      if (role.isNotEmpty && seniority.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _onGenerate();
        });
      }
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _onGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureAiDataConsent(context, ref)) return;

    // Compute teaser flag BEFORE recordUsage (first gen free, 2nd+ teaser)
    final isTeaser = ref
        .read(subscriptionProvider)
        .shouldShowTeaser(FeatureType.interview);

    setState(() => _isGenerating = true);
    showAiLoading(
      context,
      messages: const [
        'Analyzing role requirements...',
        'Generating technical questions...',
        'Crafting behavioral questions...',
      ],
    );

    final role = _roleController.text.trim();
    final seniority = _seniority ?? '';

    List<Map<String, dynamic>> payload;
    try {
      final service = ref.read(openAiServiceProvider);
      debugPrint('[DEBUG InterviewPrep] hasKey: ${service.hasKey}');
      if (service.hasKey) {
        debugPrint(
          '[DEBUG InterviewPrep] Calling real AI for $role / $seniority',
        );
        final questions = await service.generateInterviewQuestions(
          role: role,
          seniority: seniority,
        );
        debugPrint(
          '[DEBUG InterviewPrep] AI returned ${questions.length} questions',
        );
        payload = questions.map((q) => q.toMap()).toList();
      } else {
        debugPrint('[DEBUG InterviewPrep] Using mock fallback');
        await Future.delayed(const Duration(milliseconds: 3000));
        final questions = MockQuestionGenerator.generate(
          role: role,
          seniority: seniority,
        );
        payload = questions.map((q) => q.toMap()).toList();
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

    // Save set to repo
    final questions = payload.map((m) => InterviewQuestion.fromMap(m)).toList();
    final set = InterviewSet(
      id: const Uuid().v4(),
      roleName: role,
      seniority: seniority,
      questions: questions,
      createdAt: DateTime.now(),
    );
    ref.read(interviewSetListProvider.notifier).save(set);
    await ref
        .read(subscriptionProvider.notifier)
        .recordUsage(FeatureType.interview);

    if (!mounted) return;
    context.push(
      '/interview-prep/questions',
      extra: {'payload': payload, 'isTeaser': isTeaser},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final levels = _seniorityLevels(context);
    _seniority ??= levels[1];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.interviewPrepTitle),
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
                l10n.interviewPrepTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.interviewPrepSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.appText2),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: l10n.interviewPrepRole,
                  hintText: l10n.interviewPrepRoleHint,
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                ),
                textInputAction: TextInputAction.done,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.errorEmptyField
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.interviewPrepSeniority,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SenioritySelector(
                selected: _seniority!,
                levels: levels,
                onChanged: (v) => setState(() => _seniority = v),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _isGenerating ? null : _onGenerate,
                icon: const Icon(Icons.psychology_outlined, size: 18),
                label: Text(
                  _isGenerating
                      ? l10n.interviewPrepGenerating
                      : l10n.interviewPrepGenerate,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // ── Practice Mode ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.interviewPrepPracticeNew,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.interviewPrepPracticeMode,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.interviewPrepPracticeDesc,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.appText2),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _isGenerating
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              context.push(
                                '/mock-interview',
                                extra: {
                                  'role': _roleController.text.trim(),
                                  'seniority': _seniority ?? '',
                                },
                              );
                            },
                      icon: const Icon(Icons.forum_rounded, size: 18),
                      label: Text(l10n.interviewPrepStartPractice),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ],
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

class _SenioritySelector extends StatelessWidget {
  final String selected;
  final List<String> levels;
  final ValueChanged<String> onChanged;

  const _SenioritySelector({
    required this.selected,
    required this.levels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: levels.map((level) {
        final isSelected = level == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: level != levels.last ? AppSpacing.xs : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : context.appSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : context.appBorder,
                  ),
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.appText2,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/resume_provider.dart';
import '../../../../services/privacy/consent_guard.dart';
import '../../../../services/subscription/subscription_provider.dart';
import '../../../../shared/widgets/ai_loading_dialog.dart';
import '../widgets/step_personal_info.dart';
import '../widgets/step_summary.dart';
import '../widgets/step_work_experience.dart';
import '../widgets/step_education.dart';
import '../widgets/step_skills.dart';
import '../widgets/step_projects.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';

class ResumeWizardPage extends ConsumerStatefulWidget {
  final String? resumeId;
  final Map<String, dynamic>? prefill;

  const ResumeWizardPage({super.key, this.resumeId, this.prefill});

  @override
  ConsumerState<ResumeWizardPage> createState() => _ResumeWizardPageState();
}

class _ResumeWizardPageState extends ConsumerState<ResumeWizardPage> {
  bool _prefillTriggered = false;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null && prefill.isNotEmpty && !_prefillTriggered) {
      _prefillTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _runAiPrefill(prefill),
      );
    }
  }

  Future<void> _runAiPrefill(Map<String, dynamic> prefill) async {
    if (!mounted) return;
    if (!await ensureAiDataConsent(context, ref)) return;
    final notifier = ref.read(resumeEditorProvider(widget.resumeId).notifier);
    showAiLoading(
      context,
      messages: const [
        'Reviewing your experience...',
        'Identifying key skills...',
        'Building your resume...',
      ],
    );
    try {
      await notifier.generateFromPrefill(prefill);
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (!mounted) return;
    final err = ref.read(resumeEditorProvider(widget.resumeId)).error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not auto-generate resume: $err'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      // Move directly to the Summary step so the user sees the AI output
      ref.read(resumeEditorProvider(widget.resumeId).notifier).goToStep(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(resumeEditorProvider(widget.resumeId));
    final notifier = ref.read(resumeEditorProvider(widget.resumeId).notifier);
    final resumeId = widget.resumeId;

    final steps = [
      context.l10n.resumeStepBasicInfo,
      context.l10n.resumeStepSummary,
      context.l10n.resumeStepExperience,
      context.l10n.resumeStepEducation,
      context.l10n.resumeStepSkills,
      context.l10n.resumeStepProjects,
    ];
    final currentStep = editorState.currentStep;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          resumeId == null || resumeId == 'new'
              ? context.l10n.resumeNew
              : context.l10n.resumeWizardTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/resume'),
        ),
      ),
      body: Column(
        children: [
          // ── Step indicator (Linear-inspired)
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.md,
              AppTheme.sm,
              AppTheme.md,
              AppTheme.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(steps.length, (i) {
                    final isActive = i == currentStep;
                    final isDone = i < currentStep;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => notifier.goToStep(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: isDone
                                ? AppTheme.primary
                                : isActive
                                ? AppTheme.primary
                                : Colors.grey.shade200,
                            gradient: (isDone || isActive)
                                ? AppTheme.primaryGradient
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppTheme.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      steps[currentStep],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.l10n.resumeWizardStepOf(
                        currentStep + 1,
                        steps.length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Step content
          Expanded(
            child: IndexedStack(
              index: currentStep,
              children: [
                StepPersonalInfo(resumeId: resumeId),
                StepSummary(resumeId: resumeId),
                StepWorkExperience(resumeId: resumeId),
                StepEducation(resumeId: resumeId),
                StepSkills(resumeId: resumeId),
                StepProjects(resumeId: resumeId),
              ],
            ),
          ),

          // ── Navigation
          Container(
            padding: const EdgeInsets.all(AppTheme.md),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: notifier.prevStep,
                        child: Text(context.l10n.resumeWizardPrevious),
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: editorState.isSaving
                          ? null
                          : () async {
                              if (currentStep < 5) {
                                notifier.nextStep();
                              } else {
                                final isNew = resumeId == null;
                                // Compute teaser BEFORE recordUsage
                                final isTeaser = isNew
                                    ? ref
                                          .read(subscriptionProvider)
                                          .shouldShowTeaser(FeatureType.resume)
                                    : false;
                                await notifier.save();
                                if (isNew) {
                                  await ref
                                      .read(subscriptionProvider.notifier)
                                      .recordUsage(FeatureType.resume);
                                }
                                if (context.mounted) {
                                  if (isNew) {
                                    // Navigate directly to preview for new resumes
                                    final savedId = ref
                                        .read(resumeEditorProvider(resumeId))
                                        .resume
                                        .id;
                                    context.go(
                                      '/resume/$savedId/preview',
                                      extra: {'isTeaser': isTeaser},
                                    );
                                  } else {
                                    context.go('/resume');
                                  }
                                }
                              }
                            },
                      child: editorState.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              currentStep < 5
                                  ? context.l10n.resumeWizardContinue
                                  : context.l10n.resumeWizardSave,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

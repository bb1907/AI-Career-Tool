import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/validators.dart';
import '../../../../services/subscription/premium_access_feature.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/app_input_field.dart';
import '../../../../ui/components/assistant_orb.dart';
import '../../../../ui/components/section_header.dart';
import '../../../job_matching/application/selected_job_controller.dart';
import '../../../job_matching/domain/entities/job_listing.dart';
import '../../../paywall/application/premium_access_controller.dart';
import '../../../profile_import/application/candidate_profile_controller.dart';
import '../../../profile_import/application/candidate_profile_prefill.dart';
import '../../../profile_import/domain/entities/candidate_profile.dart';
import '../../../profile_import/presentation/widgets/candidate_profile_prefill_banner.dart';
import '../../application/cover_letter_controller.dart';
import '../../domain/entities/cover_letter_candidate_context.dart';
import '../../domain/entities/cover_letter_clarifying_context.dart';
import '../../domain/entities/cover_letter_job_context.dart';
import '../../domain/entities/cover_letter_request.dart';

class CoverLetterInputPage extends ConsumerStatefulWidget {
  const CoverLetterInputPage({super.key});

  @override
  ConsumerState<CoverLetterInputPage> createState() =>
      _CoverLetterInputPageState();
}

class _CoverLetterInputPageState extends ConsumerState<CoverLetterInputPage> {
  static const _toneOptions = <String>[
    'Professional',
    'Confident',
    'Warm',
    'Concise',
  ];

  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _userBackgroundController = TextEditingController();
  final _whyCompanyController = TextEditingController();
  final _achievementController = TextEditingController();
  final _emphasisController = TextEditingController();
  String _tone = _toneOptions.first;
  String? _appliedProfileSignature;
  String? _appliedJobSignature;
  bool _isSubmitting = false;
  bool _showClarifyingDetails = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _roleTitleController.dispose();
    _jobDescriptionController.dispose();
    _userBackgroundController.dispose();
    _whyCompanyController.dispose();
    _achievementController.dispose();
    _emphasisController.dispose();
    super.dispose();
  }

  void _scheduleProfilePrefill(CandidateProfile? profile) {
    if (profile == null) {
      return;
    }

    final signature = [
      profile.id ?? '',
      profile.uploadedCvId ?? '',
      profile.name,
      profile.roles.join('|'),
      profile.skills.join('|'),
      profile.industries.join('|'),
      profile.education,
    ].join('::');

    if (_appliedProfileSignature == signature) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedProfileSignature == signature) {
        return;
      }

      final prefill = CandidateProfilePrefill.forCoverLetter(profile);
      _fillIfEmpty(_roleTitleController, prefill.roleTitle);
      _fillIfEmpty(_userBackgroundController, prefill.userBackground);
      _appliedProfileSignature = signature;
    });
  }

  void _scheduleSelectedJobPrefill(JobListing? job) {
    if (job == null) {
      return;
    }

    final signature = [
      job.id,
      job.title,
      job.company,
      job.location,
      job.url,
    ].join('::');

    if (_appliedJobSignature == signature) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedJobSignature == signature) {
        return;
      }

      _companyNameController.text = job.company;
      _roleTitleController.text = job.title;
      _jobDescriptionController.text = job.jobDescription;
      _appliedJobSignature = signature;
    });
  }

  void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  CoverLetterCandidateContext? _buildCandidateContext(
    CandidateProfile? profile,
  ) {
    if (profile == null) {
      return null;
    }

    return CoverLetterCandidateContext(
      name: profile.name,
      email: profile.email,
      location: profile.location,
      yearsExperience: profile.yearsExperience,
      roles: profile.roles,
      skills: profile.skills,
      industries: profile.industries,
      seniority: profile.seniority,
      education: profile.education,
    );
  }

  CoverLetterJobContext? _buildJobContext(JobListing? job) {
    if (job == null) {
      return null;
    }

    return CoverLetterJobContext(
      jobId: job.id,
      title: job.title,
      company: job.company,
      location: job.location,
      source: job.source,
      url: job.url,
      jobDescription: job.jobDescription,
    );
  }

  CoverLetterClarifyingContext? _buildClarifyingContext() {
    final clarifyingContext = CoverLetterClarifyingContext(
      whyThisCompany: _whyCompanyController.text.trim(),
      keyAchievement: _achievementController.text.trim(),
      emphasisNotes: _emphasisController.text.trim(),
    );

    return clarifyingContext.hasContent ? clarifyingContext : null;
  }

  Future<void> _submit() async {
    final isGenerating = ref.read(coverLetterControllerProvider).isGenerating;
    if (_isSubmitting || isGenerating || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final accessDecision = await ref
          .read(premiumAccessControllerProvider.notifier)
          .requestAccess(PremiumAccessFeature.coverLetterGenerate);

      if (!accessDecision.isAllowed) {
        if (!mounted) {
          return;
        }

        final unlocked = await context.push<bool>(
          Uri(
            path: AppRoutes.paywall,
            queryParameters: {
              'from': AppRoutes.coverLetter,
              'reason': 'usage_limit',
              'feature': PremiumAccessFeature.coverLetterGenerate.name,
            },
          ).toString(),
        );

        if (!mounted || unlocked != true) {
          return;
        }

        final refreshedDecision = await ref
            .read(premiumAccessControllerProvider.notifier)
            .requestAccess(PremiumAccessFeature.coverLetterGenerate);
        if (!refreshedDecision.isAllowed) {
          return;
        }
      }

      final candidateProfile = ref
          .read(candidateProfileControllerProvider)
          .asData
          ?.value;
      final selectedJob = ref.read(selectedJobControllerProvider);
      final request = CoverLetterRequest(
        companyName: _companyNameController.text.trim(),
        roleTitle: _roleTitleController.text.trim(),
        jobDescription: _jobDescriptionController.text.trim(),
        userBackground: _userBackgroundController.text.trim(),
        tone: _tone,
        candidateContext: _buildCandidateContext(candidateProfile),
        jobContext: _buildJobContext(selectedJob),
        clarifyingContext: _buildClarifyingContext(),
      );

      unawaited(
        ref
            .read(coverLetterControllerProvider.notifier)
            .startGeneration(request),
      );

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();
      context.push(AppRoutes.coverLetterResult);
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'We couldn\'t start cover letter generation right now. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(coverLetterControllerProvider);
    final profile = ref.watch(candidateProfileControllerProvider).asData?.value;
    final selectedJob = ref.watch(selectedJobControllerProvider);

    _scheduleProfilePrefill(profile);
    _scheduleSelectedJobPrefill(selectedJob);

    return Scaffold(
      appBar: AppBar(title: const Text('Cover Letter Generator')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            AppCard(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
              borderColor: colorScheme.primary.withValues(alpha: 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      AssistantOrb(size: 42),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text('Generate a job-aware cover letter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Turn your profile and the selected role into a tailored, concise draft that sounds credible and specific.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (selectedJob != null) ...[
                    const SizedBox(height: 16),
                    _ContextCallout(
                      icon: Icons.work_outline_rounded,
                      label: 'Selected job context',
                      value:
                          '${selectedJob.title} at ${selectedJob.company} • ${selectedJob.location}',
                    ),
                  ],
                  if (profile != null) ...[
                    const SizedBox(height: 16),
                    const CandidateProfilePrefillBanner(
                      message:
                          'We prefilled the role and background fields from your imported candidate profile. You can still edit every field.',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Letter brief',
                      subtitle:
                          'Keep the prompt practical. A good company, role and job description already give the model strong direction.',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppInputField(
                            controller: _companyNameController,
                            label: 'Company Name',
                            hint: 'Shopify',
                            prefixIcon: const Icon(Icons.apartment_rounded),
                            textInputAction: TextInputAction.next,
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: 'Company name',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppInputField(
                            controller: _roleTitleController,
                            label: 'Role Title',
                            hint: 'Product Manager',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            textInputAction: TextInputAction.next,
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: 'Role title',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _jobDescriptionController,
                      label: 'Job Description',
                      hint:
                          'Paste the most important responsibilities, requirements and keywords from the posting.',
                      helper:
                          'Include the role goals, experience requirements and any tools or industry context.',
                      minLines: 6,
                      maxLines: 9,
                      textInputAction: TextInputAction.newline,
                      validator: (value) => Validators.requiredField(
                        value,
                        fieldName: 'Job description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _userBackgroundController,
                      label: 'Your Background',
                      hint:
                          'Summarize the experience, achievements and strengths that make you relevant for this role.',
                      helper:
                          'This can be short. Focus on the strongest evidence you want the letter to emphasize.',
                      minLines: 5,
                      maxLines: 7,
                      textInputAction: TextInputAction.newline,
                      validator: (value) => Validators.requiredField(
                        value,
                        fieldName: 'User background',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tone,
                      decoration: const InputDecoration(labelText: 'Tone'),
                      items: _toneOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _tone = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Clarifying details',
                    subtitle:
                        'Optional details that help the draft sound less generic and more specific to this application.',
                    action: TextButton(
                      onPressed: () {
                        setState(() {
                          _showClarifyingDetails = !_showClarifyingDetails;
                        });
                      },
                      child: Text(
                        _showClarifyingDetails
                            ? 'Hide optional clarifying details'
                            : 'Add optional clarifying details',
                      ),
                    ),
                  ),
                  if (_showClarifyingDetails) ...[
                    const SizedBox(height: 20),
                    AppInputField(
                      controller: _whyCompanyController,
                      label: 'Why this company?',
                      hint:
                          'Mention the mission, product, stage or team context that genuinely stands out.',
                      minLines: 3,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _achievementController,
                      label: 'Most relevant achievement',
                      hint:
                          'Example: Led a redesign that improved onboarding conversion by 18%.',
                      minLines: 3,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _emphasisController,
                      label: 'Anything else to emphasize?',
                      hint:
                          'Leadership scope, technical depth, domain knowledge, relocation, portfolio link, etc.',
                      minLines: 3,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            AIButton(
              label: state.isGenerating || _isSubmitting
                  ? 'Generating cover letter...'
                  : 'Generate cover letter',
              icon: const Icon(Icons.auto_awesome_rounded),
              isLoading: state.isGenerating || _isSubmitting,
              onPressed: state.isGenerating || _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCallout extends StatelessWidget {
  const _ContextCallout({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

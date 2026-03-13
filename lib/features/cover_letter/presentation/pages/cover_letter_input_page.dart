import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/subscription/premium_access_feature.dart';
import '../../../paywall/application/premium_access_controller.dart';
import '../../../profile_import/application/candidate_profile_controller.dart';
import '../../../profile_import/application/candidate_profile_prefill.dart';
import '../../../profile_import/domain/entities/candidate_profile.dart';
import '../../../profile_import/presentation/widgets/candidate_profile_prefill_banner.dart';
import '../../application/cover_letter_controller.dart';
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
  String _tone = _toneOptions.first;
  String? _appliedProfileSignature;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _roleTitleController.dispose();
    _jobDescriptionController.dispose();
    _userBackgroundController.dispose();
    super.dispose();
  }

  void _scheduleProfilePrefill(CandidateProfile? profile) {
    if (profile == null) {
      return;
    }

    final signature = _profileSignature(profile);
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

  void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  String _profileSignature(CandidateProfile profile) {
    return [
      profile.id ?? '',
      profile.uploadedCvId ?? '',
      profile.name,
      profile.roles.join('|'),
      profile.skills.join('|'),
      profile.industries.join('|'),
      profile.education,
    ].join('::');
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

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();
      final request = CoverLetterRequest(
        companyName: _companyNameController.text.trim(),
        roleTitle: _roleTitleController.text.trim(),
        jobDescription: _jobDescriptionController.text.trim(),
        userBackground: _userBackgroundController.text.trim(),
        tone: _tone,
      );

      unawaited(
        ref
            .read(coverLetterControllerProvider.notifier)
            .startGeneration(request),
      );

      if (!mounted) {
        return;
      }

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
    final state = ref.watch(coverLetterControllerProvider);
    final candidateProfile = ref.watch(candidateProfileControllerProvider);
    final theme = Theme.of(context);
    final profile = candidateProfile.asData?.value;

    _scheduleProfilePrefill(profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cover Letter Generator'),
        actions: [
          IconButton(
            tooltip: 'Back to Home',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.compact,
            AppSpacing.page,
            AppSpacing.page,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role-specific cover letters',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Share the company, role and job description alongside your background. The generator will return a tailored cover letter draft you can edit before sending.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          if (profile != null) ...[
                            const SizedBox(height: AppSpacing.section),
                            const CandidateProfilePrefillBanner(
                              message:
                                  'Your imported candidate profile prefilled the role and background fields. Adjust them as needed for this company.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.page),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    controller: _companyNameController,
                                    labelText: 'Company name',
                                    hintText: 'Acme Labs',
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        Validators.requiredField(
                                          value,
                                          fieldName: 'Company name',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.section),
                                Expanded(
                                  child: AppTextField(
                                    controller: _roleTitleController,
                                    labelText: 'Role title',
                                    hintText: 'Senior Product Designer',
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        Validators.requiredField(
                                          value,
                                          fieldName: 'Role title',
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _jobDescriptionController,
                              labelText: 'Job description',
                              hintText:
                                  'Paste the most relevant parts of the job description.',
                              helperText:
                                  'Responsibilities, requirements and company context help produce a better draft.',
                              minLines: 6,
                              maxLines: 10,
                              textInputAction: TextInputAction.newline,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Job description',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _userBackgroundController,
                              labelText: 'User background',
                              hintText:
                                  'Summarize your experience, strengths and relevant achievements.',
                              minLines: 5,
                              maxLines: 8,
                              textInputAction: TextInputAction.newline,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'User background',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            DropdownButtonFormField<String>(
                              initialValue: _tone,
                              decoration: const InputDecoration(
                                labelText: 'Tone',
                              ),
                              items: _toneOptions
                                  .map(
                                    (tone) => DropdownMenuItem<String>(
                                      value: tone,
                                      child: Text(tone),
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
                            const SizedBox(height: AppSpacing.page),
                            AppButton(
                              label: state.isGenerating || _isSubmitting
                                  ? 'Generating cover letter...'
                                  : 'Generate cover letter',
                              isLoading: state.isGenerating || _isSubmitting,
                              onPressed: state.isGenerating || _isSubmitting
                                  ? null
                                  : _submit,
                              icon: const Icon(Icons.auto_awesome),
                            ),
                          ],
                        ),
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

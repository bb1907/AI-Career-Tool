import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/subscription/premium_access_feature.dart';
import '../../../job_matching/application/selected_job_controller.dart';
import '../../../job_matching/domain/entities/job_listing.dart';
import '../../../paywall/application/premium_access_controller.dart';
import '../../../profile_import/application/candidate_profile_controller.dart';
import '../../../profile_import/application/candidate_profile_prefill.dart';
import '../../../profile_import/domain/entities/candidate_profile.dart';
import '../../../profile_import/presentation/widgets/candidate_profile_prefill_banner.dart';
import '../../application/video_introduction_controller.dart';
import '../../domain/entities/video_introduction_candidate_context.dart';
import '../../domain/entities/video_introduction_duration.dart';
import '../../domain/entities/video_introduction_job_context.dart';
import '../../domain/entities/video_introduction_request.dart';

class VideoIntroductionInputPage extends ConsumerStatefulWidget {
  const VideoIntroductionInputPage({super.key});

  @override
  ConsumerState<VideoIntroductionInputPage> createState() =>
      _VideoIntroductionInputPageState();
}

class _VideoIntroductionInputPageState
    extends ConsumerState<VideoIntroductionInputPage> {
  static const _toneOptions = <String>['Confident', 'Professional', 'Warm'];

  final _formKey = GlobalKey<FormState>();
  final _targetRoleController = TextEditingController();
  final _targetCompanyController = TextEditingController();
  final _audienceController = TextEditingController();
  final _keyPointsController = TextEditingController();
  VideoIntroductionDuration _duration = VideoIntroductionDuration.seconds60;
  String _tone = _toneOptions.first;
  String? _appliedProfileSignature;
  String? _appliedJobSignature;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _targetRoleController.dispose();
    _targetCompanyController.dispose();
    _audienceController.dispose();
    _keyPointsController.dispose();
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

      final coverLetterPrefill = CandidateProfilePrefill.forCoverLetter(
        profile,
      );
      _fillIfEmpty(_targetRoleController, coverLetterPrefill.roleTitle);
      _fillIfEmpty(_audienceController, 'Recruiter or hiring manager');
      _fillIfEmpty(
        _keyPointsController,
        [
          if (profile.roles.isNotEmpty) 'Current role: ${profile.roles.first}',
          if (profile.yearsExperience > 0)
            '${profile.yearsExperience} years of experience',
          if (profile.skills.isNotEmpty)
            'Strengths: ${profile.skills.take(4).join(', ')}',
          if (profile.industries.isNotEmpty)
            'Industry exposure: ${profile.industries.take(2).join(', ')}',
        ].join('\n'),
      );
      _appliedProfileSignature = signature;
    });
  }

  String _profileSignature(CandidateProfile profile) {
    return [
      profile.id ?? '',
      profile.uploadedCvId ?? '',
      profile.roles.join('|'),
      profile.skills.join('|'),
      profile.industries.join('|'),
      profile.yearsExperience.toString(),
    ].join('::');
  }

  void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  void _scheduleJobPrefill(JobListing? job) {
    if (job == null) {
      return;
    }

    final signature = [
      job.id,
      job.title,
      job.company,
      job.location,
      job.jobDescription,
    ].join('::');
    if (_appliedJobSignature == signature) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedJobSignature == signature) {
        return;
      }

      _targetRoleController.text = job.title.trim();
      _targetCompanyController.text = job.company.trim();
      _fillIfEmpty(_audienceController, 'Recruiter or hiring manager');
      final selectedJobContext =
          'Why this role fits: ${job.title} at ${job.company}\nKey requirement highlights: ${job.jobDescription}';
      if (!_keyPointsController.text.contains(job.jobDescription)) {
        final existing = _keyPointsController.text.trim();
        _keyPointsController.text = existing.isEmpty
            ? selectedJobContext
            : '$selectedJobContext\n$existing';
      }
      _appliedJobSignature = signature;
    });
  }

  Future<void> _submit() async {
    final isGenerating = ref
        .read(videoIntroductionControllerProvider)
        .isGenerating;
    if (_isSubmitting || isGenerating || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final accessDecision = await ref
          .read(premiumAccessControllerProvider.notifier)
          .requestAccess(PremiumAccessFeature.videoIntroductionGenerate);

      if (!accessDecision.isAllowed) {
        if (!mounted) {
          return;
        }

        final unlocked = await context.push<bool>(
          Uri(
            path: AppRoutes.paywall,
            queryParameters: {
              'from': AppRoutes.videoIntroduction,
              'reason': 'usage_limit',
              'feature': PremiumAccessFeature.videoIntroductionGenerate.name,
            },
          ).toString(),
        );

        if (!mounted || unlocked != true) {
          return;
        }

        AppFeedback.showSuccess(
          context,
          'Pro is now active. You can continue without generation limits.',
        );

        final refreshedDecision = await ref
            .read(premiumAccessControllerProvider.notifier)
            .requestAccess(PremiumAccessFeature.videoIntroductionGenerate);
        if (!refreshedDecision.isAllowed) {
          return;
        }
      }

      if (!mounted) {
        return;
      }

      context.unfocusCurrent();
      final profile = ref
          .read(candidateProfileControllerProvider)
          .asData
          ?.value;
      final selectedJob = ref.read(selectedJobControllerProvider);
      final request = VideoIntroductionRequest(
        duration: _duration,
        targetRole: _targetRoleController.text.trim(),
        targetCompany: _targetCompanyController.text.trim(),
        audience: _audienceController.text.trim(),
        tone: _tone,
        keyPoints: _keyPointsController.text.splitToEntries(),
        candidateContext: profile == null
            ? null
            : VideoIntroductionCandidateContext(
                name: profile.name,
                location: profile.location,
                yearsExperience: profile.yearsExperience,
                roles: profile.roles,
                skills: profile.skills,
                industries: profile.industries,
                seniority: profile.seniority,
                education: profile.education,
              ),
        jobContext: selectedJob == null
            ? null
            : VideoIntroductionJobContext(
                jobId: selectedJob.id,
                title: selectedJob.title,
                company: selectedJob.company,
                location: selectedJob.location,
                source: selectedJob.source,
                url: selectedJob.url,
                jobDescription: selectedJob.jobDescription,
              ),
      );

      unawaited(
        ref
            .read(videoIntroductionControllerProvider.notifier)
            .startGeneration(request),
      );

      if (!mounted) {
        return;
      }

      context.push(AppRoutes.videoIntroductionResult);
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'We couldn\'t start video script generation right now. Please try again.',
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
    final state = ref.watch(videoIntroductionControllerProvider);
    final candidateProfile = ref.watch(candidateProfileControllerProvider);
    final selectedJob = ref.watch(selectedJobControllerProvider);
    final profile = candidateProfile.asData?.value;
    final theme = Theme.of(context);

    _scheduleProfilePrefill(profile);
    _scheduleJobPrefill(selectedJob);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Introduction'),
        leading: context.canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            'Short on-camera intro scripts',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Generate a clear 30, 60 or 90 second script you can use for recruiter outreach, application videos or portfolio intros.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: AppSpacing.section),
                    const CandidateProfilePrefillBanner(
                      message:
                          'We prefilled the role and key talking points from your imported candidate profile. You can adjust everything before generating.',
                    ),
                  ],
                  if (selectedJob != null) ...[
                    const SizedBox(height: AppSpacing.section),
                    CandidateProfilePrefillBanner(
                      message:
                          'Selected job detected: ${selectedJob.title} at ${selectedJob.company}. We prefilled the target role and company so this script stays aligned to the application.',
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.section),
                    const CandidateProfilePrefillBanner(
                      message:
                          'For the strongest result, select a job first from Job Matches. You can still continue manually if needed.',
                    ),
                  ],
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
                            DropdownButtonFormField<VideoIntroductionDuration>(
                              initialValue: _duration,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                              ),
                              items: VideoIntroductionDuration.values
                                  .map(
                                    (duration) => DropdownMenuItem(
                                      value: duration,
                                      child: Text(duration.label),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _duration = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _targetRoleController,
                              labelText: 'Target role',
                              textInputAction: TextInputAction.next,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Target role',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _targetCompanyController,
                              labelText: 'Target company (optional)',
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _audienceController,
                              labelText: 'Audience',
                              textInputAction: TextInputAction.next,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Audience',
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
                                    (tone) => DropdownMenuItem(
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
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _keyPointsController,
                              labelText: 'Key talking points',
                              hintText:
                                  'Add strengths, wins, industry context or anything you want to mention on camera.',
                              minLines: 5,
                              maxLines: 8,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Key talking points',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.page),
                            AppButton(
                              label: state.isGenerating || _isSubmitting
                                  ? 'Generating script...'
                                  : 'Generate script',
                              isLoading: state.isGenerating || _isSubmitting,
                              onPressed: state.isGenerating || _isSubmitting
                                  ? null
                                  : _submit,
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

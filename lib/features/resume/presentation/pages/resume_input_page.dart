import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../ui/components/section_header.dart';
import '../../../paywall/application/premium_access_controller.dart';
import '../../../profile_import/application/candidate_profile_controller.dart';
import '../../../profile_import/application/candidate_profile_prefill.dart';
import '../../../profile_import/domain/entities/candidate_profile.dart';
import '../../../profile_import/presentation/widgets/candidate_profile_prefill_banner.dart';
import '../../application/resume_controller.dart';
import '../utils/resume_form_parser.dart';
import '../utils/resume_form_validators.dart';

class ResumeInputPage extends ConsumerStatefulWidget {
  const ResumeInputPage({super.key});

  @override
  ConsumerState<ResumeInputPage> createState() => _ResumeInputPageState();
}

class _ResumeInputPageState extends ConsumerState<ResumeInputPage> {
  static const _toneOptions = <String>[
    'Professional',
    'Confident',
    'Concise',
    'Executive',
  ];

  final _formKey = GlobalKey<FormState>();
  final _targetRoleController = TextEditingController();
  final _yearsController = TextEditingController();
  final _pastRolesController = TextEditingController();
  final _topSkillsController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _educationController = TextEditingController();
  String _preferredTone = _toneOptions.first;
  String? _appliedProfileSignature;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _targetRoleController.dispose();
    _yearsController.dispose();
    _pastRolesController.dispose();
    _topSkillsController.dispose();
    _achievementsController.dispose();
    _educationController.dispose();
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
      profile.yearsExperience.toString(),
      profile.roles.join('|'),
      profile.skills.join('|'),
      profile.education,
    ].join('::');

    if (_appliedProfileSignature == signature) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedProfileSignature == signature) {
        return;
      }

      final prefill = CandidateProfilePrefill.forResume(profile);
      _fillIfEmpty(_targetRoleController, prefill.targetRole);
      _fillIfEmpty(_yearsController, prefill.yearsOfExperience);
      _fillIfEmpty(_pastRolesController, prefill.pastRoles);
      _fillIfEmpty(_topSkillsController, prefill.topSkills);
      _fillIfEmpty(_educationController, prefill.education);
      _appliedProfileSignature = signature;
    });
  }

  void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  Future<void> _submit() async {
    final isGenerating = ref.read(resumeBuilderControllerProvider).isGenerating;
    if (_isSubmitting || isGenerating || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final accessDecision = await ref
          .read(premiumAccessControllerProvider.notifier)
          .requestAccess(PremiumAccessFeature.resumeGenerate);

      if (!accessDecision.isAllowed) {
        if (!mounted) {
          return;
        }

        final unlocked = await context.push<bool>(
          Uri(
            path: AppRoutes.paywall,
            queryParameters: {
              'from': AppRoutes.resume,
              'reason': 'usage_limit',
              'feature': PremiumAccessFeature.resumeGenerate.name,
            },
          ).toString(),
        );

        if (!mounted || unlocked != true) {
          return;
        }

        final refreshedDecision = await ref
            .read(premiumAccessControllerProvider.notifier)
            .requestAccess(PremiumAccessFeature.resumeGenerate);
        if (!refreshedDecision.isAllowed) {
          return;
        }
      }

      final request = ResumeFormParser.buildRequest(
        targetRole: _targetRoleController.text,
        yearsOfExperience: _yearsController.text,
        pastRoles: _pastRolesController.text,
        topSkills: _topSkillsController.text,
        achievements: _achievementsController.text,
        education: _educationController.text,
        preferredTone: _preferredTone,
      );

      unawaited(
        ref
            .read(resumeBuilderControllerProvider.notifier)
            .startGeneration(request),
      );

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();
      context.push(AppRoutes.resumeResult);
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'We couldn\'t start resume generation right now. Please try again.',
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
    final state = ref.watch(resumeBuilderControllerProvider);
    final profile = ref.watch(candidateProfileControllerProvider).asData?.value;
    final theme = Theme.of(context);

    _scheduleProfilePrefill(profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Resume Builder')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            AppCard(
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.08,
              ),
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATS-friendly resume generation',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep the form short, add role-relevant achievements and let AI structure the draft for recruiter readability.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 16),
                    const CandidateProfilePrefillBanner(
                      message:
                          'Fields were prefilled from your imported candidate profile. You can change everything before generating.',
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
                      title: 'Resume brief',
                      subtitle:
                          'Target role, experience and achievements are enough to generate a strong first draft.',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppInputField(
                            controller: _targetRoleController,
                            label: 'Target Role',
                            hint: 'Senior Product Designer',
                            prefixIcon: const Icon(Icons.work_outline_rounded),
                            textInputAction: TextInputAction.next,
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: 'Target role',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: AppInputField(
                            controller: _yearsController,
                            label: 'Years of Experience',
                            hint: '5',
                            prefixIcon: const Icon(Icons.timeline_rounded),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: Validators.yearsOfExperience,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _pastRolesController,
                      label: 'Past Roles',
                      hint:
                          'Product Designer at Atlas\nUX Designer at Northstar',
                      helper: 'Use commas or new lines to separate roles.',
                      minLines: 3,
                      maxLines: 5,
                      validator: (value) =>
                          ResumeFormValidators.requiredEntries(
                            value,
                            fieldName: 'Past roles',
                          ),
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _topSkillsController,
                      label: 'Key Skills',
                      hint: 'Figma, Design systems, User research, SQL',
                      helper: 'Use commas or new lines to separate skills.',
                      minLines: 3,
                      maxLines: 5,
                      validator: (value) =>
                          ResumeFormValidators.requiredEntries(
                            value,
                            fieldName: 'Top skills',
                          ),
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _educationController,
                      label: 'Education',
                      hint: 'B.A. in Visual Communication Design',
                      minLines: 2,
                      maxLines: 3,
                      validator: (value) => Validators.requiredField(
                        value,
                        fieldName: 'Education',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _achievementsController,
                      label: 'Achievements',
                      hint:
                          'Improved onboarding completion by 18%\nLaunched a reusable design system adopted by 4 squads',
                      helper: 'Add measurable wins when possible.',
                      minLines: 4,
                      maxLines: 6,
                      validator: (value) =>
                          ResumeFormValidators.requiredEntries(
                            value,
                            fieldName: 'Achievements',
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _preferredTone,
                      decoration: const InputDecoration(
                        labelText: 'Preferred tone',
                      ),
                      items: _toneOptions
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _preferredTone = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    AIButton(
                      label: 'Generate resume',
                      icon: const Icon(Icons.auto_awesome_rounded),
                      isLoading: _isSubmitting || state.isGenerating,
                      onPressed: (_isSubmitting || state.isGenerating)
                          ? null
                          : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

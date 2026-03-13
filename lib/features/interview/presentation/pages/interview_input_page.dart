import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../services/subscription/premium_access_feature.dart';
import '../../../../ui/components/ai_button.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/components/app_input_field.dart';
import '../../../../ui/components/assistant_orb.dart';
import '../../../../ui/components/section_header.dart';
import '../../../paywall/application/premium_access_controller.dart';
import '../../../profile_import/application/candidate_profile_controller.dart';
import '../../../profile_import/application/candidate_profile_prefill.dart';
import '../../../profile_import/domain/entities/candidate_profile.dart';
import '../../../profile_import/presentation/widgets/candidate_profile_prefill_banner.dart';
import '../../application/interview_controller.dart';
import '../../domain/entities/interview_request.dart';

class InterviewInputPage extends ConsumerStatefulWidget {
  const InterviewInputPage({super.key});

  @override
  ConsumerState<InterviewInputPage> createState() => _InterviewInputPageState();
}

class _InterviewInputPageState extends ConsumerState<InterviewInputPage> {
  static const _seniorityOptions = <String>[
    'Junior',
    'Mid-level',
    'Senior',
    'Lead',
  ];

  static const _companyTypeOptions = <String>[
    'Startup',
    'Scale-up',
    'Enterprise',
    'Agency',
  ];

  static const _interviewTypeOptions = <String>[
    'Mixed',
    'Technical',
    'Behavioral',
    'Hiring Manager',
  ];

  final _formKey = GlobalKey<FormState>();
  final _roleNameController = TextEditingController();
  final _focusAreasController = TextEditingController();
  String _seniority = _seniorityOptions[2];
  String _companyType = _companyTypeOptions.first;
  String _interviewType = _interviewTypeOptions.first;
  String? _appliedProfileSignature;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _roleNameController.dispose();
    _focusAreasController.dispose();
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

      final prefill = CandidateProfilePrefill.forInterview(profile);
      _fillIfEmpty(_roleNameController, prefill.roleName);
      _fillIfEmpty(_focusAreasController, prefill.focusAreas);
      if (_isSupportedSeniority(prefill.seniority) &&
          _seniority == _seniorityOptions[2]) {
        setState(() {
          _seniority = prefill.seniority;
        });
      }
      _appliedProfileSignature = signature;
    });
  }

  bool _isSupportedSeniority(String value) => _seniorityOptions.contains(value);

  void _fillIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  String _profileSignature(CandidateProfile profile) {
    return [
      profile.id ?? '',
      profile.uploadedCvId ?? '',
      profile.roles.join('|'),
      profile.skills.join('|'),
      profile.industries.join('|'),
      profile.seniority,
    ].join('::');
  }

  Future<void> _submit() async {
    final isGenerating = ref.read(interviewControllerProvider).isGenerating;
    if (_isSubmitting || isGenerating || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final accessDecision = await ref
          .read(premiumAccessControllerProvider.notifier)
          .requestAccess(PremiumAccessFeature.interviewGenerate);

      if (!accessDecision.isAllowed) {
        if (!mounted) {
          return;
        }

        final unlocked = await context.push<bool>(
          Uri(
            path: AppRoutes.paywall,
            queryParameters: {
              'from': AppRoutes.interview,
              'reason': 'usage_limit',
              'feature': PremiumAccessFeature.interviewGenerate.name,
            },
          ).toString(),
        );

        if (!mounted || unlocked != true) {
          return;
        }

        final refreshedDecision = await ref
            .read(premiumAccessControllerProvider.notifier)
            .requestAccess(PremiumAccessFeature.interviewGenerate);
        if (!refreshedDecision.isAllowed) {
          return;
        }
      }

      if (!mounted) {
        return;
      }

      context.unfocusCurrent();
      final request = InterviewRequest(
        roleName: _roleNameController.text.trim(),
        seniority: _seniority,
        companyType: _companyType,
        interviewType: _interviewType,
        focusAreas: _focusAreasController.text.splitToEntries(),
      );

      unawaited(
        ref.read(interviewControllerProvider.notifier).startGeneration(request),
      );

      if (!mounted) {
        return;
      }

      context.push(AppRoutes.interviewResult);
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'We couldn\'t start interview prep right now. Please try again.',
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
    final state = ref.watch(interviewControllerProvider);
    final profile = ref.watch(candidateProfileControllerProvider).asData?.value;

    _scheduleProfilePrefill(profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Interview Prep')),
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
                        child: Text(
                          'Practice technical and behavioral answers',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Set the interview context once and generate a structured question set with sample answers you can actually rehearse.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 16),
                    const CandidateProfilePrefillBanner(
                      message:
                          'Role, seniority and focus areas were prefilled from your imported candidate profile. Adjust them for each interview loop.',
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
                      title: 'Interview setup',
                      subtitle:
                          'Tell the assistant which loop you are preparing for so the question mix and sample answers stay relevant.',
                    ),
                    const SizedBox(height: 20),
                    AppInputField(
                      controller: _roleNameController,
                      label: 'Role Name',
                      hint: 'Senior Product Designer',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.requiredField(
                        value,
                        fieldName: 'Role name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _seniority,
                            decoration: const InputDecoration(
                              labelText: 'Seniority',
                            ),
                            items: _seniorityOptions
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
                                _seniority = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _companyType,
                            decoration: const InputDecoration(
                              labelText: 'Company Type',
                            ),
                            items: _companyTypeOptions
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
                                _companyType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _interviewType,
                      decoration: const InputDecoration(
                        labelText: 'Interview Type',
                      ),
                      items: _interviewTypeOptions
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
                          _interviewType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _focusAreasController,
                      label: 'Focus Areas',
                      hint:
                          'System design, stakeholder management, analytics, product sense',
                      helper:
                          'Use commas or new lines to separate the areas you want to practice.',
                      minLines: 4,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                      validator: (value) => Validators.requiredField(
                        value,
                        fieldName: 'Focus areas',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AIButton(
              label: state.isGenerating || _isSubmitting
                  ? 'Generating interview prep...'
                  : 'Generate interview prep',
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

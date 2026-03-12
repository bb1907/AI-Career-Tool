import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/subscription/premium_access_feature.dart';
import '../../../paywall/application/premium_access_controller.dart';
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

  @override
  void dispose() {
    _roleNameController.dispose();
    _focusAreasController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Prep'),
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
                            'Technical and behavioral prep',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Choose the target role, seniority and interview context. The generator will produce separate technical and behavioral questions with sample answers.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
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
                            AppTextField(
                              controller: _roleNameController,
                              labelText: 'Role name',
                              hintText: 'Senior Product Designer',
                              textInputAction: TextInputAction.next,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Role name',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
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
                                const SizedBox(width: AppSpacing.section),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _companyType,
                                    decoration: const InputDecoration(
                                      labelText: 'Company type',
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
                            const SizedBox(height: AppSpacing.section),
                            DropdownButtonFormField<String>(
                              initialValue: _interviewType,
                              decoration: const InputDecoration(
                                labelText: 'Interview type',
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
                            const SizedBox(height: AppSpacing.section),
                            AppTextField(
                              controller: _focusAreasController,
                              labelText: 'Focus areas',
                              hintText:
                                  'System design, stakeholder management, analytics, product sense',
                              helperText:
                                  'Use commas or new lines to separate focus areas.',
                              minLines: 4,
                              maxLines: 6,
                              textInputAction: TextInputAction.newline,
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Focus areas',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.page),
                            AppButton(
                              label: state.isGenerating
                                  ? 'Generating interview prep...'
                                  : 'Generate interview prep',
                              isLoading: state.isGenerating,
                              onPressed: state.isGenerating ? null : _submit,
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

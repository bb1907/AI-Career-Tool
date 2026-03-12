import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
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

    context.push(AppRoutes.resumeResult);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeBuilderControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
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
                            'ATS-friendly resume generation',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'Share your target role, recent experience, strongest skills and outcomes. The generator will return a tighter summary, cleaner bullets and a resume-ready skills section.',
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _targetRoleController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Target role',
                                      hintText: 'Senior Product Designer',
                                    ),
                                    validator: (value) =>
                                        Validators.requiredField(
                                          value,
                                          fieldName: 'Target role',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.section),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _yearsController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Years of experience',
                                      hintText: '5',
                                    ),
                                    validator: Validators.yearsOfExperience,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.section),
                            TextFormField(
                              controller: _pastRolesController,
                              minLines: 3,
                              maxLines: 5,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Past roles',
                                hintText:
                                    'Product Designer at Atlas\nUX Designer at Northstar',
                                helperText:
                                    'Use commas or new lines to separate roles.',
                              ),
                              validator: (value) =>
                                  ResumeFormValidators.requiredEntries(
                                    value,
                                    fieldName: 'Past roles',
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            TextFormField(
                              controller: _topSkillsController,
                              minLines: 3,
                              maxLines: 5,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Top skills',
                                hintText:
                                    'Figma, Product thinking, Design systems, User research',
                                helperText:
                                    'Use commas or new lines to separate skills.',
                              ),
                              validator: (value) =>
                                  ResumeFormValidators.requiredEntries(
                                    value,
                                    fieldName: 'Top skills',
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            TextFormField(
                              controller: _achievementsController,
                              minLines: 4,
                              maxLines: 6,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Achievements',
                                hintText:
                                    'Improved onboarding completion by 18%\nLaunched a reusable design system adopted by 4 squads',
                                helperText:
                                    'Use commas or new lines to separate achievements.',
                              ),
                              validator: (value) =>
                                  ResumeFormValidators.requiredEntries(
                                    value,
                                    fieldName: 'Achievements',
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            TextFormField(
                              controller: _educationController,
                              minLines: 2,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Education',
                                hintText:
                                    'B.A. in Visual Communication Design, Bilkent University',
                              ),
                              validator: (value) => Validators.requiredField(
                                value,
                                fieldName: 'Education',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.section),
                            DropdownButtonFormField<String>(
                              initialValue: _preferredTone,
                              decoration: const InputDecoration(
                                labelText: 'Preferred tone',
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
                                  _preferredTone = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.page),
                            AppButton(
                              label: state.isGenerating
                                  ? 'Generating resume...'
                                  : 'Generate resume',
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

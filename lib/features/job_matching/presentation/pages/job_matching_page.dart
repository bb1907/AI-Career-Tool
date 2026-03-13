import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../profile_import/application/candidate_profile_controller.dart';
import '../../../profile_import/application/candidate_profile_prefill.dart';
import '../../../profile_import/domain/entities/candidate_profile.dart';
import '../../../profile_import/presentation/widgets/candidate_profile_prefill_banner.dart';
import '../../application/job_matching_controller.dart';
import '../../application/selected_job_controller.dart';
import '../../domain/entities/job_listing.dart';
import '../../domain/entities/job_search_request.dart';
import '../widgets/job_listing_card.dart';

class JobMatchingPage extends ConsumerStatefulWidget {
  const JobMatchingPage({super.key});

  @override
  ConsumerState<JobMatchingPage> createState() => _JobMatchingPageState();
}

class _JobMatchingPageState extends ConsumerState<JobMatchingPage> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _yearsController = TextEditingController();
  String? _appliedProfileSignature;
  String? _lastAutoSearchSignature;

  @override
  void dispose() {
    _roleController.dispose();
    _locationController.dispose();
    _yearsController.dispose();
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

      final prefill = CandidateProfilePrefill.forJobSearch(profile);
      _fillIfEmpty(_roleController, prefill.role);
      _fillIfEmpty(_locationController, prefill.location);
      _fillIfEmpty(_yearsController, prefill.yearsOfExperience);
      _appliedProfileSignature = signature;
    });
  }

  void _scheduleAutoSearch(CandidateProfile? profile, bool hasSearched) {
    if (profile == null || hasSearched) {
      return;
    }

    final signature = _profileSignature(profile);
    if (_lastAutoSearchSignature == signature) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lastAutoSearchSignature == signature) {
        return;
      }

      _lastAutoSearchSignature = signature;
      _search();
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
      profile.roles.join('|'),
      profile.location,
      profile.yearsExperience.toString(),
      profile.skills.join('|'),
    ].join('::');
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final candidateProfile = ref
        .read(candidateProfileControllerProvider)
        .asData
        ?.value;
    final request = JobSearchRequest(
      role: _roleController.text.trim(),
      location: _locationController.text.trim(),
      yearsExperience: int.tryParse(_yearsController.text.trim()) ?? 0,
      skills: candidateProfile?.skills ?? const <String>[],
    );

    try {
      await ref
          .read(jobMatchingControllerProvider.notifier)
          .searchJobs(request);
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    }
  }

  void _selectJob(JobListing job) {
    ref.read(selectedJobControllerProvider.notifier).select(job);
    AppFeedback.showSuccess(
      context,
      '${job.title} at ${job.company} is ready for your next cover letter.',
    );
  }

  void _useJobForCoverLetter(JobListing job) {
    _selectJob(job);
    context.push(AppRoutes.coverLetter);
  }

  void _useJobForVideoIntro(JobListing job) {
    _selectJob(job);
    context.push(AppRoutes.videoIntroduction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(jobMatchingControllerProvider);
    final candidateProfileState = ref.watch(candidateProfileControllerProvider);
    final candidateProfile = candidateProfileState.asData?.value;
    final selectedJob = ref.watch(selectedJobControllerProvider);

    _scheduleProfilePrefill(candidateProfile);
    _scheduleAutoSearch(candidateProfile, state.hasSearched);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Matches'),
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
                            'Find jobs that fit your profile',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.compact),
                          Text(
                            'We use your candidate profile as a starting point, then turn the selected job into better downstream inputs for cover letters and future application flows.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          if (candidateProfile != null) ...[
                            const SizedBox(height: AppSpacing.section),
                            const CandidateProfilePrefillBanner(
                              message:
                                  'Role, location and experience were prefilled from your imported candidate profile. You can refine them before searching.',
                            ),
                          ],
                          if (selectedJob != null) ...[
                            const SizedBox(height: AppSpacing.section),
                            _SelectedJobSummary(
                              job: selectedJob,
                              onClear: () => ref
                                  .read(selectedJobControllerProvider.notifier)
                                  .clear(),
                              onContinueToCoverLetter: () =>
                                  context.push(AppRoutes.coverLetter),
                              onContinueToVideoIntro: () =>
                                  context.push(AppRoutes.videoIntroduction),
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
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _roleController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Role',
                                      hintText: 'Senior Product Designer',
                                    ),
                                    validator: (value) =>
                                        Validators.requiredField(
                                          value,
                                          fieldName: 'Role',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.section),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _locationController,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Location',
                                      hintText: 'Istanbul, Turkey',
                                    ),
                                    validator: (value) =>
                                        Validators.requiredField(
                                          value,
                                          fieldName: 'Location',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.section),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _yearsController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Years',
                                      hintText: '5',
                                    ),
                                    validator: Validators.yearsOfExperience,
                                    onFieldSubmitted: (_) => _search(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.page),
                            AppButton(
                              label: state.isLoading
                                  ? 'Finding matching jobs...'
                                  : 'Find matching jobs',
                              isLoading: state.isLoading,
                              onPressed: state.isLoading ? null : _search,
                              icon: const Icon(Icons.travel_explore_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.page),
                  if (state.isLoading && state.jobs.isEmpty)
                    const Card(
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: LoadingView(label: 'Searching relevant jobs...'),
                      ),
                    )
                  else if (state.errorMessage != null && state.jobs.isEmpty)
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ErrorView(
                          message: state.errorMessage!,
                          onRetry: state.isLoading ? null : _search,
                        ),
                      ),
                    )
                  else if (!state.hasSearched)
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          candidateProfile == null
                              ? 'Import a CV or enter search details to see relevant job matches.'
                              : 'Your profile details are ready. Start a search to see the first matching roles.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else if (state.isEmpty)
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No jobs matched those filters yet. Adjust the role or location and try again.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matching jobs',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.compact),
                        Text(
                          'Select one role to reuse its company, title and description in your next cover letter or video introduction.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.page),
                        for (
                          var index = 0;
                          index < state.jobs.length;
                          index++
                        ) ...[
                          JobListingCard(
                            job: state.jobs[index],
                            isSelected: selectedJob?.id == state.jobs[index].id,
                            onSelect: () => _selectJob(state.jobs[index]),
                            onUseInCoverLetter: () =>
                                _useJobForCoverLetter(state.jobs[index]),
                            onUseInVideoIntro: () =>
                                _useJobForVideoIntro(state.jobs[index]),
                          ),
                          if (index != state.jobs.length - 1)
                            const SizedBox(height: AppSpacing.section),
                        ],
                      ],
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

class _SelectedJobSummary extends StatelessWidget {
  const _SelectedJobSummary({
    required this.job,
    required this.onClear,
    required this.onContinueToCoverLetter,
    required this.onContinueToVideoIntro,
  });

  final JobListing job;
  final VoidCallback onClear;
  final VoidCallback onContinueToCoverLetter;
  final VoidCallback onContinueToVideoIntro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected job',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${job.title} at ${job.company}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This selection will prefill the company, role and job description in downstream application tools.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          Wrap(
            spacing: AppSpacing.compact,
            runSpacing: AppSpacing.compact,
            children: [
              FilledButton.tonalIcon(
                onPressed: onContinueToCoverLetter,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue to cover letter'),
              ),
              FilledButton.tonalIcon(
                onPressed: onContinueToVideoIntro,
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Continue to video intro'),
              ),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear selection'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

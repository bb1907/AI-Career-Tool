import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/app_spacing.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  static const _steps = <_OnboardingStep>[
    _OnboardingStep(
      icon: Icons.description_outlined,
      title: 'Build stronger resumes',
      description:
          'Turn your experience into role-specific resumes with a cleaner workflow and faster iteration.',
      accent: Color(0xFF0F766E),
    ),
    _OnboardingStep(
      icon: Icons.edit_note_outlined,
      title: 'Generate tailored cover letters',
      description:
          'Draft personalized cover letters that match the role, tone and company context in minutes.',
      accent: Color(0xFF2563EB),
    ),
    _OnboardingStep(
      icon: Icons.record_voice_over_outlined,
      title: 'Prepare for interviews',
      description:
          'Practice likely questions, structure better answers and keep prep material in one place.',
      accent: Color(0xFFEA580C),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentPage == _steps.length - 1) {
      await _complete();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _complete() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();

    if (!mounted) {
      return;
    }

    context.go(widget.redirectTo ?? AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting ? null : _complete,
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.page),
              Text(
                'Welcome to AI Career Tools',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.compact),
              Text(
                'A short tour before you start. These are the three core tools you will use most.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.page),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          colors: [
                            step.accent,
                            step.accent.withValues(alpha: 0.76),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        step.icon,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.page),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step.title,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.compact,
                                        ),
                                        Text(
                                          step.description,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                height: 1.5,
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.page),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(
                                            AppSpacing.section,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.14,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.22,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            'Keep your recent drafts, cover letters and interview prep in one workspace.',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.page),
              Row(
                children: [
                  for (var index = 0; index < _steps.length; index++) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                        right: index == _steps.length - 1 ? 0 : 8,
                      ),
                      height: 10,
                      width: _currentPage == index ? 28 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _nextStep,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentPage == _steps.length - 1
                                  ? 'Get started'
                                  : 'Continue',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
}

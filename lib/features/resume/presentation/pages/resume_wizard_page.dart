import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../steps/step1_personal_info.dart';
import '../steps/step2_summary.dart';
import '../steps/step3_work_experience.dart';
import '../steps/step4_education.dart';
import '../steps/step5_skills.dart';
import '../steps/step6_projects.dart';

class ResumeWizardPage extends ConsumerStatefulWidget {
  const ResumeWizardPage({super.key});

  @override
  ConsumerState<ResumeWizardPage> createState() => _ResumeWizardPageState();
}

class _ResumeWizardPageState extends ConsumerState<ResumeWizardPage> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isAnimating = false;

  static const _titles = [
    'Personal Info',
    'Summary',
    'Work Experience',
    'Education',
    'Skills',
    'Projects',
  ];

  // Instance-level list — not static const — so Flutter creates fresh State on each mount.
  final _steps = [
    const Step1PersonalInfo(),
    const Step2Summary(),
    const Step3WorkExperience(),
    const Step4Education(),
    const Step5Skills(),
    const Step6Projects(),
  ];

  void _next() {
    if (_isAnimating) return;

    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }

    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _isAnimating = true;
      });
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => setState(() => _isAnimating = false));
    } else {
      context.go('/resume/preview');
    }
  }

  void _back() {
    if (_isAnimating || _currentStep <= 0) return;
    setState(() {
      _currentStep--;
      _isAnimating = true;
    });
    _pageController
        .previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) => setState(() => _isAnimating = false));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentStep == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentStep]),
        actions: [
          TextButton(
            onPressed: () => context.go('/resume/preview'),
            child: const Text('Preview'),
          )
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_steps.length, (i) {
                final isActive = i == _currentStep;
                final isDone = i < _currentStep;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Text(
            'Step ${_currentStep + 1} of ${_steps.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          // Page content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _steps,
              ),
            ),
          ),
          // Navigation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                        onPressed: _back, child: const Text('Back')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(isLast ? 'Finish' : 'Next'),
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

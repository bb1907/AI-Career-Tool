import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/l10n_extension.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 2 state
  final Set<String> _selectedGoals = {};

  // Step 3 state
  final _roleController = TextEditingController();
  String _experience = 'Mid-level';

  static const _goals = [
    (Icons.rocket_launch, 'Find a New Job', 'Switch companies or industries'),
    (Icons.trending_up, 'Get a Promotion', 'Level up in my current company'),
    (Icons.sync_alt, 'Career Change', 'Transition to a new field'),
    (Icons.language, 'Relocate Abroad', 'Find roles in US or Canada'),
  ];

  static const _expLevels = ['Entry', 'Mid-level', 'Senior', 'Lead/Manager'];

  @override
  void dispose() {
    _pageController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('onboarding_goals', _selectedGoals.join(','));
    await prefs.setString('onboarding_target_role', _roleController.text);
    await prefs.setString('onboarding_experience', _experience);
    if (!mounted) return;
    context.go('/home');
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    height: 4,
                    width: active ? 24 : 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(onNext: _next),
                  _GoalsPage(
                    selected: _selectedGoals,
                    goals: _goals,
                    onToggle: (g) => setState(() {
                      if (_selectedGoals.contains(g)) {
                        _selectedGoals.remove(g);
                      } else {
                        _selectedGoals.add(g);
                      }
                    }),
                    onNext: _next,
                  ),
                  _ProfilePage(
                    roleController: _roleController,
                    experience: _experience,
                    expLevels: _expLevels,
                    onExpChanged: (v) => setState(() => _experience = v),
                    onDone: _complete,
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

// ── Step 1: Welcome ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Hero gradient card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.elevated(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.onboardingTitle1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.onboardingDesc1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            context.l10n.onboardingEverythingYouNeed,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),

          ...[
            (
              Icons.description_rounded,
              'Resume Builder',
              'ATS-friendly resumes in minutes',
            ),
            (
              Icons.mail_rounded,
              'Cover Letters',
              'Tailored to each job description',
            ),
            (
              Icons.psychology_rounded,
              'Interview Prep',
              'AI-generated Q&A with coaching tips',
            ),
            (
              Icons.videocam_rounded,
              'Video Scripts',
              '30-90 second intro scripts',
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.$1, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          item.$3,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.appText2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(context.l10n.getStarted),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ── Step 2: Goals ─────────────────────────────────────────────────────────────

class _GoalsPage extends StatelessWidget {
  final Set<String> selected;
  final List<(IconData, String, String)> goals;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  const _GoalsPage({
    required this.selected,
    required this.goals,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.onboardingTitle2,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.onboardingDesc2,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.appText2),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...goals.map((goal) {
            final isSelected = selected.contains(goal.$2);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onToggle(goal.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : context.appSurface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : context.appBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        goal.$1,
                        size: 28,
                        color: isSelected
                            ? AppColors.primary
                            : context.appText2,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.$2,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : context.appText1,
                                  ),
                            ),
                            Text(
                              goal.$3,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.appText2),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(context.l10n.next),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ── Step 3: Profile setup ─────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  final TextEditingController roleController;
  final String experience;
  final List<String> expLevels;
  final ValueChanged<String> onExpChanged;
  final VoidCallback onDone;

  const _ProfilePage({
    required this.roleController,
    required this.experience,
    required this.expLevels,
    required this.onExpChanged,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.onboardingTitle3,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.onboardingDesc3,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.appText2),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            context.l10n.onboardingTargetRole,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: roleController,
            decoration: InputDecoration(
              hintText: context.l10n.onboardingRoleHint,
              prefixIcon: const Icon(Icons.work_outline_rounded),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            context.l10n.onboardingExperienceLevel,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: expLevels.map((level) {
              final isSelected = level == experience;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: level != expLevels.last ? AppSpacing.xs : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onExpChanged(level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : context.appSurface,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : context.appBorder,
                        ),
                      ),
                      child: Text(
                        level,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : context.appText2,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.onboardingSettingsTip,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
              label: Text(context.l10n.getStarted),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────────────────────────────────────

enum PlanType { free, pro, proMax }

enum FeatureType {
  resume,
  coverLetter,
  interview,
  networking,
  aiPhoto,
  mockInterview,
  videoScript,
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionState {
  final PlanType plan;
  final int resumeUsed;
  final int coverLetterUsed;
  final int interviewUsed;
  final int networkingUsed;
  final int photoUsedThisMonth;
  final String lastResetKey; // "YYYY-MM"
  final bool softPaywallShown;

  const SubscriptionState({
    this.plan = PlanType.free,
    this.resumeUsed = 0,
    this.coverLetterUsed = 0,
    this.interviewUsed = 0,
    this.networkingUsed = 0,
    this.photoUsedThisMonth = 0,
    this.lastResetKey = '',
    this.softPaywallShown = false,
  });

  SubscriptionState copyWith({
    PlanType? plan,
    int? resumeUsed,
    int? coverLetterUsed,
    int? interviewUsed,
    int? networkingUsed,
    int? photoUsedThisMonth,
    String? lastResetKey,
    bool? softPaywallShown,
  }) => SubscriptionState(
    plan: plan ?? this.plan,
    resumeUsed: resumeUsed ?? this.resumeUsed,
    coverLetterUsed: coverLetterUsed ?? this.coverLetterUsed,
    interviewUsed: interviewUsed ?? this.interviewUsed,
    networkingUsed: networkingUsed ?? this.networkingUsed,
    photoUsedThisMonth: photoUsedThisMonth ?? this.photoUsedThisMonth,
    lastResetKey: lastResetKey ?? this.lastResetKey,
    softPaywallShown: softPaywallShown ?? this.softPaywallShown,
  );

  // ── Limit table ────────────────────────────────────────────────────────────
  // null = unlimited, -1 = completely blocked

  int? _limit(FeatureType f) => switch (plan) {
    PlanType.free => switch (f) {
      FeatureType.resume => 1,
      FeatureType.coverLetter => 1,
      FeatureType.interview => 1,
      FeatureType.networking => 1,
      FeatureType.aiPhoto => -1,
      FeatureType.mockInterview => -1,
      FeatureType.videoScript => -1,
    },
    PlanType.pro => switch (f) {
      FeatureType.aiPhoto => 5,
      _ => null,
    },
    PlanType.proMax => null,
  };

  int _used(FeatureType f) => switch (f) {
    FeatureType.resume => resumeUsed,
    FeatureType.coverLetter => coverLetterUsed,
    FeatureType.interview => interviewUsed,
    FeatureType.networking => networkingUsed,
    FeatureType.aiPhoto => photoUsedThisMonth,
    _ => 0,
  };

  /// Feature is completely blocked on this plan (no way to use it).
  bool isBlocked(FeatureType f) => _limit(f) == -1;

  /// Feature can be used right now.
  bool canUse(FeatureType f) {
    final lim = _limit(f);
    if (lim == null) return true;
    if (lim == -1) return false;
    return _used(f) < lim;
  }

  /// How many uses remain; null = unlimited, 0 = exhausted/blocked.
  int? remaining(FeatureType f) {
    final lim = _limit(f);
    if (lim == null) return null;
    if (lim == -1) return 0;
    return (lim - _used(f)).clamp(0, lim);
  }

  /// Durations available for video script.
  List<String> get allowedVideoDurations => switch (plan) {
    PlanType.free => [],
    PlanType.pro => ['30s'],
    PlanType.proMax => ['30s', '60s', '90s'],
  };

  bool get hasPdfWatermark => plan == PlanType.free;
  bool get isPremium => plan != PlanType.free;

  /// Returns true when a teaser (blur overlay) should be shown.
  ///
  /// Use this BEFORE calling [recordUsage] (e.g. cover letter, interview,
  /// video script, AI photo). First generation (_used == 0) → full result.
  /// Second generation onwards (_used >= 1) → teaser.
  bool shouldShowTeaser(FeatureType type) {
    if (isPremium) return false;
    return _used(type) >= 1;
  }

  /// Variant for pages that read subscription state AFTER [recordUsage] was
  /// already called (e.g. resume preview navigated from the wizard).
  bool shouldShowTeaserAfterRecord(FeatureType type) {
    if (isPremium) return false;
    return _used(type) > 1;
  }

  String get planLabel => switch (plan) {
    PlanType.free => 'Free',
    PlanType.pro => 'Pro',
    PlanType.proMax => 'Pro Max',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const _kPlan = 'sub_plan';
  static const _kResume = 'sub_resume_used';
  static const _kCoverLetter = 'sub_cover_letter_used';
  static const _kInterview = 'sub_interview_used';
  static const _kNetworking = 'sub_networking_used';
  static const _kPhoto = 'sub_photo_used_month';
  static const _kResetKey = 'sub_photo_reset_key';
  static const _kSoftPaywall = 'soft_paywall_shown';

  /// Pre-loaded in main() before runApp() so the router never sees a stale value.
  static bool initialSoftPaywallShown = false;

  /// Call from main() before runApp() to avoid async race with the router.
  static Future<bool> loadSoftPaywallShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSoftPaywall) ?? false;
  }

  @override
  SubscriptionState build() {
    _load();
    return SubscriptionState(softPaywallShown: initialSoftPaywallShown);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // ── PRODUCTION: read the real plan from RevenueCat-mirrored prefs ──────
    // Previously this branch force-promoted every install to Pro for local
    // QA. That MUST stay off in production builds — leaving it on disables
    // monetization entirely.
    final planStr = prefs.getString(_kPlan) ?? 'free';
    final plan = switch (planStr) {
      'pro' => PlanType.pro,
      'proMax' => PlanType.proMax,
      _ => PlanType.free,
    };

    // Monthly reset for photo counter
    final now = DateTime.now();
    final currentKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final storedKey = prefs.getString(_kResetKey) ?? '';
    int photoUsed = prefs.getInt(_kPhoto) ?? 0;
    if (storedKey != currentKey) {
      photoUsed = 0;
      await prefs.setString(_kResetKey, currentKey);
      await prefs.setInt(_kPhoto, 0);
    }

    final softPaywallShown = prefs.getBool(_kSoftPaywall) ?? false;

    state = SubscriptionState(
      plan: plan,
      resumeUsed: prefs.getInt(_kResume) ?? 0,
      coverLetterUsed: prefs.getInt(_kCoverLetter) ?? 0,
      interviewUsed: prefs.getInt(_kInterview) ?? 0,
      networkingUsed: prefs.getInt(_kNetworking) ?? 0,
      photoUsedThisMonth: photoUsed,
      lastResetKey: currentKey,
      softPaywallShown: softPaywallShown,
    );
  }

  Future<void> recordUsage(FeatureType f) async {
    final prefs = await SharedPreferences.getInstance();
    switch (f) {
      case FeatureType.resume:
        final v = state.resumeUsed + 1;
        await prefs.setInt(_kResume, v);
        state = state.copyWith(resumeUsed: v);
      case FeatureType.coverLetter:
        final v = state.coverLetterUsed + 1;
        await prefs.setInt(_kCoverLetter, v);
        state = state.copyWith(coverLetterUsed: v);
      case FeatureType.interview:
        final v = state.interviewUsed + 1;
        await prefs.setInt(_kInterview, v);
        state = state.copyWith(interviewUsed: v);
      case FeatureType.networking:
        final v = state.networkingUsed + 1;
        await prefs.setInt(_kNetworking, v);
        state = state.copyWith(networkingUsed: v);
      case FeatureType.aiPhoto:
        final v = state.photoUsedThisMonth + 1;
        await prefs.setInt(_kPhoto, v);
        state = state.copyWith(photoUsedThisMonth: v);
      default:
        break;
    }
  }

  /// Call this when RevenueCat confirms a purchase.
  Future<void> setPlan(PlanType plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlan, plan.name);
    state = state.copyWith(plan: plan);
  }

  Future<void> markSoftPaywallShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoftPaywall, true);
    state = state.copyWith(softPaywallShown: true);
  }

  Future<void> upgradeToPro() async {
    await upgradeWithPlan(PlanType.pro);
  }

  Future<void> upgradeToProMax() async {
    await upgradeWithPlan(PlanType.proMax);
  }

  Future<void> upgradeWithPlan(PlanType plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlan, plan.name);
    state = state.copyWith(plan: plan);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );

// ─────────────────────────────────────────────────────────────────────────────
// UI Helpers — reusable dialogs / sheets
// ─────────────────────────────────────────────────────────────────────────────

/// Generic "you've used your free generation" dialog.
/// Returns true if user tapped Upgrade (navigate to paywall).
Future<bool> showLimitDialog(
  BuildContext context, {
  required FeatureType feature,
}) async {
  final featureName = switch (feature) {
    FeatureType.resume => 'Resume Builder',
    FeatureType.coverLetter => 'Cover Letter',
    FeatureType.interview => 'Interview Prep',
    FeatureType.networking => 'Networking Messages',
    _ => 'this feature',
  };

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Free Limit Reached',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "You've used your free $featureName generation.\nUpgrade to Pro for unlimited access.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Upgrade to Pro',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Maybe later',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  return result == true;
}

/// Immediately-blocked feature dialog (Mock Interview, Video Script for free).
Future<bool> showBlockedDialog(
  BuildContext context, {
  required String featureName,
  required String featureDescription,
  required IconData featureIcon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(featureIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unlock $featureName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  featureDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'This feature is available on Pro & Pro Max plans.\nStart your 3-day free trial today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Free Trial',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Go back',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  return result == true;
}

/// Special AI Photo Studio unlock bottom sheet with before/after mockup.
void showPhotoUnlockSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _PhotoUnlockSheet(),
  );
}

class _PhotoUnlockSheet extends StatelessWidget {
  const _PhotoUnlockSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon + title
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_enhance_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unlock AI Photo Studio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Transform your photo into a professional headshot',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Before / after mock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _MockPhoto(label: 'Before', isAfter: false)),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(child: _MockPhoto(label: 'After', isAfter: true)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feature list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: const [
                _PhotoFeatureRow(
                  icon: Icons.photo_camera_rounded,
                  text: 'Professional headshots in seconds',
                ),
                _PhotoFeatureRow(
                  icon: Icons.style_rounded,
                  text: '6 job-specific outfit styles',
                ),
                _PhotoFeatureRow(
                  icon: Icons.compare_rounded,
                  text: 'Before/after comparison slider',
                ),
                _PhotoFeatureRow(
                  icon: Icons.download_rounded,
                  text: 'HD download without watermark',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/paywall');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Start Free Trial — 3 Days',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Not now',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MockPhoto extends StatelessWidget {
  final String label;
  final bool isAfter;
  const _MockPhoto({required this.label, required this.isAfter});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isAfter
            ? const LinearGradient(
                colors: [Color(0xFF5B5FEF), Color(0xFF9B5DE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isAfter ? null : Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAfter ? Icons.person_rounded : Icons.person_outline_rounded,
            size: 40,
            color: isAfter ? Colors.white : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAfter ? Colors.white : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PhotoFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

abstract final class AppConstants {
  static const appName = 'AI Career Tools';
  static const homeHeadline =
      'Build resumes, cover letters and interview plans faster.';
  static const loginHeadline =
      'Sign in to manage resumes, cover letters and interview prep in one place.';
  static const registerHeadline =
      'Create your account and start building your next career move.';
  static const onboardingStorageKey = 'has_completed_onboarding';
  static const aiTasksEndpointPath = '/v1/ai/tasks';
  static const aiRequestTimeout = Duration(seconds: 30);
  static const aiMaxAttempts = 3;
  static const aiRetryBaseDelay = Duration(milliseconds: 700);
  static const revenueCatEntitlementId = 'premium';
  static const subscriptionsTable = 'subscriptions';
  static const freeGenerationsLimit = 3;
  static const freeGenerationUsageStorageKeyPrefix = 'free_generation_usage_';
}

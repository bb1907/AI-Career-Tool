import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/services/subscription/subscription_provider.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Default state
  // ---------------------------------------------------------------------------
  group('SubscriptionState defaults', () {
    test('defaults to free plan with zero usage', () {
      const state = SubscriptionState();

      expect(state.plan, PlanType.free);
      expect(state.resumeUsed, 0);
      expect(state.coverLetterUsed, 0);
      expect(state.interviewUsed, 0);
      expect(state.networkingUsed, 0);
      expect(state.photoUsedThisMonth, 0);
      expect(state.lastResetKey, '');
      expect(state.softPaywallShown, false);
    });
  });

  // ---------------------------------------------------------------------------
  // canUse
  // ---------------------------------------------------------------------------
  group('canUse', () {
    group('free plan', () {
      test('allows first use of resume', () {
        const state = SubscriptionState(plan: PlanType.free, resumeUsed: 0);
        expect(state.canUse(FeatureType.resume), true);
      });

      test('blocks second use of resume', () {
        const state = SubscriptionState(plan: PlanType.free, resumeUsed: 1);
        expect(state.canUse(FeatureType.resume), false);
      });

      test('allows first use of coverLetter', () {
        const state = SubscriptionState(
          plan: PlanType.free,
          coverLetterUsed: 0,
        );
        expect(state.canUse(FeatureType.coverLetter), true);
      });

      test('blocks second use of coverLetter', () {
        const state = SubscriptionState(
          plan: PlanType.free,
          coverLetterUsed: 1,
        );
        expect(state.canUse(FeatureType.coverLetter), false);
      });

      test('allows first use of interview', () {
        const state = SubscriptionState(plan: PlanType.free, interviewUsed: 0);
        expect(state.canUse(FeatureType.interview), true);
      });

      test('blocks second use of interview', () {
        const state = SubscriptionState(plan: PlanType.free, interviewUsed: 1);
        expect(state.canUse(FeatureType.interview), false);
      });

      test('allows first use of networking', () {
        const state = SubscriptionState(plan: PlanType.free, networkingUsed: 0);
        expect(state.canUse(FeatureType.networking), true);
      });

      test('blocks aiPhoto completely', () {
        const state = SubscriptionState(plan: PlanType.free);
        expect(state.canUse(FeatureType.aiPhoto), false);
      });

      test('blocks mockInterview completely', () {
        const state = SubscriptionState(plan: PlanType.free);
        expect(state.canUse(FeatureType.mockInterview), false);
      });

      test('blocks videoScript completely', () {
        const state = SubscriptionState(plan: PlanType.free);
        expect(state.canUse(FeatureType.videoScript), false);
      });
    });

    group('pro plan', () {
      test('allows unlimited resume usage', () {
        const state = SubscriptionState(plan: PlanType.pro, resumeUsed: 100);
        expect(state.canUse(FeatureType.resume), true);
      });

      test('allows unlimited coverLetter usage', () {
        const state = SubscriptionState(
          plan: PlanType.pro,
          coverLetterUsed: 50,
        );
        expect(state.canUse(FeatureType.coverLetter), true);
      });

      test('allows unlimited interview usage', () {
        const state = SubscriptionState(plan: PlanType.pro, interviewUsed: 50);
        expect(state.canUse(FeatureType.interview), true);
      });

      test('allows aiPhoto up to 5 per month', () {
        const state0 = SubscriptionState(
          plan: PlanType.pro,
          photoUsedThisMonth: 0,
        );
        expect(state0.canUse(FeatureType.aiPhoto), true);

        const state4 = SubscriptionState(
          plan: PlanType.pro,
          photoUsedThisMonth: 4,
        );
        expect(state4.canUse(FeatureType.aiPhoto), true);

        const state5 = SubscriptionState(
          plan: PlanType.pro,
          photoUsedThisMonth: 5,
        );
        expect(state5.canUse(FeatureType.aiPhoto), false);
      });

      test('allows mockInterview and videoScript unlimitedly', () {
        const state = SubscriptionState(plan: PlanType.pro);
        expect(state.canUse(FeatureType.mockInterview), true);
        expect(state.canUse(FeatureType.videoScript), true);
      });
    });

    group('proMax plan', () {
      test('allows unlimited usage for all features', () {
        const state = SubscriptionState(plan: PlanType.proMax);

        for (final feature in FeatureType.values) {
          expect(
            state.canUse(feature),
            true,
            reason: '$feature should be unlimited on proMax',
          );
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // isBlocked
  // ---------------------------------------------------------------------------
  group('isBlocked', () {
    test('aiPhoto is blocked on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.isBlocked(FeatureType.aiPhoto), true);
    });

    test('mockInterview is blocked on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.isBlocked(FeatureType.mockInterview), true);
    });

    test('videoScript is blocked on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.isBlocked(FeatureType.videoScript), true);
    });

    test('resume is not blocked on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.isBlocked(FeatureType.resume), false);
    });

    test('coverLetter is not blocked on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.isBlocked(FeatureType.coverLetter), false);
    });

    test('nothing is blocked on pro plan', () {
      const state = SubscriptionState(plan: PlanType.pro);
      for (final feature in FeatureType.values) {
        expect(
          state.isBlocked(feature),
          false,
          reason: '$feature should not be blocked on pro',
        );
      }
    });

    test('nothing is blocked on proMax plan', () {
      const state = SubscriptionState(plan: PlanType.proMax);
      for (final feature in FeatureType.values) {
        expect(
          state.isBlocked(feature),
          false,
          reason: '$feature should not be blocked on proMax',
        );
      }
    });
  });

  // ---------------------------------------------------------------------------
  // remaining
  // ---------------------------------------------------------------------------
  group('remaining', () {
    test('returns 1 for unused features on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.remaining(FeatureType.resume), 1);
      expect(state.remaining(FeatureType.coverLetter), 1);
      expect(state.remaining(FeatureType.interview), 1);
      expect(state.remaining(FeatureType.networking), 1);
    });

    test('returns 0 for used features on free plan', () {
      const state = SubscriptionState(
        plan: PlanType.free,
        resumeUsed: 1,
        coverLetterUsed: 1,
      );
      expect(state.remaining(FeatureType.resume), 0);
      expect(state.remaining(FeatureType.coverLetter), 0);
    });

    test('returns 0 for blocked features on free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.remaining(FeatureType.aiPhoto), 0);
      expect(state.remaining(FeatureType.mockInterview), 0);
      expect(state.remaining(FeatureType.videoScript), 0);
    });

    test('returns null for unlimited features on pro plan', () {
      const state = SubscriptionState(plan: PlanType.pro);
      expect(state.remaining(FeatureType.resume), isNull);
      expect(state.remaining(FeatureType.coverLetter), isNull);
      expect(state.remaining(FeatureType.interview), isNull);
    });

    test('returns remaining photo count on pro plan', () {
      const state = SubscriptionState(
        plan: PlanType.pro,
        photoUsedThisMonth: 3,
      );
      expect(state.remaining(FeatureType.aiPhoto), 2);
    });

    test('returns null for all features on proMax plan', () {
      const state = SubscriptionState(plan: PlanType.proMax);
      for (final feature in FeatureType.values) {
        expect(
          state.remaining(feature),
          isNull,
          reason: '$feature should be unlimited on proMax',
        );
      }
    });

    test('never returns negative values', () {
      const state = SubscriptionState(plan: PlanType.free, resumeUsed: 10);
      expect(state.remaining(FeatureType.resume), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // shouldShowTeaser
  // ---------------------------------------------------------------------------
  group('shouldShowTeaser', () {
    test('returns false on first use (used == 0) for free plan', () {
      const state = SubscriptionState(plan: PlanType.free, resumeUsed: 0);
      expect(state.shouldShowTeaser(FeatureType.resume), false);
    });

    test('returns true on second use (used >= 1) for free plan', () {
      const state = SubscriptionState(plan: PlanType.free, resumeUsed: 1);
      expect(state.shouldShowTeaser(FeatureType.resume), true);
    });

    test('returns true when used > 1 for free plan', () {
      const state = SubscriptionState(plan: PlanType.free, coverLetterUsed: 3);
      expect(state.shouldShowTeaser(FeatureType.coverLetter), true);
    });

    test('returns false for premium users regardless of usage', () {
      const proState = SubscriptionState(plan: PlanType.pro, resumeUsed: 10);
      expect(proState.shouldShowTeaser(FeatureType.resume), false);

      const proMaxState = SubscriptionState(
        plan: PlanType.proMax,
        resumeUsed: 10,
      );
      expect(proMaxState.shouldShowTeaser(FeatureType.resume), false);
    });
  });

  // ---------------------------------------------------------------------------
  // shouldShowTeaserAfterRecord
  // ---------------------------------------------------------------------------
  group('shouldShowTeaserAfterRecord', () {
    test('returns false when used <= 1 for free plan', () {
      const state0 = SubscriptionState(plan: PlanType.free, resumeUsed: 0);
      expect(state0.shouldShowTeaserAfterRecord(FeatureType.resume), false);

      const state1 = SubscriptionState(plan: PlanType.free, resumeUsed: 1);
      expect(state1.shouldShowTeaserAfterRecord(FeatureType.resume), false);
    });

    test('returns true when used > 1 for free plan', () {
      const state = SubscriptionState(plan: PlanType.free, resumeUsed: 2);
      expect(state.shouldShowTeaserAfterRecord(FeatureType.resume), true);
    });

    test('returns false for premium users', () {
      const state = SubscriptionState(plan: PlanType.pro, resumeUsed: 10);
      expect(state.shouldShowTeaserAfterRecord(FeatureType.resume), false);
    });
  });

  // ---------------------------------------------------------------------------
  // isPremium
  // ---------------------------------------------------------------------------
  group('isPremium', () {
    test('returns false for free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.isPremium, false);
    });

    test('returns true for pro plan', () {
      const state = SubscriptionState(plan: PlanType.pro);
      expect(state.isPremium, true);
    });

    test('returns true for proMax plan', () {
      const state = SubscriptionState(plan: PlanType.proMax);
      expect(state.isPremium, true);
    });
  });

  // ---------------------------------------------------------------------------
  // planLabel
  // ---------------------------------------------------------------------------
  group('planLabel', () {
    test('returns "Free" for free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.planLabel, 'Free');
    });

    test('returns "Pro" for pro plan', () {
      const state = SubscriptionState(plan: PlanType.pro);
      expect(state.planLabel, 'Pro');
    });

    test('returns "Pro Max" for proMax plan', () {
      const state = SubscriptionState(plan: PlanType.proMax);
      expect(state.planLabel, 'Pro Max');
    });
  });

  // ---------------------------------------------------------------------------
  // allowedVideoDurations
  // ---------------------------------------------------------------------------
  group('allowedVideoDurations', () {
    test('returns empty list for free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.allowedVideoDurations, isEmpty);
    });

    test('returns only 30s for pro plan', () {
      const state = SubscriptionState(plan: PlanType.pro);
      expect(state.allowedVideoDurations, ['30s']);
    });

    test('returns all durations for proMax plan', () {
      const state = SubscriptionState(plan: PlanType.proMax);
      expect(state.allowedVideoDurations, ['30s', '60s', '90s']);
    });
  });

  // ---------------------------------------------------------------------------
  // hasPdfWatermark
  // ---------------------------------------------------------------------------
  group('hasPdfWatermark', () {
    test('returns true for free plan', () {
      const state = SubscriptionState(plan: PlanType.free);
      expect(state.hasPdfWatermark, true);
    });

    test('returns false for pro plan', () {
      const state = SubscriptionState(plan: PlanType.pro);
      expect(state.hasPdfWatermark, false);
    });

    test('returns false for proMax plan', () {
      const state = SubscriptionState(plan: PlanType.proMax);
      expect(state.hasPdfWatermark, false);
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------
  group('SubscriptionState.copyWith', () {
    test('updates only specified fields', () {
      const original = SubscriptionState();
      final updated = original.copyWith(plan: PlanType.pro, resumeUsed: 5);

      expect(updated.plan, PlanType.pro);
      expect(updated.resumeUsed, 5);
      expect(updated.coverLetterUsed, 0);
      expect(updated.interviewUsed, 0);
    });

    test('preserves all fields when no arguments given', () {
      const original = SubscriptionState(
        plan: PlanType.pro,
        resumeUsed: 3,
        coverLetterUsed: 2,
        interviewUsed: 1,
        networkingUsed: 4,
        photoUsedThisMonth: 2,
        lastResetKey: '2024-03',
        softPaywallShown: true,
      );
      final copy = original.copyWith();

      expect(copy.plan, original.plan);
      expect(copy.resumeUsed, original.resumeUsed);
      expect(copy.coverLetterUsed, original.coverLetterUsed);
      expect(copy.interviewUsed, original.interviewUsed);
      expect(copy.networkingUsed, original.networkingUsed);
      expect(copy.photoUsedThisMonth, original.photoUsedThisMonth);
      expect(copy.lastResetKey, original.lastResetKey);
      expect(copy.softPaywallShown, original.softPaywallShown);
    });
  });
}

# Final Release Audit

Last updated: 2026-03-13

## 1. Completed in code

- Feature-based architecture is in place.
- Riverpod and `go_router` flow is established.
- Supabase auth is integrated.
- Resume, cover letter, interview, CV import, history, paywall, analytics, and job matching MVP are implemented.
- Release-critical Supabase schema is now tracked in migrations.
- Free vs premium usage enforcement exists and uses `usage_events`.
- Local release sanity checks passed:
  - `flutter analyze`
  - `flutter test`
  - iOS simulator run

## 2. Ready but needs environment validation

- Hosted Supabase production project
- AI backend production endpoint
- RevenueCat products, offerings, and entitlement
- Firebase Analytics project and `GoogleService-Info.plist`
- Apple signing, archive, and TestFlight upload

## 3. Current release blockers

- Apple Developer account is not yet fully active for TestFlight distribution.
- `GoogleService-Info.plist` is still missing from `ios/Runner/`.
- RevenueCat dashboard state cannot be verified from source code alone.

## 4. Safe to postpone until after first TestFlight

- Voice or media-heavy features
- Expanding job matching beyond MVP
- Broader AI feature surface area
- Large UI redesigns

## 5. Recommended focus order

1. Apple Developer account activation
2. Firebase plist placement
3. RevenueCat verification
4. Signed archive and TestFlight upload
5. Internal tester feedback

## 6. Release decision rule

Move to TestFlight when all of these are true:

- `flutter analyze` is clean
- `flutter test` is clean
- production env values are ready
- Firebase plist is added
- RevenueCat products are verified
- Apple signing works in Xcode
- archive/upload succeeds

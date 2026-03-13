# Release Checklist

## 1. Environment setup

The project now supports a simple environment split through `APP_ENV`.

- `APP_ENV=dev`
  - Local Supabase fallback is allowed.
  - Recommended for simulator and day-to-day development.
- `APP_ENV=prod`
  - Hosted Supabase variables are required.
  - Local Supabase fallback is disabled on purpose.
  - Use this for TestFlight and App Store builds.

Reference files:

- `env/dev.example.json`
- `env/prod.example.json`

Recommended local files:

- `env/dev.json`
- `env/prod.json`

These are ignored by git.

## 2. Required environment variables

Always review these before a release build:

- `APP_ENV`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `AI_BACKEND_URL`
- `REVENUECAT_APPLE_API_KEY`
- `REVENUECAT_ENTITLEMENT_ID`

Notes:

- `SUPABASE_URL` and `SUPABASE_ANON_KEY` are mandatory in `prod`.
- `AI_BACKEND_URL` is mandatory for resume, cover letter, interview and CV parsing flows.
- `REVENUECAT_APPLE_API_KEY` is mandatory for paywall, premium state and restore purchases.
- `REVENUECAT_ENTITLEMENT_ID` defaults to `premium`, but should still be set explicitly in release config.

## 3. Build commands

Development sanity check:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ios --simulator --debug --no-codesign --dart-define-from-file=env/dev.json
```

Release candidate build:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ipa --release --dart-define-from-file=env/prod.json
```

Optional explicit versioning:

```bash
flutter build ipa \
  --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --dart-define-from-file=env/prod.json
```

## 4. iOS manual release steps

### Apple / Xcode

- Confirm paid Apple Developer membership is active.
- Confirm correct `Team` is selected in Xcode.
- Confirm bundle identifier matches the App Store Connect app record.
- Confirm signing works for `Runner`.
- Confirm archive succeeds in Xcode Organizer.
- Upload the signed build to App Store Connect / TestFlight.

### Firebase

- Add `GoogleService-Info.plist` to `ios/Runner/`.
- Confirm Firebase Analytics is enabled.
- Verify release app points to the correct Firebase project.

### RevenueCat

- Confirm iOS app is linked in RevenueCat.
- Confirm current offering exists.
- Confirm `weekly`, `monthly`, `annual` packages are attached.
- Confirm `premium` entitlement is attached to those products.
- Confirm restore purchases works with a sandbox tester.

### Supabase

- Confirm production project URL and anon key are used.
- Confirm required SQL schema exists:
  - `profiles`
  - `resumes`
  - `cover_letters`
  - `interview_sets`
  - `uploaded_cvs`
  - `candidate_profiles`
  - `usage_events`
  - optional `subscriptions`
- Confirm RLS policies are active.
- Confirm storage bucket exists:
  - `cv-uploads`

### AI backend

- Confirm `POST /v1/ai/tasks` is reachable from the iOS app.
- Confirm auth boundary is server-side and no model API key is shipped in the client.
- Confirm backend returns the expected structured JSON envelopes.

## 5. App Store metadata checklist

Prepare these before TestFlight external testing or App Store submission:

- App name
- Subtitle
- Keywords
- Marketing description
- Support URL
- Privacy Policy URL
- Terms of Use URL
- App review contact info
- App review notes
- Subscription display copy
- Restore purchases messaging
- Screenshots for required device sizes
- App icon

### Subscription copy checklist

- Clearly explain what premium unlocks.
- State billing cadence:
  - weekly
  - monthly
  - annual
- Mention auto-renewing subscription behavior.
- Mention where users can manage subscriptions.
- Mention restore purchases action.

## 6. Privacy / legal checklist

- Privacy Policy URL is public and reachable.
- Terms of Use URL is public and reachable.
- Support URL is public and reachable.
- Data collection declarations in App Store Connect match the app behavior.
- If AI outputs are stored, that storage behavior is reflected in privacy documentation.
- If analytics is enabled, analytics collection is reflected in privacy documentation.

## 7. Runtime QA checklist

- Login works.
- Register works.
- Logout works.
- Onboarding appears only on first run.
- Resume generate / save / copy works.
- Cover letter generate / edit / save / copy works.
- Interview generate / save works.
- CV import / parse / profile prefill works.
- History loads and isolates users correctly.
- Recent section shows actual recent items.
- Free usage limit triggers paywall.
- Premium users bypass the free limit.
- Purchase succeeds.
- Purchase cancel is handled gracefully.
- Restore purchases succeeds.
- Analytics events appear in Firebase debug view.

## 8. Known risks / open items

- Local Supabase fallback is only safe in development. Production must supply hosted values.
- AI reliability still depends on the backend contract staying stable.
- RevenueCat behavior should be verified on real devices with sandbox accounts.
- TestFlight/App Store release still depends on Apple signing and account configuration.
- `job_matching` is not yet a full production-ready flow.
- `analytics`, `subscriptions`, and privacy disclosures must stay aligned as product scope changes.

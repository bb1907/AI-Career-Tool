# Release Readiness Report

Last checked: 2026-03-13

## Passed

- Repo is clean after committing release-prep changes.
- `.gitignore` now excludes:
  - `supabase/.branches/`
  - `supabase/.temp/`
- `flutter clean`
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Local Supabase migrations now cover:
  - `profiles`
  - `resumes`
  - `cover_letters`
  - `interview_sets`
  - `uploaded_cvs`
  - `candidate_profiles`
  - `usage_events`
- Local Supabase RLS is enabled for the release-critical public tables.
- Local storage bucket exists:
  - `cv-uploads`
- Usage RPC functions exist:
  - `get_usage_snapshot`
  - `reserve_usage_event`
  - `finalize_usage_event`
  - `release_usage_event`
- iOS simulator run works.

## Requires manual verification

- Register / login / session restore against the intended release backend
- Resume / cover letter / interview / CV import happy paths on a real release environment
- RevenueCat products, entitlements, restore purchases, and sandbox purchase flow
- Firebase Analytics event delivery in DebugView / production project
- TestFlight upload and signed device/archive flow
- App Store metadata, legal URLs, subscription copy, screenshots

## Current blockers or gaps

- `flutter build ios --debug` for device build still depends on complete Apple signing/provisioning on this machine.
- `GoogleService-Info.plist` is not present in `ios/Runner/`, so Firebase Analytics is not fully wired for iOS release builds yet.
- RevenueCat dashboard configuration cannot be verified from the repo alone.
- Production AI backend contract and uptime still need live verification.

## iOS notes

- Bundle ID:
  - `com.aicareertools.aiCareerTools`
- Minimum iOS deployment target:
  - `15.0`
- Project now includes a default development team setting for local device signing:
  - `2TAA7YUZ2C`

## Permissions review

- No camera permission text found.
- No microphone permission text found.
- No photo library permission text found.
- No tracking permission text found.

This is acceptable for the current feature set as long as camera, microphone, and tracking are not used in release.

## Recommended next step

Use this project for TestFlight preparation now, not new feature work. The main remaining tasks are release environment validation, Apple signing, RevenueCat verification, Firebase plist setup, and App Store metadata completion.

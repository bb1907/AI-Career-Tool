# TestFlight Runbook

Use this once the Apple Developer membership is fully active.

## 1. Apple account readiness

- Confirm the latest Apple agreements are accepted in App Store Connect Business.
- Confirm your Apple Developer membership is active.
- Confirm the account has permission to create app records and upload builds.

Official references:

- Add a new app:
  - https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/
- Upload builds:
  - https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
- View builds and metadata:
  - https://developer.apple.com/help/app-store-connect/manage-builds/view-builds-and-metadata/
- TestFlight overview:
  - https://developer.apple.com/testflight/
- Add internal testers:
  - https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers

## 2. Local prerequisites

- `env/prod.json` exists and has valid values
- `ios/Runner/GoogleService-Info.plist` is added
- RevenueCat iOS setup is complete
- Supabase production schema is applied
- AI backend production URL is live

## 3. Xcode signing

1. Open:
   - `open ios/Runner.xcworkspace`
2. Select the `Runner` target.
3. Open `Signing & Capabilities`.
4. Confirm:
   - correct Team
   - bundle ID
   - automatic signing
5. Build once in Xcode if needed so provisioning resolves cleanly.

## 4. App Store Connect record

1. Open App Store Connect.
2. Create the iOS app record if it does not exist.
3. Match the bundle ID exactly.
4. Fill the minimum metadata needed for a build to sit cleanly in App Store Connect.

## 5. Build commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ipa --release --dart-define-from-file=env/prod.json
```

If you need explicit versioning:

```bash
flutter build ipa \
  --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --dart-define-from-file=env/prod.json
```

## 6. Upload flow

Option A: Xcode Organizer

1. Product > Archive
2. Open Organizer
3. Distribute App
4. App Store Connect
5. Upload

Option B: Transporter

- Use the signed archive/exported build once signing is fully configured.

## 7. After upload

1. Wait for build processing.
2. Open the app in App Store Connect.
3. Go to `TestFlight`.
4. Confirm the uploaded build appears.
5. Add the build to an internal testing group.

## 8. Internal testing pass

Ask testers to verify:

- sign up
- log in
- resume generation
- cover letter generation
- interview generation
- CV import
- history
- paywall visibility
- purchase / restore flow if sandbox is ready

## 9. What to do if upload stalls

- Recheck signing and provisioning in Xcode.
- Confirm app agreements are accepted in App Store Connect.
- Confirm bundle ID matches the app record.
- Confirm build number is newer than the previous upload.
- Confirm `GoogleService-Info.plist` and production env values are present.

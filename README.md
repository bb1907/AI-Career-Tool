# AI Career Tools

Flutter iOS app for resume building, cover letter generation, interview prep,
and career workflow management.

## Local Development

The project is configured to use a local Supabase stack by default in debug.
Hosted Supabase credentials can still override this via `--dart-define`.

### Start local services

```bash
colima start --vm-type=vz --cpu 2 --memory 4 --disk 20
supabase start
```

### Run the app on iOS Simulator

```bash
open -a Simulator
flutter run -d "iPhone 16e"
```

### Optional: use hosted Supabase instead of local

```bash
flutter run -d "iPhone 16e" \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## Useful URLs

- Supabase Studio: `http://127.0.0.1:54323`
- Supabase API: `http://127.0.0.1:54321`
- Mailpit: `http://127.0.0.1:54324`

## Verification

```bash
flutter analyze
flutter test
flutter build ios --simulator --debug --no-codesign
```

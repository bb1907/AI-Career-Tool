# Deferred Work

Items surfaced during adversarial review of `tech-spec-clean-flutter-resume-builder` but not caused by this story.

## Domain models: missing == / hashCode
All resume domain entities (ResumeData, PersonalInfo, WorkEntry, EducationEntry, ProjectEntry, AuthUser) lack `==` and `hashCode` overrides. Riverpod emits rebuilds even when state is logically identical. Fix: add `equatable` package or manual overrides.

## Project URL: unclickable text
`resume_preview_page.dart` renders project URLs as styled `Text`, not tappable links. Use `url_launcher` + `InkWell` or `GestureDetector` to open URLs.

## GoogleFonts network fetch
`AppTheme.light()` uses `GoogleFonts.poppinsTextTheme()` which fetches fonts from the network at first launch. Bundle the font assets in `pubspec.yaml` and set `GoogleFonts.config.allowRuntimeFetching = false` for offline support.

## Steps 2–6 validation
Currently only Step 1 (name + email) is validated. Consider adding optional validation for work entries (at least company or title) and education (school name) before shipping.

## Login screen flash on cold start
`initialLocation: '/login'` causes a brief flash of the login screen even for future implementations with real persistence. Address when real auth persistence is added.

## _EntryCardState: didUpdateWidget not overridden
If resume state is programmatically pre-filled from an external source while an entry card is mounted, the TextEditingControllers won't reflect the new values. Override `didUpdateWidget` to sync controllers when `widget.entry` changes identity.

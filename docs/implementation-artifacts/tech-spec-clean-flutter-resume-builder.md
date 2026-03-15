---
title: 'Clean Flutter App + Resume Builder'
type: 'feature'
created: '2026-03-15'
status: 'done'
baseline_commit: '0be6a090b160970a2d308dd1a1dfc8c8b71673b2'
context: []
---

# Clean Flutter App + Resume Builder

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** `lib/` is empty after old Codex code removal. The project needs a clean, production-ready foundation and a Resume Builder feature with a 6-step form wizard.

**Approach:** Scaffold a minimal Flutter app (Riverpod + GoRouter, feature-first structure), add InMemory auth, then implement Resume Builder with a 6-step wizard and CV preview page.

## Boundaries & Constraints

**Always:**
- Feature-first folder structure: `lib/features/<feature>/`
- State management: `flutter_riverpod` only (no BLoC, no ChangeNotifier)
- Navigation: `go_router` only
- Auth: InMemory (plain Dart list) — no Supabase, no Firebase, no external services
- pubspec.yaml: remove Supabase, Firebase, RevenueCat, camera, syncfusion, file_picker; keep flutter_riverpod, go_router, google_fonts, shared_preferences, cupertino_icons

**Ask First:**
- Any persistence layer beyond in-memory (SharedPreferences, local DB)
- Adding new third-party dependencies

**Never:**
- Supabase / Firebase / RevenueCat integration
- Complex DI / service-locator patterns (keep it flat Riverpod providers)
- Generating PDF in this iteration

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Login success | Valid registered email+password | Navigate to /resume/wizard | — |
| Login fail | Unknown or wrong credentials | Show inline error on login page | Snackbar / red text |
| Register | Email + password (min 6 chars) | Store in memory, auto-login, go to /resume/wizard | Duplicate email → error |
| Wizard navigation | Tap Next on step N | Validates current step, advances to step N+1 | Shows field errors inline |
| Wizard completion | Tap Finish on step 6 | Navigates to /resume/preview | — |
| Preview page | ResumeData state | Renders formatted CV card | Empty sections shown as placeholder |

</frozen-after-approval>

## Code Map

- `pubspec.yaml` -- remove heavy deps, keep riverpod/go_router/google_fonts
- `lib/main.dart` -- app entry, ProviderScope + runApp
- `lib/app/app.dart` -- MaterialApp.router wired to GoRouter
- `lib/app/router.dart` -- GoRouter config, auth redirect guard
- `lib/app/theme/app_theme.dart` -- ThemeData (Material 3, google_fonts)
- `lib/features/auth/domain/auth_user.dart` -- simple AuthUser value object
- `lib/features/auth/data/in_memory_auth_repository.dart` -- List<AuthUser> store, login/register
- `lib/features/auth/presentation/providers/auth_provider.dart` -- authStateProvider (AsyncNotifier)
- `lib/features/auth/presentation/pages/login_page.dart` -- login form
- `lib/features/auth/presentation/pages/register_page.dart` -- register form
- `lib/features/resume/domain/resume_data.dart` -- ResumeData + sub-models (PersonalInfo, WorkEntry, EducationEntry, Skill, Project)
- `lib/features/resume/presentation/providers/resume_provider.dart` -- resumeProvider (StateNotifier)
- `lib/features/resume/presentation/pages/resume_wizard_page.dart` -- 6-step PageView wizard shell
- `lib/features/resume/presentation/steps/step1_personal_info.dart` -- name, email, phone, location, linkedin
- `lib/features/resume/presentation/steps/step2_summary.dart` -- professional summary textarea
- `lib/features/resume/presentation/steps/step3_work_experience.dart` -- add/remove work entries (company, title, dates, bullets)
- `lib/features/resume/presentation/steps/step4_education.dart` -- add/remove education entries (school, degree, year)
- `lib/features/resume/presentation/steps/step5_skills.dart` -- add/remove skill chips
- `lib/features/resume/presentation/steps/step6_projects.dart` -- add/remove project entries (name, description, url)
- `lib/features/resume/presentation/pages/resume_preview_page.dart` -- formatted CV card view + copy/share placeholder

## Tasks & Acceptance

**Execution:**
- [ ] `pubspec.yaml` -- remove supabase_flutter, purchases_flutter, firebase_core, firebase_analytics, camera, syncfusion_flutter_pdf, file_picker; set sdk to >=3.0.0 <4.0.0
- [ ] `lib/main.dart` -- ProviderScope wrapping MyApp, runApp
- [ ] `lib/app/app.dart` -- MaterialApp.router, theme from AppTheme
- [ ] `lib/app/router.dart` -- routes: /login, /register, /resume/wizard, /resume/preview; redirect guard using authStateProvider
- [ ] `lib/app/theme/app_theme.dart` -- Material 3 ThemeData, google_fonts Poppins
- [ ] `lib/features/auth/domain/auth_user.dart` -- AuthUser(id, email, passwordHash)
- [ ] `lib/features/auth/data/in_memory_auth_repository.dart` -- InMemoryAuthRepository with register/login methods
- [ ] `lib/features/auth/presentation/providers/auth_provider.dart` -- authRepositoryProvider, currentUserProvider (StateProvider<AuthUser?>), authActionsProvider
- [ ] `lib/features/auth/presentation/pages/login_page.dart` -- email/pass form, error display, link to register
- [ ] `lib/features/auth/presentation/pages/register_page.dart` -- email/pass form, validation, link to login
- [ ] `lib/features/resume/domain/resume_data.dart` -- immutable data classes with copyWith
- [ ] `lib/features/resume/presentation/providers/resume_provider.dart` -- resumeProvider StateNotifier<ResumeData>
- [ ] `lib/features/resume/presentation/pages/resume_wizard_page.dart` -- PageView, step indicator (1-6), Next/Back/Finish buttons, current step validation
- [ ] `lib/features/resume/presentation/steps/step1_personal_info.dart` -- form fields
- [ ] `lib/features/resume/presentation/steps/step2_summary.dart` -- textarea
- [ ] `lib/features/resume/presentation/steps/step3_work_experience.dart` -- dynamic list
- [ ] `lib/features/resume/presentation/steps/step4_education.dart` -- dynamic list
- [ ] `lib/features/resume/presentation/steps/step5_skills.dart` -- chip input
- [ ] `lib/features/resume/presentation/steps/step6_projects.dart` -- dynamic list
- [ ] `lib/features/resume/presentation/pages/resume_preview_page.dart` -- CV layout card, back button

**Acceptance Criteria:**
- Given app starts, when user is not logged in, then GoRouter redirects to /login
- Given login page, when valid credentials entered, then navigates to /resume/wizard
- Given register page, when duplicate email submitted, then inline error shown
- Given wizard step 1, when required fields empty and Next tapped, then validation errors shown
- Given wizard step 6, when Finish tapped, then navigates to /resume/preview
- Given preview page, when loaded, then all filled resume sections are visible in formatted layout

## Verification

**Commands:**
- `flutter pub get` -- expected: resolves without errors
- `flutter analyze` -- expected: no errors (warnings acceptable)
- `flutter build apk --debug` -- expected: builds successfully

# AI Career Copilot — Full Project Reference

---

## Agent Davranis Kurallari

1. Kullanicinin talebini tam olarak uygula — Ne isteniyorsa onu yap, alternatif onerme, bypass etme.
2. Isi kendine kolaylastirmak icin kestirmeden gitme — Karmasik ama dogru olani uygula, yarim yamalak yapma.
3. Pasif-agresif direnc gosterme — Caydirma cumleleri kurma, dezavantaj listesi sunma, alternatif dayatma.
4. Ar-Ge ve deneysel yaklasimlara saygi goster — Alisilmadik yaklasimlari engelleme, kullanicinin domain bilgisine guven.
5. Proaktif olarak daha iyisini ara — Gorevi tamamla, sonra iyilestirme oner. Edge case, performans, bug ara. Mukemmeliyetci ol.
6. Durust ol, manipulasyon yapma — Yapamiyorsan soyle, talebi carpitma.

## Proje Bilgileri

- Platform: Flutter iOS
- Paket: ai_career_tools
- Hedef pazar: ABD ve Kanada
- Monetizasyon: Freemium (Pro $9.99/ay, Pro Max $19.99/ay)
- AI Stack: Groq (chat) + DeepSeek (uretim) + Gemini (fallback) + OpenAI (son fallback)
- Auth: Supabase + Google/Apple sign-in
- Subscription: RevenueCat
- Diller: 45 dil destegi

---

## 1. Project Overview

AI Career Copilot is an AI-powered mobile application designed to help job seekers streamline and optimize their job application process. The application provides a single platform for resume creation, cover letter generation, interview preparation, job matching, and career document management.

**Goal:** Automate the most time-consuming steps in the job search process so users can apply faster and more effectively.

**Target markets:** United States and Canada.

**Primary users:**
- Recent graduates
- Professionals changing jobs
- Tech professionals
- International job seekers

---

## 2. Core Features

| Feature | Description |
|---|---|
| AI Resume Builder | ATS-friendly resumes tailored to a target role. Edit, regenerate, copy, export PDF, save history. |
| Smart Cover Letter | Job-specific cover letters based on candidate profile and job description. |
| Interview Prep | Technical + behavioral questions with sample answers and coaching tips. |
| CV Import | Upload a PDF resume; extract skills, experience, education into structured profile. |
| Job-Specific Cover Letters | AI analyzes JD + candidate profile to generate tailored letters. |
| Video Script Generator | Generate 30/60/90s scripts for video applications. |
| Teleprompter + Recording | Record video cover letters with teleprompter overlay, scroll speed, font size. |
| Job Matching | AI suggests jobs, highlights missing and matching skills. |
| History & Document Management | Stores resumes, cover letters, interview sets, video scripts. |

---

## 3. Business Model

**Freemium.**

| Plan | Limits |
|---|---|
| Free | 3 AI generations total, limited history, no PDF export |
| Premium | Unlimited generations, full history, PDF export, early access to new tools |

**Subscription options:** Weekly · Monthly · Annual

---

## 4. Technology Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter |
| State Management | Riverpod 3.x |
| Routing | GoRouter 17.x |
| Backend / Auth / DB | Supabase |
| AI | OpenAI API (gpt-4o-mini) |
| Subscriptions | RevenueCat |
| Analytics | Firebase Analytics or PostHog |
| Crash Monitoring | Firebase Crashlytics |

---

## 5. Application Architecture

Feature-based clean architecture with Domain / Data / Application / Presentation layers.

```
lib/
  app/               ← router, shell, theme, app.dart
  features/
    auth/
    onboarding/
    home/
    resume/
    cover_letter/
    interview_prep/
    cv_upload/
    job_match/
    video_script/
    video/
    history/
    paywall/
    settings/
    usage/
  services/
    openai/
    supabase/      ← future
    revenuecat/    ← future
  ui/
    components/    ← shared UI widgets
  shared/
    widgets/
```

Each feature folder contains:
- `domain/` — pure Dart models, repository interfaces
- `data/` — in-memory (current) or Supabase (future) implementations
- `presentation/` — pages, providers (Riverpod), widgets

---

## 6. Database Schema (Supabase — future)

```
profiles
  id, email, full_name, target_role, years_experience, plan_type, created_at

resumes
  id, user_id, target_role, skills (jsonb), generated_json (jsonb), created_at

cover_letters
  id, user_id, company_name, role_name, job_description, generated_text, tone, created_at

interview_sets
  id, user_id, role_name, seniority, generated_json (jsonb), created_at

video_scripts
  id, user_id, duration_type, script_text, tone, application_id, created_at

recorded_videos
  id, user_id, script_id, storage_path, thumbnail_path, duration_seconds, created_at

uploaded_cvs
  id, user_id, file_url, parsed_text, parsed_json (jsonb), created_at

job_applications
  id, user_id, company_name, role_name, job_description, match_score, created_at

usage_events
  id, user_id, tool_type, credits_used, created_at
```

---

## 7. Development Roadmap

### Phase 1 — Core Career Tools ✅
- Authentication (in-memory mock, Supabase-ready)
- Onboarding flow (target role + experience level)
- Resume Builder (6-step wizard)
- Cover Letter Generator
- Interview Prep (technical + behavioral)
- History (4-tab: Resumes, Cover Letters, Interviews, Scripts)
- Paywall (weekly/monthly/annual)
- Settings (theme, account, notifications)
- PDF Export for resumes

### Phase 2 — Smart Features ✅
- PDF CV Upload + mock parsing
- Job-specific Cover Letter (2-step: context + JD)
- Job Matching (skill overlap analysis)

### Phase 3 — Video Applications ✅
- Video Script Generator (30s/60s/90s, tone selection)
- Teleprompter (auto-scroll, mirror, font/speed sliders)
- Video list management

### Future Features
- Job tracker
- Automated job applications
- AI interview simulations (voice + video)
- Voice resume builder
- Resume scoring (ATS optimizer)

---

## 8. Design System

### Style
**"AI Productivity Minimal"** — Clean, powerful, focus-driven. Inspired by Notion, Linear, Arc Browser, Raycast, Duolingo.

### Color Tokens
| Token | Hex | Usage |
|---|---|---|
| `primary` | `#5B5FEF` | Main button, link, accent |
| `secondary` | `#7C80F2` | Secondary elements |
| `accent` | `#00C2A8` | Teal — success, chips, badges |
| `lightBG` | `#F7F8FB` | Scaffold background (light) |
| `darkBG` | `#111827` | Scaffold background (dark) |
| `darkSurface` | `#1F2937` | Card surface (dark) |
| `lightBorder` | `#E6E8EF` | Borders (light) |
| `darkBorder` | `#374151` | Borders (dark) |
| `error` | `#EF4444` | Errors, destructive |
| `success` | `#22C55E` | Success, completion |
| `warning` | `#F59E0B` | Warnings, amber score |

**Gradients:**
- `primaryGradient`: `#5B5FEF → #7C80F2` (topLeft → bottomRight)
- `heroGradient`: `#5B5FEF → #9B5DE5`
- `accentGradient`: `#00C2A8 → #00D4BA`

### Spacing (AppSpacing)
`xs=4, sm=8, md=16, lg=24, xl=32, xxl=48`

### Radii (AppRadius)
`card=16, button=14, input=12, chip=20, badge=8`

### Card Design
- `borderRadius: 16`, `padding: 20`
- No elevation — manual `BoxShadow` (soft purple tint + 4% black)
- Dark mode: use `context.appSurface`, `context.appBorder`, `context.appText1/2`

### Typography (Inter)
- Headlines: `fontWeight: w700`, `letterSpacing: -0.3…-0.5`
- Buttons: `fontWeight: w600`, `letterSpacing: -0.1`
- Body: default weight

### Buttons
- Primary: `FilledButton`, `borderRadius: 14`, height 52, `backgroundColor: AppColors.primary`
- Outlined: `borderSide: BorderSide(color: primary, width: 1.5)`
- AI button: gradient + sparkle icon `Icons.auto_awesome_rounded`

### AI Loading (Raycast-inspired)
```dart
showAiLoading(context, messages: ['Step 1...', 'Step 2...', 'Step 3...']);
```
- Pulsing gradient icon (ScaleTransition)
- ~1.4s per step; completed = green checkmark; active = spinner; pending = grey dot
- NEVER use raw CircularProgressIndicator for AI operations

**Message sets:**
- Cover Letter: `Analyzing job description` → `Matching your profile` → `Crafting your cover letter`
- Interview Prep: `Analyzing role requirements` → `Generating technical questions` → `Crafting behavioral questions`
- Resume Summary: `Reviewing your experience` → `Identifying key skills` → `Writing your summary`
- Video Script: `Analyzing your profile` → `Crafting your intro` → `Polishing the script`
- CV Parse: `Reading your CV` → `Extracting skills` → `Building your profile`

### Shared Components (lib/ui/components/)
| Component | Usage |
|---|---|
| `AppCard` | Surface card with border/shadow, optional `onTap`, `showBorder`, `padding` |
| `AppInputField` | Styled TextFormField |
| `AiScoreBadge(score: int)` | Circular progress badge, color-coded ≥90 teal / ≥75 amber / <75 purple |
| `AiSuggestionChip(label: String)` | Teal chip with lightbulb icon |
| `FeatureCard` | Icon + gradient + title + description + optional `badge` |
| `SectionHeader` | Title + optional trailing action link |
| `AiButton` | Gradient button with sparkle icon, `isLoading` state |
| `AiLoadingIndicator` | Pure widget (used inside dialog) |

---

## 9. Key AI Prompts

### Resume Generator
> Generate an ATS-friendly resume for a candidate based on their experience, skills, and target role. Use action verbs and measurable achievements.

### Cover Letter Generator
> Generate a professional cover letter (250–350 words) tailored to a job description and candidate profile.

### Interview Questions Generator
> Create technical and behavioral interview questions with short, strong example answers. Return JSON: `{questions: [{category, question, sampleAnswer}]}`.

### Video Script Generator
> Generate a [30/60/90]-second video introduction script for a [tone] job application. Role: [role].

---

## 10. Development Notes

- **API key:** `--dart-define=OPENAI_API_KEY=sk-...`
- **Mock fallback:** All features work without an API key using mock generators
- **Riverpod 3.x:** No `StateProvider` — use `Notifier`/`AsyncNotifier` + `NotifierProvider`
- **GoRouter:** Shell wraps `/home`, `/history`, `/profile` only. Feature pages are outside the shell (no bottom nav).
- **IDs:** Use `uuid` package: `const Uuid().v4()`
- **Every result page** must include `AiScoreBadge` + at least 2 `AiSuggestionChip` widgets
- **Freemium counter:** Currently tracked client-side (UsageEvent). Supabase integration pending.
- **PDF export:** Uses `printing` + `pdf` packages. Premium-gated (show paywall if free plan).

---

## 11. Current Route Map

| Route | Page | Shell? |
|---|---|---|
| `/` | SplashPage | No |
| `/onboarding` | OnboardingPage | No |
| `/login` | LoginPage | No |
| `/home` | HomePage | Yes |
| `/history` | HistoryPage | Yes |
| `/profile` | ProfilePage | Yes |
| `/settings` | SettingsPage | No |
| `/paywall` | PaywallPage | No |
| `/resume` | ResumeListPage | No |
| `/resume/new` | ResumeWizardPage | No |
| `/resume/:id` | ResumeWizardPage | No |
| `/resume/:id/preview` | ResumePreviewPage | No |
| `/cover-letter` | CoverLetterFormPage | No |
| `/cover-letter/result` | CoverLetterResultPage | No |
| `/job-cover-letter` | JobCoverLetterPage | No |
| `/interview-prep` | InterviewPrepFormPage | No |
| `/interview-prep/questions` | InterviewPrepQuestionsPage | No |
| `/cv-upload` | CvUploadPage | No |
| `/job-match` | JobMatchPage | No |
| `/video-script` | VideoScriptFormPage | No |
| `/video-script/result` | VideoScriptResultPage | No |
| `/teleprompter` | TeleprompterPage | No |
| `/videos` | VideoListPage | No |

---

## 12. Product Vision

AI Career Copilot aims to become a **complete AI career assistant** — not just a resume tool.

The long-term vision is a platform where users can:
1. Build their professional profile once
2. Apply it across resumes, cover letters, and video applications
3. Track job applications and get AI-driven insights
4. Practice and improve interview skills with AI simulations
5. Stay ahead of job market trends with skill gap analysis

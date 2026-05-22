/// Branding tagline shown in-app instead of naming individual AI vendors.
const kAiBrandingTagline = 'Powered by GPT & Gemini';

/// AI providers listed in the privacy disclosure screen.
/// All entries are required for legal transparency under GDPR / CCPA.
const List<({String name, String purpose, String privacyUrl})>
providersForDisclosure = [
  (
    name: 'Groq',
    purpose: 'Fast chat responses and real-time career suggestions',
    privacyUrl: 'https://groq.com/privacy-policy',
  ),
  (
    name: 'Google Gemini',
    purpose:
        'Resume parsing, content generation (cover letters, interview prep, video scripts) and CV file understanding',
    privacyUrl: 'https://policies.google.com/privacy',
  ),
  (
    name: 'OpenAI',
    purpose: 'Fallback natural language generation for resumes and career documents',
    privacyUrl: 'https://openai.com/policies/privacy-policy',
  ),
  (
    name: 'FASHN',
    purpose: 'AI virtual try-on and professional outfit generation for photo studio',
    privacyUrl: 'https://fashn.ai/privacy',
  ),
];

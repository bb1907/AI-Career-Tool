/// Branding tagline shown in-app instead of naming individual AI vendors.
const kAiBrandingTagline = 'Powered by AI';

/// AI providers listed in the privacy disclosure screen.
/// DeepSeek is included here for legal transparency even though it does not
/// appear in product marketing copy.
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
        'CV parsing, skill analysis and multi-modal document understanding',
    privacyUrl: 'https://policies.google.com/privacy',
  ),
  (
    name: 'OpenAI',
    purpose: 'Natural language generation for resumes and cover letters',
    privacyUrl: 'https://openai.com/policies/privacy-policy',
  ),
  (
    name: 'DeepSeek',
    purpose: 'High-quality content generation for structured documents',
    privacyUrl: 'https://www.deepseek.com/privacy_policy',
  ),
];

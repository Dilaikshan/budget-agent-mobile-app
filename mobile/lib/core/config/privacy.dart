/// Provider privacy policy version the user consents to (docs/07 "Financial
/// privacy and provider gate"). Must equal the backend AI_PRIVACY_POLICY_VERSION;
/// the server refuses AI calls (PRIVACY_NOT_ELIGIBLE) when they differ.
const kPrivacyPolicyVersion = 'pp-2026-09';

/// Plain-language disclosure shown before enabling AI.
const kAiDisclosure =
    'When AI is on, the text you type in quick entry and minimal, sanitized details '
    '(account aliases like "A1", category names and merchant words) are sent to the '
    'Budget Agent server, which may forward them to Google Gemini and, if you allow '
    'fallback, to an approved OpenRouter provider. Account names, numbers, emails and '
    'links are removed first. AI only suggests; you confirm every change. You can turn '
    'AI, fallback, daily review and learning off at any time; manual entry always works.';

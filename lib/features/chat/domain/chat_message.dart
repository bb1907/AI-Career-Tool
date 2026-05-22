enum MessageRole { user, ai }

enum ChatFlow {
  none,
  resume,
  coverLetter,
  interview,
  cvUpload,
  jobMatch,
  videoIntro,
  // ── New flows ─────────────────────────────────────────────────────────────
  skillGap, // Skill Gap Analyzer
  mockInterview, // Mock Interview with AI feedback
  networking, // Networking Message Generator
  aiPhoto, // AI Photo Studio
  jobPlan, // Apply to Job — complete application plan
}

/// Semantic action codes for chip taps. When a chip has an action, the UI
/// dispatches to the matching handler instead of sending the chip text as a
/// regular message. This keeps chip behaviour language-independent.
class ChipAction {
  static const scratch = 'scratch'; // Resume Q1: start blank
  static const pdfPick = 'pdf_pick'; // Resume Q1: open file picker
  static const linkedInUrl = 'linkedin_url'; // Resume Q1: show URL dialog
  static const cvContinue =
      'cv_continue'; // After PDF/LinkedIn parse: advance flow
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime createdAt;

  // Optional: action chips shown below an AI message
  final List<String>? chips;

  // Optional: parallel list of action codes for each chip. Same length as
  // [chips] when present. A null entry means "send the chip text as a
  // normal message".
  final List<String?>? chipActions;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.chips,
    this.chipActions,
  });
}

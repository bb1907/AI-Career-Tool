/// Every AI operation that can be requested.
enum AiTaskType {
  /// Fast conversational replies, quick-reply chip suggestions
  chatResponse,

  /// ATS-optimised resume JSON generation
  resumeGeneration,

  /// Job-specific cover letter (250-350 words)
  coverLetter,

  /// Technical + behavioural interview Q&A
  interviewQuestions,

  /// 30 / 60 / 90-second video intro script
  videoScript,

  /// Suggest 3-5 relevant skill chips for a role
  skillSuggestions,

  /// Parse raw CV text → structured profile JSON
  cvParsing,

  /// Draft a LinkedIn / cold-email networking message
  networkingMessage,

  /// Skill-gap analysis against a job description
  skillGapAnalysis,

  /// Feedback on a mock-interview answer
  mockInterviewFeedback,

  /// Full job application plan: match score, skill gap, photo tip
  jobPlanAnalysis,
}

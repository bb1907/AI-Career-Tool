enum PremiumAccessFeature {
  resumeGenerate,
  coverLetterGenerate,
  interviewGenerate,
  cvParse,
  voiceResume;

  String get label => switch (this) {
    PremiumAccessFeature.resumeGenerate => 'Resume Builder',
    PremiumAccessFeature.coverLetterGenerate => 'Cover Letter Generator',
    PremiumAccessFeature.interviewGenerate => 'Interview Prep',
    PremiumAccessFeature.cvParse => 'CV Parser',
    PremiumAccessFeature.voiceResume => 'Voice Resume',
  };
}

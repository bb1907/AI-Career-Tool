enum AiTaskType {
  resumeGenerate,
  coverLetterGenerate,
  interviewGenerate,
  cvParse,
  jobMatch,
  videoIntroductionGenerate,
}

extension AiTaskTypeX on AiTaskType {
  String get value => switch (this) {
    AiTaskType.resumeGenerate => 'resume_generate',
    AiTaskType.coverLetterGenerate => 'cover_letter_generate',
    AiTaskType.interviewGenerate => 'interview_generate',
    AiTaskType.cvParse => 'cv_parse',
    AiTaskType.jobMatch => 'job_match',
    AiTaskType.videoIntroductionGenerate => 'video_introduction_generate',
  };

  static AiTaskType fromValue(String value) {
    return switch (value) {
      'resume_generate' => AiTaskType.resumeGenerate,
      'cover_letter_generate' => AiTaskType.coverLetterGenerate,
      'interview_generate' => AiTaskType.interviewGenerate,
      'cv_parse' => AiTaskType.cvParse,
      'job_match' => AiTaskType.jobMatch,
      'video_introduction_generate' => AiTaskType.videoIntroductionGenerate,
      _ => throw FormatException('Unsupported AI task type: $value'),
    };
  }
}
